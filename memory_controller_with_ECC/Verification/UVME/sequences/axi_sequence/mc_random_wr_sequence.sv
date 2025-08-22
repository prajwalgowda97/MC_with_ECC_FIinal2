class mc_random_wr_sequence extends uvm_sequence#(mc_axi_seq_item);

//factory registration
  `uvm_object_utils (mc_random_wr_sequence)

     bit [31:0] addr;
     bit [3:0]  len ;
     bit [1:0] burst;
     bit [31:0] aw_addr;
     
  mc_axi_seq_item axi_seq_item;        
  int scenario;
    
//constructor
 function new (string name= "mc_random_wr_sequence" );
    super.new(name);
  
  endfunction
  
  // build phase
  function void build_phase(uvm_phase phase);
        axi_seq_item = mc_axi_seq_item::type_id::create("axi_seq_item");
  endfunction

  task body();

// reset zero 
    if(scenario == 1)
         begin

           `uvm_info(get_type_name(),$sformatf("Reset scenario 1 Started"),UVM_MEDIUM) 
                    `uvm_do_with(axi_seq_item,{ 
                         axi_seq_item.zmc_top_rstn    == 0;       
                         axi_seq_item.zmc_top_sw_rst  == 1;                    
                         })                                      
            `uvm_info(get_type_name(),$sformatf("Reset scenario 1 competed"),UVM_MEDIUM) 
         end

// reset zero 
    if(scenario == 2)
         begin

           `uvm_info(get_type_name(),$sformatf("Reset disable scenario 2 Started"),UVM_MEDIUM) 
                    `uvm_do_with(axi_seq_item,{ 
                         axi_seq_item.zmc_top_rstn    == 1;       
                         axi_seq_item.zmc_top_sw_rst  == 0;
                         axi_seq_item.zmc_top_mem_init== 0;                
                                                  
                         axi_seq_item.wr_rd           == 0;
                         axi_seq_item.arvalid         == 1;
                         axi_seq_item.araddr          == 0;            
                         axi_seq_item.arlen           == 0;                 
                         axi_seq_item.arburst         == 0;
                         axi_seq_item.rready          == 1; 

                         })                                      
            `uvm_info(get_type_name(),$sformatf("Reset disable scenario 2 competed"),UVM_MEDIUM) 
         end

    if (scenario == 4)
        repeat (10)
         begin
           `uvm_info(get_type_name(),$sformatf("Write scenario 4 Started"),UVM_MEDIUM) 
                        // Read back the data to verify
                    `uvm_do_with(axi_seq_item, {
                         axi_seq_item.zmc_top_rstn    == 1;       
                         axi_seq_item.zmc_top_sw_rst  == 0;                
                         axi_seq_item.zmc_top_mem_init== 1;                
                         axi_seq_item.wr_rd           == 1;                
                         axi_seq_item.awvalid         == 1;                
                         axi_seq_item.awlen           == 0;                             
                         axi_seq_item.awburst         == 0;                       
                       //axi_seq_item.wdata[0]        == 0;                
                         axi_seq_item.wstrb           == 4'b1111;                          
                         axi_seq_item.wlast           == 1;                
                         axi_seq_item.wvalid          == 1;                
                         axi_seq_item.bready          == 1;
                         }) 
          
                        addr = axi_seq_item.awaddr;
                        len  = axi_seq_item.awlen ;
                        burst= axi_seq_item.awburst;

           `uvm_info(get_type_name(),$sformatf("Write scenario 4 competed"),UVM_MEDIUM) 
         end    
     endtask
endclass

