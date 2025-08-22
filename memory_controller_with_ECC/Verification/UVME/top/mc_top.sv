module mc_top;

    import uvm_pkg::*;
    import mc_uvm_pkg::*;

    `include "uvm_macros.svh"
    logic zmc_top_clk,zmc_top_rstn, zmc_top_sw_rst;

  mc_interface intf(zmc_top_clk);
  mc_apb_interface apb_intf(zmc_top_clk);

 /***********************************************************************************/
 
//DUT instantiation
zmc_axi4_top dut (
               .zmc_top_clk       (intf.zmc_top_clk        ),
               .zmc_top_rstn      (intf.zmc_top_rstn       ),
               .zmc_top_sw_rst    (intf.zmc_top_sw_rst     ),
               .zmc_top_mem_init  (intf.zmc_top_mem_init   ),
               .awaddr            (intf.awaddr             ),
               .awlen             (intf.awlen              ),
               .awburst           (intf.awburst            ),
               .awvalid           (intf.awvalid            ),
               .awready           (intf.awready            ),
               .wdata             (intf.wdata              ),
               .wlast             (intf.wlast              ),     
               .wstrb             (intf.wstrb              ),
               .wvalid            (intf.wvalid             ),
               .wready            (intf.wready             ),
               .bvalid            (intf.bvalid             ),
               .bready            (intf.bready             ),
               .bresp             (intf.bresp              ),
               .araddr            (intf.araddr             ),
               .arlen             (intf.arlen              ),
               .arburst           (intf.arburst            ),
               .arvalid           (intf.arvalid            ),
               .arready           (intf.arready            ),
               .rdata             (intf.rdata              ),
               .rlast             (intf.rlast              ),
               .rresp             (intf.rresp              ),
               .rvalid            (intf.rvalid             ),
               .rready            (intf.rready             ),
               .ECC_interrupt     (intf.ECC_interrupt      ),
               .o_ECC_STAUS_REG   (intf.o_ECC_STAUS_REG    ),
               .MEM_init_ACK  	  (intf.MEM_init_ACK  	   ),	
                                   
               .i_psel                (apb_intf.i_psel     ),          
               .i_penable             (apb_intf.i_penable  ),          
               .i_pwrite              (apb_intf.i_pwrite   ),          
               .i_pwdata              (apb_intf.i_pwdata   ),          
               .i_paddr               (apb_intf.i_paddr    ),          
               .i_pstrb               (apb_intf.i_pstrb    ),          
               .i_ECC_STAUS_REG_clear (apb_intf.i_ECC_STAUS_REG_clear));



/************************************************************************************/
                            //creating interface handle
  initial
  begin
    zmc_top_clk=1'b0; 
    `uvm_info("TOP",$sformatf("zmc_top_clk=%b",zmc_top_clk),UVM_LOW)
  end

  always #5 zmc_top_clk = ~zmc_top_clk;

// Single bit error injection
    initial begin
        string test_name;
        if ($value$plusargs("UVM_TESTNAME=%s", test_name)) begin
            if (test_name =="mc_single_bit_error_injection_test") begin
                force dut.dual_port_ram_inst.RAM_rd_data[15] = 1'b1;
            end
        end
    end

  //Double bit error injection
    initial begin
        string test_name;
        if ($value$plusargs("UVM_TESTNAME=%s", test_name)) begin
            if (test_name == "mc_double_bit_error_injection_test") begin
                force dut.dual_port_ram_inst.RAM_rd_data[9:8] =2'b01;
            end
        end
    end

    initial begin
        string test_name;
        if ($value$plusargs("UVM_TESTNAME=%s", test_name)) begin
            if (test_name == "mc_interrupt_enable_test") begin
                force dut.dual_port_ram_inst.RAM_rd_data[14:13] = 2'b11;
            end
        end
    end


    initial begin
        string test_name;
        if ($value$plusargs("UVM_TESTNAME=%s", test_name)) begin
            if (test_name == "mc_interrupt_disable_test") begin
                force dut.dual_port_ram_inst.RAM_rd_data[14:13] = 2'b11;
            end
        end
    end

// Setting config_db
    initial
    begin

//setting config db in top
    uvm_config_db#(virtual mc_interface)::set(null,"*","mc_interface", intf);
    uvm_config_db#(virtual mc_apb_interface)::set(null,"*","mc_apb_interface", apb_intf);
    end

//wave generation
    initial 
        begin
        $shm_open("wave.shm");
        $shm_probe("ACTMF");
        end

// Run_test
    initial
        begin
        run_test("mc_base_test");
        end

endmodule


