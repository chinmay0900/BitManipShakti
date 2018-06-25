import lzcounter   ::*;
import tzcounter   ::*;
import countsetbt  ::*;
import greverse    ::*;
import andwithc    ::*;
import shiftones   ::*;
import rotate      ::*;
import btextract   ::*;
import btdeposit   ::*;
import gzip        ::*;
import c_not       ::*;
import c_neg       ::*;


typedef 64 N;

(*synthesize*)
module mkTestbench_copy(Empty);
 

  Ifc_lzcounter#(N) lzcount <- mklzcounter;
  Ifc_tzcounter#(N) tzcount <- mktzcounter;
  Ifc_countsetbt#(N) bcounter <- mkcountsetbt;
  Ifc_greverse#(N) reverser <- mkgreverse;
  Ifc_andwithc#(N) andwithcer <- mkandwithc;
  Ifc_shiftones#(N) oneshifter <- mkshiftones;
  Ifc_rotate#(N) rotater <- mkrotate;
  Ifc_btextract#(N) btextracter <- mkbtextract;
  Ifc_btdeposit#(N) btdepositer <- mkbtdeposit;
  Ifc_gzip#(N) ziper <- mkgzip;
  Ifc_c_not#(N) noter <- mkc_not;
  Ifc_c_neg#(N) negater <- mkc_neg; 

  Reg#(Bit#(8)) rg_opcode <- mkReg(14);
      //Change opcode here to execute lzcounter(0) or tzcounter(1) or
      //greverse(2) or countsetbits(3) or andwithc (4) or shiftoneleft(5) or 
      //shiftoneright(6) or rotateleft(7) or rotateright(8) or btextract(9)
      //or btdeposit(10) or gzip(11) or c_not(12) or c_neg(13) or c_brev(14)
  Reg#(Bit#(N)) rg_rs1 <- mkReg('h054523902341478);
            //Insert the number here ^^
  Reg#(Bit#(N)) rg_rs2 <- mkReg('h23f5670f);
  Reg#(Bit#(N)) rg_rd <- mkReg(0);
  Reg#(Bit#(N)) rg_state<-mkReg(0);


//Rule start sends argument to lzcounter
  rule rl_start(rg_state == 0);
    if(rg_opcode == 0) begin
      lzcount.ma_start(rg_rs1);
      rg_state <= 1; end
    if(rg_opcode == 1) begin
      tzcount.ma_start(rg_rs1);
      rg_state <= 1; end
    if(rg_opcode == 2) begin
      reverser.ma_start(rg_rs1, rg_rs2);
      rg_state <= 1; end
    if(rg_opcode == 3) begin
      bcounter.ma_start(rg_rs1);
      rg_state <= 1; end
    if(rg_opcode == 4) begin
      andwithcer.ma_start(rg_rs1,rg_rs2);
      rg_state <= 1; end
    if(rg_opcode == 5) begin
      oneshifter.ma_start(rg_rs1,rg_rs2,1'b0);
      rg_state <= 1; end
    if(rg_opcode == 6) begin
      oneshifter.ma_start(rg_rs1,rg_rs2,1'b1);
      rg_state <= 1; end
    if(rg_opcode == 7) begin
      rotater.ma_start(rg_rs1,rg_rs2,1'b0);
      rg_state <= 1; end
    if(rg_opcode == 8) begin
      rotater.ma_start(rg_rs1,rg_rs2,1'b1);
      rg_state <= 1; end
    if(rg_opcode == 9) begin
      btextracter.ma_start(rg_rs1,rg_rs2);
      rg_state <= 1; end
    if(rg_opcode == 10) begin
      btdepositer.ma_start(rg_rs1,rg_rs2);
      rg_state <= 1; end
    if(rg_opcode == 11) begin
      ziper.ma_start(rg_rs1,rg_rs2);
      rg_state <= 1; end
    if(rg_opcode == 12) begin
      noter.ma_start(rg_rs1);
      rg_state <= 1; end
    if(rg_opcode == 13) begin
        negater.ma_start(rg_rs1);
      rg_state <= 1; end
    if(rg_opcode == 14) begin
      reverser.ma_start(rg_rs1,'hff);
      rg_state <= 1; end
  endrule

//Rule store_rd gets output from lzcounter and stores in rd 
//(reflected in next cycle)
  rule rl_store_rd_lz(rg_state == 1 && rg_opcode == 0);    
    rg_rd <= zeroExtend(lzcount.mn_done());
    rg_state <= 2;
  endrule

  rule rl_store_rd_tz(rg_state == 1 && rg_opcode == 1);    
    rg_rd <= tzcount.mn_done();
    rg_state <= 2;
  endrule

  rule rl_store_rd_grev(rg_state == 1 && rg_opcode == 2);   
    rg_rd <= reverser.mn_done();
    rg_state <= 2;
  endrule

  rule rl_store_rd_sbc(rg_state == 1 && rg_opcode == 3);
    rg_rd <= bcounter.mn_done();
    rg_state <= 2;
  endrule

  rule rl_store_rd_andwc(rg_state == 1 && rg_opcode == 4);
    rg_rd <= andwithcer.mn_done;
    rg_state <= 2;
  endrule

  rule rl_store_rd_oneshift(rg_state == 1 && (rg_opcode == 5 || rg_opcode == 6));
    rg_rd <= oneshifter.mn_done;
    rg_state <= 2;
  endrule

  rule rl_store_rd_rotate(rg_state == 1 && (rg_opcode == 7 || rg_opcode == 8));
    rg_rd <= rotater.mn_done;
    rg_state <= 2;
  endrule

  rule rl_store_rd_bextract(rg_state == 1 && rg_opcode == 9);
    rg_rd <= btextracter.mn_done;
    rg_state <= 2;
  endrule
  
  rule rl_store_rd_bdeposit(rg_state == 1 && rg_opcode == 10);
    rg_rd <= btdepositer.mn_done;
    rg_state <= 2;
  endrule
 
  rule rl_store_rd_gzip(rg_state == 1 && rg_opcode == 11);
    rg_rd <= ziper.mn_done;
    rg_state <= 2;
  endrule

  rule rl_store_rd_c_not(rg_state == 1 && rg_opcode == 12);
    rg_rd <= noter.mn_done;
    rg_state <= 2;
  endrule

  rule rl_store_rd_c_neg(rg_state == 1 && rg_opcode == 13);
    rg_rd <= negater.mn_done;
    rg_state <= 2;
  endrule

  rule rl_store_rd_c_brev(rg_state == 1 && rg_opcode == 14);
    rg_rd <= reverser.mn_done;
    rg_state <= 2;
  endrule

//Rule finish showsoutput in terminal
  rule rl_finish(rg_state == 2);
    $display("\n",$time,":Output:Hex-%h or Dec-%d\n", rg_rd,rg_rd);
    $finish;
  endrule
 


endmodule
