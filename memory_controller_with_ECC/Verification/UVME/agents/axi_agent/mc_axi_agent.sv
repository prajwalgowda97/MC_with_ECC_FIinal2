class mc_axi_agent extends uvm_agent;
    //factory registration
    `uvm_component_utils(mc_axi_agent)

    //creating driver, monitor & sequencer handle
    mc_axi_driver axi_drv;
    mc_axi_monitor axi_mon;
    mc_axi_sequencer axi_seqr;

    //constructor
    function new (string name = "mc_axi_agent", uvm_component parent=null);
      super.new(name, parent);
      `uvm_info("axi_agent_class", "Inside constructor!", UVM_MEDIUM)
    endfunction
    
    //build phase
    function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      axi_drv = mc_axi_driver::type_id::create("axi_drv",this);
      axi_mon = mc_axi_monitor::type_id::create("axi_mon",this);
      axi_seqr = mc_axi_sequencer::type_id::create("axi_seqr",this);
      `uvm_info("axi_agent_class", "Inside Build Phase!", UVM_MEDIUM)
    endfunction
    
    //connect phase
    function void connect_phase (uvm_phase phase);
      super.connect_phase(phase);
      axi_drv.seq_item_port.connect(axi_seqr.seq_item_export);
      `uvm_info("axi_agent_class", "Inside Connect Phase!", UVM_MEDIUM)
    endfunction

endclass

