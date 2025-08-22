class mc_apb_seq_item extends uvm_sequence_item;

             rand     logic                        i_psel                                   ;
             rand     logic                        i_penable                                ;
             rand     logic                        i_pwrite                                 ;
             rand     logic [31:0]                 i_pwdata                                 ;
             rand     logic [9:0]                  i_paddr                                  ;
             rand     logic [3:0]                  i_pstrb                                  ;
             rand     logic                        i_ECC_STAUS_REG_clear                    ;
                      logic                        ecc_status                               ;
             rand     logic                        zmc_top_rstn                             ;  
 //factory registration
 `uvm_object_utils_begin(mc_apb_seq_item)
                        `uvm_field_int(i_psel               ,UVM_ALL_ON) 
                        `uvm_field_int(i_penable            ,UVM_ALL_ON)
                        `uvm_field_int(i_pwrite             ,UVM_ALL_ON)
                        `uvm_field_int(i_pwdata             ,UVM_ALL_ON)
                        `uvm_field_int(i_paddr              ,UVM_ALL_ON)
                        `uvm_field_int(i_pstrb              ,UVM_ALL_ON)
                        `uvm_field_int(i_ECC_STAUS_REG_clear,UVM_ALL_ON)
                        `uvm_field_int(zmc_top_rstn         ,UVM_ALL_ON)

 `uvm_object_utils_end


 //constructor
  function new(string name="mc_apb_seq_item");
   super.new(name);
  endfunction
constraint c_paddr {i_paddr inside {0, 4, 8}; }

endclass
