import lzcounter::*;

(*synthesize*)
module mkTestbench();
	Ifc_lzcounter counter <- mklzcounter;
	Integer verbosity=0;
	rule rl_start;
		counter.start('h00000002);
	endrule
endmodule
