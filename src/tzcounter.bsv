package tzcounter;

  interface Ifc_tzcounter;
    method Action ma_start(Bit #(64) rs1);
    method Bit#(64) mn_done;
  endinterface
  
  module mktzcounter(Ifc_tzcounter);

    
    Reg#(Bit#(64)) rg_x <- mkRegU();
    Reg#(Bit#(7)) rg_count <- mkRegU();
    Reg#(Bit#(64)) rg_work <- mkReg(0);
       
//The interface has one input (rg_rs1 stored in rg_x) and one output
//The algorithm calculates (x-1)&(~x) which sets the trailing zeroes and resets everthing else
//Then the no. of set bits is counted in rule get_count 
//The 7 bit output is zeroExtended in rule put_count and stored in rg_x which reflects in next cycle and returned as output
//rg_work decides which job is to be performed.

    rule rl_getcount(rg_work==1&&rg_x!=0);
      rg_count <= pack(countOnes((rg_x-1)&(~rg_x)));
      rg_work <= 2;
      $display("rg_x value in tzcounter : %h\n",rg_x);
    endrule

    rule rl_putcount(rg_work == 2);
      rg_x <= zeroExtend(rg_count);
      rg_work <= 3;
    endrule
  
    method Action ma_start(Bit#(64) rs1) if(rg_work==0);
      rg_work <= 1;
      rg_x <= rs1;
    endmethod

    method Bit#(64) mn_done if(rg_work==3);
      return rg_x;
    endmethod

  endmodule
  
endpackage
