/*class mc_ecc_disable_test extends mc_base_test;

  // Factory registration
  `uvm_component_utils(mc_ecc_disable_test)
  mc_ecc_disable_sequence ecc_disable_seq;

  // Constructor
  function new(string name = "mc_ecc_disable_test", uvm_component parent = null);
    super.new(name, parent);
    ecc_disable_seq = mc_ecc_disable_sequence::type_id::create("ecc_disable_seq");
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // Run Phase
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_full_name(), $sformatf("Inside the ecc_disable test"), UVM_MEDIUM)

      ecc_disable_seq.scenario = 1;
      ecc_disable_seq.start(env.axi_agent.axi_seqr);
    `uvm_info(get_type_name(),$sformatf("ecc_disable scenario 1 is competed"),UVM_MEDIUM)

     ecc_disable_seq.scenario = 2;
      ecc_disable_seq.start(env.axi_agent.axi_seqr);
    `uvm_info(get_type_name(),$sformatf("ecc_disable scenario 2 is competed"),UVM_MEDIUM)      

    ecc_disable_seq.scenario = 3;
      ecc_disable_seq.start(env.axi_agent.axi_seqr);
    `uvm_info(get_type_name(),$sformatf("ecc_disable scenario 3 is competed"),UVM_MEDIUM)      


    phase.phase_done.set_drain_time(this,300000);

    phase.drop_objection(this);
endtask

endclass */

class mc_ecc_disable_test extends mc_base_test;

  // Factory registration
  `uvm_component_utils(mc_ecc_disable_test)
  mc_ecc_disable_sequence ecc_disable_seq;
  mc_ral_ecc_disable_sequence ral_ecc_disable_seq;

  // Constructor
  function new(string name = "mc_ecc_disable_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ecc_disable_seq = mc_ecc_disable_sequence::type_id::create("ecc_disable_seq",this);
    ral_ecc_disable_seq = mc_ral_ecc_disable_sequence::type_id::create("ral_ecc_disable_seq", this);
    
  endfunction

  // Run Phase
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_full_name(), $sformatf("Inside the ecc_disable test"), UVM_MEDIUM)

    ral_ecc_disable_seq.regmodel = env.regmodel;

      ecc_disable_seq.scenario = 1;
      ecc_disable_seq.start(env.axi_agent.axi_seqr);
    `uvm_info(get_type_name(),$sformatf("ecc_disable scenario 1 is competed"),UVM_MEDIUM)

     ecc_disable_seq.scenario = 2;
      ecc_disable_seq.start(env.axi_agent.axi_seqr);
    `uvm_info(get_type_name(),$sformatf("ecc_disable scenario 2 is competed"),UVM_MEDIUM)      

    ecc_disable_seq.scenario = 3;
      ecc_disable_seq.start(env.axi_agent.axi_seqr);
    `uvm_info(get_type_name(),$sformatf("ecc_disable scenario 3 is competed"),UVM_MEDIUM)      

    ral_ecc_disable_seq.scenario = 3;
      ral_ecc_disable_seq.start(env.apb_agent.apb_seqr);
    `uvm_info(get_type_name(),$sformatf("ecc_disable ral scenario 3 is competed"),UVM_MEDIUM)  

    phase.phase_done.set_drain_time(this,300000);

    phase.drop_objection(this);
endtask

endclass


