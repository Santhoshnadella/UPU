/**
 * UPU v2 "Ultra" UVM Verification Environment
 * Target: Industrial Grade Verification for 2nm/7nm Silicon.
 */

`include "uvm_macros.svh"
import uvm_pkg::*;

// -------------------------------------------------------------------------
// 1. INTERFACE DEFINITION
// -------------------------------------------------------------------------
interface upu_noc_if(input logic clk);
    logic [255:0] flit;
    logic         valid;
    logic         ready;

    clocking cb @(posedge clk);
        default input #1ns output #1ns;
        output flit, valid;
        input  ready;
    endclocking
endinterface

// -------------------------------------------------------------------------
// 2. TRANSACTION (SEQUENCE ITEM)
// -------------------------------------------------------------------------
class upu_transaction extends uvm_sequence_item;
    rand logic [255:0] flit;
    
    `uvm_object_utils_begin(upu_transaction)
        `uvm_field_int(flit, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "upu_transaction");
        super.new(name);
    endfunction
endclass

// -------------------------------------------------------------------------
// 3. DRIVER
// -------------------------------------------------------------------------
class upu_driver extends uvm_driver #(upu_transaction);
    virtual upu_noc_if vif;

    `uvm_component_utils(upu_driver)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            drive_item(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_item(upu_transaction item);
        @(vif.cb);
        vif.cb.flit  <= item.flit;
        vif.cb.valid <= 1'b1;
        wait(vif.cb.ready);
        @(vif.cb);
        vif.cb.valid <= 1'b0;
    endtask
endclass

// -------------------------------------------------------------------------
// 4. MONITOR
// -------------------------------------------------------------------------
class upu_monitor extends uvm_monitor;
    virtual upu_noc_if vif;
    uvm_analysis_port #(upu_transaction) item_collected_port;

    `uvm_component_utils(upu_monitor)

    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            upu_transaction tr;
            @(vif.cb);
            if (vif.cb.valid && vif.cb.ready) begin
                tr = upu_transaction::type_id::create("tr");
                tr.flit = vif.cb.flit;
                item_collected_port.write(tr);
            end
        end
    endtask
endclass

// -------------------------------------------------------------------------
// 5. AGENT
// -------------------------------------------------------------------------
class upu_agent extends uvm_agent;
    upu_driver    driver;
    upu_monitor   monitor;
    upu_sequencer #(upu_transaction) sequencer;

    `uvm_component_utils(upu_agent)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        monitor = upu_monitor::type_id::create("monitor", this);
        if (get_is_active() == UVM_ACTIVE) begin
            driver = upu_driver::type_id::create("driver", this);
            sequencer = uvm_sequencer#(upu_transaction)::type_id::create("sequencer", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        if (get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction
endclass

// -------------------------------------------------------------------------
// 6. SCORED BOARD (SIMPLIFIED)
// -------------------------------------------------------------------------
class upu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(upu_scoreboard)
    
    uvm_analysis_imp #(upu_transaction, upu_scoreboard) item_collected_export;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        item_collected_export = new("item_collected_export", this);
    endfunction

    function void write(upu_transaction tr);
        `uvm_info("SCB", $sformatf("Observed Flit on NoC: %h", tr.flit), UVM_LOW)
    endfunction
endclass

// -------------------------------------------------------------------------
// 7. ENVIRONMENT
// -------------------------------------------------------------------------
class upu_env extends uvm_env;
    upu_agent      agent;
    upu_scoreboard sb;

    `uvm_component_utils(upu_env)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        agent = upu_agent::type_id::create("agent", this);
        sb = upu_scoreboard::type_id::create("sb", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        agent.monitor.item_collected_port.connect(sb.item_collected_export);
    endfunction
endclass
