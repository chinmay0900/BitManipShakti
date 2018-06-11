package ALU

  interface Ifc_ALU;
    method Action ma_start(Bit#(64) instruction, Bit#(64) rs1, Bit#(64) rs2);
    method Bit#(64) mn_done;
  endinterface

  module mkALU(Ifc_ALU);

    Reg#(Bit#(64)) rg_rs1 <- mkRegU;
    Reg#(Bit#(64)) rg_rs2 <- mkRegU;
    Reg#(Bit#(64)) rg_rd <- mkRegU;
    Reg#(Bit#(7)) rg_tempresult <- mkRegU;
    Reg#(Bit#(7)) rg_opcode <- mkRegU;
    Reg#(Bit#(3)) rg_funct3 <- mkRegU;
    Reg#(Bit#(12)) rg_imm <- mkRegU;

//opcode OP-IMM = 0 funct3 = 0 : CLZ
//opcode OP-IMM = 0 funct3 = 1 : CTZ
//opcode OP-IMM = 0 funct3 = 2 : PCNT
//opcode OP-IMM = 0 funct3 = 3 imm = 10: SLOI
//opcode OP-IMM = 0 funct3 = 4 imm = 10: SROI

//opcode OP = 4 funct3 = 0 : ANDC
//opcode OP = 4 funct3 = 1 imm = 10: SRO
//opcode OP = 4 funct3 = 2 imm = 10: SLO
//opcode OP = 4 funct3 = 1 imm = 11: ROR
//opcode OP = 4 funct3 = 2 imm = 11: ROL
//opcode OP = 4 funct3 = 2 : SLO

    rule rl_start(rg_work == 1);
      if(rg_opcode == 0) begin
        if(rg_funct3 == 0) rg_tempresult <= pack(countZerosMSB(rg_rs1));
        if(rg_funct3 == 1) rg_tempresult <= pack(countZerosLSB(rg_rs1));
        if(rg_funct3 == 2) rg_tempresult <= pack(countOnes(rg_rs1));
        if(rg_funct3 == 3 && rg_imm[11:10] == 2) rg_rd <= ~(~rg_rs1 << (rg_imm & 63));
        if(rg_funct3 == 4 && rg_imm[11:10] == 2) rg_rd <= ~(~rg_rs1 >> (rg_imm & 63));
      end
      else if(rg_opcode == 4) begin 
        if(rg_funct3 == 0) rg_rd <= (rg_rs1 & ~rg_rs2);
        if(rg_funct3 == 1 && rg_imm[11:10] == 2) rg_rd <= ~(~rg_rs1 >> (rg_rs2 & 63));
        if(rg_funct3 == 2 && rg_imm[11:10] == 2) rg_rd <= ~(~rg_rs1 << (rg_rs2 & 63));
      end

    endrule
    
    method Action ma_start(Bit#(64) instruction, Bit#(64) rs1, Bit#(64) rs2) if(rg_work == 0); 
      rg_work <= 1;
      rg_rs1 <= rs1;
      rg_rs2 <= rs2;
      rg_opcode <= instruction[6:0];
      rg_funct3 <= instruction[14:12];
      rg_imm <= instruction[31:20];
    endmethod

    method Bit#(64) mn_done if(rg_work==2);
      return rg_rd;
    endmethod


  endmodule

endpackage
