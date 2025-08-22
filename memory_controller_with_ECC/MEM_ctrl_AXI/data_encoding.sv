

module data_enc
              #(
                parameter DATA_WIDTH        =  32                                          ,
                parameter MEMORY_DATA_WIDTH =  39                                          ,
                parameter ADDR_WIDTH        =  14                                          ,
                parameter PARITY_BITS       =  6     
               )
               (
                input   logic                                ECC_en                   ,

                input   logic                                wr_en_i                  ,
                input   logic  [ADDR_WIDTH-1:0]              wr_addr_i                ,
                input   logic  [DATA_WIDTH-1:0]              data_in                  ,
                input   logic  [PARITY_BITS:1]               parity_bits_in           ,

                output  logic                                wr_en_o                  ,
                output  logic  [ADDR_WIDTH-1:0]              wr_addr_o                ,                  
                output  logic  [MEMORY_DATA_WIDTH-1:0]       encoded_data    
               );

               logic                    parity_bit                                    ;
               logic  [ADDR_WIDTH-1:0]  wr_addr_w                                     ;
               logic  [ADDR_WIDTH-1:0]  wr_addr_w1                                    ;

               assign wr_addr_w  = {wr_addr_i[13:2],{2'd0}}                           ;
               assign wr_addr_w1 = wr_addr_w >> 2'd2                                  ;

               //    PADDING THE INPUT DATA AND PARITY CALCULATED DATA
               always_comb
               begin
               wr_en_o      = wr_en_i                                                 ;
               wr_addr_o    = wr_addr_w1                                              ;

               if(ECC_en)
                   begin
                   parity_bit   = (
                                   data_in[0]        ^ data_in[16]       ^
                                   data_in[1]        ^ data_in[17]       ^
                                   data_in[2]        ^ data_in[18]       ^
                                   data_in[3]        ^ data_in[19]       ^
                                   data_in[4]        ^ data_in[20]       ^
                                   data_in[5]        ^ data_in[21]       ^
                                   data_in[6]        ^ data_in[22]       ^
                                   data_in[7]        ^ data_in[23]       ^
                                   data_in[8]        ^ data_in[24]       ^
                                   data_in[9]        ^ data_in[25]       ^
                                   data_in[10]       ^ data_in[26]       ^
                                   data_in[11]       ^ data_in[27]       ^
                                   data_in[12]       ^ data_in[28]       ^
                                   data_in[13]       ^ data_in[29]       ^
                                   data_in[14]       ^ data_in[30]       ^
                                   data_in[15]       ^ data_in[31]       ^
                                   parity_bits_in[1] ^ parity_bits_in[2] ^
                                   parity_bits_in[3] ^ parity_bits_in[4] ^
                                   parity_bits_in[5] ^ parity_bits_in[6]
                                  )                                                      ;
                   end
               else
                   begin
                   parity_bit = 1'b0                ;
                   end
               end

//assign encoded_data = {data_in[31:26],parity_bits_in[6],data_in[25:11],parity_bits_in[5],data_in[10:4],parity_bits_in[4],data_in[3:1],parity_bits_in[3],data_in[0],parity_bits_in[2:1],parity_bit}    ;                                

assign encoded_data={parity_bits_in[6:1],parity_bit,data_in[31:0]};                           

endmodule               
