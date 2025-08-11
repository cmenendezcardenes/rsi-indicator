import fixed_pkg::*;
module top_rsi 
#(
    parameter N=14,
    parameter G_POLARITY=0
)
(
    input  logic    i_clk,
    input  logic    i_rst,
    input  logic    i_en,
    input  uq8_8_t  i_prices[N],
    output uq8_8_t  o_rsi_scaled,
    output logic    o_rsi_valid,
    input  uq8_8_t i_curr_price,  
    input  logic   i_valid_price
);
logic s_en_rs_to_rsi;
uq8_8_t s_rs_scaled;

rsi_seq #(.G_POLARITY(G_POLARITY)) u_rsi_seq (
        .i_clk(i_clk), 
        .i_rst(i_rst),
        .i_en(s_en_rs_to_rsi),
        .i_rs_scaled(s_rs_scaled),
        .o_rsi_scaled(o_rsi_scaled),
        .o_rsi_valid(o_rsi_valid)
);

rs_q8_8_seq #(.G_POLARITY(G_POLARITY),.N(N)) u_rs_q8_8 (
        .i_clk(i_clk), 
        .i_rst(i_rst),
        .i_en(i_en),
        .i_prices(i_prices),
        .o_rs_scaled(s_rs_scaled),
        .o_rs_valid(s_en_rs_to_rsi)    ,
        .i_curr_price(i_curr_price),
        .i_valid_price(i_valid_price)
);
endmodule

