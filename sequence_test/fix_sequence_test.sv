class fix_sequence_test extends base_sequence_test;
	`uvm_component_utils(fix_sequence_test)

	function new(string name = "fix_sequence_test",uvm_component parent);
		super.new(name,parent);
	endfunction

	virtual task run_phase(uvm_phase phase);
		fix_sequence fix_seq;
		phase.raise_objection(this);
		fix_seq = fix_sequence::type_id::create("fix_seq",this);
		fix_seq.start(env.agent.sequencer);

		#1000;
		phase.drop_objection(this);
	endtask
endclass
