import fixed_pkg::*;
module rsi_seq
#(
    parameter G_POLARITY=0
)
(
    input  logic    i_clk,
    input  logic    i_rst,
    input  logic    i_en,
    input  uq8_8_t  i_rs_scaled,
    output uq8_8_t  o_rsi_scaled,
    output logic    o_rsi_valid
);

localparam int FRAC_Q8 = 8;
localparam uq8_8_t ONE_Q8      = uq8_8_t'(1 << FRAC_Q8);      
localparam uq8_8_t HUNDRED_Q8  = uq8_8_t'(100 << FRAC_Q8); 

uq8_8_t    denom_q8;
uq8_8_t    rsi_q8;
logic [63:0] num64; 

always_comb begin
    denom_q8 = ONE_Q8 + i_rs_scaled;
    num64   = (64'(HUNDRED_Q8) << FRAC_Q8);
    rsi_q8  = HUNDRED_Q8 - uq8_8_t'( num64 / denom_q8 );
end

always_ff @(posedge i_clk ) begin 
    if (i_rst==G_POLARITY) begin
        o_rsi_valid<=1'b0;
    end else begin
        if (i_en) begin 
            o_rsi_valid<=1'b1;
            o_rsi_scaled<=rsi_q8;
        end else begin
            o_rsi_valid<=1'b0;
        end
    end
end

endmodule