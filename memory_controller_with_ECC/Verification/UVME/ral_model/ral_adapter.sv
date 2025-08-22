class ral_adapter extends uvm_reg_adapter;

  `uvm_object_utils(ral_adapter)

  function new(string name = "ral_adapter");
    super.new(name);
    // Required: to force transaction to be aligned
    supports_byte_enable = 0;
  endfunction

  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    mc_apb_seq_item tx = mc_apb_seq_item::type_id::create("tx");

    tx.i_pwrite   = (rw.kind == UVM_WRITE) ? 1'b1 : 1'b0;
    tx.i_paddr    = rw.addr;
    tx.i_pwdata   = rw.data;
    tx.i_psel     = 1'b1;
    tx.i_penable  = 1'b1;

    `uvm_info("RAL_ADAPTER", $sformatf(
      "reg2bus: kind=%s addr=0x%0h data=0x%0h", rw.kind.name(), rw.addr, rw.data), UVM_DEBUG)

    return tx;
  endfunction

  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    mc_apb_seq_item tx;

    if (!$cast(tx, bus_item)) begin
      `uvm_fatal("RAL_ADAPTER", $sformatf(
        "Failed to cast bus_item to mc_apb_seq_item. Got: %s", bus_item.get_type_name()))
    end

    rw.kind   = (tx.i_pwrite == 1'b1) ? UVM_WRITE : UVM_READ;
    rw.addr   = tx.i_paddr;
    rw.data   = tx.i_pwdata;
    rw.status = UVM_IS_OK;

    `uvm_info("RAL_ADAPTER", $sformatf(
      "bus2reg: kind=%s addr=0x%0h data=0x%0h", rw.kind.name(), rw.addr, rw.data), UVM_DEBUG)
  endfunction

endclass

