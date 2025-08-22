class mc_fixed_burst_test extends mc_base_test;

  // Factory registration
  `uvm_component_utils(mc_fixed_burst_test)
  mc_fixed_burst_sequence fixed_burst_seq;
  mc_ral_fixed_burst_sequence ral_fixed_burst_seq;

  // Constructor
  function new(string name = "mc_fixed_burst_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    fixed_burst_seq = mc_fixed_burst_sequence::type_id::create("fixed_burst_seq",this);
    ral_fixed_burst_seq = mc_ral_fixed_burst_sequence::type_id::create("ral_fixed_burst_seq", this);
    
  endfunction

  // Run Phase
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_full_name(), $sformatf("Inside the fixed_burst test"), UVM_MEDIUM)

    ral_fixed_burst_seq.regmodel = env.regmodel;

   
    fixed_burst_seq.scenario = 1;
      fixed_burst_seq.start(env.axi_agent.axi_seqr);
   
    fixed_burst_seq.scenario = 2;
      fixed_burst_seq.start(env.axi_agent.axi_seqr);

    ral_fixed_burst_seq.scenario = 3;
      ral_fixed_burst_seq.start(env.apb_agent.apb_seqr);

     fixed_burst_seq.scenario = 4;
      fixed_burst_seq.start(env.axi_agent.axi_seqr);

    fixed_burst_seq.scenario = 5;
      fixed_burst_seq.start(env.axi_agent.axi_seqr);
 
       phase.phase_done.set_drain_time(this,300000);

    phase.drop_objection(this);
endtask

endclass
