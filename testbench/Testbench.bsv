`ifdef RV64
  typedef 64 XLEN;
  import "BDPI" function Bit#(XLEN) checker_64 (Bit#(7) rg_opcode, Bit#(3) rg_funct3, Bit#(12) rg_imm, Bit#(XLEN) rs1, Bit#(XLEN) rs2);
`else
  typedef 32 XLEN;
  import "BDPI" function Bit#(XLEN) checker_32 (Bit#(7) rg_opcode, Bit#(3) rg_funct3, Bit#(12) rg_imm, Bit#(XLEN) rs1, Bit#(XLEN) rs2);
`endif

import ALU ::*;
//import ALU_copy::*;
import LFSR::*;

(*synthesize*)
module mkTestbench();
 
  Ifc_ALU alu <- mkALU;
  LFSR #(Bit #(32)) lfsr_rs11 <- mkLFSR_32;
  LFSR #(Bit #(32)) lfsr_rs12 <- mkLFSR_32;
  LFSR #(Bit #(32)) lfsr_rs21 <- mkLFSR_32;
  LFSR #(Bit #(32)) lfsr_rs22 <- mkLFSR_32;
  LFSR #(Bit #(32)) lfsr_opcode <- mkLFSR_32;

//opcode OP-IMM = 13 funct3 = 0 : CLZ             'h260/1/2/3  //'h000/1/2/3
//opcode OP-IMM = 13 funct3 = 1 : CTZ             'h264/5/6/7  //'h004/5/6/7
//opcode OP-IMM = 13 funct3 = 2 : PCNT            'h268/9/a/b  //'h008/9/a/b
//opcode OP-IMM = 13 funct3 = 3 imm = 8**: SLOI   'h26e        //'h00e
//opcode OP-IMM = 13 funct3 = 4 imm = 8**: SROI   'h272        //'h012
//opcode OP-IMM = 13 funct3 = 3 imm = c**: RORI   'h26f        //'h00f
//opcode OP-IMM = 13 funct3 = 5 : GREVI           'h274/5/6/7  //'h014/5/6/7
//opcode OP-IMM = 13 funct3 = 6 : GZIP            'h278/9/a/b  //'h018/9/a/b

//opcode OP-IMM-32 = 1B funct3 = 0 : CLZW         'h360/1/2/3
//opcode OP-IMM-32 = 1B funct3 = 1 : CTZW         'h364/5/6/7
//opcode OP-IMM-32 = 1B funct3 = 2 : PCNTW        'h368/9/a/b
//opcode OP-IMM-32 = 1B funct3 = 3 : SLOIW        'h36c/d/e/f
//opcode OP-IMM-32 = 1B funct3 = 4 : SROIW        'h370/1/2/3
//opcode OP-IMM-32 = 1B funct3 = 5 : RORIW        'h374/5/6/7

//opcode OP = 33 funct3 = 0 : ANDC                'h660/1/2/3  //'h080/1/2/3
//opcode OP = 33 funct3 = 1 imm = 8**: SRO        'h666        //'h086
//opcode OP = 33 funct3 = 2 imm = 8**: SLO        'h66a        //'h08a
//opcode OP = 33 funct3 = 1 imm = c**: ROR        'h667        //'h087
//opcode OP = 33 funct3 = 2 imm = c**: ROL        'h66b        //'h08b
//opcode OP = 33 funct3 = 3 : GREV                'h66c/d/e/f  //'h08c/d/e/f
//opcode OP = 33 funct3 = 4 : BEXT                'h670/1/2/3  //'h090/1/2/3
//opcode OP = 33 funct3 = 5 : BDEP                'h674/5/6/7  //'h094/5/6/7

//opcode OP-32 = 3B funct3 = 0 : SROW             'h760/1/2/3
//opcode OP-32 = 3B funct3 = 1 : SLOW             'h764/5/6/7
//opcode OP-32 = 3B funct3 = 2 : RORW             'h768/9/a/b
//opcode OP-32 = 3B funct3 = 3 : ROLW             'h76c/d/e/f
//opcode OP-32 = 3B funct3 = 4 : BEXTW            'h770/1/2/3
//opcode OP-32 = 3B funct3 = 5 : BDEPW            'h774/5/6/7


//opcode OP = 1 funct3 = 3 imm = 0 : CNEG        'h02c  **
//opcode OP = 1 funct3 = 3 imm = 1 : CNOT        'h02d  **
//opcode OP = 1 funct3 = 3 imm = 2 : CBREV       'h02e  **
// ** -> OpCodes assigned properly, others are placeholders.

  Reg#(Bit#(32)) rg_count <- mkReg(0);
  Reg#(Bool) rg_state <- mkReg(True);
  Reg#(Bit#(XLEN)) rg_checker <- mkReg(0);

  rule rl_init(rg_count == 0);
      lfsr_rs11.seed('h241c43);
      lfsr_rs12.seed('h651387);
      lfsr_rs21.seed('h4c9208);
      lfsr_rs22.seed('h523b5a);
      lfsr_opcode.seed('h161344);
      rg_count <= 1;
  endrule

  rule rl_start(rg_count != 0);
    Bit#(XLEN) rs1, rs2;
    Bit#(7) opcode;
    Bit#(3) funct3;
    Bit#(12) imm;
    rs1 = truncate({lfsr_rs11.value,lfsr_rs12.value});
    rs2 = truncate({lfsr_rs21.value,lfsr_rs22.value});
    opcode = 'h13;//{4'b0,lfsr_opcode.value[11],2'b0};
    funct3 = lfsr_opcode.value[5:3];
    imm = {1'b1,lfsr_opcode.value[26:16]};
    $display($time, "\tInputs: rs1: %h rs2: %h \n\t\t\topcode: %h funct3: %h imm:%h\n", rs1, rs2, opcode, funct3, imm);
    alu.ma_start(opcode, funct3, imm, rs1, rs2);
    `ifdef RV64 rg_checker <= checker_64(opcode, funct3, imm, rs1, rs2); 
    `else rg_checker <= checker_32(opcode, funct3, imm, rs1, rs2);
    `endif
    lfsr_rs11.next();
    lfsr_rs12.next();
    lfsr_rs21.next();
    lfsr_rs22.next();
    lfsr_opcode.next();
    //rg_state <= False;
    rg_count <= rg_count + 1; 
  endrule

  rule rl_store(rg_count > 1);
    let rd = alu.mn_done;
    if(rg_checker == rd) $display($time,"\tOutput:Program-%h or Checker-%h\n Passed", rd, rg_checker);
    if(rg_checker != rd) $display($time,"\tOutput:Program-%h or Checker-%h\n Failed", rd, rg_checker);
    //if(rg_checker != rd) $display("Failed!!!");
    //rg_state <= True
    if(rg_count == 101) $finish;
  endrule
/*
  rule rl_start(rg_state);
    Bit#(64) rs1 = 'h5f2ca38415d78b29;
    Bit#(64) rs2 = 'h38;
    $display($time, "\tInputs: rs1: %h rs2: %h \n\t\t\topcode: %h funct3: %h imm:%h\n", rs1, rs2, opcode, funct3, imm);
    alu.ma_start(opcode, funct3, imm, rs1, rs2);
    rg_state <= False;
  endrule

  rule rl_end(!rg_state);
    let rd = alu.mn_done;
    $display($time,"\tOutput:Program-%h", rd);
    $finish;
  endrule
*/
endmodule
