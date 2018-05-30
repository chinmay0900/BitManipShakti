package countsetbt;

  interface Ifc_countsetbt;
    method Action ma_start(Bit #(64) rs1);
    method Bit#(64) mn_done;
  endinterface
  
  module mkcountsetbt(Ifc_countsetbt);

    Reg#(Bit#(64)) rg_x <- mkRegU();
    Reg#(Bit#(7)) rg_y <- mkRegU();
    Reg#(Bit#(64)) rg_work <- mkReg(0);

    rule rl_getcount(rg_work==1);
      rg_y <= pack(countOnes(rg_x)); 
      rg_work <= 2;
    endrule
    
    method Action ma_start(Bit#(64) rs1) if(rg_work == 0); 
      rg_work <= 1;
      rg_x <= rs1;
    endmethod

    method Bit#(64) mn_done if(rg_work==2);
      return zeroExtend(rg_y);
    endmethod
 
  endmodule

endpackage
