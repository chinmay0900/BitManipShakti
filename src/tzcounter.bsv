package tzcounter;

  interface Ifc_tzcounter;
    method Action start(Bit #(32) x);  
  endinterface
  
  module mktzcounter(Ifc_tzcounter);
    
    Reg#(Bit#(32)) rg_rs1 <- mkRegU();
    Reg#(Bit#(32)) rg_count <- mkReg(0);
    Reg#(Bool) work <- mkReg(False);
    Wire #(Bit#(32)) wr_shifter <- mkWire();
    
    rule rl_checkzero(rg_rs1==0&&work);
      $display("Output : 32\n");
      work <= False;
      $finish;
    endrule

    for(Integer i=0;i<32;i=i+1)
      rule rl_shift_i(rg_rs1[i] == 1 &&work);
        $display("Output : %d\n",i);
        work <= False;
        $finish;
      endrule
  
    method Action start(Bit#(32) x);
      work <= True;
      rg_rs1 <= x;
    endmethod
    
  endmodule
  
endpackage
