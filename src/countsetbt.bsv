package countsetbt;

  interface Ifc_countsetbt#(type size_t);
    method Action ma_start(Bit #(size_t) rs1);
    method Bit#(size_t) mn_done;
  endinterface
  
  module mkcountsetbt(Ifc_countsetbt#(size_t)) provisos(Add#(a__, TLog#(TAdd#(1, size_t)), size_t),Add#(1, b__, TLog#(TAdd#(1, size_t))));

    Reg#(Bit#(size_t)) rg_rd <- mkRegU();
    Reg#(Bit#(1)) rg_work <- mkReg(0);
   
    method Action ma_start(Bit#(size_t) rs1) if(rg_work == 0); 
      rg_work <= 1;
      rg_rd <= zeroExtend(pack(countOnes(rs1)));
    endmethod

    method Bit#(size_t) mn_done if(rg_work==1);
      return rg_rd;
    endmethod
 
  endmodule

endpackage
