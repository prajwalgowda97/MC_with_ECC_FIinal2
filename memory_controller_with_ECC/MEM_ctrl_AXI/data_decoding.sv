
module data_decoding#(
                      parameter DATA_WIDTH        = 32                                        ,
                      parameter PARITY_BITS       = 6                                         ,
                      parameter MEMORY_DATA_WIDTH = 39
                     )
                     (
                       input    logic   [MEMORY_DATA_WIDTH-1:0]       rd_data_i         ,

                       output   logic   [MEMORY_DATA_WIDTH-1:0]       rd_data_o         ,
                       output   logic   [PARITY_BITS:0]               parity_dec_o      ,
                       output   logic   [DATA_WIDTH-1:0]              rd_data_dec        
                     );  

                     //-------DECOCDING THE PARITY BITS AND DATA FROM THE ENCODED DATA -------- 
                     always_comb
                     begin
                //   rd_data_o     =  rd_data_i                                                                                                       ;
                //   parity_dec_o  =  {rd_data_i[32] , rd_data_i[16] , rd_data_i[8] , rd_data_i[4] , rd_data_i[2:0]}                                  ; 
                //   rd_data_dec   =  {rd_data_i[38:33] , rd_data_i[31:17] , rd_data_i[15:9] , rd_data_i[7:5] , rd_data_i[3]}                         ;
                     parity_dec_o  =  rd_data_i[38:32]                                                                                                                                          ;
                     rd_data_dec   =  rd_data_i[31:0]                                                                                                                                           ;
                     rd_data_o     =  {rd_data_i[31:26],rd_data_i[38],rd_data_i[25:11],rd_data_i[37],rd_data_i[10:4],rd_data_i[36],rd_data_i[3:1],rd_data_i[35],rd_data_i[0],rd_data_i[34:32]}  ;
                     end
                     //------------------------------------------------------------------------

endmodule                      

