class mc_axi_sequencer extends uvm_sequencer #(mc_axi_seq_item);

    `uvm_component_utils(mc_axi_sequencer)

    //constructor
    function new (string name= "mc_axi_sequencer", uvm_component parent=null);
        super.new(name,parent);
   `uvm_info("Sequencer_AXI_class", "Inside Constructor!", UVM_MEDIUM)       
    endfunction

   //build phase
   function void build_phase(uvm_phase phase);
        super.build_phase(phase);
  endfunction
  
endclass
