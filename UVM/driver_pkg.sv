package driver_pkg;
  `include "uvm_macros.svh"
  import transaction_pkg::*;
  import uvm_pkg::*;
  
class driver extends uvm_driver#(transaction);
    `uvm_component_utils(driver)

    virtual rsi_if vif;
    transaction tr;

    function new(input string inst="DRV", uvm_component parent=null);
        super.new(inst,parent);
    endfunction 

    task reset_dut(); 
        vif.rst<=1'b0;
        vif.en<=1'b0;
        foreach (vif.prices[i]) begin
            vif.prices[i] <= 16'd0;
        end
        repeat(5)@(posedge vif.clk);
        vif.rst<=~vif.rst;
        `uvm_info("DRV", "Reset Done",UVM_NONE);
    endtask 

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        tr=transaction::type_id::create("tr");
        if (!uvm_config_db#(virtual rsi_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("DRV", "Unable to access vif from uvm_config_db")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        reset_dut(); 
        forever begin
            seq_item_port.get_next_item(tr);
            vif.en<=tr.en;
            vif.valid_price<=tr.valid_price;
            vif.curr_price<=tr.curr_price;
            //vif.prices<=tr.prices;
            foreach (tr.prices[i]) begin
                vif.prices[i] <= tr.prices[i];
            end
            seq_item_port.item_done(); 
            `uvm_info("DRV", $sformatf("-------------------------"),UVM_NONE);
            `uvm_info("DRV", $sformatf("Enable %0d", tr.en),UVM_NONE);
            if (tr.en==1) begin
                foreach(tr.prices[i])  begin
                    `uvm_info("DRV", $sformatf("Price[%0d]= %0d", i,tr.prices[i]),UVM_NONE);
                end
            end
            `uvm_info("DRV", $sformatf("-------------------------"),UVM_NONE);
            repeat(1)@(posedge vif.clk);
            vif.en<=0;
            vif.valid_price<=0;
            repeat(8)@(posedge vif.clk);
        end
    endtask
endclass 
endpackage