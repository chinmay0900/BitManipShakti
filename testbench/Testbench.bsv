import ALU ::*;
//import ALU_copy::*;
import LFSR::*;
import "BDPI" function Bit#(64) checker (Bit#(7) rg_opcode, Bit#(3) rg_funct3, Bit#(12) rg_imm, Bit#(64) rs1, Bit#(64) rs2);

(*synthesize*)
module mkTestbench();
  
  Ifc_ALU alu <- mkALU;
  LFSR #(Bit #(32)) lfsr_rs11 <- mkLFSR_32;
  LFSR #(Bit #(32)) lfsr_rs12 <- mkLFSR_32;
  LFSR #(Bit #(32)) lfsr_rs21 <- mkLFSR_32;
  LFSR #(Bit #(32)) lfsr_rs22 <- mkLFSR_32;

//opcode OP-IMM = 0 funct3 = 0 : CLZ             'h000/1/2/3
//opcode OP-IMM = 0 funct3 = 1 : CTZ             'h004/5/6/7
//opcode OP-IMM = 0 funct3 = 2 : PCNT            'h008/9/a/b
//opcode OP-IMM = 0 funct3 = 3 imm = 8**: SLOI   'h00e
//opcode OP-IMM = 0 funct3 = 4 imm = 8**: SROI   'h012
//opcode OP-IMM = 0 funct3 = 3 imm = c**: RORI   'h00f
//opcode OP-IMM = 0 funct3 = 5 : GREVI           'h014/5/6/7
//opcode OP-IMM = 0 funct3 = 6 : GZIP            'h018/9/a/b

//opcode OP = 4 funct3 = 0 : ANDC                'h080/1/2/3
//opcode OP = 4 funct3 = 1 imm = 8**: SRO        'h086
//opcode OP = 4 funct3 = 2 imm = 8**: SLO        'h08a
//opcode OP = 4 funct3 = 1 imm = c**: ROR        'h087
//opcode OP = 4 funct3 = 2 imm = c**: ROL        'h08b
//opcode OP = 4 funct3 = 3 : GREV                'h08c/d/e/f
//opcode OP = 4 funct3 = 4 : BEXT                'h090/1/2/3
//opcode OP = 4 funct3 = 5 : BDEP                'h094/5/6/7

  Bit#(7) rg_opcode = 'h00;
  Bit#(3) rg_funct3 = 'h1;
  Bit#(12) rg_imm = 'h804;
  Reg#(Bit#(32)) rg_count <- mkReg(0);
  Reg#(Bool) rg_state <- mkReg(True);
  Reg#(Bit#(64)) rg_checker <- mkReg(0);

  rule rl_init(rg_count == 0);
      lfsr_rs11.seed('h241c43);
      lfsr_rs12.seed('h651387);
      lfsr_rs21.seed('h4c9208);
      lfsr_rs22.seed('h523b5a);
      rg_count <= 1;
  endrule

  rule rl_start(rg_count != 0);
    Bit#(64) rs1;
    Bit#(64) rs2;
    rs1 = {lfsr_rs11.value,lfsr_rs12.value};
    rs2 = {lfsr_rs21.value,lfsr_rs22.value};
    //$display($time, "\tInputs: rs1: %h rs2: %h \n\t\t\topcode: %h funct3: %h imm:%h\n", rs1, rs2, rg_opcode, rg_funct3, rg_imm);
    alu.ma_start(rg_opcode, rg_funct3, rg_imm, rs1, rs2);
    rg_checker <= checker(rg_opcode, rg_funct3, rg_imm, rs1, rs2);
    lfsr_rs11.next();
    lfsr_rs12.next();
    lfsr_rs21.next();
    lfsr_rs22.next();
    //rg_state <= False;
    rg_count <= rg_count + 1; 
  endrule

  rule rl_store(rg_count > 1);
    let rd = alu.mn_done;
    //if(rg_checker == rd) $display($time,"\tOutput:Program-%h or Checker-%h\n Passed", rd, rg_checker);
    if(rg_checker != rd) $display($time,"\tOutput:Program-%h or Checker-%h\n Failed", rd, rg_checker);
    //rg_state <= True;
    if(rg_count == 100000001) $finish;
  endrule
/*
  rule rl_start(rg_state);
    Bit#(64) rs1 = 'h5f2ca38415d78b29;
    Bit#(64) rs2 = 'h38;
    $display($time, "\tInputs: rs1: %h rs2: %h \n\t\t\topcode: %h funct3: %h imm:%h\n", rs1, rs2, rg_opcode, rg_funct3, rg_imm);
    alu.ma_start(rg_opcode, rg_funct3, rg_imm, rs1, rs2);
    rg_state <= False;
  endrule

  rule rl_end(!rg_state);
    let rd = alu.mn_done;
    $display($time,"\tOutput:Program-%h", rd);
    $finish;
  endrule
*/
endmodule
