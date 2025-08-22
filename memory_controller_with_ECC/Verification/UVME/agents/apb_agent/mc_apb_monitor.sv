class mc_apb_monitor extends uvm_monitor;

    `uvm_component_utils(mc_apb_monitor)

    virtual mc_apb_interface apb_intf;
    mc_apb_seq_item apb_seq_item;
    
    // Analysis port to send transactions to the scoreboard
    uvm_analysis_port #(mc_apb_seq_item) analysis_port;
    

    //constructor
    function new (string name ="mc_apb_monitor", uvm_component parent =null);
        super.new(name, parent);
        `uvm_info("apb_Monitor_class", "Inside Constructor!", UVM_MEDIUM)
    endfunction

    //build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        analysis_port = new("analysis_port", this);
        `uvm_info("APB_Monitor_class", "Inside Build Phase!", UVM_MEDIUM)

    if (!uvm_config_db#(virtual mc_apb_interface)::get(this, "", "mc_apb_interface", apb_intf)) 
        begin
            `uvm_fatal(get_full_name(), "Error while getting read interface from top apb monitor")
        end    
    endfunction

    //run phase
    task run_phase(uvm_phase phase);
        super.run_phase(phase);

        fork
            forever begin
               @(posedge apb_intf.zmc_top_clk);
                  //if(apb_intf.i_psel && apb_intf.i_penable && apb_intf.zmc_top_rstn) begin
                  //if(apb_intf.i_psel && apb_intf.zmc_top_rstn) begin

                  apb_seq_item = mc_apb_seq_item::type_id::create("apb_seq_item",this);
                  
                  apb_seq_item.i_paddr  = apb_intf.mc_apb_monitor_cb.i_paddr;
                  apb_seq_item.i_pwrite = apb_intf.mc_apb_monitor_cb.i_pwrite;
                  apb_seq_item.i_pstrb  = apb_intf.mc_apb_monitor_cb.i_pstrb;
                  apb_seq_item.i_psel   =  apb_intf.mc_apb_monitor_cb.i_psel;
                  apb_seq_item.i_penable =apb_intf.mc_apb_monitor_cb.i_penable;
                  apb_seq_item.zmc_top_rstn = apb_intf.mc_apb_monitor_cb.zmc_top_rstn;

                  apb_seq_item.i_ECC_STAUS_REG_clear = apb_intf.mc_apb_monitor_cb.i_ECC_STAUS_REG_clear;
                      
                      if (apb_intf.i_pwrite)
                       begin
                        apb_seq_item.i_pwdata = apb_intf.i_pwdata;
                        @(posedge apb_intf.zmc_top_clk);
                        `uvm_info("MON", $sformatf("Mode : Write WDATA : %h ADDR : %0d", apb_intf.mc_apb_monitor_cb.i_pwdata, apb_intf.mc_apb_monitor_cb.i_paddr), UVM_NONE);
                       end
                       analysis_port.write(apb_seq_item);
                //end 
            end
        join_none
    endtask 
 
endclass
