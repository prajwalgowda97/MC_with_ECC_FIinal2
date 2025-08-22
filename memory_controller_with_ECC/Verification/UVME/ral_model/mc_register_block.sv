//////////////////////////////////////////////////////////////////////
// RAL Register Model
/////////////////////////////////////////////////////////////////////
// ECC Status Register (0x00)
class o_ECC_STAUS_REG_ECC_STAUS extends uvm_reg;
  `uvm_object_utils(o_ECC_STAUS_REG_ECC_STAUS)
  uvm_reg_field ecc_status;

  function new(string name = "o_ECC_STAUS_REG_ECC_STAUS");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    ecc_status = uvm_reg_field::type_id::create("ecc_status");
    ecc_status.configure(
      this, 2, 0, "RO", 0, 0, 1, 0, 1
    );                              
  endfunction
endclass

// ECC Interrupt Enable Register (0x04)
class o_ECC_EN_IRQ_REG_ECC_EN_IRQ_REG extends uvm_reg;
  `uvm_object_utils(o_ECC_EN_IRQ_REG_ECC_EN_IRQ_REG)
  uvm_reg_field irq_enable;

  function new(string name = "o_ECC_EN_IRQ_REG_ECC_EN_IRQ_REG");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    irq_enable = uvm_reg_field::type_id::create("irq_enable");
    irq_enable.configure(
      this, 1, 0, "RW", 0, 0, 1, 0, 1
    );                              
  endfunction
endclass

// ECC Enable Register (0x08)
class o_ECC_ONOFF_REG_ECC_ONOFF_REG extends uvm_reg;
  `uvm_object_utils(o_ECC_ONOFF_REG_ECC_ONOFF_REG)
  uvm_reg_field ecc_enable;

  function new(string name = "o_ECC_ONOFF_REG_ECC_ONOFF_REG");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction

  virtual function void build();
    ecc_enable = uvm_reg_field::type_id::create("ecc_enable");
    ecc_enable.configure(
      this, 1, 0, "RW", 0, 0, 1, 0, 1
    );                              
  endfunction
endclass



//////////////////////////////////////////////////////////////////////
// RAL Register Block
/////////////////////////////////////////////////////////////////////

class mc_register_block extends uvm_reg_block;
  `uvm_object_utils(mc_register_block)
  
  // Register instances
  o_ECC_STAUS_REG_ECC_STAUS            o_ecc_staus_reg_ecc_staus;
  o_ECC_EN_IRQ_REG_ECC_EN_IRQ_REG      o_ecc_en_irq_reg_ecc_en_irq_reg;
  o_ECC_ONOFF_REG_ECC_ONOFF_REG        o_ecc_onoff_reg_ecc_onoff_reg;
  
  uvm_reg_map default_map;
  
  function new(string name = "mc_register_block");
    super.new(name, UVM_NO_COVERAGE);
  endfunction
  
  virtual function void build();
    // Create the register map
    default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN, 1);
    
    // ECC Status Register
    o_ecc_staus_reg_ecc_staus = o_ECC_STAUS_REG_ECC_STAUS::type_id::create("o_ecc_staus_reg_ecc_staus");
    o_ecc_staus_reg_ecc_staus.build();
    o_ecc_staus_reg_ecc_staus.configure(this, null);
    default_map.add_reg(o_ecc_staus_reg_ecc_staus, 'h0);
    
    // Interrupt Enable Register  
    o_ecc_en_irq_reg_ecc_en_irq_reg = o_ECC_EN_IRQ_REG_ECC_EN_IRQ_REG::type_id::create("o_ecc_en_irq_reg_ecc_en_irq_reg");
    o_ecc_en_irq_reg_ecc_en_irq_reg.build();
    o_ecc_en_irq_reg_ecc_en_irq_reg.configure(this, null);
    default_map.add_reg(o_ecc_en_irq_reg_ecc_en_irq_reg, 'h4);
    
    // ECC ON/OFF Register
    o_ecc_onoff_reg_ecc_onoff_reg = o_ECC_ONOFF_REG_ECC_ONOFF_REG::type_id::create("o_ecc_onoff_reg_ecc_onoff_reg");
    o_ecc_onoff_reg_ecc_onoff_reg.build();
    o_ecc_onoff_reg_ecc_onoff_reg.configure(this, null);
    default_map.add_reg(o_ecc_onoff_reg_ecc_onoff_reg, 'h8);
    
    // Lock the model after all registers are configured
    lock_model();
  endfunction
endclass
