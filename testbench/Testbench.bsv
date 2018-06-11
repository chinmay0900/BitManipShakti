import ALU ::*;

(*synthesize*)
module mkTestbench();
  
  Ifc_ALU alu <- mkALU;

  Reg#(Bit#(32)) rg_inst <- mkReg('h000002000);
  Reg#(Bit#(64)) rg_rs1 <- mkReg('h000000002d402d2f);
            //Insert the number here ^^
  Reg#(Bit#(64)) rg_rs2 <- mkReg('h000000000f003030);
  Reg#(Bit#(64)) rg_rd <- mkRegU();
  Reg#(Bit#(64)) rg_state<-mkReg(0);

  rule rl_start(rg_state == 0);
    alu.ma_start(rg_inst, rg_rs1, rg_rs2);
    rg_state <= 1;
  endrule

  rule rl_store(rg_state == 1);
    rg_rd <= alu.mn_done;
    rg_state <= 2;
  endrule

  rule rl_finish(rg_state == 2);
    $display("\n",$time,":Output:Hex-%h or Dec-%d\n", rg_rd,rg_rd);
    $finish;
  endrule

endmodule
