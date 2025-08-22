class mc_axi_seq_item extends uvm_sequence_item;


 // MEMORY CONTROLLER SIGNALS
              rand     logic                        wr_rd                                    ;
              rand     logic                        zmc_top_clk                              ;
              rand     logic                        zmc_top_rstn                             ;
              rand     logic                        zmc_top_sw_rst                           ;
              rand     logic                        zmc_top_mem_init                         ;

              //   WRITE ADDRESS CHANNEL SIGNALS 
              rand      logic    [31:0]             awaddr                                   ;
              rand      logic    [3:0]              awlen                                    ;
              rand      logic    [1:0]              awburst                                  ;
              rand      logic                       awvalid                                  ;
                        logic                       awready                                  ;

              //   WRITE DATA CHANNEL SIGNALS
              rand      logic    [31:0]             wdata[$]                                 ;
              rand      logic                       wlast                                    ;     
              rand      logic    [3:0]              wstrb                                    ;
              rand      logic                       wvalid                                   ;
                        logic                       wready                                   ;

              //    WRITE RESPONSE CHANNEL SIGNALS
                        logic                       bvalid                                   ;
              rand      logic                       bready                                   ;
                        logic    [1:0]              bresp                                    ;

              //    READ ADDRESS CHANNEL SIGNALS
              rand      logic    [31:0]             araddr                                   ;
              rand      logic    [3:0]              arlen                                    ;
              rand      logic    [1:0]              arburst                                  ;
              rand      logic                       arvalid                                  ;
                        logic                       arready                                  ;

              //    READ DATA CHANNEL SIGNALS
                        logic    [31:0]             rdata[$]                                 ;
                        logic                       rlast                                    ;
                        logic    [1:0]              rresp                                    ;
                        logic                       rvalid                                   ;
              rand      logic                       rready                                   ;

                       logic                        ECC_interrupt                            ;
                       logic   [31:0]               o_ECC_STAUS_REG                          ;
                       logic                        MEM_init_ACK                             ;
 
 //factory registration
 `uvm_object_utils_begin(mc_axi_seq_item)
                       `uvm_field_int(wr_rd             ,UVM_ALL_ON)
                       `uvm_field_int(zmc_top_clk       ,UVM_ALL_ON)
                       `uvm_field_int(zmc_top_rstn      ,UVM_ALL_ON)
                       `uvm_field_int(zmc_top_sw_rst    ,UVM_ALL_ON)
                       `uvm_field_int(zmc_top_mem_init  ,UVM_ALL_ON)
                                         
                                         
                       `uvm_field_int(awaddr            ,UVM_ALL_ON)
                       `uvm_field_int(awlen             ,UVM_ALL_ON)
                       `uvm_field_int(awburst           ,UVM_ALL_ON)
                       `uvm_field_int(awvalid           ,UVM_ALL_ON)
                       `uvm_field_int(awready           ,UVM_ALL_ON)
                                         
                                         
                       `uvm_field_queue_int(wdata       ,UVM_ALL_ON)
                       `uvm_field_int(wlast             ,UVM_ALL_ON)
                       `uvm_field_int(wstrb             ,UVM_ALL_ON)
                       `uvm_field_int(wvalid            ,UVM_ALL_ON)
                       `uvm_field_int(wready            ,UVM_ALL_ON)
                                         
                                         
                       `uvm_field_int(bvalid            ,UVM_ALL_ON)
                       `uvm_field_int(bready            ,UVM_ALL_ON)
                       `uvm_field_int(bresp             ,UVM_ALL_ON)
                                                        
                                                        
                       `uvm_field_int(araddr            ,UVM_ALL_ON)
                       `uvm_field_int(arlen             ,UVM_ALL_ON)
                       `uvm_field_int(arburst           ,UVM_ALL_ON)
                       `uvm_field_int(arvalid           ,UVM_ALL_ON)
                       `uvm_field_int(arready           ,UVM_ALL_ON)
                                         
                                         
                       `uvm_field_queue_int(rdata       ,UVM_ALL_ON)
                       `uvm_field_int(rlast             ,UVM_ALL_ON)
                       `uvm_field_int(rresp             ,UVM_ALL_ON)
                       `uvm_field_int(rvalid            ,UVM_ALL_ON)
                       `uvm_field_int(rready            ,UVM_ALL_ON)
                                         
                       /*`uvm_field_queue_int(ECC_interrupt   ,UVM_ALL_ON)
                       `uvm_field_queue_int(o_ECC_STAUS_REG ,UVM_ALL_ON)
                       `uvm_field_queue_int(MEM_init_ACK    ,UVM_ALL_ON)*/
                                                        
 `uvm_object_utils_end                                  

 //constructor
  function new(string name="mc_axi_seq_item");
   super.new(name);
  endfunction

    constraint valid_init  {zmc_top_mem_init inside {0,1};}
    constraint w_data_size {wdata.size() == awlen+1; }


endclass
