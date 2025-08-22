class mc_soft_reset_sequence extends uvm_sequence#(mc_axi_seq_item);

//factory registration
  `uvm_object_utils (mc_soft_reset_sequence)

     bit [31:0] addr;


  constraint addr_c { addr < 32'h1000_0000; }

  mc_axi_seq_item axi_seq_item;        
  int scenario;
    
//constructor
 function new (string name= "mc_soft_reset_sequence" );
    super.new(name);
  
  endfunction
  
  // build phase
  function void build_phase(uvm_phase phase);
        //axi_seq_item = mc_axi_seq_item::type_id::create("axi_seq_item");
  endfunction

  task body();

// soft_reset zero 
    if(scenario == 1)
  
   // Assert soft_reset & reset
   // axi_seq_item = axi_seq_item::type_id::create("axi_seq_item");
    axi_seq_item = mc_axi_seq_item::type_id::create("axi_seq_item");
    start_item(axi_seq_item);
    axi_seq_item.zmc_top_rstn   = 0;
    axi_seq_item.zmc_top_sw_rst = 1;
    finish_item(axi_seq_item);

    // Wait during soft_reset
    #(100);

   // Deassert soft_reset & Assert reset
   // axi_seq_item = axi_seq_item::type_id::create("axi_seq_item");
    axi_seq_item = mc_axi_seq_item::type_id::create("axi_seq_item");
    start_item(axi_seq_item);
    axi_seq_item.zmc_top_rstn   = 0;
    axi_seq_item.zmc_top_sw_rst = 0;
    finish_item(axi_seq_item);

        // Wait during soft_reset
    #(100);

   // Assert soft_reset & Deassert reset
   // axi_seq_item = axi_seq_item::type_id::create("axi_seq_item");
    axi_seq_item = mc_axi_seq_item::type_id::create("axi_seq_item");
    start_item(axi_seq_item);
    axi_seq_item.zmc_top_rstn   = 1;
    axi_seq_item.zmc_top_sw_rst = 1;
    finish_item(axi_seq_item);

    // Wait during soft_reset
    #(100);

   // Deassert soft_reset & reset
   // axi_seq_item = axi_seq_item::type_id::create("axi_seq_item");
    axi_seq_item = mc_axi_seq_item::type_id::create("axi_seq_item");
    start_item(axi_seq_item);
    axi_seq_item.zmc_top_rstn   = 1;
    axi_seq_item.zmc_top_sw_rst = 0;
    finish_item(axi_seq_item);


    endtask
endclass

