class mc_random_wr_rd_test extends mc_base_test;

  // Factory registration
  `uvm_component_utils(mc_random_wr_rd_test)
  mc_random_wr_rd_sequence random_wr_rd_seq;
  mc_ral_random_wr_rd_sequence ral_random_wr_rd_seq;

  // Constructor
  function new(string name = "mc_random_wr_rd_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    random_wr_rd_seq = mc_random_wr_rd_sequence::type_id::create("random_wr_rd_seq",this);
    ral_random_wr_rd_seq = mc_ral_random_wr_rd_sequence::type_id::create("ral_random_wr_rd_seq", this);
    
  endfunction

  // Run Phase
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_full_name(), $sformatf("Inside the random_wr_rd test"), UVM_MEDIUM)

    ral_random_wr_rd_seq.regmodel = env.regmodel;

   
    random_wr_rd_seq.scenario = 1;
      random_wr_rd_seq.start(env.axi_agent.axi_seqr);
   
    random_wr_rd_seq.scenario = 2;
      random_wr_rd_seq.start(env.axi_agent.axi_seqr);

    ral_random_wr_rd_seq.scenario = 3;
      ral_random_wr_rd_seq.start(env.apb_agent.apb_seqr);

     random_wr_rd_seq.scenario = 4;
      random_wr_rd_seq.start(env.axi_agent.axi_seqr);

    random_wr_rd_seq.scenario = 5;
      random_wr_rd_seq.start(env.axi_agent.axi_seqr);
 
       phase.phase_done.set_drain_time(this,300000);

    phase.drop_objection(this);
endtask

endclass
