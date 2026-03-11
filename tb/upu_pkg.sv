/**
 * UPU UVM Package - Verification Environment
 */
package upu_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class upu_transaction extends uvm_sequence_item;
        rand logic [63:0] addr;
        rand logic [63:0] data;
        rand logic        we;
        
        `uvm_object_utils_begin(upu_transaction)
            `uvm_field_int(addr, UVM_ALL_ON)
            `uvm_field_int(data, UVM_ALL_ON)
            `uvm_field_int(we,   UVM_ALL_ON)
        `uvm_object_utils_end

        function new(string name = "upu_transaction");
            super.new(name);
        endfunction
    endclass

    // Agent, Driver, Monitor... (Simplified for Phase 3 Baseline)
endpackage
