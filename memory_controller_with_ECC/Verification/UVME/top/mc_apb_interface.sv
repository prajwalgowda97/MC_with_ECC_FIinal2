interface mc_apb_interface (input logic zmc_top_clk);

              //  REGISTERS SIGNALS 
                  logic                        zmc_top_rstn          ;
                  logic                        zmc_top_sw_rst        ;
                  logic                        i_psel                ;
                  logic                        i_penable             ;
                  logic                        i_pwrite              ;
                  logic [31:0]                 i_pwdata              ;
                  logic [31:0]                 i_paddr               ;
                  logic [3:0]                  i_pstrb               ;
                  logic                        i_ECC_STAUS_REG_clear ;

clocking mc_apb_driver_cb @(posedge zmc_top_clk);
  default input #1 output #1;

  output   zmc_top_rstn;
  output   i_psel;
  output   i_penable;
  output   i_paddr;
  output   i_pwrite;
  output   i_pstrb;
  output   i_pwdata;
  output   i_ECC_STAUS_REG_clear;

endclocking


clocking mc_apb_monitor_cb @(posedge zmc_top_clk);
  default input #1 output #1;
  input       zmc_top_rstn;
  input       i_psel;
  input       i_penable;
  input       i_paddr;
  input       i_pwrite;
  input       i_pstrb;
  input       i_pwdata;
  input       i_ECC_STAUS_REG_clear;

endclocking 


endinterface

