`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
import transaction_pkg::*;
class generator extends uvm_sequence#(transaction);
    `uvm_object_utils(generator)

    transaction tr; 

    function new(input string path="generator");
        super.new(path);
    endfunction 

    virtual task body(); 
    int counter=1; 
    repeat (5)
        begin 
            tr=transaction::type_id::create("tr");
            tr.set_size(14);
            start_item(tr);
            assert(tr.randomize());
            `uvm_info("SEQ", $sformatf("-------------------------"),UVM_NONE);
            `uvm_info("SEQ", $sformatf("Sequence %0d", counter),UVM_NONE);
            `uvm_info("SEQ", $sformatf("Enable %0d", tr.en),UVM_NONE);
            if (tr.en==1) begin
                foreach(tr.prices[i])  begin
                    `uvm_info("SEQ", $sformatf("Price[%0d]= %0d", i,tr.prices[i]),UVM_NONE);
                end
            end
            counter++;
            `uvm_info("SEQ", $sformatf("-------------------------"),UVM_NONE);
            finish_item(tr);
        end
    endtask
endclass