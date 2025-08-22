class mc_double_bit_error_injection_test extends mc_base_test;

  // Factory registration
  `uvm_component_utils(mc_double_bit_error_injection_test)
  mc_double_bit_error_injection_sequence double_bit_error_injection_seq;
  mc_ral_double_bit_error_injection_sequence ral_double_bit_error_injection_seq;

  // Constructor
  function new(string name = "mc_double_bit_error_injection_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    double_bit_error_injection_seq = mc_double_bit_error_injection_sequence::type_id::create("double_bit_error_injection_seq",this);
    ral_double_bit_error_injection_seq = mc_ral_double_bit_error_injection_sequence::type_id::create("ral_double_bit_error_injection_seq", this);
    
  endfunction

  // Run Phase
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_full_name(), $sformatf("Inside the double_bit_error_injection test"), UVM_MEDIUM)

    ral_double_bit_error_injection_seq.regmodel = env.regmodel;

   
    double_bit_error_injection_seq.scenario = 1;
      double_bit_error_injection_seq.start(env.axi_agent.axi_seqr);
   
    double_bit_error_injection_seq.scenario = 2;
      double_bit_error_injection_seq.start(env.axi_agent.axi_seqr);
 
    ral_double_bit_error_injection_seq.scenario = 3;
      ral_double_bit_error_injection_seq.start(env.apb_agent.apb_seqr);

     double_bit_error_injection_seq.scenario = 4;
      double_bit_error_injection_seq.start(env.axi_agent.axi_seqr);

    double_bit_error_injection_seq.scenario = 5;
      double_bit_error_injection_seq.start(env.axi_agent.axi_seqr);
 
       phase.phase_done.set_drain_time(this,300000);

    phase.drop_objection(this);
endtask

endclass

