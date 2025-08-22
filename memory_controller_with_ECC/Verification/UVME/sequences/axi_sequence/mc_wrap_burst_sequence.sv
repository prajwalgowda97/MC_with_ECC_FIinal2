class mc_wrap_burst_sequence extends uvm_sequence#(mc_axi_seq_item);

//factory registration
  `uvm_object_utils (mc_wrap_burst_sequence)

  mc_axi_seq_item axi_seq_item;        
     int scenario;
     int i = 0;
   
     bit [31:0] addr[$];
     bit [3:0]  len[$] ;
     bit [1:0] burst[$];
                         
     int temp_araddr;
     int temp_arlen;
     int temp_arburst;
     
     // Wrap boundary calculation variables
     bit [31:0] wrap_size;
     bit [31:0] lower_boundary;
     bit [31:0] upper_boundary;
     bit [31:0] current_addr;
     
//constructor
  function new (string name= "mc_wrap_burst_sequence" );
        super.new(name);  
  endfunction
  
  // build phase
  function void build_phase(uvm_phase phase);
        axi_seq_item = mc_axi_seq_item::type_id::create("axi_seq_item");
  endfunction

  // Function to calculate wrap boundaries
  function void calculate_wrap_boundaries(bit [31:0] start_addr, bit [3:0] burst_len);
    // Calculate wrap size: (AxLEN + 1) * 4 bytes (fixed 32-bit operation)
    wrap_size = (burst_len + 1) * 4;
    
    // Calculate lower boundary: (Start_Address / Wrap_Size) * Wrap_Size
    lower_boundary = (start_addr / wrap_size) * wrap_size;
    
    // Calculate upper boundary: Lower_boundary + Wrap_Size - 1
    upper_boundary = lower_boundary + wrap_size - 1;
    
    `uvm_info(get_type_name(), 
              $sformatf("Wrap Boundaries - Start: 0x%08x, Lower: 0x%08x, Upper: 0x%08x, Size: %0d bytes", 
                       start_addr, lower_boundary, upper_boundary, wrap_size), UVM_MEDIUM)
  endfunction

  // Function to get next wrapped address
  function bit [31:0] get_next_wrap_address(bit [31:0] current_addr);
    bit [31:0] next_addr;
    next_addr = current_addr + 4; // Add 4 bytes for 32-bit operation
    
    // Check if address exceeds upper boundary, then wrap to lower boundary
    if (next_addr > upper_boundary)
      next_addr = lower_boundary;
      
    return next_addr;
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

// reset disable
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

    // Write operation with wrap burst
    if (scenario == 4)
        begin
        for (int i = 0; i < 20; i++) 
         begin
           `uvm_info(get_type_name(),$sformatf("Write scenario 4 Started - Transaction %0d", i),UVM_MEDIUM)
                        
                    `uvm_do_with(axi_seq_item, {
                         axi_seq_item.zmc_top_rstn    == 1;       
                         axi_seq_item.zmc_top_sw_rst  == 0;                
                         axi_seq_item.zmc_top_mem_init== 1;                
                         axi_seq_item.wr_rd           == 1;                
                         axi_seq_item.awvalid         == 1;
                         axi_seq_item.awlen           == 15;                             
                         axi_seq_item.awburst         == 2'b10;                        
                         axi_seq_item.wstrb           == 4'b1111;                          
                         axi_seq_item.wlast           == 1;                
                         axi_seq_item.wvalid          == 1;                
                         axi_seq_item.bready          == 1;
                         }) 
          
                        addr[i] = axi_seq_item.awaddr;
                        len[i]  = axi_seq_item.awlen ;
                        burst[i]= axi_seq_item.awburst;

           // Calculate wrap boundaries using the randomized address
           calculate_wrap_boundaries(axi_seq_item.awaddr, axi_seq_item.awlen);
           
           // Log the expected wrap sequence for this transaction
           `uvm_info(get_type_name(), "Expected Address Sequence:", UVM_MEDIUM)
           current_addr = axi_seq_item.awaddr;
           for (int beat = 0; beat <= axi_seq_item.awlen; beat++) begin
             `uvm_info(get_type_name(), $sformatf("Beat %0d: Address 0x%08x", beat, current_addr), UVM_MEDIUM)
             if (beat < axi_seq_item.awlen) // Don't calculate next address for last beat
               current_addr = get_next_wrap_address(current_addr);
           end

           `uvm_info(get_type_name(),$sformatf("Write scenario 4 completed - Transaction %0d", i),UVM_MEDIUM) 
         end 
        end
    
    // Read operation with wrap burst
    if (scenario == 5)
        begin
        for (int i = 0; i < 20; i++) 
         begin
           `uvm_info(get_type_name(),$sformatf("Read scenario 5 Started - Transaction %0d", i),UVM_MEDIUM) 
                         
                         temp_araddr  = addr[i];
                         temp_arlen   = len[i];
                         temp_arburst = burst[i];
                    
                    // Recalculate wrap boundaries for read operation
                    calculate_wrap_boundaries(temp_araddr, temp_arlen);
                    
                    `uvm_do_with(axi_seq_item, {                
                         axi_seq_item.zmc_top_rstn    == 1;
                         axi_seq_item.zmc_top_sw_rst  == 0;
                         axi_seq_item.zmc_top_mem_init== 0;
                         axi_seq_item.wr_rd           == 0;
                         axi_seq_item.arvalid         == 1;  // Fixed: was 0, should be 1 for valid read
                         axi_seq_item.araddr          == temp_araddr;            
                         axi_seq_item.arlen           == temp_arlen;                 
                         axi_seq_item.arburst         == temp_arburst;
                         axi_seq_item.rready          == 1;  // Fixed: was 0, should be 1 for ready
                     }) 

           // Log the expected wrap sequence for read operation
           `uvm_info(get_type_name(), "Expected Read Address Sequence:", UVM_MEDIUM)
           current_addr = temp_araddr;
           for (int beat = 0; beat <= temp_arlen; beat++) begin
             `uvm_info(get_type_name(), $sformatf("Beat %0d: Address 0x%08x", beat, current_addr), UVM_MEDIUM)
             if (beat < temp_arlen) // Don't calculate next address for last beat
               current_addr = get_next_wrap_address(current_addr);
           end
                    
           `uvm_info(get_type_name(),$sformatf("Read scenario 5 completed - Transaction %0d", i),UVM_MEDIUM) 
         end 
        end
    endtask
endclass
