class mc_ecc_enable_test extends mc_base_test;

  // Factory registration
  `uvm_component_utils(mc_ecc_enable_test)
  mc_ecc_enable_sequence ecc_enable_seq;
  mc_ral_ecc_enable_sequence ral_ecc_enable_seq;

  // Constructor
  function new(string name = "mc_ecc_enable_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ecc_enable_seq = mc_ecc_enable_sequence::type_id::create("ecc_enable_seq",this);
    ral_ecc_enable_seq = mc_ral_ecc_enable_sequence::type_id::create("ral_ecc_enable_seq", this);
    
  endfunction

  // Run Phase
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_full_name(), $sformatf("Inside the ecc_enable test"), UVM_MEDIUM)

    ral_ecc_enable_seq.regmodel = env.regmodel;

   
    ecc_enable_seq.scenario = 1;
      ecc_enable_seq.start(env.axi_agent.axi_seqr);
   
    ecc_enable_seq.scenario = 2;
      ecc_enable_seq.start(env.axi_agent.axi_seqr);

    ral_ecc_enable_seq.scenario = 3;
      ral_ecc_enable_seq.start(env.apb_agent.apb_seqr);

     ecc_enable_seq.scenario = 4;
      ecc_enable_seq.start(env.axi_agent.axi_seqr);

    ecc_enable_seq.scenario = 5;
      ecc_enable_seq.start(env.axi_agent.axi_seqr);
 
       phase.phase_done.set_drain_time(this,300000);

    phase.drop_objection(this);
endtask

endclass
