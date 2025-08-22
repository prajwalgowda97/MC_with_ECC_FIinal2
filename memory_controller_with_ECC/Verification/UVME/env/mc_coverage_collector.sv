class mc_coverage_collector1 extends uvm_subscriber#(mc_axi_seq_item);
mc_axi_seq_item axi_seq_item;
int i;

//factory registration
    `uvm_component_utils(mc_coverage_collector1)

// Covergroup for Input Signals
    covergroup input_signals_cg();
        option.per_instance = 1;

       
        cp_rst: coverpoint axi_seq_item.zmc_top_rstn
        {bins active = {1}; 
         bins low    = {0}; 
        } 

        // Control Signals
        cp_soft_reset: coverpoint axi_seq_item.zmc_top_sw_rst
         {bins active = {1}; 
          bins low    = {0}; 
         }

        cp_mem_init: coverpoint axi_seq_item.zmc_top_mem_init
         {bins low  = {0}; 
          bins high = {1}; 
         }

        // AXI4 Inputs
        cp_awaddr: coverpoint axi_seq_item.awaddr 
         {bins low_range   = {[32'h0000_0000 : 32'h0FFF_FFFF]};  
          bins high_range  = {[32'h1000_0000 : 32'hFFFF_FFFF]};  
         }

        cp_awlen: coverpoint axi_seq_item.awlen 
         {bins all_values = {0,3,7 };
          ignore_bins invalid_bins = {[1:2], [4:6], [8:15]};
         }

        cp_awburst: coverpoint axi_seq_item.awburst 
         {bins burst[] = {[0:1]};}

        cp_awvalid: coverpoint axi_seq_item.awvalid 
         {bins low  = {0}; 
          bins high = {1}; 
         }

        cp_wdata: coverpoint axi_seq_item.wdata[i]
         {bins auto_bin_max={[0:$]};
         } 
  
        cp_wlast: coverpoint axi_seq_item.wlast 
         {bins low  = {0}; 
          bins high = {1}; 
         }

       cp_wstrb: coverpoint axi_seq_item.wstrb 
         {bins fullword  = {4'b1111};  
         }

        cp_wvalid: coverpoint axi_seq_item.wvalid 
         {bins low  = {0}; 
          bins high = {1}; 
         }


        cp_bready: coverpoint axi_seq_item.bready 
         {bins low  = {0}; 
          bins high = {1}; 
         }


        cp_araddr: coverpoint axi_seq_item.araddr 
         {bins low_range   = {[32'h0000_0000 : 32'h0FFF_FFFF]};  
          bins high_range  = {[32'h1000_0000 : 32'hFFFF_FFFF]};  
         }
         
        cp_arlen: coverpoint axi_seq_item.arlen 
         {bins all_values = {0,3,7 };
          ignore_bins invalid_bins = {[1:2], [4:6], [8:15]};
         }
        
        cp_arburst: coverpoint axi_seq_item.arburst 
         {bins burst[]={[0:1]}; 
         }
        cp_arvalid: coverpoint axi_seq_item.arvalid 
         {bins low  = {0}; 
          bins high = {1}; 
         }


        cp_rready: coverpoint axi_seq_item.rready 
         {bins low  = {0}; 
          bins high = {1}; 
         }
    endgroup
             
// Covergroup for Output Signals
    covergroup output_signals_cg();
        option.per_instance = 1;

// AXI4 Outputs
        cp_awready: coverpoint axi_seq_item.awready 
         {bins low  = {0}; 
          bins high = {1}; 
         }
        
        cp_wready: coverpoint axi_seq_item.wready 
         {bins low  = {0}; 
          bins high = {1}; 
         }

        cp_bvalid: coverpoint axi_seq_item.bvalid 
         {bins low  = {0}; 
          bins high = {1}; 
         }
        
        cp_bresp: coverpoint axi_seq_item.bresp 
         {bins okay = {2'b00};
         }

        cp_arready: coverpoint axi_seq_item.arready 
         {bins low  = {0}; 
          bins high = {1}; 
         }

        cp_rdata: coverpoint axi_seq_item.rdata[i]
         {bins auto_bin_max={[0:$]};
         }
        cp_rlast: coverpoint axi_seq_item.rlast 
         {bins low  = {0}; 
          bins high = {1}; 
         }
        
        cp_rvalid: coverpoint axi_seq_item.rvalid 
         {bins low  = {0}; 
          bins high = {1}; 
         }
        
        cp_rresp: coverpoint axi_seq_item.rresp 
         {bins okay = {2'b00};
         }

// ECC Outputs
        cp_ecc_interrupt: coverpoint axi_seq_item.ECC_interrupt 
         {bins low  = {0}; 
          bins high = {1}; 
         }
        
        cp_mem_init_ack: coverpoint axi_seq_item.MEM_init_ACK
         {bins  ack_received = {1};
         bins not_ack_received ={0};
         }

        // ECC Status Register
        cp_ecc_status: coverpoint  axi_seq_item.o_ECC_STAUS_REG
         {bins no_error = {32'h00000000};
          bins single_bit_error = {32'h00000001};
          bins double_bit_error = {32'h00000002};
         }
    endgroup
             
    function new(string name,uvm_component parent);
        super.new(name,parent);

        input_signals_cg  = new();
        output_signals_cg = new();
        
    endfunction
    
    virtual function void write(mc_axi_seq_item t);
        this.axi_seq_item = t;

    if(t!=null) begin
        `uvm_info("COVERAGE", "Sampling AXI Transactions", UVM_MEDIUM)
                  input_signals_cg.sample();
                  output_signals_cg.sample(); 
                 end
    endfunction
endclass


class mc_coverage_collector2 extends uvm_subscriber#(mc_apb_seq_item);
    mc_apb_seq_item apb_seq_item;
    int i;
//factory registration
    `uvm_component_utils(mc_coverage_collector2)
          
    covergroup apb_config_regs_cg();
        option.per_instance = 1;

        cp_apb_sel: coverpoint apb_seq_item.i_psel 
         {bins select = {1'b1};
         }
        
        cp_apb_enable: coverpoint apb_seq_item.i_penable 
         {bins enable = {1'b1};
          bins disabled ={1'b0};                                     
         }
        
        cp_apb_write: coverpoint apb_seq_item.i_pwrite 
         {bins write = {1};
         }

        cp_apb_wdata: coverpoint apb_seq_item.i_pwdata 
         {bins enable = {32'b00000001};
          bins disabled = {32'b00000000};
         }
        
        cp_apb_addr: coverpoint apb_seq_item.i_paddr 
         {ignore_bins addr_0x00 = {32'h00000000}; 
          bins addr_0x04 = {32'h00000004};  
          bins addr_0x08 = {32'h00000008};  
         }
        
        cp_apb_strobe: coverpoint apb_seq_item.i_pstrb 
         {bins fullword  = {4'b1111}; 
         }

        cp_ecc_clear:coverpoint apb_seq_item.i_ECC_STAUS_REG_clear
         {bins disabled ={1'b0}; 
         }

    endgroup

    function new(string name,uvm_component parent);
        super.new(name,parent);
        apb_config_regs_cg = new();
    endfunction
    
    virtual function void write(mc_apb_seq_item t);
        this.apb_seq_item = t;

     if(t!= null) begin
        
        `uvm_info("COVERAGE", "Sampling APB Transactions", UVM_MEDIUM)
        apb_config_regs_cg.sample();
     end
    endfunction
endclass


