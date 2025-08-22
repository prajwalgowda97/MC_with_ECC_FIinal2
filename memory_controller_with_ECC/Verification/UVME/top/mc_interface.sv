interface mc_interface (input logic zmc_top_clk);

               logic                       zmc_top_mem_init;
               logic                       zmc_top_rstn;
               logic                       zmc_top_sw_rst;
              //   WRITE ADDRESS CHANNEL SIGNALS 
               logic                       wr_dr       ;
               logic    [31:0]             awaddr      ;                             
               logic    [3:0]              awlen       ;                             
               logic    [1:0]              awburst     ;                             
               logic                       awvalid     ;                             
               logic                       awready     ;                             

              //   WRITE DATA CHANNEL SIGNALS
               logic    [31:0]             wdata       ;                             
               logic                       wlast       ;                                  
               logic    [3:0]              wstrb       ;                             
               logic                       wvalid      ;                             
               logic                       wready      ;                             

              //    WRITE RESPONSE CHANNEL SIGNALS
               logic                       bvalid      ;                             
               logic                       bready      ;                             
               logic    [1:0]              bresp       ;                             

              //    READ ADDRESS CHANNEL SIGNALS
               logic    [31:0]             araddr      ;                            
               logic    [3:0]              arlen       ;                             
               logic    [1:0]              arburst     ;                             
               logic                       arvalid     ;                             
               logic                       arready     ;                             

              //    READ DATA CHANNEL SIGNALS
               logic    [31:0]             rdata       ;                            
               logic                       rlast       ;                             
               logic    [1:0]              rresp       ;                             
               logic                       rvalid      ;                             
               logic                       rready      ;                             

               logic                       ECC_interrupt   ;                         
               logic   [31:0]              o_ECC_STAUS_REG ;                         
               logic                       MEM_init_ACK    ;      
               

//driver clocking block
clocking mc_driver_cb @(posedge zmc_top_clk);
        output zmc_top_rstn;
        output zmc_top_sw_rst;
        output zmc_top_mem_init;
        output awaddr, awlen, awburst, awvalid;
        input  awready;
        output wdata, wlast, wstrb, wvalid;
        input  wready;
        output bready;
        input  bvalid, bresp;
        output araddr, arlen, arburst, arvalid;
        input  arready;
        output rready;
        input  rdata, rlast, rresp, rvalid;
        input  ECC_interrupt, o_ECC_STAUS_REG,MEM_init_ACK;
             
endclocking


//Monitor clocking block
clocking mc_monitor_cb @(posedge zmc_top_clk);
             input zmc_top_rstn, zmc_top_sw_rst, zmc_top_mem_init;
             input awaddr, awlen, awburst, awvalid, bready, rready;
             input awready, bresp, bvalid, wready, arready,  ECC_interrupt, o_ECC_STAUS_REG, MEM_init_ACK;                     
             input wdata, wlast, wstrb, wvalid, rdata, rlast, rresp, rvalid, araddr, arlen, arburst, arvalid;  

endclocking
endinterface
