import lzcounter::*;

(*synthesize*)
module mkTestbench();
	Ifc_lzcounter counter <- mklzcounter;
	Integer verbosity=0;
	rule rl_start;
    counter.start('h00700360);
    //Insert number here ^^
	endrule
endmodule
