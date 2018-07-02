package ALU;

  `ifdef RV64
    typedef 64 XLEN;
  `else
    typedef 32 XLEN;
  `endif

  import DReg::*;
  import UniqueWrappers::*;
  import Vector::*;
  interface Ifc_ALU;
    method Action ma_start(Bit#(7) opcode, Bit#(3) funct3, Bit#(12) imm, Bit#(XLEN) rs1, Bit#(XLEN) rs2); 
    method Bit#(XLEN) mn_done;
  endinterface

  (*noinline*)
  function Bit#(XLEN) notrotate(Tuple4#(Bit#(XLEN), Bit#(1), Bit#(1), Bit#(7)) inp);
    let {src, sl, sr, lnum}=inp;
    return (((~src & signExtend(sl)) << lnum) | ((~src & signExtend(sr)) >> (fromInteger(valueOf(XLEN)) - lnum)));
  endfunction

  (*noinline*)
  function Bit#(XLEN) gzip_stage(Bit#(XLEN) src, Bit#(64) sl, Bit#(64) sr, Bit#(6) num);
    return (truncate((zeroExtend(src) & (~(sl | sr))) | ((zeroExtend(src) << num) & sl) | ((zeroExtend(src) >> num) & sr)));
  endfunction

  (*synthesize*)
  module mkALU(Ifc_ALU);

    Integer size = valueOf(XLEN);

    Reg#(Bit#(XLEN)) rg_rd <- mkReg(0);
    Reg#(Bit#(XLEN)) rg_m <- mkReg(1);
    Reg#(Bit#(XLEN)) rg_x <- mkReg(0);
    Reg#(Bit#(XLEN)) rg_y <- mkReg(0);
    Reg#(Bit#(3)) rg_depext <- mkDReg(0);
    Reg#(Bit#(7)) rg_count <- mkReg(0);
    Reg#(Bit#(6)) rg_shamt <- mkReg(0);
    Wrapper#(Tuple4#(Bit#(XLEN), Bit#(1), Bit#(1), Bit#(7)),  Bit#(XLEN)) unotrotate <- mkUniqueWrapper(notrotate);

    rule rl_putbtdeposit(rg_depext == 1 || rg_depext == 2); //bit extract and deposit
      let lastsetbit = (rg_y & (-rg_y));
      if((rg_x & (rg_m)) > 0 && rg_depext == 2) rg_rd <= rg_rd | lastsetbit; //deposit
      else if((rg_x & lastsetbit) > 0 && rg_depext == 1) rg_rd <= rg_rd | rg_m; //extract
      rg_y <= rg_y - lastsetbit;
      rg_m <= rg_m << 1;
      if (rg_y != 0) rg_depext <= rg_depext;
    endrule

    rule rl_greverse(rg_depext == 3);
      Vector#(XLEN,bit) buffer_bfly_unzip = replicate(0);
      for(Integer i=0; i<size/2; i=i+1) begin
        buffer_bfly_unzip[i] = ((rg_m & rg_y) != 0) ? rg_x[(2*i)+1] : rg_x[2*i];
        buffer_bfly_unzip[(size/2)+i] = ((rg_m & rg_y) != 0) ? rg_x[2*i] : rg_x[(2*i)+1];
      end
      rg_x <= pack(buffer_bfly_unzip);
      //$display("\nrg_rd : %h, rg_m : %h, rg_x : %h\n",rg_rd, rg_m, rg_x);
      rg_m <= rg_m << 1;
      if(rg_m==fromInteger(size/2)) begin rg_depext <= 0; rg_rd <= pack(buffer_bfly_unzip); end
      else rg_depext <= rg_depext;
    endrule

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

    method Action ma_start(Bit#(7) opcode, Bit#(3) funct3, Bit#(12) imm, Bit#(XLEN) rs1, Bit#(XLEN)
    rs2)if(rg_depext==0); 
      Bit#(XLEN) a = 0, b = 0, c = 0, d = 0, e = 0;
      Bit#(12) funsel = {opcode,funct3,imm[11:10]};
      Bit#(TLog#(XLEN)) shamt = 0;

      case(funsel)
        'h66a, 'h66b, 'h66c, 'h66d, 'h66e, 'h66f, 'h278, 'h279, 'h27a, 'h27b : shamt = truncate(rs2);
        'h666, 'h667 : shamt = truncate('h40-rs2);
        'h26e  : shamt = truncate(imm);
        'h272, 'h26f: shamt = truncate('h40 - {1'b0,imm[5:0]}); 
        'h02e : rs2 = zeroExtend(6'h3f);
        'h274, 'h275, 'h276, 'h277 : rs2 = zeroExtend(imm[6:0]);
      endcase

      case(funsel)
        `ifdef RV64 'h360, 'h361, 'h362, 'h363, `endif 'h260, 'h261, 'h262, 'h263 : rg_rd <= zeroExtend(pack(countZerosMSB(rs1))); //clz clzw
        `ifdef RV64 'h364, 'h365, 'h366, 'h367, `endif 'h004, 'h005, 'h006, 'h007 : rg_rd <= zeroExtend(pack(countZerosLSB(rs1))); //ctz ctzw
        `ifdef RV64 'h368, 'h369, 'h36a, 'h36b, `endif 'h008, 'h009, 'h00a, 'h00b : rg_rd <= zeroExtend(pack(countOnes(rs1))); //pcnt pcntw 
        'h080, 'h081, 'h082, 'h083 : begin  //andwithc
//          let temp <- ureverse.func(tuple5(rs1, ~rs2, 'h0, 'h0, 'h0));
          rg_rd <= rs1&(~rs2);//temp; 
        end
        'h02c : rg_rd <= (~rs1) + 1; //cneg
        'h02d : rg_rd <= ~rs1; //cnot
        `ifdef RV64 'h760, 'h761, 'h762, 'h763, 'h370, 'h371, 'h372, 'h373 `endif 'h086, 'h012 : begin //sro sroi srow sroiw
          let temp <- unotrotate.func(tuple4(rs1, (1'h0), (1'h1),(shamt==0)?fromInteger(valueOf(XLEN)):zeroExtend(shamt)));
          rg_rd <= ~temp;
        end
        `ifdef RV64 'h764, 'h765, 'h766, 'h767, 'h36c, 'h36d, 'h36e, 'h36f, `endif 'h08a, 'h00e : begin //slo sloi slow sloiw
          let temp <- (unotrotate.func(tuple4(rs1, (1'h1), (1'h0), zeroExtend(shamt))));
          rg_rd <= ~temp;
        end
        `ifdef RV64 'h768, 'h769, 'h76a, 'h76b, 'h374, 'h375, 'h376, 'h377, 'h76c, 'h76d, 'h76e, 'h76f `endif 'h087, 'h00f, 'h08b : begin //ror rori rol rorw roriw rolw
          let temp <- unotrotate.func(tuple4(~rs1, (1'h1), (1'h1), zeroExtend(shamt)));
          rg_rd <= temp;
        end
 //       'h08c, 'h08d, 'h08e, 'h08f, 'h014, 'h015, 'h016, 'h017, 'h02e : begin //grev grevi
 //         if(rs2[0] == 1) a = reverse(tuple5(rs1, 64'h5555555555555555, 64'hAAAAAAAAAAAAAAAA, 1, 1));
 //         else a = rs1;
 //         if(rs2[1] == 1) b = reverse(tuple5(a, 64'h3333333333333333, 64'hCCCCCCCCCCCCCCCC, 2, 2));
 //         else b = a;
 //         if(rs2[2] == 1) c = reverse(tuple5(b, 64'h0F0F0F0F0F0F0F0F, 64'hF0F0F0F0F0F0F0F0, 4, 4));
 //         else c = b;
 //         if(rs2[3] == 1) d = reverse(tuple5(c, 64'h00FF00FF00FF00FF, 64'hFF00FF00FF00FF00, 8, 8));
 //         else d = c;
 //         if(rs2[4] == 1) e = reverse(tuple5(d, 64'h0000FFFF0000FFFF, 64'hFFFF0000FFFF0000, 16, 16));
 //         else e = d;
 //         if(rs2[5] == 1) f = reverse(tuple5(e, 64'h00000000FFFFFFFF, 64'hFFFFFFFF00000000, 32, 32));
 //         else f = e;
 //         rg_rd <= f;
 //       end
        'h278, 'h279, 'h27a, 'h27b : begin //gzip
        if(shamt[0] == 1) begin
            if(shamt[1] == 1) a = gzip_stage(rs1, 64'h4444444444444444, 64'h2222222222222222, 1);
            else a = rs1;
            if(shamt[2] == 1) b = gzip_stage(a, 64'h3030303030303030, 64'h0c0c0c0c0c0c0c0c, 2);
            else b = a;
            if(shamt[3] == 1) c = gzip_stage(b, 64'h0f000f000f000f00, 64'h00f000f000f000f0, 4);
            else c = b;
            if(shamt[4] == 1) d = gzip_stage(c, 64'h00ff000000ff0000, 64'h0000ff000000ff00, 8);
            else d = c;
            e = d;
            `ifdef RV64
            if(shamt[5] == 1) e = gzip_stage(d, 64'h0000ffff00000000, 64'h00000000ffff0000, 16);
            `endif
            rg_rd <= e;
          end  
          else begin
             a = rs1;
            `ifdef RV64
            if(shamt[5] == 1) a = gzip_stage(rs1, 64'h0000ffff00000000, 64'h00000000ffff0000, 16);
            `endif
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
        default : begin
          rg_x <= rs1; 
          rg_y <= rs2;
          rg_rd <= 0;
          rg_m <= 1;
        end
      endcase

      case (funsel)
        `ifdef RV64 'h770, 'h771, 'h772, 'h773, `endif 'h670, 'h671, 'h672, 'h673 : rg_depext <= 1;
        `ifdef RV64 'h774, 'h775, 'h776, 'h777, `endif 'h674, 'h675, 'h676, 'h677 : rg_depext <= 2;
        'h66c, 'h66d, 'h66e, 'h66f, 'h274, 'h275, 'h276, 'h277, 'h02e : rg_depext <= 3; 
      endcase

//      if((opcode == 1 && funct3 == 3) || (opcode == 0 && funct3 == 5)) begin //serial grev grevi
//        rg_count <= 1; 
//        rg_shamt <= (shamt);
//        rg_rd <= rs1;
//        rg_depext <= 3;
//      end
//      else if(opcode == 0 && funct3 == 6) begin //serial gzip
//        rg_shamt <= shamt;
//        rg_m <= (shamt[0] == 1) ? 'h1 : 'h200;
//        rg_rd <= rs1;
//        rg_depext <= 4;
//      end

    endmethod

    method Bit#(XLEN) mn_done if(rg_depext == 0);
      return rg_rd;
    endmethod

  endmodule

endpackage
