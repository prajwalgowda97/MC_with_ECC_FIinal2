class mc_mem_initial_test extends mc_base_test;

  // Factory registration
  `uvm_component_utils(mc_mem_initial_test)
  mc_mem_initial_sequence mem_initial_seq;

  // Constructor
  function new(string name = "mc_mem_initial_test", uvm_component parent = null);
    super.new(name, parent);
    mem_initial_seq = mc_mem_initial_sequence::type_id::create("mem_initial_seq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Run Phase
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_full_name(), $sformatf("Inside the mem_initial test"), UVM_MEDIUM)

      mem_initial_seq.scenario = 1;
      mem_initial_seq.start(env.axi_agent.axi_seqr);
    `uvm_info(get_type_name(),$sformatf("mem_initial scenario 1 is competed"),UVM_MEDIUM)

     mem_initial_seq.scenario = 2;
      mem_initial_seq.start(env.axi_agent.axi_seqr);
    `uvm_info(get_type_name(),$sformatf("mem_initial scenario 2 is competed"),UVM_MEDIUM)      

    mem_initial_seq.scenario = 3;
      mem_initial_seq.start(env.axi_agent.axi_seqr);
    `uvm_info(get_type_name(),$sformatf("mem_initial scenario 3 is competed"),UVM_MEDIUM)      


    phase.phase_done.set_drain_time(this,300000);

    phase.drop_objection(this);
endtask

endclass
