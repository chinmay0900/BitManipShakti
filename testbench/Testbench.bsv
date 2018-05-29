import lzcounter::*;
import tzcounter::*;
import greverse ::*;

(*synthesize*)
module mkTestbench();

	Ifc_lzcounter lzcount <- mklzcounter;
  Ifc_tzcounter tzcount <- mktzcounter;
  Ifc_greverse reverser <- mkgreverse;

  Reg#(Bit#(8)) rg_opcode <- mkReg(2);
      //Change opcode here to execute lzcounter(00) or tzcounter(01) or greverse(10) 
  Reg#(Bit#(64)) rg_rs1 <- mkReg('h0000000000700360);
            //Insert the number here ^^
  Reg#(Bit#(64)) rg_rs2 <- mkReg('h0000000000000010);
  Reg#(Bit#(64)) rg_rd <- mkRegU();
  Reg#(Bit#(64)) rg_state<-mkReg(0);

//Rule start sends argument to lzcounter
  rule rl_start_lz(rg_state == 0);
    if(rg_opcode==0) begin
    lzcount.ma_start(rg_rs1);
    rg_state <= 1; end
    if(rg_opcode==1) begin
    tzcount.ma_start(rg_rs1);
    rg_state <= 1; end
    if(rg_opcode==2) begin
    reverser.ma_start(rg_rs1, rg_rs2);
    rg_state <= 1; end
  endrule

//Rule store_rd gets output from lzcounter and stores in rd 
//(reflected in next cycle)
  rule rl_store_rd_lz(rg_state == 1 && rg_opcode==0);    
    rg_rd <= lzcount.mn_done();
    rg_state <= 2;
  endrule

  rule rl_store_rd_tz(rg_state == 1 && rg_opcode==1);    
    rg_rd <= tzcount.mn_done();
    rg_state <= 2;
  endrule

  rule rl_store_rd_grev(rg_state == 1 && rg_opcode==2);   
    rg_rd <= reverser.mn_done();
    rg_state <= 2;
  endrule

//Rule finish shows output in terminal
  rule rl_finish(rg_state == 2);
    $display("\n",$time,":Output:Hex-%h or Dec-%d\n", rg_rd,rg_rd);
    $finish;
  endrule

endmodule
