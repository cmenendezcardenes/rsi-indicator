`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;


class transaction extends uvm_sequence_item;

    //randc bit [15:0] prices[N];  //option 1
    randc bit [15:0] prices[]; //option 2
    rand bit en;
    bit [15:0]  rsi_scaled;
    bit  rsi_valid;

    constraint en_c{ en dist{0:=30, 1:=60};}
    
    function new(input string inst="transaction");
        super.new(inst);
    endfunction

    function void set_size(int size);
        prices=new[size];
    endfunction

    `uvm_object_utils_begin(transaction)
    `uvm_field_int(en, UVM_DEFAULT);
    `uvm_field_int(rsi_valid, UVM_DEFAULT);
    `uvm_field_array_int(prices, UVM_DEFAULT|UVM_DEC);
    `uvm_field_int(rsi_scaled, UVM_DEFAULT|UVM_DEC);
    `uvm_object_utils_end


endclass 