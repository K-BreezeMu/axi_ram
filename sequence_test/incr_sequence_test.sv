class incr_sequence_test extends base_sequence_test;
    `uvm_component_utils(incr_sequence_test)

    function new(string name = "incr_sequence_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        incr_sequence incr_seq;
        phase.raise_objection(this);
        
        incr_seq = incr_sequence::type_id::create("incr_seq");
        incr_seq.start(env.agent.sequencer);
        
        #2000;
        phase.drop_objection(this);
    endtask
endclass
