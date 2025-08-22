class mc_parity_generator_test extends mc_base_test;

  // Factory registration
  `uvm_component_utils(mc_parity_generator_test)
  mc_parity_generator_sequence parity_generator_seq;
  mc_ral_parity_generator_sequence ral_parity_generator_seq;

  // Constructor
  function new(string name = "mc_parity_generator_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    parity_generator_seq = mc_parity_generator_sequence::type_id::create("parity_generator_seq",this);
    ral_parity_generator_seq = mc_ral_parity_generator_sequence::type_id::create("ral_parity_generator_seq", this);
    
  endfunction

  // Run Phase
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_full_name(), $sformatf("Inside the parity_generator test"), UVM_MEDIUM)

    ral_parity_generator_seq.regmodel = env.regmodel;

   
    parity_generator_seq.scenario = 1;
      parity_generator_seq.start(env.axi_agent.axi_seqr);
   
    parity_generator_seq.scenario = 2;
      parity_generator_seq.start(env.axi_agent.axi_seqr);

    ral_parity_generator_seq.scenario = 3;
      ral_parity_generator_seq.start(env.apb_agent.apb_seqr);

     parity_generator_seq.scenario = 4;
      parity_generator_seq.start(env.axi_agent.axi_seqr);

       phase.phase_done.set_drain_time(this,300000);

    phase.drop_objection(this);
endtask

endclass
