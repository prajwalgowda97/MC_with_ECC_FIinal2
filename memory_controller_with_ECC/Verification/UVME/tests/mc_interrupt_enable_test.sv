class mc_interrupt_enable_test extends mc_base_test;

  // Factory registration
  `uvm_component_utils(mc_interrupt_enable_test)
  mc_interrupt_enable_sequence interrupt_enable_seq;
  mc_ral_interrupt_enable_sequence ral_interrupt_enable_seq;

  // Constructor
  function new(string name = "mc_interrupt_enable_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    interrupt_enable_seq = mc_interrupt_enable_sequence::type_id::create("interrupt_enable_seq",this);
    ral_interrupt_enable_seq = mc_ral_interrupt_enable_sequence::type_id::create("ral_interrupt_enable_seq", this);
    
  endfunction

  // Run Phase
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_full_name(), $sformatf("Inside the interrupt_enable test"), UVM_MEDIUM)

    ral_interrupt_enable_seq.regmodel = env.regmodel;

   
    interrupt_enable_seq.scenario = 1;
      interrupt_enable_seq.start(env.axi_agent.axi_seqr);
   
    interrupt_enable_seq.scenario = 2;
      interrupt_enable_seq.start(env.axi_agent.axi_seqr);
 
    ral_interrupt_enable_seq.scenario = 3;
      ral_interrupt_enable_seq.start(env.apb_agent.apb_seqr);

     interrupt_enable_seq.scenario = 4;
      interrupt_enable_seq.start(env.axi_agent.axi_seqr);

    interrupt_enable_seq.scenario = 5;
      interrupt_enable_seq.start(env.axi_agent.axi_seqr);
 
       phase.phase_done.set_drain_time(this,300000);

    phase.drop_objection(this);
endtask

endclass

