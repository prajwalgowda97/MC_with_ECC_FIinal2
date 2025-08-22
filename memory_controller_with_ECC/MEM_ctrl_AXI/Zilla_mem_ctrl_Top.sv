module zmc_axi4_top
            #(
              GLOBAL_MEM_INIT    =  1                                                        ,       
              DATA_WIDTH         =  32                                                       ,
              ADDR_WIDTH         =  32                                                       ,
              DEPTH              =  16384                                                    ,
              PARITY_BITS        =  6                                                        ,
              MEMORY_DATA_WIDTH  =  39                                                       ,
              REG_ADDR_WIDTH     =  10                                                         
            )
             (
              // MEMORY CONTROLLER SIGNALS
              input    logic                        zmc_top_clk                              ,
              input    logic                        zmc_top_rstn                             ,
              input    logic                        zmc_top_sw_rst                           ,
              input    logic                        zmc_top_mem_init                         ,

              //   WRITE ADDRESS CHANNEL SIGNALS 
              input     logic    [ADDR_WIDTH-1:0]   awaddr                                   ,
              input     logic    [3:0]              awlen                                    ,
              input     logic    [1:0]              awburst                                  ,
              input     logic                       awvalid                                  ,
              output    logic                       awready                                  ,

              //   WRITE DATA CHANNEL SIGNALS
              input     logic    [DATA_WIDTH-1:0]   wdata                                    ,
              input     logic                       wlast                                    ,     
              input     logic    [3:0]              wstrb                                    ,
              input     logic                       wvalid                                   ,
              output    logic                       wready                                   ,

              //    WRITE RESPONSE CHANNEL SIGNALS
              output    logic                       bvalid                                   ,
              input     logic                       bready                                   ,
              output    logic    [1:0]              bresp                                    ,

              //    READ ADDRESS CHANNEL SIGNALS
              input     logic    [ADDR_WIDTH-1:0]   araddr                                   ,
              input     logic    [3:0]              arlen                                    ,
              input     logic    [1:0]              arburst                                  ,
              input     logic                       arvalid                                  ,
              output    logic                       arready                                  ,

              //    READ DATA CHANNEL SIGNALS
              output    logic    [DATA_WIDTH-1:0]   rdata                                    ,
              output    logic                       rlast                                    ,
              output    logic    [1:0]              rresp                                    ,
              output    logic                       rvalid                                   ,
              input     logic                       rready                                   ,

              output   logic                        ECC_interrupt                            ,
              output   logic   [DATA_WIDTH-1:0]     o_ECC_STAUS_REG                          ,
              output   logic                        MEM_init_ACK                             ,
 
              //  REGISTERS SIGNALS 
              input    logic                        i_psel                                   ,
              input    logic                        i_penable                                ,
              input    logic                        i_pwrite                                 ,
              input    logic [DATA_WIDTH-1:0]       i_pwdata                                 ,
              input    logic [REG_ADDR_WIDTH-1:0]   i_paddr                                  ,
              input    logic [3:0]                  i_pstrb                                  ,
              input    logic                        i_ECC_STAUS_REG_clear
             );

//-------------INTERNAL DECLARED SIGNALS------------------------------------
logic                               wr_en_w                         ;
logic   [ADDR_WIDTH-1:0]            wr_addr_w                       ;
logic   [DATA_WIDTH-1:0]            wr_data_w                       ;
logic   [3:0]                       wr_strb_w                       ;
logic   [1:0]                       wr_resp_w                       ;

logic                               rd_en_w                         ;
logic   [ADDR_WIDTH-1:0]            rd_addr_w                       ;
logic   [DATA_WIDTH-1:0]            rd_data_w                       ;
logic   [1:0]                       rd_resp_w                       ;

logic                               RAM_en_w                        ;
logic   [13:0]                      RAM_wr_addr_w                   ;
logic   [13:0]                      RAM_rd_addr_w                   ;
                    
logic                               RAM_wr_en_w                     ;
logic   [MEMORY_DATA_WIDTH-1:0]     RAM_wr_data_w                   ;
             
logic                               RAM_rd_en_w                     ;
logic   [MEMORY_DATA_WIDTH-1:0]     RAM_rd_data_w                   ;

logic   [13:0]                      wr_addr_w1                      ;
logic   [13:0]                      rd_addr_w1                      ;


always_ff@(posedge zmc_top_clk or negedge zmc_top_rstn)
begin

if(!zmc_top_rstn)
    begin
      wr_addr_w1  <= {ADDR_WIDTH{1'b0}}         ;
    end
else if(zmc_top_sw_rst)
    begin
      wr_addr_w1  <= {ADDR_WIDTH{1'b0}}         ;
    end
else 
    begin
      wr_addr_w1  <= wr_addr_w[13:0]            ;
    end
end

assign rd_addr_w1 = rd_addr_w[13:0]             ;

//---------------AXI4 SLAVE MODULE INSTANTIATION---------------------------------------------
axi4_slave 
             #(
               .DATA_WIDTH                 ( DATA_WIDTH             )      ,     
               .ADDR_WIDTH                 ( ADDR_WIDTH             )     
              )
axi4_slave_inst             
              (
               .axi4_slave_clk             ( zmc_top_clk            )       ,  
               .axi4_slave_rstn            ( zmc_top_rstn           )       , 
               .axi4_slave_sw_rst          ( zmc_top_sw_rst         )       , 
                                                   
               .awaddr                     ( awaddr                 )       , 
               .awlen                      ( awlen                  )       , 
               .awburst                    ( awburst                )       , 
               .awvalid                    ( awvalid                )       , 
               .awready                    ( awready                )       , 
                                                                   
               .wdata                      ( wdata                  )       , 
               .wlast                      ( wlast                  )       , 
               .wstrb                      ( wstrb                  )       , 
               .wvalid                     ( wvalid                 )       , 
               .wready                     ( wready                 )       , 
                                                                   
               .bvalid                     ( bvalid                 )       , 
               .bready                     ( bready                 )       , 
               .bresp                      ( bresp                  )       , 
                                                                   
               .araddr                     ( araddr                 )       , 
               .arlen                      ( arlen                  )       , 
               .arburst                    ( arburst                )       , 
               .arvalid                    ( arvalid                )       , 
               .arready                    ( arready                )       , 
                                                                   
               .rdata                      ( rdata                  )       , 
               .rlast                      ( rlast                  )       , 
               .rresp                      ( rresp                  )       , 
               .rvalid                     ( rvalid                 )       , 
               .rready                     ( rready                 )       , 
                                                   
               .slave_wr_en_o              ( wr_en_w                )       , 
               .slave_wr_addr              ( wr_addr_w              )       , 
               .slave_wr_data              ( wr_data_w              )       , 
               .slave_wr_strb              ( wr_strb_w              )       ,
               .slave_wr_resp              ( wr_resp_w              )       ,
                                                   
               .slave_rd_en_o              ( rd_en_w                )       , 
               .slave_rd_addr              ( rd_addr_w              )       , 
               .slave_rd_data              ( rd_data_w              )       ,
               .slave_rd_resp              ( rd_resp_w              )       
             ); 
/////////////////////////////////////////////////////////////////////////////////////////////

//---------------MEMORY CINTROL MODULE INSTANTIATION-----------------------------------------
mem_ctrl 
             #(
               .GLOBAL_MEM_INIT                   ( GLOBAL_MEM_INIT   )      ,
               .DEPTH                             ( DEPTH             )      ,
               .DATA_WIDTH                        ( DATA_WIDTH        )      ,     
               .PARITY_BITS                       ( PARITY_BITS       )      ,
               .MEMORY_DATA_WIDTH                 ( MEMORY_DATA_WIDTH )      ,
               .REG_ADDR_WIDTH                    ( REG_ADDR_WIDTH    )
             )
mem_ctrl_inst
              (
               .MEM_ctrl_clk                      ( zmc_top_clk                      )      ,              
               .MEM_ctrl_rstn                     ( zmc_top_rstn                     )      ,
                                                                      
               .MEM_ctrl_sw_rst                   ( zmc_top_sw_rst                   )      ,
               .MEM_ctrl_mem_init                 ( zmc_top_mem_init                 )      ,

               .MEM_ctrl_wr_en                    ( wr_en_w                          )      ,
               .MEM_ctrl_wr_addr_bus              ( wr_addr_w1                       )      ,       
               .MEM_ctrl_write_data_bus           ( wr_data_w                        )      ,
               .MEM_ctrl_wr_strobe                ( wr_strb_w                        )      ,
               .wr_resp                           ( wr_resp_w                        )      ,

               .MEM_ctrl_rd_en                    ( rd_en_w                          )      ,
               .MEM_ctrl_rd_addr_bus              ( rd_addr_w1                       )      ,       
               .MEM_ctrl_data_out                 ( rd_data_w                        )      ,
               .rd_resp                           ( rd_resp_w                        )      ,
                                                                             
               .ECC_interrupt                     ( ECC_interrupt                    )      ,
               .MEM_init_ACK                      ( MEM_init_ACK                     )      ,  
                                                                                                               
               .BRAM_en                           ( RAM_en_w                         )      ,
                                                                    
               .BRAM_wr_en                        ( RAM_wr_en_w                      )      ,
               .BRAM_wr_addr                      ( RAM_wr_addr_w                    )      ,               
               .BRAM_wr_data                      ( RAM_wr_data_w                    )      ,
                                                                    
               .BRAM_rd_en                        ( RAM_rd_en_w                      )      ,
               .BRAM_rd_addr                      ( RAM_rd_addr_w                    )      ,                              
               .BRAM_rd_data                      ( RAM_rd_data_w                    )      ,

               .o_ECC_STAUS_REG_ECC_STATUS        ( o_ECC_STAUS_REG                  )      ,
                                                                                                               
               .i_psel                            ( i_psel                           )      ,                        
               .i_penable                         ( i_penable                        )      ,        
               .i_pwrite                          ( i_pwrite                         )      ,       
               .i_pwdata                          ( i_pwdata                         )      ,       
               .i_paddr                           ( i_paddr                          )      ,       
               .i_pstrb                           ( i_pstrb                          )      ,       
               .i_ECC_STAUS_REG_ECC_STATUS_clear  ( i_ECC_STAUS_REG_clear )
              );
//--------------------------------------------------------------------------------------------              

//----------------SINGLE PORT RAM MODULE INSTANTIATION----------------------------------------
dual_port_ram
             #(
              .MEMORY_DATA_WIDTH                  ( MEMORY_DATA_WIDTH   )       ,       
              .DEPTH                              ( DEPTH               )
             )
dual_port_ram_inst            
              (
               .RAM_clk                           ( zmc_top_clk         )       , 
               .RAM_rstn                          ( zmc_top_rstn        )       ,

               .RAM_en                            ( RAM_en_w            )       ,
                                                                                   
               .RAM_wr_en                         ( RAM_wr_en_w         )       ,
               .RAM_wr_addr                       ( RAM_wr_addr_w       )       ,               
               .RAM_wr_data                       ( RAM_wr_data_w       )       ,
                                                                 
               .RAM_rd_en                         ( RAM_rd_en_w         )       ,
               .RAM_rd_addr                       ( RAM_rd_addr_w       )       ,               
               .RAM_rd_data                       ( RAM_rd_data_w       )       
              );
//------------------------------------------------------------------------------------------

endmodule              
