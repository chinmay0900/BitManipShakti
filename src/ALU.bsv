package ALU;

  import DReg::*;
  interface Ifc_ALU;
    method Action ma_start(Bit#(5) opcode, Bit#(3) funct3, Bit#(12) imm, Bit#(64) rs1, Bit#(64) rs2); 
    method Bit#(64) mn_done;
  endinterface

  (*noinline*)
   function Bit#(64) reverse(Bit#(64) src, Bit#(64) sl, Bit#(64) sr, Bit#(64) num);
     return (((src & sl) << num) | ((src & sr) >> num));
   endfunction

  (*noinline*)
   function Bit#(64) gzip_stage(Bit#(64) src, Bit#(64) sl, Bit#(64) sr, Bit#(64) num);
     return ((src & (~(sl | sr))) | ((src << num) & sl) | ((src >> num) & sr));
   endfunction

  (*synthesize*)
  module mkALU(Ifc_ALU);

    Reg#(Bit#(64)) rg_rd <- mkReg(0);
    Reg#(Bool) rg_work <- mkDReg(False);
    Reg#(Bit#(64)) rg_m <- mkReg(1);
    Reg#(Bit#(64)) rg_x <- mkReg(0);
    Reg#(Bit#(64)) rg_y <- mkReg(0);
    Reg#(Bit#(2)) rg_depext <- mkReg(0);

//opcode OP-IMM = 0 funct3 = 0 : CLZ
//opcode OP-IMM = 0 funct3 = 1 : CTZ
//opcode OP-IMM = 0 funct3 = 2 : PCNT
//opcode OP-IMM = 0 funct3 = 3 imm = 8**: SLOI
//opcode OP-IMM = 0 funct3 = 4 imm = 8**: SROI
//opcode OP-IMM = 0 funct3 = 3 imm = c**: RORI
//opcode OP-IMM = 0 funct3 = 5 : GREVI
//opcode OP-IMM = 0 funct3 = 6 : GZIP

//opcode OP = 1 funct3 = 0 : ANDC
//opcode OP = 1 funct3 = 1 imm = 8**: SRO
//opcode OP = 1 funct3 = 2 imm = 8**: SLO
//opcode OP = 1 funct3 = 1 imm = c**: ROR
//opcode OP = 1 funct3 = 2 imm = c**: ROL
//opcode OP = 1 funct3 = 3 : GREV
//opcode OP = 1 funct3 = 4 : BEXT
//opcode OP = 1 funct3 = 5 : BDEP

    rule rl_putbtdeposit(rg_depext != 0);
      if((rg_x & (rg_m)) > 0 && rg_depext == 2) rg_rd <= rg_rd | (rg_y & -rg_y); //deposit
      else if((rg_x & (rg_y & -rg_y)) > 0 && rg_depext == 1) rg_rd <= rg_rd | rg_m; //extract
      rg_y <= rg_y - (rg_y & -rg_y);
      rg_m <= rg_m << 1;
      if (rg_y == 0) begin
        rg_work <= True;
        rg_depext<= 0;
      end
    endrule

    method Action ma_start(Bit#(5) opcode, Bit#(3) funct3, Bit#(12) imm, Bit#(64) rs1, Bit#(64)
    rs2)if(rg_depext==0); 
      Bit#(64) a = 0, b = 0, c = 0, d = 0, e = 0, f = 0;
      Bit#(12) funsel = {opcode,funct3,'b00,imm[11:10]};
      Bit#(6) shamt = 0;

      //if(opcode == 0 && (funct3 == 0 || funct3 == 1)) begin //clz ctz
      // if(funct3 == 0) f = reverseBits(rs1);
      //  else f = rs1;
      //  rg_rd <= zeroExtend(pack(countZerosLSB(f)));
      //end

      case(funsel)
        'h112,'h122, 'h113, 'h123 : shamt = truncate(rs2);
        'h042, 'h032, 'h033 : shamt = truncate(imm);
      endcase

      case(funsel)
        'h00_ : rg_rd <= zeroExtend(pack(countZerosMSB(rs1)));
        'h01_ : rg_rd <= zeroExtend(pack(countZerosLSB(rs1)));
        'h02_ : rg_rd <= zeroExtend(pack(countOnes(rs1))); 
        'h10_ : rg_rd <= (rs1 & ~rs2);
        'h112 : rg_rd <= ~(~rs1 >> shamt); //sro
        'h042 : rg_rd <= ~(~rs1 >> shamt); //sroi
        'h122 : rg_rd <= ~(~rs1 << shamt); //slo
        'h032 : rg_rd <= ~(~rs1 << shamt); //sloi
        'h113 : rg_rd <= ((rs1 >> shamt) | (rs1 << (64 - {1'b0,shamt}))); //ror
        'h033 : rg_rd <= ((rs1 >> shamt) | (rs1 << (64 - {1'b0,shamt}))); //rori
        'h123 : rg_rd <= ((rs1 << shamt) | (rs1 >> (64 - {1'b0,shamt}))); //rol
      endcase

      //if(opcode == 0 && funct3 == 0) rg_rd <= zeroExtend(pack(countZerosMSB(rs1)));
      //if(opcode == 0 && funct3 == 1) rg_rd <= zeroExtend(pack(countZerosLSB(rs1)));
      //if(opcode == 0 && funct3 == 2) rg_rd <= zeroExtend(pack(countOnes(rs1))); //pcnt
      //if(opcode == 1 && funct3 == 0) rg_rd <= (rs1 & ~rs2); //andc
      //if((opcode == 1 && funct3 == 1 && imm[11:10] == 2) || (opcode == 0 && funct3 == 4 && imm[11:10] == 2)) begin //sro sroi
      //  if (opcode == 0 && funct3 == 4 && imm[11:10] == 2) rs2 = zeroExtend(imm);
      //  rg_rd <= ~(~rs1 >> (rs2 & 63)); //sro
      //end
      //if((opcode == 1 && funct3 == 2 && imm[11:10] == 2) || (opcode == 0 && funct3 == 3 && imm[11:10] == 2)) begin //slo sloi
      //  if (opcode == 0 && funct3 == 3 && imm[11:10] == 2) rs2 = zeroExtend(imm);
      //  rg_rd <= ~(~rs1 << (rs2 & 63)); //slo
      //end
      //if((opcode == 1 && funct3 == 1 && imm[11:10] == 3) || (opcode == 0 && funct3 == 3 && imm[11:10] == 3)) begin //ror rori
      //  if (opcode == 0 && funct3 == 3 && imm[11:10] == 3) rs2 = zeroExtend(imm);
      //  rg_rd <= ((rs1 >> (rs2 & 63)) | (rs1 << (64 - (rs2 & 63)))); 
      //end
      //if(opcode == 1 && funct3 == 2 && imm[11:10] == 3) rg_rd <= ((rs1 << (rs2 & 63)) | (rs1 >> (64 - (rs2 & 63)))); //rol
      if((opcode == 1 && funct3 == 3)||(opcode == 0 && (funct3 == 5 /*|| funct3 == 0*/))) begin //grev and grevi
        //if(opcode == 0 && funct3 == 0) rs2 = 'h00000000000000ff;
        if(opcode == 0 && funct3 == 5) rs2 = zeroExtend(imm);
        if(rs2[0] == 1) a = reverse(rs1, 64'h5555555555555555, 64'hAAAAAAAAAAAAAAAA, 1);
        else a = rs1;
        if(rs2[1] == 1) b = reverse(a, 64'h3333333333333333, 64'hCCCCCCCCCCCCCCCC, 2);
        else b = a;
        if(rs2[2] == 1) c = reverse(b, 64'h0F0F0F0F0F0F0F0F, 64'hF0F0F0F0F0F0F0F0, 4);
        else c = b;
        if(rs2[3] == 1) d = reverse(c, 64'h00FF00FF00FF00FF, 64'hFF00FF00FF00FF00, 8);
        else d = c;
        if(rs2[4] == 1) e = reverse(d, 64'h0000FFFF0000FFFF, 64'hFFFF0000FFFF0000, 16);
        else e = d;
        if(rs2[5] == 1) f = reverse(e, 64'h00000000FFFFFFFF, 64'hFFFFFFFF00000000, 32);
        else f = e;
        //if(funct3 != 0)
        rg_rd <= f;
      end
      //if(opcode == 0 && (funct3 == 1 || funct3 == 0)) begin
      //  if(funct3 == 1) f = rs1;
      //  rg_rd <= zeroExtend(pack(countZerosLSB(f)));
      //end
      if(opcode == 0 && funct3 == 6) begin //gzip
        if(rs2[0] == 1) begin
          if(rs2[1] == 1) a = gzip_stage(rs1, 64'h4444444444444444, 64'h2222222222222222, 1);
          else a = rs1;
          if(rs2[2] == 1) b = gzip_stage(a, 64'h3030303030303030, 64'h0c0c0c0c0c0c0c0c, 2);
          else b = a;
          if(rs2[3] == 1) c = gzip_stage(b, 64'h0f000f000f000f00, 64'h00f000f000f000f0, 4);
          else c = b;
          if(rs2[4] == 1) d = gzip_stage(c, 64'h00ff000000ff0000, 64'h0000ff000000ff00, 8);
          else d = c;
          if(rs2[5] == 1) e = gzip_stage(d, 64'h0000ffff00000000, 64'h00000000ffff0000, 16);
          else e = d;
        rg_rd <= e;
        end  
          else begin
          if(rs2[5] == 1) a = gzip_stage(rs1, 64'h0000ffff00000000, 64'h00000000ffff0000, 16);
          else a = rs1;
          if(rs2[4] == 1) b = gzip_stage(a, 64'h00ff000000ff0000, 64'h0000ff000000ff00, 8);
          else b = a;
          if(rs2[3] == 1) c = gzip_stage(b, 64'h0f000f000f000f00, 64'h00f000f000f000f0, 4);
          else c = b;
          if(rs2[2] == 1) d = gzip_stage(c, 64'h3030303030303030, 64'h0c0c0c0c0c0c0c0c, 2);
          else d = c;
          if(rs2[1] == 1) e = gzip_stage(d, 64'h4444444444444444, 64'h2222222222222222, 1);
          else e = d;
        rg_rd <= e;
        end
      end
      if(opcode == 1 && funct3 == 4) begin //bit extract
        rg_x <= rs1; 
        rg_y <= rs2;
        rg_rd <= 0;
        rg_m <= 1;
        rg_depext <= 1;
      end
      else if(opcode == 1 && funct3 == 5) begin //bit deposit
        rg_x <= rs1; 
        rg_y <= rs2;
        rg_rd <= 0;
        rg_m <= 1;
        rg_depext <= 2;
      end
      else rg_work <= True;
    endmethod

    method Bit#(64) mn_done if(rg_work);
      return rg_rd;
    endmethod

  endmodule

endpackage
