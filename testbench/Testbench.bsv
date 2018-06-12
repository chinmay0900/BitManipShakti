import ALU ::*;

(*synthesize*)
module mkTestbench();
  
  Ifc_ALU alu <- mkALU;

  Reg#(Bit#(32)) rg_inst <- mkReg('h000002000);
  Reg#(Bit#(64)) rg_rs1 <- mkReg('h000000002d402d2f);
            //Insert the number here ^^
  Reg#(Bit#(64)) rg_rs2 <- mkReg('h000000000f003030);
  Reg#(Bit#(64)) rg_state<-mkReg(0);

  rule rl_start(rg_state == 0);
    $display($time, "\tInputs: rs1: %h rs2: %h instruction: %h", rg_rs1, rg_rs2, rg_inst);
    alu.ma_start(rg_inst, rg_rs1, rg_rs2);
    rg_state <= 1;
  endrule

  rule rl_store;
    let rd = alu.mn_done;
    $display($time,"\tOutput:Hex-%h or Dec-%d\n", rd, rd);
    $finish;
  endrule

endmodule
