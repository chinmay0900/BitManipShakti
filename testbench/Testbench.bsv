import ALU ::*;

(*synthesize*)
module mkTestbench();
  
  Ifc_ALU alu <- mkALU;

  Bit#(5) rg_opcode = 'h00;
  Bit#(3) rg_funct3 = 'h5;
  Bit#(12) rg_imm = 'h030;
  Bit#(64) rg_rs1 = 'h000000002d402d2f;
            //Insert the number here ^^
  Bit#(64) rg_rs2 = 'h000000000f003004;
  Reg#(Bool) rg_state <- mkReg(True);

  rule rl_start(rg_state);
    $display($time, "\tInputs: rs1: %h rs2: %h \n\t\t\topcode: %h funct3: %h imm:%h\n", rg_rs1, rg_rs2, rg_opcode, rg_funct3, rg_imm);
    alu.ma_start(rg_opcode, rg_funct3, rg_imm, rg_rs1, rg_rs2);
    rg_state <= False;
  endrule

  rule rl_store;
    let rd = alu.mn_done;
    $display($time,"\tOutput:Hex-%h or Dec-%d\n", rd, rd);
    $finish;
  endrule

endmodule
