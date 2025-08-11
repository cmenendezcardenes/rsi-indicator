`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;

import fixed_pkg::*;
import test_pkg::*;


module tb;
    rsi_if vif ();

    initial begin 
        vif.clk=0;
        vif.rst=1;
        vif.curr_price  = '0;
  vif.valid_price = 0;
    end

    localparam CLK_PERIOD = 10;
    always #(CLK_PERIOD/2) vif.clk=~vif.clk;
    top_rsi #(.N(14),.G_POLARITY(0)) dut (
        .i_clk(vif.clk),
        .i_rst(vif.rst),
        .i_en(vif.en),
        .i_prices(vif.prices),
        .o_rsi_scaled(vif.rsi_scaled),
        .o_rsi_valid(vif.rsi_valid),
        .i_curr_price(vif.curr_price),
        .i_valid_price(vif.valid_price)
    );




initial begin
    uvm_config_db#(virtual rsi_if)::set(null,"","vif",vif);
    run_test("test");
end

endmodule
