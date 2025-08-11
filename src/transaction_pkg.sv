`timescale 1ns/1ps


package transaction_pkg;
`include "uvm_macros.svh"
import uvm_pkg::*;
class transaction extends uvm_sequence_item;

    //randc bit [15:0] prices[N];  //option 1
    bit [15:0] prices[]; //option 2 //it should be rand but I dont have the license 
    bit en; //it should be rand but I dont have the license
    bit [15:0]  rsi_scaled;
    bit  rsi_valid;
    bit valid_price;
    bit [15:0] curr_price;


    //constraint en_c{ en dist{0:=30, 1:=60};} //it should be rand but I dont have the license
    
    function new(input string inst="transaction");
        super.new(inst);
    endfunction

    function void set_size(int size);
        prices=new[size];
    endfunction

    function void manual_randomize();
      en = 0; 
      valid_price=1;
      curr_price=10000;
      foreach (prices[i])
        prices[i] = '0; 
    endfunction

    function void manual_randomize1();
      en = 0; 
      valid_price=1;
      curr_price=1000;
      foreach (prices[i])
        prices[i] = '0; 
    endfunction

    function void stop_randomize();
      en = 0; 
      valid_price=0;
      curr_price='0;
      foreach (prices[i])
        prices[i] = '0; 
    endfunction

    function void init_values(); 
      en=1;//($urandom() % 10 < 6);  // 60% probabilidad de 1
      valid_price=0;
      curr_price='0;
      foreach (prices[i])
        prices[i] = $urandom_range(2000, 10000);
    endfunction

    function void disable_();
      en = 0; //($urandom() % 10 < 6);  // 60% probabilidad de 1
      foreach (prices[i])
        prices[i] = $urandom_range(2000, 50000); // Valores aleatorios entre 100 y 1000
    endfunction

    `uvm_object_utils_begin(transaction)
    `uvm_field_int(en, UVM_DEFAULT);
    `uvm_field_int(rsi_valid, UVM_DEFAULT);
    `uvm_field_array_int(prices, UVM_DEFAULT|UVM_DEC);
    `uvm_field_int(rsi_scaled, UVM_DEFAULT|UVM_DEC);
    `uvm_object_utils_end


endclass 
endpackage