import fixed_pkg::*;


module gain_loss_unit 
#(
    parameter G_PIPELINED=0,
    parameter G_POLARITY=0
)
(
    input logic i_clk,
    input logic i_rst,
    input logic i_valid, 
    input uq8_8_t i_past_price,
    input uq8_8_t i_actual_price,
    output uq8_8_t o_gain, 
    output uq8_8_t o_loss,
    output logic o_valid
);

uq8_8_t s_gain;
uq8_8_t s_loss;
logic s_valid;


generate
    if (G_PIPELINED) begin : pipelined
        always_ff @(posedge i_clk) begin
            if (i_rst == G_POLARITY) begin
                s_gain <= '0;
                s_loss <= '0;
                s_valid<=1'b0;
            end else begin
                s_gain <= (i_past_price < i_actual_price) ? (i_actual_price - i_past_price) : 0;
                s_loss <= (i_past_price > i_actual_price) ? (i_past_price  - i_actual_price) : 0;
                s_valid<=i_valid;
            end
        end
    end 
endgenerate  

generate
    if (!G_PIPELINED) begin : combinational
        always_comb begin
            s_gain = (i_past_price < i_actual_price) ? (i_actual_price - i_past_price) : 0;
            s_loss = (i_past_price > i_actual_price) ? (i_past_price  - i_actual_price) : 0;
            s_valid=i_valid;
        end
    end
endgenerate

assign o_gain=s_gain;
assign o_loss=s_loss;   
assign o_valid=s_valid; 

endmodule