class mc_apb_sequencer extends uvm_sequencer #(mc_apb_seq_item);

    `uvm_component_utils(mc_apb_sequencer)

    //constructor
    function new (string name= "mc_apb_sequencer", uvm_component parent=null);
        super.new(name,parent);
    `uvm_info("Sequencer_APB_class", "Inside Constructor!", UVM_MEDIUM)       
    endfunction

   //build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
  
endclass
