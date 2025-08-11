`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
import transaction_pkg::*;
class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    uvm_analysis_port#(transaction) recv;
    int counter =1;
    function new(input string inst="SCO", uvm_component parent=null);
        super.new(inst,parent);
    endfunction 

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        recv=new("recv",this);
    endfunction

    virtual function void write(input transaction tr);
            `uvm_info("SCO", $sformatf("-------------------------"),UVM_NONE);
            `uvm_info("SCO", $sformatf("Sequence %0d", counter),UVM_NONE);
            `uvm_info("SCO", $sformatf("Enable %0d", tr.en),UVM_NONE);
            foreach(tr.prices[i])  begin
                `uvm_info("SCO", $sformatf("Price[%0d]= %0d", i,tr.prices[i]),UVM_NONE);
            end
            `uvm_info("SCO", $sformatf("-------------------------"),UVM_NONE);
            counter ++;
    endfunction

endclass 