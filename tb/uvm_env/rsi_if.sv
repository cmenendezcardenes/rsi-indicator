import fixed_pkg::*;

interface rsi_if;
logic   clk; 
logic   rst; 
logic   en; 
uq8_8_t prices[14]; //must be N
uq8_8_t rsi_scaled;
logic   rsi_valid;
uq8_8_t curr_price;
logic   valid_price;
endinterface 
