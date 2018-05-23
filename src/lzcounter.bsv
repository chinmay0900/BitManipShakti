package lzcounter;

  interface Ifc_lzcounter;
  	method Bool read_rs1();
  	method Action load_rs1(Bit#(8) newval);
  	method Bit#(8) read_count();
  	method Action increment_count();
  	method Bit#(8) read_rs1value();
  	method Action leftshift_rs1(Bit#(8) shiftvalue);
  endinterface
  
  (*synthesize*)
  module mklzcounter(Ifc_lzcounter);
  	Reg#(Bit#(8)) rg_rs1 <- mkRegU();
  	Reg#(Bit#(8)) rg_count <- mkReg(0);
  
  	method Action load_rs1(Bit#(8) newval);
  		rg_rs1 <= newval;
  	endmethod
  	method Bit#(8) read_rs1value();
  		return rg_rs1;
  	endmethod
  	method Bool read_rs1();
  		if(rg_rs1[7]==1) return True;
  		else return False;
  	endmethod
  	method Bit#(8) read_count();
  		return rg_count;
  	endmethod
  	method Action increment_count();
  		rg_count <= rg_count + 1;
  	endmethod
  	method Action leftshift_rs1(Bit#(8) shiftvalue);
  		rg_rs1 <= rg_rs1 << shiftvalue;
  	endmethod
  endmodule
endpackage
