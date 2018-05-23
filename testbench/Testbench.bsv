import LeadingZeroCounter::*;

(*synthesize*)
module mkTestbench();
	LeadingZeroCounter counter <- mkLeadingZeroCounter;
	Reg#(Bit#(8)) state <- mkReg(0);
	Integer verbosity=0;
	rule rl_start(state == 0);
		counter.load_rs1(5);
		state <= 1;
		if(verbosity>0) $display("1. %d %b\n",counter.read_count(),counter.read_rs1value());
	endrule
	rule rl_work(state == 1);
		if(verbosity>0) $display("2. %d %b\n",counter.read_count(),counter.read_rs1value());
		if(counter.read_rs1() || counter.read_count==8) begin
			$display("%d\n",counter.read_count()); 
			$finish;
		end
		counter.increment_count();
		counter.leftshift_rs1(1);
		if(verbosity>0) $display("%d",counter.read_count());
	endrule
endmodule
