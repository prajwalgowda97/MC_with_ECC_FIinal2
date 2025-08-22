class mc_wrap_burst_test extends mc_base_test;

  // Factory registration
  `uvm_component_utils(mc_wrap_burst_test)
  mc_wrap_burst_sequence wrap_burst_seq;
  mc_ral_wrap_burst_sequence ral_wrap_burst_seq;

  // Constructor
  function new(string name = "mc_wrap_burst_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    wrap_burst_seq = mc_wrap_burst_sequence::type_id::create("wrap_burst_seq",this);
    ral_wrap_burst_seq = mc_ral_wrap_burst_sequence::type_id::create("ral_wrap_burst_seq", this);
    
  endfunction

  // Run Phase
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_full_name(), $sformatf("Inside the wrap_burst test"), UVM_MEDIUM)

    ral_wrap_burst_seq.regmodel = env.regmodel;

   
    wrap_burst_seq.scenario = 1;
      wrap_burst_seq.start(env.axi_agent.axi_seqr);
   
    wrap_burst_seq.scenario = 2;
      wrap_burst_seq.start(env.axi_agent.axi_seqr);

    ral_wrap_burst_seq.scenario = 3;
      ral_wrap_burst_seq.start(env.apb_agent.apb_seqr);

     wrap_burst_seq.scenario = 4;
      wrap_burst_seq.start(env.axi_agent.axi_seqr);

    wrap_burst_seq.scenario = 5;
      wrap_burst_seq.start(env.axi_agent.axi_seqr);
 
       phase.phase_done.set_drain_time(this,300000);

    phase.drop_objection(this);
endtask

endclass
