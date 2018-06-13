package lzcounter;

  interface Ifc_lzcounter;
    method Action ma_start(Bit #(64) rs1);
    method Bit#(64) mn_done;
  endinterface
  
  module mklzcounter(Ifc_lzcounter);

    Reg#(Bit#(64)) rg_rd <- mkReg(0);
    Reg#(Bit#(1)) rg_work <- mkReg(0);

//The interface has one input (rg_rs1 stored in rg_x) and one output
//The algorithm calculates (x-1)&(~x) which sets the trailing zeroes and resets everthing else
//Hence the input is first reversed in rule reverse
//Then the no. of set bits is counted in rule get_count 
//The 7 bit output is zeroExtended in rule put_count and stored in rg_x which reflects in next cycle and returned as output
//rg_work decides which job is to be performed.

    method Action ma_start(Bit#(64) rs1) if(rg_work==0);
      rg_work <= 1;
      rg_rd <= zeroExtend(pack(countZerosMSB(rs1)));
    endmethod
    
    method Bit#(64) mn_done if(rg_work==1);
      return rg_rd;
    endmethod
    
  endmodule
  
endpackage
