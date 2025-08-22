

module axi4_slave
               #(
                  parameter DATA_WIDTH = 32                                   ,
                  parameter ADDR_WIDTH = 32 
                )
                (
                  input    logic                          axi4_slave_clk      ,
                  input    logic                          axi4_slave_rstn     ,
                  input    logic                          axi4_slave_sw_rst   ,


                  //   WRITE ADDRESS CHANNEL SIGNALS 
                  input     logic    [ADDR_WIDTH-1:0]     awaddr              ,
                  input     logic    [3:0]                awlen               ,
                  input     logic    [1:0]                awburst             ,
                  input     logic                         awvalid             ,
                  output    logic                         awready             ,

                  //   WRITE DATA CHANNEL SIGNALS
                  input     logic    [DATA_WIDTH-1:0]     wdata               ,
                  input     logic                         wlast               ,     
                  input     logic    [3:0]                wstrb               ,
                  input     logic                         wvalid              ,
                  output    logic                         wready              ,

                  //    WRITE RESPONSE CHANNEL SIGNALS
                  output    logic                         bvalid              ,
                  input     logic                         bready              ,
                  output    logic    [1:0]                bresp               ,

                  //    READ ADDRESS CHANNEL SIGNALS
                  input     logic    [ADDR_WIDTH-1:0]     araddr              ,
                  input     logic    [3:0]                arlen               ,
                  input     logic    [1:0]                arburst             ,
                  input     logic                         arvalid             ,
                  output    logic                         arready             ,

                  //    READ DATA CHANNEL SIGNALS
                  output    logic    [DATA_WIDTH-1:0]     rdata               ,
                  output    logic                         rlast               ,
                  output    logic    [1:0]                rresp               ,
                  output    logic                         rvalid              ,
                  input     logic                         rready              ,

                  
                  // WRITE_ADDR , READ_ADDR , ENABLE AND DATA'S
                  output    logic                         slave_wr_en_o       ,
                  output    logic    [ADDR_WIDTH-1:0]     slave_wr_addr       ,
                  output    logic    [DATA_WIDTH-1:0]     slave_wr_data       ,
                  output    logic    [3:0]                slave_wr_strb       ,
                  input     logic    [1:0]                slave_wr_resp       ,

                  output    logic                         slave_rd_en_o       ,
                  output    logic    [ADDR_WIDTH-1:0]     slave_rd_addr       ,
                  input     logic    [DATA_WIDTH-1:0]     slave_rd_data       ,
                  input     logic    [1:0]                slave_rd_resp
                );

            //              DECLARING STATES FOR WRITE FSM
            localparam    IDLE_W    = 2'd0                                ;
            localparam    WR_ADDR   = 2'd1                                ;
            localparam    WR_DATA   = 2'd2                                ;
            localparam    WR_RESP   = 2'd3                                ;
            
            logic  [1:0]  wr_present_state                                ;
            logic  [1:0]  wr_next_state                                   ;

            logic  [3:0]  wr_down_counter                                 ; 
            logic         wr_addr_valid                                   ;
            ///////////////////////////////////////////////////////////////

            //              DECLARING STATES FOR READ FSM   
            localparam    IDLE_R    = 2'd0                                ;
            localparam    RD_ADDR   = 2'd1                                ;
            localparam    RD_DATA   = 2'd2                                ;

            logic  [1:0]  rd_present_state                                ;
            logic  [1:0]  rd_next_state                                   ;

            logic  [3:0]  rd_down_counter                                 ; 
            logic         rd_addr_valid                                   ;
            logic         slave_rd_en_r                                   ;

  //------------WRITE BURST STATES FSM-------------------------------
            localparam    WR_IDLE       = 2'd0                                ;
            localparam    WR_FIX_BURST  = 2'd1                                ;
            localparam    WR_INCR_BURST = 2'd2                                ;
            localparam    WR_WRAP_BURST = 2'd3                                ;

            localparam    NO_OF_BYTES   = 4                                   ;
            
            logic  [1:0]  present_state_wr                                    ;
            logic  [1:0]  next_state_wr                                       ;

            logic  [ADDR_WIDTH-1:0] wr_addr_r                                 ;
            logic  [ADDR_WIDTH-1:0] wr_addr_w                                 ;
            logic  [ADDR_WIDTH-1:0] wr_addr_w1                                ;

            logic  [ADDR_WIDTH-1:0] addr_n_wr                                 ;
            logic  [ADDR_WIDTH-1:0] addr_n_r                                  ;

            logic  [ADDR_WIDTH-1:0] wrap_bndry                                ;
            logic  [ADDR_WIDTH-1:0] wrap_bndry_r                              ;

            logic  [31:0] add_wr                                              ;
            logic  [3:0]  awlen_r                                             ;                         
            logic  [3:0]  awlen_reg                                           ;                         
            ///////////////////////////////////////////////////////////////////            


            //------------READ BURST STATES FSM--------------------------------
            localparam    RD_IDLE       = 2'd0                                ;
            localparam    RD_FIX_BURST  = 2'd1                                ;
            localparam    RD_INCR_BURST = 2'd2                                ;
            localparam    RD_WRAP_BURST = 2'd3                                ;

            logic  [1:0]  present_state_rd                                    ;
            logic  [1:0]  next_state_rd                                       ;

            logic  [ADDR_WIDTH-1:0] rd_addr_r                                 ;
            logic  [ADDR_WIDTH-1:0] rd_addr_w                                 ;
            logic  [ADDR_WIDTH-1:0] rd_addr_w1                                ;

            logic  [ADDR_WIDTH-1:0] addr_n_rd                                 ;
            logic  [ADDR_WIDTH-1:0] addr_n_w                                  ;

            logic  [ADDR_WIDTH-1:0] wrap_bndry_rd                             ;
            logic  [ADDR_WIDTH-1:0] wrap_bndry_w                              ;

            logic  [31:0] add_rd                                              ;
            logic  [3:0]  arlen_r                                             ;                         
            logic  [3:0]  arlen_reg                                           ;                         
            ///////////////////////////////////////////////////////////////////            

           //-----------LATCHING THE WRITE ADDRESS FOR FIXED BURST-----------

            assign wr_addr_w = (awvalid) ? awaddr : wr_addr_w1 ;
            assign arlen_r   = (arvalid) ? arlen  : arlen_reg  ;
            assign awlen_r   = (awvalid) ? awlen  : awlen_reg  ;

            always_ff@(posedge axi4_slave_clk or negedge axi4_slave_rstn)
            begin
            
            if(!axi4_slave_rstn)
                begin
                wr_addr_w1    <= {ADDR_WIDTH{1'b0}}     ;
                arlen_reg     <= 4'd0                   ;
                awlen_reg     <= 4'd0                   ;
                slave_rd_en_r <= 1'b0                   ;
                end
            else if(axi4_slave_sw_rst)
                begin
                wr_addr_w1    <= {ADDR_WIDTH{1'b0}}     ;
                arlen_reg     <= 4'd0                   ;
                awlen_reg     <= 4'd0                   ;
                slave_rd_en_r <= 1'b0                   ;
                end
            else
                begin
                wr_addr_w1    <= wr_addr_w              ;
                arlen_reg     <= arlen_r                ;
                awlen_reg     <= awlen_r                ;
                slave_rd_en_r <= slave_rd_en_o          ;
                end

            end

            ///////////////////////////////////////////////////////////////
            //                 WRITE FSM LOGIC                           //
            ///////////////////////////////////////////////////////////////

            //                  PRESENT STATE LOGIC
            always_ff@(posedge axi4_slave_clk or negedge axi4_slave_rstn)
            begin
            
            if(!axi4_slave_rstn)
                begin
                wr_present_state  <=  IDLE_W                                   ;                
                end
            else if(axi4_slave_sw_rst)
                begin
                wr_present_state  <=  IDLE_W                                   ;                
                end    
            else 
                begin
                wr_present_state  <=  wr_next_state                            ;
                end

            end
            ///////////////////////////////////////////////////////////////////

            //                   NEXT STATE LOGIC
            always_comb
            begin

            unique case(wr_present_state)

            IDLE_W :
                  begin
                        if(awvalid)
                            begin
                            wr_next_state = WR_ADDR                                      ; 
                            end                       
                        else
                            begin
                            wr_next_state = IDLE_W                                       ;                
                            end
                  end
       
            WR_ADDR :
                  begin
                        if(awvalid && awready)
                            begin
                            wr_next_state = WR_DATA                                      ;
                            end
                        else
                            begin
                            wr_next_state = WR_ADDR                                      ;
                            end
                  end

            WR_DATA :
                  begin
                       if(wlast == 1'b1)
                           begin
                                if(wvalid && wready)
                                    begin
                                    wr_next_state = WR_RESP                               ;
                                    end
                                else
                                    begin
                                    wr_next_state = WR_DATA                               ;
                                    end
                           end
                       else
                           begin
                           wr_next_state = WR_DATA                                        ;
                           end
                  end

            WR_RESP :
                  begin
                       if(bvalid && bready)
                            begin
                                if(bresp == 2'b00)
                                    begin
                                    wr_next_state = IDLE_W                                 ;
                                    end
                                else
                                    begin
                                    wr_next_state = WR_DATA                              ;
                                    end
                            end         
                       else
                            begin
                            wr_next_state = WR_RESP                                      ;
                            end                            
                  end 

            
            
            default : wr_next_state = IDLE_W                                              ;
            
            endcase

            end
            ////////////////////////////////////////////////////////////////////

            //                      OUTPUT LOGIC
            always_comb
            begin
            awready         =     1'b0                                         ; 
            wready          =     1'b0                                         ;
            bvalid          =     1'b0                                         ;
            bresp           =     2'd0                                        ;
            slave_wr_addr   =     {ADDR_WIDTH{1'b0}}                           ;
            slave_wr_data   =     {DATA_WIDTH{1'b0}}                           ;
            slave_wr_en_o   =     1'b0                                         ;
            slave_wr_strb   =     4'd0                                         ;

            unique case(wr_present_state)

            WR_ADDR :
            begin
            awready          =     1'b1                                        ;
            slave_wr_addr    =     awaddr                                      ;            
            end
    
            WR_DATA :
            begin
            if(wr_addr_valid)
                begin
                slave_wr_addr    =     wr_addr_r                               ;            
                end
            else 
                begin
                slave_wr_addr    =     {ADDR_WIDTH{1'b0}}                      ;            
                end
            
            if(wvalid)
                begin
                    slave_wr_en_o    =     1'b1                                        ;
                    wready           =     1'b1                                        ;
                    slave_wr_strb    =     wstrb                                       ;
                end

            slave_wr_data    =     wdata                                       ;
            end

            WR_RESP :
            begin
            slave_wr_en_o    =     1'b0                                        ;
            bvalid           =     1'b1                                        ;
            bresp            =     slave_wr_resp                               ;
            end

            
            default : 
            begin
            awready          =     1'b0                                        ; 
            wready           =     1'b0                                        ;
            bvalid           =     1'b0                                        ;
            slave_wr_addr    =     {ADDR_WIDTH{1'b0}}                          ;
            slave_wr_data    =     {DATA_WIDTH{1'b0}}                          ;
            end

            endcase

            end
            ////////////////////////////////////////////////////////////////////

            /////////////////////////////////////////////////////////////// 
            //                   WRITE BURST FSM                         // 
            ///////////////////////////////////////////////////////////////

            //              PRESENT STATE LOGIC
            always_ff@(posedge axi4_slave_clk or negedge axi4_slave_rstn)
            begin
            
            if(!axi4_slave_rstn)
                begin
                present_state_wr  <=  WR_IDLE                                ;                
                end
            else if(axi4_slave_sw_rst)
                begin
                present_state_wr  <=  WR_IDLE                                ;                
                end    
            else 
                begin
                present_state_wr  <=  next_state_wr                          ;
                end

            end
            ////////////////////////////////////////////////////////////////////

            //              NEXT STATE LOGIC
            always_comb
            begin

            case(present_state_wr)
            WR_IDLE         : begin 

                                if(awvalid && awburst == 2'd0)
                                    begin
                                    next_state_wr = WR_FIX_BURST        ;
                                    end
                                else if(awvalid && awburst == 2'd1)
                                    begin
                                    next_state_wr = WR_INCR_BURST       ;
                                    end
                                else if(awvalid && awburst == 2'd2) 
                                    begin
                                    next_state_wr = WR_WRAP_BURST       ; 
                                    end
                                else
                                    begin
                                    next_state_wr = WR_IDLE             ;
                                    end
                                    
                              end

            WR_FIX_BURST    : begin
                                
                                if(wr_down_counter == 4'd0)
                                    begin
                                    next_state_wr = WR_IDLE            ;
                                    end
                                else
                                    begin
                                    next_state_wr = WR_FIX_BURST       ;
                                    end
                                
                              end

            WR_INCR_BURST   : begin 
                            
                                 if(wr_down_counter == 4'd0)
                                    begin
                                    next_state_wr = WR_IDLE            ;
                                    end
                                else
                                    begin
                                    next_state_wr = WR_INCR_BURST      ;
                                    end

                              end

            WR_WRAP_BURST   : begin 

                                 if(wr_down_counter == 4'd0)
                                    begin
                                    next_state_wr = WR_IDLE            ;
                                    end
                                else
                                    begin
                                    next_state_wr = WR_WRAP_BURST      ;
                                    end

                              end

            endcase
            end
            ////////////////////////////////////////////////////////////////////

            //                   ADDRESS OUTPUT LOGIC
            always_ff@(posedge axi4_slave_clk or negedge axi4_slave_rstn)
            begin

            if(!axi4_slave_rstn)
                begin
                wr_addr_r  <=  32'd0    ;
                end
            else if(axi4_slave_sw_rst)
                begin
                wr_addr_r  <=  32'd0    ;
                end    
            else
                begin

            case(present_state_wr)
            WR_IDLE         : begin
                              wr_addr_r <= 32'd0 ;    
                              end

            WR_FIX_BURST    : begin
                                  wr_addr_r <= wr_addr_w         ;  
                              end 

            WR_INCR_BURST   : begin

                              if(wr_down_counter == (awlen_r))
                                  begin
                                  wr_addr_r <= wr_addr_w + 32'd4       ;
                                  end
                              else if(wr_down_counter != 4'd0)
                                  begin
                                  wr_addr_r <= wr_addr_r + 32'd4       ;
                                  end
                              else
                                  begin
                                  wr_addr_r <= 32'd0                   ;
                                  end

                              end

            WR_WRAP_BURST   : begin

                              if((wr_down_counter) == (awlen_r))
                                  begin
                                  wr_addr_r <= wr_addr_w + 32'd4        ;
                                  end 
                              else if((wr_addr_r + 32'd4) == addr_n_wr)
                                  begin
                                  wr_addr_r <= wrap_bndry               ;
                                  end
                              else if(wr_down_counter != 4'd0)
                                  begin
                                  wr_addr_r <= wr_addr_r + 32'd4        ;
                                  end    
                              else 
                                  begin
                                  wr_addr_r <= 32'd0                    ;
                                  end
                              
                              end
            endcase
            end
            end
            ////////////////////////////////////////////////////////////////////

            //                WRITE DOWN COUNTER LOGIC
            always_ff@(posedge axi4_slave_clk or negedge axi4_slave_rstn)
            begin

            if(!axi4_slave_rstn)
                begin
                wr_down_counter  <= 5'd0                       ; 
                end

            else if(axi4_slave_sw_rst)
                begin
                wr_down_counter  <= 5'd0                       ; 
                end     

            else if(awvalid && (present_state_wr == 2'd0))
                begin
                wr_down_counter <= awlen                       ;
                end
            
            else if((present_state_wr == 2'd1)||(present_state_wr==2'd2)||(present_state_wr==2'd3)) 
                begin
                wr_down_counter <= wr_down_counter - 1'b1       ;
                end

            else 
                begin
                wr_down_counter <= 32'd0                        ;
                end

            end
            ////////////////////////////////////////////////////////////////////

            //--------------------WRAP BOUNDRY CALCULATION-------------------------------------
            assign add_wr = (NO_OF_BYTES * (awlen+1'b1))          ;

            assign wrap_bndry = (awvalid && (awburst == 2'd2))  ? ((wr_addr_w/add_wr)*add_wr) : wrap_bndry_r ;

            always_ff@(posedge axi4_slave_clk or negedge axi4_slave_rstn)
            begin

            if(!axi4_slave_rstn)
                begin
                wrap_bndry_r <= {ADDR_WIDTH{1'b0}}      ;
                end
            else if(axi4_slave_sw_rst)
                begin
                wrap_bndry_r <= {ADDR_WIDTH{1'b0}}      ;
                end
            else
                begin
                wrap_bndry_r <= wrap_bndry              ;                
                end

            end
            ////////////////////////////////////////////////////////////////////


            //-----------------------ADDRESS_N CALCULATION-------------------------------------
            assign addr_n_wr = (awvalid && awburst == 2'd2) ? (wrap_bndry + (NO_OF_BYTES*(awlen+1'b1))) : addr_n_r  ;

            always_ff@(posedge axi4_slave_clk or negedge axi4_slave_rstn)
            begin

            if(!axi4_slave_rstn)
                begin
                addr_n_r <= {ADDR_WIDTH{1'b0}}      ;
                end
            else if(axi4_slave_sw_rst)
                begin
                addr_n_r <= {ADDR_WIDTH{1'b0}}      ;
                end
            else
                begin
                addr_n_r <= addr_n_wr               ;                
                end

            end
            ////////////////////////////////////////////////////////////////////

            //----------READ ADDRESS IS LATCHED FOR FIXED BURSTS--------------
            assign rd_addr_w = (arvalid) ? araddr : rd_addr_w1 ;

            always_ff@(posedge axi4_slave_clk or negedge axi4_slave_rstn)
            begin
            
            if(!axi4_slave_rstn)
                begin
                rd_addr_w1 <= {ADDR_WIDTH{1'b0}}        ;                
                end
            else if(axi4_slave_sw_rst)
                begin
                rd_addr_w1 <= {ADDR_WIDTH{1'b0}}        ;
                end
            else
                begin
                rd_addr_w1 <= rd_addr_w                 ;
                end

            end

            assign rd_addr_valid = ((present_state_rd==2'd1)||(present_state_rd==2'd2)||(present_state_rd==2'd3)) ;
            assign wr_addr_valid = ((present_state_wr==2'd1)||(present_state_wr==2'd2)||(present_state_wr==2'd3)) ;

            ////////////////////////////////////////////////////////////////////
            //                      READ FSM LOGIC                            //
            ////////////////////////////////////////////////////////////////////

            //                  PRESENT STATE LOGIC
            always_ff@(posedge axi4_slave_clk or negedge axi4_slave_rstn)
            begin
            
            if(!axi4_slave_rstn)
                begin
                rd_present_state  <=  IDLE_R                                   ;                
                end
            else if(axi4_slave_sw_rst)
                begin
                rd_present_state  <=  IDLE_R                                   ;                
                end    
            else 
                begin
                rd_present_state  <=  rd_next_state                            ;
                end

            end
            /////////////////////////////////////////////////////////////////////////

            //                 NEXT STATE LOGIC
            always_comb
            begin

            unique case(rd_present_state)

            IDLE_R  :
                  begin
                       if(arvalid)
                           begin
                           rd_next_state = RD_ADDR                                       ;
                           end
                       else
                           begin
                           rd_next_state =  IDLE_R                                       ;
                           end
                  end
            RD_ADDR :
                  begin
                       if(arvalid && arready)                           
                            begin
                            rd_next_state = RD_DATA                                      ;
                            end
                        else
                            begin
                            rd_next_state = RD_ADDR                                      ;
                            end                            
                  end

            RD_DATA :
                  begin
                      if(rlast == 1'b1)
                           begin
                               if(rvalid && rready)
                                  begin
                                      if(rresp == 2'd0)
                                         begin
                                         rd_next_state = IDLE_R                         ;
                                         end                                  
                                      else
                                         begin
                                         rd_next_state = RD_DATA                        ;
                                         end
                                  end
                               else
                                   begin
                                   rd_next_state = RD_DATA                              ;
                                   end
                           end
                      else
                          begin
                          rd_next_state = RD_DATA                                       ;
                          end
                  end
             
            default :
                   begin
                   rd_next_state = IDLE_R                                               ;
                   end
            
            endcase

            end
            ///////////////////////////////////////////////////////////////////////////

            //                      OUTPUT LOGIC
            always_comb
            begin
            slave_rd_en_o    =    1'b0                                                 ;
            slave_rd_addr    =    {ADDR_WIDTH{1'b0}}                                   ;
            arready          =    1'b0                                                 ;
            rvalid           =    1'b0                                                 ;
            rdata            =    {DATA_WIDTH{1'b0}}                                   ;
            rlast            =    1'b0                                                 ;
            rresp            =    2'd0                                                 ;
            
            case(rd_present_state)
            
            IDLE_R  :
                    begin
                    slave_rd_en_o    =    1'b0                                         ;
                    slave_rd_addr    =    {ADDR_WIDTH{1'b0}}                           ;
                    arready          =    1'b0                                         ;
                    rvalid           =    1'b0                                         ;
                    rdata            =    {DATA_WIDTH{1'b0}}                           ;
                    end
            
            RD_ADDR :
                    begin
                    slave_rd_en_o    =    1'b1                                         ;            
                    slave_rd_addr    =    araddr                                       ; 
                    arready          =    1'b1                                         ;
                    end

            RD_DATA :
                    begin
                    if(rd_addr_valid)
                        begin
                        slave_rd_en_o    =    1'b1                                     ;            
                        end
                    else
                        begin
                        slave_rd_en_o    =    1'b0                                     ;            
                        end

                    slave_rd_addr    =    rd_addr_r                                    ; 
                    
                    rvalid           =    1'b1                                         ;
                    rdata            =    slave_rd_data                                ;
                    rlast            =    (slave_rd_en_o ^ slave_rd_en_r) ? 1'b1 : 1'b0;
                    rresp            =    slave_rd_resp                                ;
                    end

            default :
                    begin
                    slave_rd_en_o    =    1'b0                                         ; 
                    slave_rd_addr    =    {ADDR_WIDTH{1'b0}}                           ; 
                    arready          =    1'b0                                         ;
                    rvalid           =    1'b0                                         ;
                    rdata            =    {DATA_WIDTH{1'b0}}                           ;
                    end

            endcase

            end
            ////////////////////////////////////////////////////////////////////////// 

            /////////////////////////////////////////////////////////////// 
            //                   READ BURST FSM                          // 
            ///////////////////////////////////////////////////////////////

            //              PRESENT STATE LOGIC
            always_ff@(posedge axi4_slave_clk or negedge axi4_slave_rstn)
            begin
            
            if(!axi4_slave_rstn)
                begin
                present_state_rd  <=  RD_IDLE                                ;                
                end
            else if(axi4_slave_sw_rst)
                begin
                present_state_rd  <=  RD_IDLE                                ;                
                end    
            else 
                begin
                present_state_rd  <=  next_state_rd                          ;
                end

            end
            ////////////////////////////////////////////////////////////////////            

            //              NEXT STATE LOGIC
            always_comb
            begin

            case(present_state_rd)
            RD_IDLE         : begin 

                                if(arvalid && arburst == 2'd0)
                                    begin
                                    next_state_rd = RD_FIX_BURST        ;
                                    end
                                else if(arvalid && arburst == 2'd1)
                                    begin
                                    next_state_rd = RD_INCR_BURST       ;
                                    end
                                else if(arvalid && arburst == 2'd2) 
                                    begin
                                    next_state_rd = RD_WRAP_BURST       ; 
                                    end
                                else
                                    begin
                                    next_state_rd = RD_IDLE             ;
                                    end
                                    
                              end

            RD_FIX_BURST    : begin
                                
                                if(rd_down_counter == 4'd0)
                                    begin
                                    next_state_rd = RD_IDLE            ;
                                    end
                                else
                                    begin
                                    next_state_rd = RD_FIX_BURST       ;
                                    end
                                
                              end

            RD_INCR_BURST   : begin 
                            
                                 if(rd_down_counter == 4'd0)
                                    begin
                                    next_state_rd = RD_IDLE            ;
                                    end
                                else
                                    begin
                                    next_state_rd = RD_INCR_BURST      ;
                                    end

                              end

            RD_WRAP_BURST   : begin 

                                 if(rd_down_counter == 4'd0)
                                    begin
                                    next_state_rd = RD_IDLE            ;
                                    end
                                else
                                    begin
                                    next_state_rd = RD_WRAP_BURST      ;
                                    end

                              end

            endcase
            end
            ////////////////////////////////////////////////////////////////////

            //                   ADDRESS OUTPUT LOGIC
            always_ff@(posedge axi4_slave_clk or negedge axi4_slave_rstn)
            begin

            if(!axi4_slave_rstn)
                begin
                rd_addr_r  <=  32'd0    ;
                end
            else if(axi4_slave_sw_rst)
                begin
                rd_addr_r  <=  32'd0    ;
                end    
            else
                begin

            case(present_state_rd)
            RD_IDLE         : begin
                              rd_addr_r <= 32'd0 ;    
                              end

            RD_FIX_BURST    : begin
                                  rd_addr_r <= rd_addr_w         ;  
                              end 

            RD_INCR_BURST   : begin

                              if((rd_down_counter) == (arlen_r))
                                  begin
                                  rd_addr_r <= rd_addr_w + 32'd4   ;
                                  end
                              else if(rd_down_counter != 4'd0)
                                  begin
                                  rd_addr_r <= rd_addr_r + 32'd4  ;
                                  end
                              else
                                  begin
                                  rd_addr_r <= {ADDR_WIDTH{1'b0}} ;
                                  end

                              end

            RD_WRAP_BURST   : begin     
                              if((rd_down_counter) == (arlen_r))
                                  begin
                                  rd_addr_r <= rd_addr_w + 32'd4  ;
                                  end
                              else if((rd_addr_r + 32'd4) == addr_n_rd)
                                  begin
                                  rd_addr_r <= wrap_bndry_rd      ;
                                  end
                              else if(rd_down_counter != 4'd0)
                                  begin
                                  rd_addr_r <= rd_addr_r + 32'd4  ;
                                  end    
                              else 
                                  begin
                                  rd_addr_r <= {ADDR_WIDTH{1'b0}}  ;
                                  end
                              
                              end
            endcase
            end
            end
            ////////////////////////////////////////////////////////////////////

            //---------------READ DOWN COUNTER LOGIC FOR BURST-------------------------
            always_ff@(posedge axi4_slave_clk or negedge axi4_slave_rstn)
            begin

            if(!axi4_slave_rstn)
                begin
                rd_down_counter  <= 4'd0                       ; 
                end

            else if(axi4_slave_sw_rst)
                begin
                rd_down_counter  <= 4'd0                       ; 
                end     

            else if(arvalid && (present_state_rd == 2'd0))
                begin
                rd_down_counter <= arlen                       ;
                end
            
            else if((present_state_rd == 2'd1)||(present_state_rd==2'd2)||(present_state_rd==2'd3)) 
                begin
                rd_down_counter <= rd_down_counter - 1'b1       ;
                end

            else 
                begin
                rd_down_counter <= 4'd0                        ;
                end

            end
            ////////////////////////////////////////////////////////////////////


            //--------------------WRAP BOUNDRY CALCULATION FOR READ WRAP BURST-----------------
            assign add_rd = (NO_OF_BYTES * (arlen+1'b1))          ;

            assign wrap_bndry_rd = (arvalid && (arburst == 2'd2))  ? ((rd_addr_w/add_rd)*add_rd) : wrap_bndry_w ;

            always_ff@(posedge axi4_slave_clk or negedge axi4_slave_rstn)
            begin

            if(!axi4_slave_rstn)
                begin
                wrap_bndry_w <= {ADDR_WIDTH{1'b0}}      ;
                end
            else if(axi4_slave_sw_rst)
                begin
                wrap_bndry_w <= {ADDR_WIDTH{1'b0}}      ;
                end
            else
                begin
                wrap_bndry_w <= wrap_bndry_rd           ;                
                end

            end
            ////////////////////////////////////////////////////////////////////            

            //-----------------------ADDRESS_N CALCULATION FOR READ WRAP BURST-----------------
            assign addr_n_rd = (arvalid && arburst == 2'd2) ? (wrap_bndry_rd + (NO_OF_BYTES*(arlen+1'b1))) : addr_n_w  ;

            always_ff@(posedge axi4_slave_clk or negedge axi4_slave_rstn)
            begin

            if(!axi4_slave_rstn)
                begin
                addr_n_w <= {ADDR_WIDTH{1'b0}}      ;
                end
            else if(axi4_slave_sw_rst)
                begin
                addr_n_w <= {ADDR_WIDTH{1'b0}}      ;
                end
            else
                begin
                addr_n_w <= addr_n_rd               ;                
                end

            end
            ////////////////////////////////////////////////////////////////////
           
endmodule                                                                              











 
               

