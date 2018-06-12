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
//opcode OP-IMM = 0 funct3 = 3 imm = 10: SLOI
//opcode OP-IMM = 0 funct3 = 4 imm = 10: SROI
//opcode OP-IMM = 0 funct3 = 3 imm = 11: RORI

//opcode OP = 4 funct3 = 0 : ANDC
//opcode OP = 4 funct3 = 1 imm = 10: SRO
//opcode OP = 4 funct3 = 2 imm = 10: SLO
//opcode OP = 4 funct3 = 1 imm = 11: ROR
//opcode OP = 4 funct3 = 2 imm = 11: ROL
//opcode OP = 4 funct3 = 2 : SLO
    
    method Action ma_start(Bit#(5) opcode, Bit#(3) funct3, Bit#(12) imm, Bit#(64) rs1, Bit#(64) rs2); 
      if(funct3 == 0) rg_rd <= zeroExtend(pack(countZerosMSB(rs1)));
      if(funct3 == 1) rg_rd <= zeroExtend(pack(countZerosLSB(rs1)));
      if(funct3 == 2) rg_rd <= zeroExtend(pack(countOnes(rs1)));
      if(funct3 == 3 && imm[11:10] == 2) rg_rd <= ~(~rs1 << (imm & 63));
      if(funct3 == 4 && imm[11:10] == 2) rg_rd <= ~(~rs1 >> (imm & 63));
      if(funct3 == 3 && imm[11:10] == 3) rg_rd <= ((rs1 >> (imm & 63)) | (rs1 << (64 - (imm & 63))));
      if(funct3 == 0) rg_rd <= (rs1 & ~rs2);
      if(funct3 == 1 && imm[11:10] == 2) rg_rd <= ~(~rs1 >> (rs2 & 63));
      if(funct3 == 2 && imm[11:10] == 2) rg_rd <= ~(~rs1 << (rs2 & 63));
      if(funct3 == 1 && imm[11:10] == 3) rg_rd <= ((rs1 >> (rs2 & 63)) | (rs1 << (64 - (rs2 & 63))));
      if(funct3 == 2 && imm[11:10] == 3) rg_rd <= ((rs1 << (rs2 & 63)) | (rs1 >> (64 - (rs2 & 63))));
      rg_work <= True;
    endmethod

    method Bit#(64) mn_done if(rg_work);
      return rg_rd;
    endmethod


  endmodule

endpackage
