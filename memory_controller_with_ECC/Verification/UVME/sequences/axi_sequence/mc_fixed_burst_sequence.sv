class mc_fixed_burst_sequence extends uvm_sequence#(mc_axi_seq_item);

//factory registration
  `uvm_object_utils (mc_fixed_burst_sequence)

  //constraint addr_c { awaddr < 32'h100_0000; }

  mc_axi_seq_item axi_seq_item;        
     int scenario;
     int i = 0;
   
     bit [31:0] addr[$];
     bit [3:0]  len[$] ;
     bit [1:0] burst[$];
                         
     int temp_araddr;
     int temp_arlen;
     int temp_arburst;
     
//constructor
  function new (string name= "mc_fixed_burst_sequence" );
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
        begin
        for (int i = 0; i < 10; i++) 
         begin

           `uvm_info(get_type_name(),$sformatf("Write scenario 4 Started"),UVM_MEDIUM) 
                        // Read back the data to verify
                    `uvm_do_with(axi_seq_item, {
                         axi_seq_item.zmc_top_rstn    == 1;       
                         axi_seq_item.zmc_top_sw_rst  == 0;                
                         axi_seq_item.zmc_top_mem_init== 1;                
                         axi_seq_item.wr_rd           == 1;                
                         axi_seq_item.awvalid         == 1;                
                         axi_seq_item.awlen           == 3;                             
                         axi_seq_item.awburst         == 0;                       
                       //axi_seq_item.wdata[0]        == 0;                
                         axi_seq_item.wstrb           == 4'b1111;                          
                         axi_seq_item.wlast           == 1;                
                         axi_seq_item.wvalid          == 1;                
                         axi_seq_item.bready          == 1;
                         }) 
          
                        addr[i] = axi_seq_item.awaddr;
                        len[i]  = axi_seq_item.awlen ;
                        burst[i]= axi_seq_item.awburst;

           `uvm_info(get_type_name(),$sformatf("Write scenario 4 competed"),UVM_MEDIUM) 
         end 
        end
    
    if (scenario == 5)
        begin
        for (int i = 0; i < 10; i++) 
         begin

           `uvm_info(get_type_name(),$sformatf("Read scenario 5 Started"),UVM_MEDIUM) 
                         
                         temp_araddr  = addr[i];
                         temp_arlen   = len[i];
                         temp_arburst = burst[i];
                    
                    `uvm_do_with(axi_seq_item, {                
                        // Read back the data to verify

                         axi_seq_item.zmc_top_rstn    == 1;
                         axi_seq_item.zmc_top_sw_rst  == 0;
                         axi_seq_item.zmc_top_mem_init== 0;
                         axi_seq_item.wr_rd           == 0;
                         axi_seq_item.arvalid         == 0;
                         axi_seq_item.araddr          == temp_araddr;            
                         axi_seq_item.arlen           == temp_arlen;                 
                         axi_seq_item.arburst         == temp_arburst;
                         axi_seq_item.rready          == 0; 
                     }) 
                    
           `uvm_info(get_type_name(),$sformatf("Read scenario 5 competed"),UVM_MEDIUM) 
         end 
        end
    endtask
endclass

