package c_neg;
  
   interface Ifc_c_neg#(type size_t);
     method Action ma_start(Bit#(size_t) rs1);
     method Bit#(size_t) mn_done;
   endinterface

   module mkc_neg(Ifc_c_neg#(size_t));
     
     Reg#(Bit#(size_t)) rg_rd <- mkReg(0);
     Reg#(Bit#(1)) rg_work <- mkReg(0);

     method Action ma_start(Bit#(size_t) rs1) if(rg_work == 0);
       rg_rd <= rg_rd - rs1;
       rg_work <= 1;
     endmethod     

     method Bit#(size_t) mn_done if(rg_work == 1);
       return rg_rd;
     endmethod

   endmodule

endpackage
