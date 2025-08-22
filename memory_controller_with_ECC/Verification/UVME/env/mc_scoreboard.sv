class mc_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(mc_scoreboard)

// Analysis FIFOs
    uvm_tlm_analysis_fifo #(mc_axi_seq_item) axi_fifo;
    uvm_tlm_analysis_fifo #(mc_apb_seq_item) apb_fifo;

 
    bit [31:0] reference_mem_queue[$];
// ECC Registers
    bit[31:0]    o_ECC_STAUS_REG_ECC_STAUS;            
    logic[31:0]  o_ECC_EN_IRQ_REG_ECC_EN_IRQ_REG;     
    logic[31:0]  o_ECC_ONOFF_REG_ECC_ONOFF_REG;        
    int i;
    int num_writes, num_reads, num_single_bit_errors, num_double_bit_errors;

    logic [31:0] signal_value;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

  	function void build_phase(uvm_phase phase);
  	    axi_fifo = new("axi_fifo", this);
        apb_fifo = new("apb_fifo", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        mc_axi_seq_item axi_seq_item;
        mc_apb_seq_item apb_seq_item;
  
    fork
        forever begin
             axi_seq_item = mc_axi_seq_item::type_id::create("axi_seq_item");
             `uvm_info("SBD axi_seq_item SIGNALS",$sformatf("sbd axi_seq_item"),UVM_LOW)
      
             axi_fifo.get(axi_seq_item);
             check_axi_transfer(axi_seq_item, apb_seq_item);

            `uvm_info("SCB_DEBUG", $sformatf("Received AXI apb_seq_item: Addr=%h, Data=%p, wr_rd=%b", axi_seq_item.awaddr, axi_seq_item.wdata, axi_seq_item.wr_rd), UVM_MEDIUM)
             axi_seq_item.print();
        end

        forever begin
             apb_seq_item = mc_apb_seq_item::type_id::create("apb_seq_item");
             `uvm_info("SBD apb_seq_item SIGNALS",$sformatf("sbd apb_seq_item"),UVM_LOW)

             apb_fifo.get(apb_seq_item);
             check_apb_transfer(apb_seq_item);
        end      
    join_any
        disable fork;
    endtask

// AXI Transfer Check
    virtual function void check_axi_transfer(mc_axi_seq_item axi_seq_item, mc_apb_seq_item apb_seq_item);
        bit [31:0] addr = axi_seq_item.awaddr;
        bit [31:0] expected_data;
    
    if(addr >= 0 && addr < reference_mem_queue.size()) begin   
        expected_data = reference_mem_queue[addr];
    end else begin
        expected_data = '0; 
    end

    if(axi_seq_item.wr_rd) begin
        reference_mem_queue[addr] = axi_seq_item.wdata[0];
     
    // reference_mem_queue.push_back(axi_seq_item.wdata);
    num_writes++;
        `uvm_info("SCB_DEBUG", $sformatf("AXI Write: Addr=%h, Data=%p, Total Writes=%0d", axi_seq_item.awaddr, axi_seq_item.wdata, num_writes), UVM_MEDIUM)
    end else begin
    
    num_reads++;
        `uvm_info("SCB_DEBUG", $sformatf("AXI Read: Addr=%h, Data=%p, Total Reads=%0d", axi_seq_item.araddr, axi_seq_item.wdata, num_reads), UVM_MEDIUM)
    
    if(o_ECC_ONOFF_REG_ECC_ONOFF_REG[0]) begin
        `uvm_info("INSIDE AXI CASE ",$sformatf("o_ECC_ONOFF_REG_ECC_ONOFF_REG[31:0]=%h",o_ECC_ONOFF_REG_ECC_ONOFF_REG[31:0]),UVM_LOW)
        uvm_hdl_read("zmc_top.dut.mem_ctrl_inst.CSR_registers_inst.o_ECC_STAUS_REG_ECC_STATUS[31:0]", signal_value);

    if(signal_value!==32'h00000000) begin
        `uvm_info("INSIDE AXI CASE ",$sformatf("o_ECC_STAUS_REG_ECC_STAUS[31:0]=%h",o_ECC_STAUS_REG_ECC_STAUS[31:0]),UVM_LOW)
        uvm_hdl_read("zmc_top.dut.mem_ctrl_inst.CSR_registers_inst.o_ECC_STAUS_REG_ECC_STATUS[31:0]", signal_value);
        
    case (signal_value[31:0])
    32'h0000_0000: begin // No Error
        if($size(axi_seq_item.wdata) > 0 && axi_seq_item.wdata[0] !== expected_data)
            `uvm_error("SCRB", $sformatf("No Error Mismatch. Addr: %h, Expected: %h, Got: %h", addr, expected_data, axi_seq_item.wdata[0]))
        end

    32'h0000_0001: begin // Single-Bit Error
        `uvm_info("INSIDE AXI CASE ",$sformatf("o_ECC_STAUS_REG_ECC_STAUS[31:0]=%h",o_ECC_STAUS_REG_ECC_STAUS[31:0]),UVM_LOW)    
    num_single_bit_errors++;

        if($size(axi_seq_item.wdata) > 0 && axi_seq_item.wdata[0] === expected_data)
            `uvm_info("SCRB", "Single-bit error corrected recognized!",UVM_LOW)
        end
          
    32'h0000_0002: begin // Double-Bit Error Detected, ECC Interrupt Must Be Triggered
    num_double_bit_errors++;  // Ensure the count increases
    
        if (!axi_seq_item.ECC_interrupt) begin
            `uvm_error("SCRB", "ECC interrupt not triggered for double-bit error!")
        end                         
    
        if ($size(axi_seq_item.wdata) > 0) begin
            if (axi_seq_item.wdata[0] === expected_data) begin
                `uvm_error("SCRB", "Double-bit error detected but data was corrected incorrectly!")
            end else begin
                `uvm_info("SCRB", $sformatf("Double-bit error detected! Addr: %h, Written: %h, Read: %h",addr, expected_data, axi_seq_item.wdata[0]), UVM_LOW)
            end
        end
        end
    endcase
    end
    end else begin
       // if (axi_seq_item.wdata !== expected_data)
        if ($size(axi_seq_item.wdata) > 0 && axi_seq_item.wdata[0] !== expected_data)
            `uvm_info("SCRB", "ECC disabled: Read mismatch!",UVM_LOW)
        end
    end
    endfunction

    virtual function void check_apb_transfer(mc_apb_seq_item apb_seq_item);
    bit [31:0] prev_value;
    
    case (apb_seq_item.i_paddr)
    10'h00: begin // ECC Status Register
        prev_value = o_ECC_STAUS_REG_ECC_STAUS;
        o_ECC_STAUS_REG_ECC_STAUS  = apb_seq_item.i_pwdata;
        `uvm_info("SCRB", $sformatf("APB Write: ECC_STATUS_REG updated from %h to %h", prev_value, apb_seq_item.i_pwdata), UVM_MEDIUM)
    end

    10'h04: begin // ECC Interrupt Enable Register
        prev_value = o_ECC_EN_IRQ_REG_ECC_EN_IRQ_REG;
        o_ECC_EN_IRQ_REG_ECC_EN_IRQ_REG  = apb_seq_item.i_pwdata;
        `uvm_info("SCRB", $sformatf("APB Write: ECC_EN_IRQ_REG updated from %h to %h", prev_value, apb_seq_item.i_pwdata), UVM_MEDIUM)
    end

    10'h08: begin // ECC ON/OFF Register
        prev_value = o_ECC_ONOFF_REG_ECC_ONOFF_REG;
        o_ECC_ONOFF_REG_ECC_ONOFF_REG  = apb_seq_item.i_pwdata;
        `uvm_info("SCRB", $sformatf("APB Write: ECC_ONOFF_REG updated from %h to %h", prev_value, apb_seq_item.i_pwdata), UVM_MEDIUM)
    end

    default: `uvm_error("SCRB", $sformatf("Invalid register address: %h", apb_seq_item.i_paddr))
    endcase
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SCRB_REPORT", $sformatf("\n=== Scoreboard Report ===\nTotal Writes: %0d\nTotal Reads: %0d\nSingle Bit Errors: %0d\nDouble Bit Errors: %0d", num_writes, num_reads, num_single_bit_errors, num_double_bit_errors), UVM_LOW)
    endfunction

endclass
