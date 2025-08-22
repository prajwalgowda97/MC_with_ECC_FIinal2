class mc_apb_agent extends uvm_agent;
    //factory registration
    `uvm_component_utils(mc_apb_agent)

    //creating driver, monitor & sequencer handle
    mc_apb_driver apb_drv;
    mc_apb_monitor apb_mon;
    mc_apb_sequencer apb_seqr;

    //constructor
    function new (string name = "mc_apb_agent", uvm_component parent=null);
      super.new(name, parent);
      `uvm_info("apb_agent_class", "Inside constructor!", UVM_MEDIUM)
    endfunction
    
    //build phase
    function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      apb_drv = mc_apb_driver::type_id::create("apb_drv",this);
      apb_mon = mc_apb_monitor::type_id::create("apb_mon",this);
      apb_seqr = mc_apb_sequencer::type_id::create("apb_seqr",this);
      `uvm_info("apb_agent_class", "Inside Build Phase!", UVM_MEDIUM)
    endfunction
    
    //connect phase
    function void connect_phase (uvm_phase phase);
      super.connect_phase(phase);
      apb_drv.seq_item_port.connect(apb_seqr.seq_item_export);
      `uvm_info("apb_agent_class", "Inside Connect Phase!", UVM_MEDIUM)
    endfunction

endclass
