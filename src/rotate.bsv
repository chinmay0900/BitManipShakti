package rotate;

  interface Ifc_rotate#(type size_t);
    method Action ma_start(Bit #(size_t) rs1, Bit#(size_t) rs2, Bit#(1) dir);
    method Bit#(size_t) mn_done;
  endinterface

  module mkrotate(Ifc_rotate#(size_t));

    Integer n = valueOf (size_t);  

    Reg#(Bit#(size_t)) rg_rd <- mkReg(0);
    Reg#(Bit#(1)) rg_work <- mkReg(0);


    method Action ma_start(Bit#(size_t) rs1, Bit#(size_t) rs2, Bit#(1) dir) if(rg_work == 0); 
      if(dir==0) rg_rd <= ~(~rs1 >> (rs2 & fromInteger(n-1)));
      else rg_rd <= ~(~rs1 << (rs2 & fromInteger(n-1)));
      rg_work <= 1;
    endmethod

    method Bit#(size_t) mn_done if(rg_work==1);
      return rg_rd;
    endmethod


  endmodule

endpackage
