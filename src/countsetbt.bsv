package countsetbt;

  interface Ifc_countsetbt;
    method Action ma_start(Bit #(64) rs1);
    method Bit#(64) mn_done;
  endinterface
  
  module mkcountsetbt(Ifc_countsetbt);

    Reg#(Bit#(64)) rg_rd <- mkRegU();
    Reg#(Bit#(1)) rg_work <- mkReg(0);
   
    method Action ma_start(Bit#(64) rs1) if(rg_work == 0); 
      rg_work <= 1;
      rg_rd <= zeroExtend(pack(countOnes(rs1)));
    endmethod

    method Bit#(64) mn_done if(rg_work==1);
      return rg_rd;
    endmethod
 
  endmodule

endpackage
