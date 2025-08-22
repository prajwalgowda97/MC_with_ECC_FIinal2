class mc_base_test extends uvm_test;

    //fectory registration
    `uvm_component_utils(mc_base_test)

    //env handle creation
    mc_env env;
    mc_base_sequence base_seq;
     
    //constructor
    function new(string name = "mc_base_test", uvm_component parent =null);
        super.new(name, parent);
        `uvm_info(get_type_name(), "Inside Constuctor!", UVM_MEDIUM)
    endfunction

    //build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env=mc_env::type_id::create("env",this);
    base_seq = mc_base_sequence::type_id::create("base_seq");
    `uvm_info(get_type_name(), "Inside Build Phase!", UVM_MEDIUM)
    endfunction
    
    //end of elaboration
    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
#1000;
        `uvm_info(get_name(), $sformatf("inside base test"),UVM_MEDIUM)
        phase.drop_objection(this);
    endtask
endclass
