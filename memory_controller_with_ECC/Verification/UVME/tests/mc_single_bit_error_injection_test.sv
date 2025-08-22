/*class mc_single_bit_error_injection_test extends mc_base_test;
  // Factory registration
  `uvm_component_utils(mc_single_bit_error_injection_test)
  
  mc_single_bit_error_injection_sequence single_bit_error_injection_seq;
  mc_ral_single_bit_error_injection_sequence ral_single_bit_error_injection_seq;
  
  // Constructor
  function new(string name = "mc_single_bit_error_injection_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    single_bit_error_injection_seq = mc_single_bit_error_injection_sequence::type_id::create("single_bit_error_injection_seq", this);
    ral_single_bit_error_injection_seq = mc_ral_single_bit_error_injection_sequence::type_id::create("ral_single_bit_error_injection_seq", this);
  endfunction
  
  // Run Phase
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    
    `uvm_info(get_full_name(), "Starting single bit error injection test", UVM_MEDIUM)
    
    // Set the regmodel handle
    ral_single_bit_error_injection_seq.regmodel = env.regmodel;
    
    // Step 1: Apply reset
    `uvm_info(get_full_name(), "Step 1: Applying reset", UVM_MEDIUM)
    single_bit_error_injection_seq.scenario = 1;
    single_bit_error_injection_seq.start(env.axi_agent.axi_seqr);
    
    // Step 2: Disable reset
    `uvm_info(get_full_name(), "Step 2: Disabling reset", UVM_MEDIUM)
    single_bit_error_injection_seq.scenario = 2;
    single_bit_error_injection_seq.start(env.axi_agent.axi_seqr);
    
    // Step 3: Enable ECC
    `uvm_info(get_full_name(), "Step 3: Enabling ECC", UVM_MEDIUM)
    ral_single_bit_error_injection_seq.scenario = 3;
    ral_single_bit_error_injection_seq.start(env.apb_agent.apb_seqr);
    
    // Step 4: Write data to memory
    `uvm_info(get_full_name(), "Step 4: Writing data to memory", UVM_MEDIUM)
    single_bit_error_injection_seq.scenario = 4;
    single_bit_error_injection_seq.start(env.axi_agent.axi_seqr);
    
    // Step 5: Inject single bit errors at written addresses
    `uvm_info(get_full_name(), "Step 5: Injecting single bit errors", UVM_MEDIUM)
    // Add the addresses that were written to the error injection list
    foreach(single_bit_error_injection_seq.addr[i]) begin
      ral_single_bit_error_injection_seq.add_error_injection_addr(single_bit_error_injection_seq.addr[i]);
    end
    ral_single_bit_error_injection_seq.scenario = 4;
    ral_single_bit_error_injection_seq.start(env.apb_agent.apb_seqr);
    
    // Step 6: Read data from memory (this should trigger ECC correction)
    `uvm_info(get_full_name(), "Step 6: Reading data from memory", UVM_MEDIUM)
    single_bit_error_injection_seq.scenario = 5;
    single_bit_error_injection_seq.start(env.axi_agent.axi_seqr);
    
    // Step 7: Check ECC status
    `uvm_info(get_full_name(), "Step 7: Checking ECC status", UVM_MEDIUM)
    ral_single_bit_error_injection_seq.scenario = 6;
    ral_single_bit_error_injection_seq.start(env.apb_agent.apb_seqr);
    
    `uvm_info(get_full_name(), "Single bit error injection test completed", UVM_MEDIUM)
    
    phase.phase_done.set_drain_time(this, 300000);
    phase.drop_objection(this);
  endtask
endclass */


class mc_single_bit_error_injection_test extends mc_base_test;

  // Factory registration
  `uvm_component_utils(mc_single_bit_error_injection_test)
  mc_single_bit_error_injection_sequence single_bit_error_injection_seq;
  mc_ral_single_bit_error_injection_sequence ral_single_bit_error_injection_seq;

  // Constructor
  function new(string name = "mc_single_bit_error_injection_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build Phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    single_bit_error_injection_seq = mc_single_bit_error_injection_sequence::type_id::create("single_bit_error_injection_seq",this);
    ral_single_bit_error_injection_seq = mc_ral_single_bit_error_injection_sequence::type_id::create("ral_single_bit_error_injection_seq", this);
    
  endfunction

  // Run Phase
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info(get_full_name(), $sformatf("Inside the single_bit_error_injection test"), UVM_MEDIUM)

    ral_single_bit_error_injection_seq.regmodel = env.regmodel;

   
    single_bit_error_injection_seq.scenario = 1;
      single_bit_error_injection_seq.start(env.axi_agent.axi_seqr);
   
    single_bit_error_injection_seq.scenario = 2;
      single_bit_error_injection_seq.start(env.axi_agent.axi_seqr);

    ral_single_bit_error_injection_seq.scenario = 3;
      ral_single_bit_error_injection_seq.start(env.apb_agent.apb_seqr);

     single_bit_error_injection_seq.scenario = 4;
      single_bit_error_injection_seq.start(env.axi_agent.axi_seqr);

    single_bit_error_injection_seq.scenario = 5;
      single_bit_error_injection_seq.start(env.axi_agent.axi_seqr);
 
       phase.phase_done.set_drain_time(this,300000);

    phase.drop_objection(this);
endtask

endclass

