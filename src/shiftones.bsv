package shiftones;

  interface Ifc_shiftones;
    method Action ma_start_lft(Bit #(64) rs1, Bit#(64) rs2);
    method Action ma_start_rgt(Bit #(64) rs1, Bit#(64) rs2);
    method Bit#(64) mn_done;
  endinterface

  module mkshiftones(Ifc_shiftones);

    Reg#(Bit#(64)) rg_x <- mkRegU();
    Reg#(Bit#(6)) rg_y <- mkRegU();
    Reg#(Bit#(64)) rg_work <- mkReg(0);
 
    rule rl_shiftonelft(rg_work==1);
      rg_x <= ~(~rg_x << rg_y);
      rg_work <= 3;
    endrule

    rule rl_shiftonergt(rg_work==2);
      rg_x <= ~(~rg_x >> rg_y);
      rg_work <= 3;
    endrule

    method Action ma_start_lft(Bit#(64) rs1, Bit#(64) rs2) if(rg_work == 0); 
      rg_work <= 1;
      rg_x <= rs1;
      rg_y <= truncate(rs2);
    endmethod

    method Action ma_start_rgt(Bit#(64) rs1, Bit#(64) rs2) if(rg_work == 0); 
      rg_work <= 2;
      rg_x <= rs1;
      rg_y <= truncate(rs2);
    endmethod

    method Bit#(64) mn_done if(rg_work==3);
      return rg_x;
    endmethod

  endmodule

endpackage