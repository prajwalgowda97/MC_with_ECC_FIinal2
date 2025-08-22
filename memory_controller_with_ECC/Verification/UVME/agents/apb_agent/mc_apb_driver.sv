class mc_apb_driver extends uvm_driver #(mc_apb_seq_item);
    
    `uvm_component_utils(mc_apb_driver)

    mc_apb_seq_item apb_seq_item;
    virtual mc_apb_interface apb_intf;

    //constructor
    function new(string name="mc_apb_seq_item", uvm_component parent =null);
        super.new(name, parent);

    endfunction

    //build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        //apb_seq_item = mc_apb_seq_item::type_id::create("apb_seq_item",this);
  if(!uvm_config_db#(virtual mc_apb_interface)::get(this,"*","mc_apb_interface",apb_intf))
      `uvm_fatal(get_full_name(),"unable to get interface in read driver")
    endfunction

//run phase
    task run_phase(uvm_phase phase);
        super.run_phase (phase);
    
    forever begin
        seq_item_port.get_next_item(apb_seq_item);
       
        if(apb_seq_item.i_pwrite)
        begin
            write(apb_seq_item);
        end 

        seq_item_port.item_done();
        end
    endtask

task write(mc_apb_seq_item apb_seq_item);
  
    @(posedge apb_intf.zmc_top_clk);
    apb_intf.mc_apb_driver_cb.i_paddr   <= apb_seq_item.i_paddr;
    apb_intf.mc_apb_driver_cb.i_pwdata  <= apb_seq_item.i_pwdata;
    apb_intf.mc_apb_driver_cb.i_pwrite  <= 1'b1;
    apb_intf.mc_apb_driver_cb.i_psel    <= 1'b1;
    apb_intf.mc_apb_driver_cb.i_pstrb   <= 4'b1111;
    apb_intf.mc_apb_driver_cb.i_ECC_STAUS_REG_clear  <= 1'b0;

    @(posedge apb_intf.zmc_top_clk);
    apb_intf.mc_apb_driver_cb.i_penable <= 1'b1;
    `uvm_info("DRV", $sformatf("Mode : Write WDATA : %h ADDR : %0d", apb_intf.mc_apb_driver_cb.i_pwdata, apb_intf.mc_apb_driver_cb.i_paddr), UVM_NONE)

    @(posedge apb_intf.zmc_top_clk);
    apb_intf.mc_apb_driver_cb.i_psel    <= 1'b0;
    apb_intf.mc_apb_driver_cb.i_penable <= 1'b0;
    apb_intf.mc_apb_driver_cb.i_paddr   <= '0;
    apb_intf.mc_apb_driver_cb.i_pwdata  <= '0;
    apb_intf.mc_apb_driver_cb.i_pwrite  <= 1'b0;
    apb_intf.mc_apb_driver_cb.i_pstrb   <= '0;
endtask

endclass
