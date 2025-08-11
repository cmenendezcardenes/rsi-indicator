`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
import transaction_pkg::*;
class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)

    virtual rsi_if vif;
    transaction tr;
    uvm_analysis_port#(transaction) send;

    function new(input string inst="MON", uvm_component parent=null);
        super.new(inst,parent);
    endfunction 

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr=transaction::type_id::create("tr");
        send=new("send",this);
        if (!uvm_config_db#(virtual rsi_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("MON", "Unable to access vif from uvm_config_db")
        end
    endfunction

    virtual task run_phase(uvm_phase phase); 
        forever begin
            repeat(2) @(posedge vif.clk);
            tr.en=vif.en;
            foreach (vif.prices[i]) begin
                tr.prices[i] = vif.prices[i];
            end
            tr.rsi_scaled=vif.rsi_scaled;
            tr.rsi_valid=vif.rsi_valid;
            send.write(tr);
            tr.print(uvm_default_line_printer);
        end
    endtask
endclass 