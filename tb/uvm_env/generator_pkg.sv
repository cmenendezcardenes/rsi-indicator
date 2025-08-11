package generator_pkg;
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
        repeat (4)
        begin 
            tr=transaction::type_id::create("tr");
            tr.set_size(14);
            start_item(tr);
            //assert(tr.randomize());
        
            if (counter==3) begin 
                tr.manual_randomize();
            end
            if (counter==4) begin 
                tr.manual_randomize1();
            end
            if (counter==1) begin 
                tr.init_values();
            end
            if (counter==2 ) begin 
                tr.stop_randomize();
            end
            `uvm_info("SEQ", $sformatf("-------------------------"),UVM_NONE);
            `uvm_info("SEQ", $sformatf("Sequence %0d", counter),UVM_NONE);
            `uvm_info("SEQ", $sformatf("Enable %0d", tr.en),UVM_NONE);
            `uvm_info("SEQ", $sformatf("Valid %0d", tr.valid_price),UVM_NONE);
            `uvm_info("SEQ", $sformatf("curr_price %0d", tr.curr_price),UVM_NONE);
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
endpackage