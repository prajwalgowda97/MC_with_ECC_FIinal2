/*`include "uvm_macros.svh"

class mc_ral_single_bit_error_injection_sequence extends uvm_sequence;
  `uvm_object_utils(mc_ral_single_bit_error_injection_sequence)

  // RAL block handle (set from test)
  mc_register_block regmodel;
  int               scenario;

  // Storage for addresses where single bit errors will be injected
  bit [31:0]        error_injection_addrs[$];

  // Constructor
  function new(string name = "mc_ral_single_bit_error_injection_sequence");
    super.new(name);
  endfunction

  // Body phase
  task body();
    uvm_status_e     status;
    uvm_reg_data_t   rdata2;

    // Scenario 3: Enable ECC and interrupt
    if (scenario == 3) begin
      if (regmodel == null) begin
        `uvm_fatal("SEQ", "Register model handle is null")
        return;
      end

      `uvm_info("RAL_SEQ", "Scenario 3: Configuring ECC to enable mode", UVM_MEDIUM)
      // Write 1 to enable ECC (adjust field/register name if your regmodel uses different names)
      regmodel.o_ecc_onoff_reg_ecc_onoff_reg.write(status, 32'h00000001);
      if (status != UVM_IS_OK) begin
        `uvm_error("SEQ", $sformatf("Frontdoor write failed with status=%s", status.name()))
        return;
      end

      `uvm_info("RAL_SEQ", "Configuring ECC interrupt to ENABLE mode", UVM_MEDIUM)
      regmodel.o_ecc_en_irq_reg_ecc_en_irq_reg.write(status, 32'h00000001);
      if (status != UVM_IS_OK) begin
        `uvm_error("SEQ", $sformatf("Frontdoor write failed with status=%s", status.name()))
        return;
      end

      #10;
      regmodel.o_ecc_staus_reg_ecc_staus.read(status, rdata2);
      if (status != UVM_IS_OK) begin
        `uvm_error("SEQ", $sformatf("Register read failed with status=%s", status.name()))
        return;
      end
      `uvm_info("RAL_SEQ", $sformatf("ECC Status Register Value: 0x%08x", rdata2), UVM_MEDIUM)
    end

    // Scenario 4: Inject single-bit errors using backdoor
    if (scenario == 4) begin
      if (regmodel == null) begin
        `uvm_fatal("SEQ", "Register model handle is null")
        return;
      end

      `uvm_info("RAL_SEQ", "Scenario 4: Injecting single bit errors into memory", UVM_MEDIUM)

      foreach (error_injection_addrs[i]) begin
        `uvm_info("RAL_SEQ", $sformatf("Injecting single bit error at address: 0x%08x", error_injection_addrs[i]), UVM_MEDIUM)
        inject_single_bit_error(error_injection_addrs[i]);
        #1000; // small delay between injections
      end

      `uvm_info("RAL_SEQ", "Single bit error injection completed", UVM_MEDIUM)
    end

    // Scenario 6: Check ECC status after injection
    if (scenario == 6) begin
      if (regmodel == null) begin
        `uvm_fatal("SEQ", "Register model handle is null")
        return;
      end

      `uvm_info("RAL_SEQ", "Scenario 6: Checking ECC status after error injection", UVM_MEDIUM)
      #50;
      regmodel.o_ecc_staus_reg_ecc_staus.read(status, rdata2);
      if (status != UVM_IS_OK) begin
        `uvm_error("RAL_SEQ", $sformatf("Register read failed with status=%s", status.name()))
        return;
      end

      case (rdata2[1:0])
        2'b00: `uvm_info("RAL_SEQ", "ECC Status: NO ERROR detected", UVM_MEDIUM)
        2'b01: begin
                 `uvm_info("RAL_SEQ", "ECC Status: SINGLE BIT ERROR detected and corrected", UVM_MEDIUM)
                 `uvm_info("RAL_SEQ", "Single bit error injection test PASSED", UVM_LOW)
               end
        2'b10: `uvm_error("RAL_SEQ", "ECC Status: DOUBLE BIT ERROR detected - Unexpected!")
        default: `uvm_error("RAL_SEQ", $sformatf("ECC Status: Unknown status 0x%02x", rdata2[1:0]))
      endcase

      `uvm_info("RAL_SEQ", $sformatf("Full ECC Status Register Value: 0x%08x", rdata2), UVM_MEDIUM)

      `uvm_info("RAL_SEQ", "Clearing ECC status register", UVM_MEDIUM)
      regmodel.o_ecc_staus_reg_ecc_staus.write(status, 32'h00000000);
      if (status != UVM_IS_OK) begin
        `uvm_error("RAL_SEQ", $sformatf("ECC status clear write failed with status=%s", status.name()))
      end
    end
  endtask

  // Robust backdoor injection task - FIXED VERSION
  virtual task inject_single_bit_error(bit [31:0] addr);
    bit [31:0] original_data;
    bit [31:0] corrupted_data;
    int        bit_to_flip;
    string     mem_path;
    int        mem_index;
    string     possible_paths[$];
    bit        path_found;

    // Choose a random bit to flip in 32-bit word
    bit_to_flip = $urandom_range(0, 31);

    // Word index calculation - ensure proper alignment
    // If addresses are byte-addressed, divide by 4 for 32-bit words
    if (addr[1:0] != 2'b00) begin
      `uvm_warning("RAL_SEQ", $sformatf("Address 0x%08x is not 32-bit aligned, aligning to 0x%08x", 
                                       addr, {addr[31:2], 2'b00}))
      addr = {addr[31:2], 2'b00};
    end
    mem_index = addr >> 2;

    // Add bounds checking for reasonable memory sizes
    if (mem_index > 32'h100000) begin  // Adjust this limit based on your memory size
      `uvm_error("RAL_SEQ", $sformatf("Memory index %0d (addr=0x%08x) exceeds reasonable bounds", mem_index, addr))
      return;
    end

    // Updated possible paths - customize these to match YOUR testbench hierarchy
    possible_paths.delete();
    
    // Common testbench hierarchies - ADD/MODIFY based on your actual TB structure
    possible_paths.push_back($sformatf("uvm_test_top.env.dut.mem_inst.memory[%0d]", mem_index));
    possible_paths.push_back($sformatf("uvm_test_top.env.dut.u_memory.mem_array[%0d]", mem_index));
    possible_paths.push_back($sformatf("uvm_test_top.env.dut.memory[%0d]", mem_index));
    possible_paths.push_back($sformatf("uvm_test_top.env.mc_agent.dut.mem_inst.memory[%0d]", mem_index));
    possible_paths.push_back($sformatf("tb_top.dut.mem_inst.memory[%0d]", mem_index));
    possible_paths.push_back($sformatf("tb_top.dut.u_memory.mem_array[%0d]", mem_index));
    possible_paths.push_back($sformatf("tb_top.dut.memory[%0d]", mem_index));
    possible_paths.push_back($sformatf("top.dut.mem_inst.memory[%0d]", mem_index));
    possible_paths.push_back($sformatf("dut.mem_inst.memory[%0d]", mem_index));
    possible_paths.push_back($sformatf("dut.u_memory.mem_array[%0d]", mem_index));
    possible_paths.push_back($sformatf("mem_inst.memory[%0d]", mem_index));
    possible_paths.push_back($sformatf("memory[%0d]", mem_index));
    
    // Try different memory array names
    possible_paths.push_back($sformatf("uvm_test_top.env.dut.mem_inst.mem[%0d]", mem_index));
    possible_paths.push_back($sformatf("tb_top.dut.mem_inst.mem[%0d]", mem_index));
    possible_paths.push_back($sformatf("dut.mem_inst.mem[%0d]", mem_index));
    
    path_found = 0;

    foreach (possible_paths[i]) begin
      mem_path = possible_paths[i];
      `uvm_info("RAL_SEQ", $sformatf("Trying memory path [%0d/%0d]: %s", i+1, possible_paths.size(), mem_path), UVM_HIGH)

      // Try to read via HDL backdoor. uvm_hdl_read returns 1 on success.
      if (uvm_hdl_read(mem_path, original_data)) begin
        `uvm_info("RAL_SEQ", $sformatf("SUCCESS: Found memory at path: %s, data=0x%08x", mem_path, original_data), UVM_MEDIUM)
        path_found = 1;
        break;
      end else begin
        `uvm_info("RAL_SEQ", $sformatf("FAILED: Cannot access memory at path: %s", mem_path), UVM_HIGH)
      end
    end

    if (!path_found) begin
      `uvm_error("RAL_SEQ", $sformatf("CRITICAL: Failed to find valid memory path for address: 0x%08x (index=%0d)", addr, mem_index))
      `uvm_error("RAL_SEQ", "Please verify your memory hierarchy and update possible_paths array")
      return;
    end

    // Flip the selected bit to create single bit error
    corrupted_data = original_data ^ (32'h1 << bit_to_flip);

    `uvm_info("RAL_SEQ", $sformatf("Error Injection Details: Addr=0x%08x, Index=%0d, Original=0x%08x, Corrupted=0x%08x, Flipped_bit=%0d",
               addr, mem_index, original_data, corrupted_data, bit_to_flip), UVM_MEDIUM)

    // Force corrupted data back into RTL
    if (!uvm_hdl_force(mem_path, corrupted_data)) begin
      `uvm_error("RAL_SEQ", $sformatf("Failed to force corrupted data to memory at path: %s", mem_path))
      return;
    end

    `uvm_info("RAL_SEQ", $sformatf("SUCCESS: Single bit error injected at address 0x%08x (path=%s)", addr, mem_path), UVM_MEDIUM)
    
    // Optional: Read back to verify injection
    begin
      bit [31:0] readback_data;
      if (uvm_hdl_read(mem_path, readback_data)) begin
        if (readback_data == corrupted_data) begin
          `uvm_info("RAL_SEQ", $sformatf("VERIFIED: Corrupted data successfully written: 0x%08x", readback_data), UVM_HIGH)
        end else begin
          `uvm_warning("RAL_SEQ", $sformatf("WARNING: Readback data mismatch. Expected=0x%08x, Got=0x%08x", corrupted_data, readback_data))
        end
      end
    end
  endtask

  // Add/clear helper functions
  function void add_error_injection_addr(bit [31:0] addr);
    error_injection_addrs.push_back(addr);
    `uvm_info("RAL_SEQ", $sformatf("Added address 0x%08x for error injection (total=%0d)", addr, error_injection_addrs.size()), UVM_HIGH)
  endfunction

  function void clear_error_injection_addrs();
    error_injection_addrs.delete();
    `uvm_info("RAL_SEQ", "Cleared all error injection addresses", UVM_HIGH)
  endfunction

  // Helper function to print all addresses that will be used for injection
  function void print_error_injection_addrs();
    `uvm_info("RAL_SEQ", $sformatf("Total addresses for error injection: %0d", error_injection_addrs.size()), UVM_MEDIUM)
    foreach (error_injection_addrs[i]) begin
      `uvm_info("RAL_SEQ", $sformatf("[%0d] Address: 0x%08x", i, error_injection_addrs[i]), UVM_MEDIUM)
    end
  endfunction

endclass */



class mc_ral_single_bit_error_injection_sequence extends uvm_sequence;

  // RAL block handle
  mc_register_block regmodel;

  // Scenario selector
  int scenario;

  `uvm_object_utils(mc_ral_single_bit_error_injection_sequence)

  // Constructor
  function new(string name = "mc_ral_single_bit_error_injection_sequence");
    super.new(name);
  endfunction

  // Body phase
  task body;
    uvm_status_e     status;
    uvm_reg_data_t   rdata2;

    if (scenario == 3) begin  // ECC enable Scenario

      if (regmodel == null) begin
        `uvm_fatal("SEQ", "Register model handle is null")
        return;
      end
      //ECC enable condition
      `uvm_info("RAL_SEQ", "Scenario 3: Configuring ECC to enable mode", UVM_MEDIUM)

      // Write 0 to ECC ON/OFF register to enable ECC
      regmodel.o_ecc_onoff_reg_ecc_onoff_reg.write(status, 32'h00000001);
      if (status != UVM_IS_OK) begin
        `uvm_error("SEQ", $sformatf("Frontdoor write failed with status=%s", status.name()));
        return;
      end

       //ECC interrupt  enable condition
      `uvm_info("RAL_SEQ", "Configuring ECC interrupt to ENABLE mode", UVM_MEDIUM)
      regmodel.o_ecc_en_irq_reg_ecc_en_irq_reg.write(status, 32'h00000001);      
      if (status != UVM_IS_OK) begin
      `uvm_error("SEQ", $sformatf("frontdoor write failed with status=%0s", status.name()));
        return;
      end
    #10;
      // Read ECC Status Register
      regmodel.o_ecc_staus_reg_ecc_staus.read(status, rdata2);
      if (status != UVM_IS_OK) begin
        `uvm_error("SEQ", $sformatf("Register read failed with status=%s", status.name()));
        return;
      end

      `uvm_info("RAL_SEQ", $sformatf("ECC Status Register Value: 0x%08x", rdata2), UVM_MEDIUM)

    end 

  endtask

endclass




