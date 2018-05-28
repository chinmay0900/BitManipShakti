import lzcounter::*;
import tzcounter::*;

(*synthesize*)
module mkTestbench();

	Ifc_lzcounter lzcount <- mklzcounter;
  Ifc_tzcounter tzcount <- mktzcounter;
  
  Reg#(Bit#(1)) rg_opcode <- mkReg('b1);
      //Change opcode here to execute lzcounter(0) or tzcounter(1) in MSB
  Reg#(Bit#(64)) rg_rs1 <- mkReg('h00700360);
            //Insert the number here ^^
  Reg#(Bit#(64)) rg_rd <- mkRegU();
  Reg#(Bit#(64)) rg_state<-mkReg(0);

//Rule start sends argument to lzcounter
  rule rl_start_lz(rg_state == 0 && rg_opcode==0);
    lzcount.ma_start(rg_rs1);
    rg_state <= 1;
  endrule

  rule rl_start_tz(rg_state == 0 && rg_opcode==1);
    tzcount.ma_start(rg_rs1);
    rg_state <= 1;
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

//Rule finish shows output in terminal
  rule rl_finish(rg_state == 2);
    $display("\n",$time,":Output:%d\n", rg_rd);
    $finish;
  endrule

endmodule
