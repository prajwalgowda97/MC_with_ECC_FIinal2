class mc_reset_test extends mc_base_test;

  // Factory registration
  `uvm_component_utils(mc_reset_test)
  mc_reset_sequence reset_seq;

  // Constructor
  function new(string name = "mc_reset_test", uvm_component parent = null);
    super.new(name, parent);
    reset_seq = mc_reset_sequence::type_id::create("reset_seq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Run Phase
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_full_name(), $sformatf("Inside the reset test"), UVM_MEDIUM)

      reset_seq.scenario = 1;
      reset_seq.start(env.axi_agent.axi_seqr);
    `uvm_info(get_type_name(),$sformatf("reset scenario 1 is competed"),UVM_MEDIUM)

    phase.phase_done.set_drain_time(this,300000);

    phase.drop_objection(this);
endtask

endclass
