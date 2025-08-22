class mc_base_sequence extends uvm_sequence #(mc_axi_seq_item);

//factory registrastion
`uvm_object_utils (mc_base_sequence)

//seq_item handle creation
mc_axi_seq_item axi_seq_item;

int scenario;

//constructor
function new(string name="mc_base_sequence");
super.new(name);
endfunction

//build_phase
function void build_phase(uvm_phase phase);
//super.build_phase(phase);
axi_seq_item = mc_axi_seq_item::type_id::create("axi_seq_item"); //clarity

endfunction

//task body

  task body();
 start_item(axi_seq_item);

 finish_item(axi_seq_item);
         
  endtask

endclass
