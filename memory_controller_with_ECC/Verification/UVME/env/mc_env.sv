class mc_env extends uvm_env;

  //factory registration
  `uvm_component_utils(mc_env)

  //creating agent handle
  mc_apb_agent apb_agent;
  mc_axi_agent axi_agent;
  ral_adapter adapter_inst;
  mc_register_block regmodel;
  uvm_reg_predictor #(mc_apb_seq_item)  predictor_inst;
  mc_scoreboard sbd;
  mc_coverage_collector1 cov1;
  mc_coverage_collector2 cov2;

  //constructor
  function new(string name = "mc_env",uvm_component parent=null);
    super.new(name,parent);
    `uvm_info("env_class", "Inside constructor!", UVM_MEDIUM)
  endfunction

  //build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    apb_agent = mc_apb_agent::type_id::create("apb_agent",this); 
    axi_agent = mc_axi_agent::type_id::create("axi_agent",this); 
    sbd       = mc_scoreboard::type_id::create("sbd", this);
	cov1      = mc_coverage_collector1::type_id::create("cov1",this);
    cov2      = mc_coverage_collector2::type_id::create("cov2",this);

      regmodel = mc_register_block::type_id::create("regmodel",this);
        if (regmodel == null) begin
           `uvm_fatal("SEQ", "Register model handle is null")
        end else begin
        regmodel.build();
            `uvm_info("SEQ", $sformatf("Register model handle is valid: %s", regmodel.get_name()), UVM_NONE)
        end
           adapter_inst = ral_adapter::type_id::create("adapter_inst",this);
           predictor_inst = uvm_reg_predictor#(mc_apb_seq_item)::type_id::create("predictor_inst", this);
   
   `uvm_info("env_class", "Inside Build Phase!", UVM_MEDIUM)
  endfunction

  //connect phase
  function void connect_phase(uvm_phase phase);
           axi_agent.axi_mon.analysis_port.connect(sbd.axi_fifo.analysis_export);
           apb_agent.apb_mon.analysis_port.connect(sbd.apb_fifo.analysis_export);
           
           axi_agent.axi_mon.analysis_port.connect(cov1.analysis_export); 
  		   apb_agent.apb_mon.analysis_port.connect(cov2.analysis_export);
           
           regmodel.default_map.set_sequencer(apb_agent.apb_seqr, adapter_inst);
           regmodel.default_map.set_base_addr(0);
          
           apb_agent.apb_mon.analysis_port.connect(predictor_inst.bus_in);
           predictor_inst.map       = regmodel.default_map;
           predictor_inst.adapter   = adapter_inst; 
  endfunction

endclass

