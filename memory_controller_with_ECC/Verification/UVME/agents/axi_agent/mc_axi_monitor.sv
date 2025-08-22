class mc_axi_monitor extends uvm_monitor;

    `uvm_component_utils(mc_axi_monitor)

    virtual mc_interface intf;
    mc_axi_seq_item axi_seq_item;
    
    // Analysis port to send transactions to the scoreboard
    uvm_analysis_port #(mc_axi_seq_item) analysis_port;
    uvm_analysis_port #(mc_axi_seq_item) wr_analysis_port;
    uvm_analysis_port #(mc_axi_seq_item) rd_analysis_port;
    
    // Flag to trigger initial sampling
        bit first_sample = 1;

//constructor
    function new (string name ="mc_axi_monitor", uvm_component parent =null);
        super.new(name, parent);
        `uvm_info("AXI_Monitor_class", "Inside Constructor!", UVM_MEDIUM)
    endfunction

    //build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_port    = new("analysis_port", this);
        wr_analysis_port = new("wr_analysis_port", this);
        rd_analysis_port = new("rd_analysis_port", this);

        `uvm_info("AXI_Monitor_class", "Inside Build Phase!", UVM_MEDIUM)
        if (!uvm_config_db#(virtual mc_interface)::get(this, "", "mc_interface", intf)) 
        begin
            `uvm_fatal(get_full_name(), "Error while getting read interface from top axi monitor")
        end

    endfunction

//run phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);

    if (first_sample) begin
        axi_seq_item=mc_axi_seq_item ::type_id::create("axi_seq_item");

        axi_seq_item.zmc_top_sw_rst        = intf.mc_monitor_cb.zmc_top_sw_rst;
        axi_seq_item.zmc_top_rstn          = intf.mc_monitor_cb.zmc_top_rstn;
        axi_seq_item.zmc_top_mem_init      = intf.mc_monitor_cb.zmc_top_mem_init;
        axi_seq_item.ECC_interrupt         = intf.mc_monitor_cb.ECC_interrupt;
        axi_seq_item.MEM_init_ACK          = intf.mc_monitor_cb.MEM_init_ACK;
        axi_seq_item.o_ECC_STAUS_REG       = intf.mc_monitor_cb.o_ECC_STAUS_REG;
        axi_seq_item.awvalid               = intf.mc_monitor_cb.awvalid;
        axi_seq_item.awready               = intf.mc_monitor_cb.awready;
        axi_seq_item.wvalid                = intf.mc_monitor_cb.wvalid;
        axi_seq_item.wready                = intf.mc_monitor_cb.wready;
        axi_seq_item.bvalid                = intf.mc_monitor_cb.bvalid;
        axi_seq_item.bready                = intf.mc_monitor_cb.bready;
        axi_seq_item.arvalid               = intf.mc_monitor_cb.arvalid;
        axi_seq_item.arready               = intf.mc_monitor_cb.arready;
        axi_seq_item.rvalid                = intf.mc_monitor_cb.rvalid;
        axi_seq_item.rready                = intf.mc_monitor_cb.rready;
        
        analysis_port.write(axi_seq_item);

    end

    begin
        axi_seq_item=mc_axi_seq_item ::type_id::create("axi_seq_item");

        forever begin
        @(posedge intf.zmc_top_clk);

        axi_seq_item.zmc_top_sw_rst        = intf.mc_monitor_cb.zmc_top_sw_rst;
        axi_seq_item.zmc_top_rstn          = intf.mc_monitor_cb.zmc_top_rstn;
        axi_seq_item.zmc_top_mem_init      = intf.mc_monitor_cb.zmc_top_mem_init;
        axi_seq_item.ECC_interrupt         = intf.mc_monitor_cb.ECC_interrupt;
        axi_seq_item.MEM_init_ACK          = intf.mc_monitor_cb.MEM_init_ACK;
        axi_seq_item.o_ECC_STAUS_REG       = intf.mc_monitor_cb.o_ECC_STAUS_REG;

// Wait for valid and handshake
    if (intf.mc_monitor_cb.awvalid && intf.mc_monitor_cb.awready) begin
        axi_seq_item.wr_rd                 = 1;
        axi_seq_item.awaddr                = intf.mc_monitor_cb.awaddr;
        axi_seq_item.awburst               = intf.mc_monitor_cb.awburst;
        axi_seq_item.awlen                 = intf.mc_monitor_cb.awlen;
        axi_seq_item.awvalid               = intf.mc_monitor_cb.awvalid;
        axi_seq_item.awready               = intf.mc_monitor_cb.awready;

        `uvm_info("ZMC_MON_INFO",  $sformatf("WRITE ADDR | Addr: 0x%h, Burst: %b, Length: %0d",  axi_seq_item.awaddr, axi_seq_item.awburst, axi_seq_item.awlen), UVM_LOW)
    end

//write data channel
      if (intf.mc_monitor_cb.wvalid && intf.mc_monitor_cb.wready) begin
        axi_seq_item.wdata.push_back(intf.mc_monitor_cb.wdata);
        axi_seq_item.wstrb                 = intf.mc_monitor_cb.wstrb;
        axi_seq_item.wlast                 = intf.mc_monitor_cb.wlast;
        axi_seq_item.wvalid                = intf.mc_monitor_cb.wvalid;
        axi_seq_item.wready                = intf.mc_monitor_cb.wready;
       
       `uvm_info("ZMC_MON_INFO",  $sformatf("WRITE DATA | Data: %p, Strb: 0x%h, WLAST: %b",  axi_seq_item.wdata, axi_seq_item.wstrb, axi_seq_item.wlast),  UVM_LOW)
      end

//write response
      if (intf.mc_monitor_cb.bvalid && intf.mc_monitor_cb.bready) begin
        axi_seq_item.bresp  = intf.mc_monitor_cb.bresp;
        axi_seq_item.bvalid = intf.mc_monitor_cb.bvalid;
        axi_seq_item.bready = intf.mc_monitor_cb.bready;
       
        `uvm_info("ZMC_MON_INFO", $sformatf("WRITE RESPONSE | BRESP: %b", axi_seq_item.bresp),  UVM_LOW)              
        
        analysis_port.write(axi_seq_item);
        `uvm_info(get_type_name(), $sformatf("FIFO Size: %0d", analysis_port.size()), UVM_MEDIUM)

       `uvm_info("ZMC_MON_INFO", $sformatf("WRITE RESPONSE | BRESP: %b", axi_seq_item.bresp),  UVM_LOW)
      end

//read adress channel
      if (intf.mc_monitor_cb.arvalid && intf.mc_monitor_cb.arready) begin
        axi_seq_item.wr_rd                 = 0;
        axi_seq_item.araddr                = intf.mc_monitor_cb.araddr;
        axi_seq_item.arburst               = intf.mc_monitor_cb.arburst;
        axi_seq_item.arlen                 = intf.mc_monitor_cb.arlen;
        axi_seq_item.arvalid               = intf.mc_monitor_cb.arvalid;
        axi_seq_item.arready               = intf.mc_monitor_cb.arready;
       
       `uvm_info("ZMC_MON_INFO",  $sformatf("READ ADDR | Addr: 0x%h, Burst: %b, Length: %0d",  axi_seq_item.araddr, axi_seq_item.arburst, axi_seq_item.arlen), UVM_LOW)
      end               

//read data channel
      if (intf.mc_monitor_cb.rvalid && intf.mc_monitor_cb.rready) begin
        axi_seq_item.rdata.push_back( intf.mc_monitor_cb.rdata);
        axi_seq_item.rlast                 = intf.mc_monitor_cb.rlast;
        axi_seq_item.rresp                 = intf.mc_monitor_cb.rresp;
        axi_seq_item.rvalid                = intf.mc_monitor_cb.rvalid;
        axi_seq_item.rready                = intf.mc_monitor_cb.rready;
        
        `uvm_info("ZMC_MON_INFO",  $sformatf("READ DATA | Data:%p, RLAST: %0b, RRESP: %b",  axi_seq_item.rdata, axi_seq_item.rlast, axi_seq_item.rresp),  UVM_LOW)
        
        analysis_port.write(axi_seq_item);
        `uvm_info("ZMC_MON_INFO",  $sformatf("READ DATA | Data:%p, RLAST: %0b, RRESP: %b",  axi_seq_item.rdata, axi_seq_item.rlast, axi_seq_item.rresp),  UVM_LOW)
      end
      end    
      end

    endtask

endclass
