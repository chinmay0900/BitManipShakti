package ALU;

  import DReg::*;
  interface Ifc_ALU;
    method Action ma_start(Bit#(5) opcode, Bit#(3) funct3, Bit#(12) imm, Bit#(64) rs1, Bit#(64) rs2); 
    method Bit#(64) mn_done;
  endinterface

  module mkALU(Ifc_ALU);

    Reg#(Bit#(64)) rg_rd <- mkRegU;
    Reg#(Bool) rg_work <- mkDReg(False);
//opcode OP-IMM = 0 funct3 = 0 : CLZ
//opcode OP-IMM = 0 funct3 = 1 : CTZ
//opcode OP-IMM = 0 funct3 = 2 : PCNT
//opcode OP-IMM = 0 funct3 = 3 imm = 8**: SLOI
//opcode OP-IMM = 0 funct3 = 4 imm = 8**: SROI
//opcode OP-IMM = 0 funct3 = 3 imm = c**: RORI
//opcode OP-IMM = 0 funct3 = 5 : GREVI

//opcode OP = 1 funct3 = 0 : ANDC
//opcode OP = 1 funct3 = 1 imm = 8**: SRO
//opcode OP = 1 funct3 = 2 imm = 8**: SLO
//opcode OP = 1 funct3 = 1 imm = c**: ROR
//opcode OP = 1 funct3 = 2 imm = c**: ROL
//opcode OP = 1 funct3 = 3 : GREV
    
    method Action ma_start(Bit#(5) opcode, Bit#(3) funct3, Bit#(12) imm, Bit#(64) rs1, Bit#(64) rs2); 
      Bit#(64) a = 0, b = 0, c = 0, d = 0, e = 0, f = 0;

      if(opcode == 0 && funct3 == 0) rg_rd <= zeroExtend(pack(countZerosMSB(rs1)));
      if(opcode == 0 && funct3 == 1) rg_rd <= zeroExtend(pack(countZerosLSB(rs1)));
      if(opcode == 0 && funct3 == 2) rg_rd <= zeroExtend(pack(countOnes(rs1)));
      if(opcode == 0 && funct3 == 3 && imm[11:10] == 2) rg_rd <= ~(~rs1 << (imm & 63));
      if(opcode == 0 && funct3 == 4 && imm[11:10] == 2) rg_rd <= ~(~rs1 >> (imm & 63));
      if(opcode == 0 && funct3 == 3 && imm[11:10] == 3) rg_rd <= ((rs1 >> (imm & 63)) | (rs1 << (64 - (imm & 63))));
      if(opcode == 0 && funct3 == 5) begin
        if(imm[0] == 1) a = ((rs1&64'h5555555555555555)<<1)|((rs1&64'hAAAAAAAAAAAAAAAA)>>1);
        else a = rs1;
        if(imm[1] == 1) b = ((a&64'h3333333333333333)<<2)|((a&64'hCCCCCCCCCCCCCCCC)>>2);
        else b = a;
        if(imm[2] == 1) c = ((b&64'h0F0F0F0F0F0F0F0F)<<4)|((b&64'hF0F0F0F0F0F0F0F0)>>4);
        else c = b;
        if(imm[3] == 1) d = ((c&64'h00FF00FF00FF00FF)<<8)|((c&64'hFF00FF00FF00FF00)>>8);
        else d = c;
        if(imm[4] == 1) e = ((d&64'h0000FFFF0000FFFF)<<16)|((d&64'hFFFF0000FFFF0000)>>16);
        else e = d;
        if(imm[5] == 1) f = ((e&64'h00000000FFFFFFFF)<<32)|((e&64'hFFFFFFFF00000000)>>32);
        else f = e;
        rg_rd <= f;
      end
if(opcode == 1 && funct3 == 0) rg_rd <= (rs1 & ~rs2);
      if(opcode == 1 && funct3 == 1 && imm[11:10] == 2) rg_rd <= ~(~rs1 >> (rs2 & 63));
      if(opcode == 1 && funct3 == 2 && imm[11:10] == 2) rg_rd <= ~(~rs1 << (rs2 & 63));
      if(opcode == 1 && funct3 == 1 && imm[11:10] == 3) rg_rd <= ((rs1 >> (rs2 & 63)) | (rs1 << (64 - (rs2 & 63))));
      if(opcode == 1 && funct3 == 2 && imm[11:10] == 3) rg_rd <= ((rs1 << (rs2 & 63)) | (rs1 >> (64 - (rs2 & 63))));
      if(opcode == 1 && funct3 == 3) begin
        if(rs2[0] == 1) a = ((rs1&64'h5555555555555555)<<1)|((rs1&64'hAAAAAAAAAAAAAAAA)>>1);
        else a = rs1;
        if(rs2[1] == 1) b = ((a&64'h3333333333333333)<<2)|((a&64'hCCCCCCCCCCCCCCCC)>>2);
        else b = a;
        if(rs2[2] == 1) c = ((b&64'h0F0F0F0F0F0F0F0F)<<4)|((b&64'hF0F0F0F0F0F0F0F0)>>4);
        else c = b;
        if(rs2[3] == 1) d = ((c&64'h00FF00FF00FF00FF)<<8)|((c&64'hFF00FF00FF00FF00)>>8);
        else d = c;
        if(rs2[4] == 1) e = ((d&64'h0000FFFF0000FFFF)<<16)|((d&64'hFFFF0000FFFF0000)>>16);
        else e = d;
        if(rs2[5] == 1) f = ((e&64'h00000000FFFFFFFF)<<32)|((e&64'hFFFFFFFF00000000)>>32);
        else f = e;
        rg_rd <= f;
      end
      rg_work <= True;
    endmethod

    method Bit#(64) mn_done if(rg_work);
      return rg_rd;
    endmethod


  endmodule

endpackage
