class mc_axi_driver extends uvm_driver #(mc_axi_seq_item);
    
    // UVM Factory Registration
    `uvm_component_utils(mc_axi_driver)

    // Virtual interface
    virtual mc_interface intf;

    bit mem_init_flag;

 //////////////////////////////////////////////////////////////////////
// New Function: New Constructor of Driver
/////////////////////////////////////////////////////////////////////
     function new(string name="mc_axi_seq_item", uvm_component parent =null);
        super.new(name, parent);

    endfunction

//////////////////////////////////////////////////////////////////////
// Build Phase: Build Phase & getting virtual Interface from conf_db
/////////////////////////////////////////////////////////////////////
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

      if(!uvm_config_db#(virtual mc_interface)::get(this,"","mc_interface",intf))
      `uvm_fatal(get_full_name(),"unable to get interface in read driver")

    endfunction

//////////////////////////////////////////////////////////////////////
// Run phase task: Driving sequence to send2dut
/////////////////////////////////////////////////////////////////////
    task run_phase(uvm_phase phase);
        super.run_phase (phase);

        initialization;
        repeat(2)
        @(intf.mc_driver_cb);            
               
        fork
            begin
                if(!mem_init_flag)begin
                    wait(intf.mc_monitor_cb.zmc_top_rstn && !intf.mc_monitor_cb.zmc_top_sw_rst)
                    drive_mem_init();
                    mem_init_flag = 1;
                end
            end
        join_none

        forever begin
            seq_item_port.get_next_item(req);
            send2dut(req);              
            seq_item_port.item_done();
        end
    endtask

//////////////////////////////////////////////////////////////////////
// Send2dut task: Driving Write and read transaction
/////////////////////////////////////////////////////////////////////
    task send2dut(mc_axi_seq_item axi_seq_item);
        $display("Started Driving");

        repeat(2)
         @(intf.mc_driver_cb);

        intf.mc_driver_cb.zmc_top_rstn      <= axi_seq_item.zmc_top_rstn; 
        intf.mc_driver_cb.zmc_top_sw_rst    <= axi_seq_item.zmc_top_sw_rst;

        if(!mem_init_flag && axi_seq_item.zmc_top_rstn && !axi_seq_item.zmc_top_sw_rst)begin
            while(!intf.mc_driver_cb.MEM_init_ACK)
                @(intf.mc_driver_cb);

            while(intf.mc_driver_cb.MEM_init_ACK)
                @(intf.mc_driver_cb);
        end

        $display("wr_rd Entered");
        if(axi_seq_item.wr_rd)
            drive_write(axi_seq_item);
        else
            drive_read(axi_seq_item);

        $display("Finished Driving");
    endtask

//////////////////////////////////////////////////////////////////////
// drive_mem_init task: Initialze the memory and wait for mem_ACK 
/////////////////////////////////////////////////////////////////////
    task drive_mem_init();

        $display("Started Drive Mem initial");

        @(intf.mc_driver_cb); // Synchronize with the appropriate scope

        // Step 1: Drive zmc_top_mem_init high
        intf.mc_driver_cb.zmc_top_mem_init <= 1'b1;

        // Step 2: Wait for MEM_init_ACK to be asserted
        //if(intf.mc_monitor_cb.zmc_top_rstn && !intf.mc_monitor_cb.zmc_top_sw_rst)
            while(!intf.mc_driver_cb.MEM_init_ACK)
                @(intf.mc_driver_cb);

        // Step 4: Deassert zmc_top_mem_init after acknowledgment
        intf.mc_driver_cb.zmc_top_mem_init <= 0;

        // Step 5: Wait for MEM_init_ACK to be deasserted
        //if(intf.mc_monitor_cb.zmc_top_rstn && !intf.mc_monitor_cb.zmc_top_sw_rst)
            while(intf.mc_driver_cb.MEM_init_ACK)
                @(intf.mc_driver_cb);
    
        // Ensure no retriggering happens
        @(intf.mc_driver_cb); // Add a clock cycle delay if necessary
        
        $display("Finished Drive Mem Initial");
    endtask


//////////////////////////////////////////////////////////////////////
// drive_write task: Driving Write transaction
/////////////////////////////////////////////////////////////////////
    task drive_write(mc_axi_seq_item axi_seq_item);
        $display("Started drive_write");

        @(intf.mc_driver_cb);
        intf.mc_driver_cb.awvalid       <= 1;
        intf.mc_driver_cb.awaddr        <= axi_seq_item.awaddr;
        intf.mc_driver_cb.awlen         <= axi_seq_item.awlen;
        intf.mc_driver_cb.awburst       <= axi_seq_item.awburst;
    
        @(intf.mc_driver_cb);
        if(axi_seq_item.zmc_top_rstn && !axi_seq_item.zmc_top_sw_rst)
            wait (intf.mc_driver_cb.awready);
        @(intf.mc_driver_cb);
        // Wait for handshake
        intf.mc_driver_cb.awvalid      <= 0;
        intf.mc_driver_cb.awaddr        <= 0;
        intf.mc_driver_cb.awlen         <= 0;
        intf.mc_driver_cb.awburst       <= 0;

        // Write data channel
        for (int i = 0; i < axi_seq_item.awlen + 1; i++) begin
            intf.mc_driver_cb.wvalid      <= 1;
            intf.mc_driver_cb.wdata       <= axi_seq_item.wdata[i];
            intf.mc_driver_cb.wstrb       <= axi_seq_item.wstrb;
            intf.mc_driver_cb.wlast       <= (i == axi_seq_item.awlen);
        @(intf.mc_driver_cb);
        end

        if(axi_seq_item.zmc_top_rstn && !axi_seq_item.zmc_top_sw_rst)
            wait (intf.mc_driver_cb.wready == 1); 
        intf.mc_driver_cb.wvalid     <= 0;
        intf.mc_driver_cb.wdata      <= 0;
        intf.mc_driver_cb.wstrb      <= 0;
        intf.mc_driver_cb.wlast      <= 0;
       
       // @(intf.mc_driver_cb);
        intf.mc_driver_cb.bready        <= axi_seq_item.bready;
    
        @(intf.mc_driver_cb);
        if(axi_seq_item.zmc_top_rstn && !axi_seq_item.zmc_top_sw_rst)
            wait(intf.mc_driver_cb.bvalid);
        intf.mc_driver_cb.bready        <= 0;

        $display("Finished drive write");
    endtask

//////////////////////////////////////////////////////////////////////
// drive_read task: Driving Read transaction
/////////////////////////////////////////////////////////////////////
    task drive_read(mc_axi_seq_item axi_seq_item);
        $display("Started drive_read");

        @(intf.mc_driver_cb);
        intf.mc_driver_cb.araddr        <= axi_seq_item.araddr;
        intf.mc_driver_cb.arlen         <= axi_seq_item.arlen;
        intf.mc_driver_cb.arburst       <= axi_seq_item.arburst;
        intf.mc_driver_cb.arvalid       <= 1;
 
        if(axi_seq_item.zmc_top_rstn && !axi_seq_item.zmc_top_sw_rst)
            wait (intf.mc_driver_cb.arready == 1);
        @(intf.mc_driver_cb);
        intf.mc_driver_cb.arvalid       <= 0;
        intf.mc_driver_cb.araddr        <= 0;
        intf.mc_driver_cb.arlen         <= 0;
        intf.mc_driver_cb.arburst       <= 0; 
        
        intf.mc_driver_cb.rready        <= 1;
        
        //Fixed Burst with len is >0 (it takes arlen+1 clock cycles)
        $display("Burst:0x%0h Len:0x%0h", axi_seq_item.arburst, axi_seq_item.arlen);
        for(int i=0;i<axi_seq_item.arlen+1;i++)begin
            @(intf.mc_driver_cb);
            if(axi_seq_item.zmc_top_rstn && !axi_seq_item.zmc_top_sw_rst)
                wait(intf.mc_driver_cb.rvalid);
        end
        intf.mc_driver_cb.rready        <=1'b0; 

        $display("Finished drive_read");
        
        //Fixed Burst with len is >0 (going on loop)
        $display("Burst:0x%0h Len:0x%0h", axi_seq_item.arburst, axi_seq_item.arlen);
        /*if(axi_seq_item.arburst==2'b01 || axi_seq_item.arburst==2'b10) begin

        for(int i=0; i<axi_seq_item.arlen+1; i++)begin
            @(intf.mc_driver_cb);
            if(axi_seq_item.zmc_top_rstn && !axi_seq_item.zmc_top_sw_rst)
                wait(intf.mc_driver_cb.rvalid);
        end
        intf.mc_driver_cb.rready        <=1'b0; 

        $display("Finished drive_read");
        end
        else begin
            @(intf.mc_driver_cb);
        $display("Burst:0x%0h Len:0x%0h", axi_seq_item.arburst, axi_seq_item.arlen);
            if(axi_seq_item.zmc_top_rstn && !axi_seq_item.zmc_top_sw_rst)
                wait(intf.mc_driver_cb.rvalid);

        intf.mc_driver_cb.rready        <=1'b0; 

        $display("Finished drive_read");
        end */

    endtask

//////////////////////////////////////////////////////////////////////
// initialzation task: Driving initial zero to inputs
/////////////////////////////////////////////////////////////////////
    task initialization;
        $display("started initializaation");
        
        intf.mc_driver_cb.zmc_top_rstn      <= 0;
        intf.mc_driver_cb.zmc_top_sw_rst    <= 1;
        intf.mc_driver_cb.zmc_top_mem_init  <= 0;   
        intf.mc_driver_cb.awaddr            <= 0;
        intf.mc_driver_cb.awlen             <= 0;
        intf.mc_driver_cb.awburst           <= 0;
        intf.mc_driver_cb.awvalid           <= 0;
        intf.mc_driver_cb.wdata             <= 0;
        intf.mc_driver_cb.wstrb             <= 0;
        intf.mc_driver_cb.wlast             <= 0;
        intf.mc_driver_cb.wvalid            <= 0;
        intf.mc_driver_cb.bready            <= 0;    
        intf.mc_driver_cb.araddr            <= 0;
        intf.mc_driver_cb.arlen             <= 0;
        intf.mc_driver_cb.arburst           <= 0;
        intf.mc_driver_cb.arvalid           <= 0;
        intf.mc_driver_cb.rready            <= 0;
     
        $display("finished initialization");
    endtask
endclass
