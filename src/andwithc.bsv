package andwithc;

  interface Ifc_andwithc;
    method Action ma_start(Bit#(64) rs1, Bit#(64) rs2);
    method Bit#(64) mn_done;
  endinterface

  module mkandwithc(Ifc_andwithc);

    Reg#(Bit#(64)) rg_x <- mkRegU();
    Reg#(Bit#(64)) rg_y <- mkRegU();
    Reg#(Bit#(64)) rg_work <- mkReg(0);

    rule rl_getandwithc(rg_work==1);
      rg_x <= (rg_x) & (~rg_y);
      rg_work <= 2;
    endrule
    
    method Action ma_start(Bit#(64) rs1, Bit#(64) rs2) if(rg_work == 0); 
      rg_work <= 1;
      rg_x <= rs1;
      rg_y <= rs2;
    endmethod

    method Bit#(64) mn_done if(rg_work==2);
      return rg_x;
    endmethod

  endmodule

endpackage
