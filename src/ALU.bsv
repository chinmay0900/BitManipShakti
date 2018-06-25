package ALU;

  import DReg::*;
  import UniqueWrappers::*;
  interface Ifc_ALU;
    method Action ma_start(Bit#(5) opcode, Bit#(3) funct3, Bit#(12) imm, Bit#(64) rs1, Bit#(64) rs2); 
    method Bit#(64) mn_done;
  endinterface

  (*noinline*)
  function Bit#(64) reverse(Tuple5#(Bit#(64), Bit#(64), Bit#(64), Bit#(7), Bit#(7)) inp);
    let {src, sl, sr, lnum, rnum}=inp;
    return (((src & sl) << lnum) | ((src & sr) >> rnum));
  endfunction

  (*noinline*)
  function Bit#(64) gzip_stage(Bit#(64) src, Bit#(64) sl, Bit#(64) sr, Bit#(6) num);
    return ((src & (~(sl | sr))) | ((src << num) & sl) | ((src >> num) & sr));
  endfunction

  (*synthesize*)
  module mkALU(Ifc_ALU);

    Reg#(Bit#(64)) rg_rd <- mkReg(0);
    Reg#(Bool) rg_work <- mkDReg(False);
    Reg#(Bit#(64)) rg_m <- mkReg(1);
    Reg#(Bit#(64)) rg_x <- mkReg(0);
    Reg#(Bit#(64)) rg_y <- mkReg(0);
    Reg#(Bit#(3)) rg_depext <- mkReg(0);
    Reg#(Bit#(7)) rg_count <- mkReg(0);
    Reg#(Bit#(6)) rg_shamt <- mkReg(0);
    Wrapper#(Tuple5#(Bit#(64), Bit#(64), Bit#(64), Bit#(7), Bit#(7)),  Bit#(64)) ureverse <- mkUniqueWrapper(reverse);

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

    rule rl_putbtdeposit(rg_depext == 1 || rg_depext == 2);
      if((rg_x & (rg_m)) > 0 && rg_depext == 2) rg_rd <= rg_rd | (rg_y & -rg_y); //deposit
      else if((rg_x & (rg_y & -rg_y)) > 0 && rg_depext == 1) rg_rd <= rg_rd | rg_m; //extract
      rg_y <= rg_y - (rg_y & -rg_y);
      rg_m <= rg_m << 1;
      if (rg_y == 0) begin
        rg_work <= True;
        rg_depext<= 0;
      end
    endrule

//    rule rl_greverse(rg_depext == 3);
//      Bit#(64) y = 0;
//      Int#(4) count = 0;
//      case(rg_count)
//      'h1 : y = 64'h5555555555555555;
//      'h2 : begin y = 64'h3333333333333333; count = 1; end
//      'h4 : begin y = 64'h0F0F0F0F0F0F0F0F; count = 2; end
//      'h8 : begin y = 64'h00FF00FF00FF00FF; count = 3; end
//      'h10 : begin y = 64'h0000FFFF0000FFFF; count = 4; end
//      'h20 : begin y = 64'h00000000FFFFFFFF; count = 5; end
//      endcase
//      if(rg_shamt[count] == 1) begin
//        let temp <- ureverse.func(tuple5(rg_rd, y, ~y, rg_count, rg_count));//grev
//        rg_rd <= temp;
//      end
//      rg_count <= rg_count << 1;
//      //$display("\nrg_rd : %h, rg_count : %h, count : %h\n",rg_rd, rg_count, count);
//      if(rg_count == 'h20) begin
//        rg_work <= True;
//        rg_depext <= 0;
//      end
//      endrule
//
//    rule rl_gzip(rg_depext == 4);//gzip
//      Bit#(64) x=0;
//      Int#(4) count = 0;
//      case(rg_m)
//      'h1, 'h20 : begin x = 64'h4444444444444444; count = 1; end
//      'h2, 'h40 : begin x = 64'h3030303030303030;  count = 2; end
//      'h4, 'h80 : begin x = 64'h0f000f000f000f00;  count = 3; end
//      'h8, 'h100 : begin x = 64'h00ff000000ff0000;  count = 4; end
//      'h10, 'h200 : begin x = 64'h0000ffff00000000;  count = 5; end
//      endcase
//      if(rg_shamt[0] == 1) begin
//        if(rg_shamt[count]==1) rg_rd <= gzip_stage(rg_rd, x, x >> rg_m, truncate(rg_m));
//       //$display("rg_rd : %h rg_x : %h rg_x >> rg_m : %h rg_m : %d \n", rg_rd, x, x >> rg_m, rg_m);
//        rg_m <= rg_m << 1;
//      end
//      else if(rg_shamt[0] == 0) begin
//        if(rg_shamt[count]==1) rg_rd <= gzip_stage(rg_rd, x, x >> (rg_m >> 5), truncate(rg_m >> 5));
//        //$display("rg_rd : %h rg_x : %h rg_x >> rg_m>>5 : %h rg_m>>5 : %d \n",rg_rd,x,x>>(rg_m>>5),(rg_m>>5));
//        rg_m <= rg_m >> 1;
//      end
//        //$display("value of var %d is \n", rg_var);
//        //$display("value of rg_p %h is \n", rg_p);         
//      if(rg_m=='h20 || rg_m=='h10) begin
//        rg_work <= True;
//        rg_depext <= 0;
//      end
//    endrule

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
        'h092,'h0a2, 'h093, 'h0b0, 'h0b1, 'h0b2, 'h0b3, 'h060, 'h061, 'h062, 'h063 : shamt = truncate(rs2);
        'h0a3 : shamt = truncate('h40 - rs2);
        'h042, 'h032, 'h033, 'h050, 'h051, 'h052, 'h053: shamt = truncate(imm);
      endcase

     //$display("\nfunsel : %h or %b\nshamt : %h",funsel, funsel, shamt);

      case(funsel) matches
        'h00?_ : rg_rd <= zeroExtend(pack(countZerosMSB(rs1)));
        'h01?_ : rg_rd <= zeroExtend(pack(countZerosLSB(rs1)));
        'h02?_ : rg_rd <= zeroExtend(pack(countOnes(rs1))); 
        'h08?_ : begin 
          let temp <- ureverse.func(tuple5(rs1, ~rs2, 'h0, 'h0, 'h0));//(rs1 & ~rs2); //andwithc
          rg_rd <= temp;
        end
      endcase

      case(funsel)
        'h092, 'h042 : begin
          let temp <- ureverse.func(tuple5(~rs1, 'h0, 'hffffffffffffffff, 'h0, {1'b0,shamt}));//~(~rs1 >> shamt); //sro sroi
          rg_rd <= ~temp;
        end
        'h0a2, 'h032 : begin 
          let temp <- (ureverse.func(tuple5(~rs1, 'hffffffffffffffff, 'h0, {1'b0,shamt}, 'h0)));//~(~rs1 << shamt); //slo sloi
          rg_rd <= ~temp;
        end
        'h093, 'h033, 'h0a3 : begin
          let temp <- ureverse.func(tuple5(rs1, 'hffffffffffffffff, 'hffffffffffffffff, (64 - {1'b0,shamt}), {1'b0,shamt})); //((rs1 >> shamt) | (rs1 << (64 - {1'b0,shamt}))); //ror rori rol
          rg_rd <= temp;
        end
        'h050, 'h051, 'h052, 'h053, 'h0b0, 'h0b1, 'h0b2, 'h0b3 : begin
          if(shamt[0] == 1) a = reverse(tuple5(rs1, 64'h5555555555555555, 64'hAAAAAAAAAAAAAAAA, 1, 1));
          else a = rs1;
          if(shamt[1] == 1) b = reverse(tuple5(a, 64'h3333333333333333, 64'hCCCCCCCCCCCCCCCC, 2, 2));
          else b = a;
          if(shamt[2] == 1) c = reverse(tuple5(b, 64'h0F0F0F0F0F0F0F0F, 64'hF0F0F0F0F0F0F0F0, 4, 4));
          else c = b;
          if(shamt[3] == 1) d = reverse(tuple5(c, 64'h00FF00FF00FF00FF, 64'hFF00FF00FF00FF00, 8, 8));
          else d = c;
          if(shamt[4] == 1) e = reverse(tuple5(d, 64'h0000FFFF0000FFFF, 64'hFFFF0000FFFF0000, 16, 16));
          else e = d;
          if(shamt[5] == 1) f = reverse(tuple5(e, 64'h00000000FFFFFFFF, 64'hFFFFFFFF00000000, 32, 32));
          else f = e;
        rg_rd <= f;

        end
        'h060, 'h061, 'h062, 'h063 : begin
        if(shamt[0] == 1) begin
          if(shamt[1] == 1) a = gzip_stage(rs1, 64'h4444444444444444, 64'h2222222222222222, 1);
          else a = rs1;
          if(shamt[2] == 1) b = gzip_stage(a, 64'h3030303030303030, 64'h0c0c0c0c0c0c0c0c, 2);
          else b = a;
          if(shamt[3] == 1) c = gzip_stage(b, 64'h0f000f000f000f00, 64'h00f000f000f000f0, 4);
          else c = b;
          if(shamt[4] == 1) d = gzip_stage(c, 64'h00ff000000ff0000, 64'h0000ff000000ff00, 8);
          else d = c;
          if(shamt[5] == 1) e = gzip_stage(d, 64'h0000ffff00000000, 64'h00000000ffff0000, 16);
          else e = d;
        rg_rd <= e;
        end  
          else begin
          if(shamt[5] == 1) a = gzip_stage(rs1, 64'h0000ffff00000000, 64'h00000000ffff0000, 16);
          else a = rs1;
          if(shamt[4] == 1) b = gzip_stage(a, 64'h00ff000000ff0000, 64'h0000ff000000ff00, 8);
          else b = a;
          if(shamt[3] == 1) c = gzip_stage(b, 64'h0f000f000f000f00, 64'h00f000f000f000f0, 4);
          else c = b;
          if(shamt[2] == 1) d = gzip_stage(c, 64'h3030303030303030, 64'h0c0c0c0c0c0c0c0c, 2);
          else d = c;
          if(shamt[1] == 1) e = gzip_stage(d, 64'h4444444444444444, 64'h2222222222222222, 1);
          else e = d;
        rg_rd <= e;
          end
        end
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
      //if((opcode == 1 && funct3 == 3)||(opcode == 0 && (funct3 == 5 /*|| funct3 == 0*/))) begin //grev and grevi
        //if(opcode == 0 && funct3 == 0) rs2 = 'h00000000000000ff;
      //end
      //if(opcode == 0 && (funct3 == 1 || funct3 == 0)) begin
      //  if(funct3 == 1) f = rs1;
      //  rg_rd <= zeroExtend(pack(countZerosLSB(f)));
      //end
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
//      else if((opcode == 1 && funct3 == 3) || (opcode == 0 && funct3 == 5)) begin //grev
//        rg_count <= 1; 
//        rg_shamt <= (shamt);
//        rg_rd <= rs1;
//        rg_depext <= 3;
//      end
//      else if(opcode == 0 && funct3 == 6) begin 
//        rg_shamt <= shamt;
//        rg_m <= (shamt[0] == 1) ? 'h1 : 'h200;
//        rg_rd <= rs1;
//        rg_depext <= 4;
//      end
      else rg_work <= True;
    endmethod

    method Bit#(64) mn_done if(rg_work);
      return rg_rd;
    endmethod

  endmodule

endpackage
