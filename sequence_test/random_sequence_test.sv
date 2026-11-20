class random_test extends base_sequence_test;
    `uvm_component_utils(random_test)

    function new(string name = "random_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        random_sequence rand_seq;
        phase.raise_objection(this);
        
        rand_seq = random_sequence::type_id::create("rand_seq");
        rand_seq.start(env.agent.sequencer);
        
        #5000;
        phase.drop_objection(this);
    endtask
endclass
