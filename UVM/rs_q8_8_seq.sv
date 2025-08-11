import fixed_pkg::*;

module rs_q8_8_seq
#(
    parameter N=14,
    parameter G_POLARITY=0
)
(
    input   logic   i_clk,
    input   logic   i_rst,
    input   logic   i_en,
    input   uq8_8_t i_prices[N],
    output  uq8_8_t o_rs_scaled,
    output  logic   o_rs_valid,
    input  uq8_8_t i_curr_price,  
    input  logic   i_valid_price
);

uq8_8_t gains [N-1];
uq8_8_t losses [N-1];
logic [N-2:0] s_output_valid ;
logic s_valid_reduction; 
uq16_16_t sum_gain, sum_loss;
logic s_valid_sum_gain;//=1'b0;
logic s_valid_sum_loss;//=1'b0;
uq16_16_t avg_gain, avg_loss;
uq16_16_t rs_temp;
uq8_8_t s_rs_scaled;
logic [63:0] rs_num; 
logic [63:0] gain_num; 
logic [63:0] loss_num; 
logic seed_done;
uq8_8_t last_prize;

// Bloque 1 : generacion de los tabs gain & losses
genvar j; 
generate
    for (j=0;j<N-1;j++) begin : GEN_GAIN_LOSS
        gain_loss_unit         #(
            .G_PIPELINED(1),
            .G_POLARITY(G_POLARITY)
        )u_gain_loss

        (
            .i_clk(i_clk),
            .i_rst(i_rst),
            .i_valid(i_en),
            .i_past_price     (i_prices[j]),
            .i_actual_price   (i_prices[j+1]),
            .o_gain           (gains[j]),
            .o_loss           (losses[j]),
            .o_valid (s_output_valid[j])
        );
    end
endgenerate

// bloque 2 : Tree adder
assign s_valid_reduction= s_output_valid[N-2]; // only if pipelined // if not pipelined, do a tab reduction $s_output_valid

tree_adder_14 #(
    .N(13),
    .G_POLARITY(G_POLARITY)
) inst_tree_adder_gain 

(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_valid(s_valid_reduction),
    .i_values(gains),
    .o_sum(sum_gain),
    .o_valid(s_valid_sum_gain)
);

tree_adder_14 #(
    .N(13),
    .G_POLARITY(G_POLARITY)
) inst_tree_adder_loss 

(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_valid(s_valid_reduction),
    .i_values(losses),
    .o_sum(sum_loss),
    .o_valid(s_valid_sum_loss)
);

// Bloque 3 : division
logic     s_valid_stage3;

uq16_16_t avg_gain_next, avg_loss_next;
uq16_16_t curr_gain_q16;
uq16_16_t curr_loss_q16; 
logic     s_valid_stage3_s1,s_valid_stage3_s2;

always_ff @(posedge i_clk) begin
  if (i_rst == G_POLARITY) begin
    avg_gain       <= '0;
    avg_loss       <= '1;

    s_valid_stage3 <= 1'b0;
    seed_done      <= 1'b0;
    last_prize     <= '0;
    s_valid_stage3_s1<=1'b0;
    curr_gain_q16 <= '0;
        curr_loss_q16 <= '0;
  end else begin
    s_valid_stage3_s1<=1'b0;
    s_valid_stage3 <= 1'b0;
    if (!seed_done) begin
        s_valid_stage3_s1<=1'b0;
        if (i_en) 
            last_prize<=i_prices[N-1];

        if  (s_valid_sum_gain && s_valid_sum_loss) begin     
            avg_gain_next = sum_gain / N;  // Q16.16 / entero -> Q16.16
            avg_loss_next = (sum_loss == 0) ? uq16_16_t'(1<<16) : (sum_loss / N);

            avg_gain       <= avg_gain_next;
            avg_loss       <= avg_loss_next;
            s_valid_stage3 <= s_valid_sum_gain;
            seed_done      <= 1'b1;
            
        end  
    end else begin
        

        if (i_valid_price) begin
            s_valid_stage3_s1<=1'b1;
            last_prize<=i_curr_price;
            if (i_curr_price > last_prize) begin
                curr_gain_q16 <= uq16_16_t'(i_curr_price - last_prize);
                curr_loss_q16 <= '0;
            end else begin
                curr_gain_q16 <= '0;
                
                curr_loss_q16 <= uq16_16_t'(last_prize - i_curr_price);
            end
        end
    end
  end
end




uq16_16_t avg_gain_next_s1, avg_loss_next_s1;

logic tmp;


//bloque 3.1 rs : habra que hacer pipeline de esto
always_ff @(posedge i_clk) begin
    if (i_rst == G_POLARITY) begin

        s_valid_stage3_s2=1'b0;
        avg_loss_next_s1='0;
        avg_gain_next_s1='0;
        tmp<=1'b0;

    end else begin
        if (seed_done) begin
            tmp<=1'b1;
        end else begin
            tmp<=0'b0;
        end
        if (tmp) begin
            avg_gain_next_s1 = ( (avg_gain * (N-1)) + curr_gain_q16 ) / N;
            avg_loss_next_s1 = ( (avg_loss * (N-1)) + curr_loss_q16 ) / N;
            if (avg_loss_next_s1 == 0) avg_loss_next_s1 = uq16_16_t'(1<<16); // 1.0
        end else begin
            avg_gain_next_s1 = ( (avg_gain_next_s1 * (N-1)) + curr_gain_q16 ) / N;
            avg_loss_next_s1 = ( (avg_loss_next_s1 * (N-1)) + curr_loss_q16 ) / N;
            if (avg_loss_next_s1 == 0) avg_loss_next_s1 = uq16_16_t'(1<<16); // 1.0
        end
        if (s_valid_stage3_s1) 
            s_valid_stage3_s2<=1'b1;
        else
            s_valid_stage3_s2<=1'b0;
    end
end



//bloque 4: rs

logic     s_valid_stage4;

always_ff @(posedge i_clk) begin
    if (i_rst == G_POLARITY) begin
        rs_temp       <= '0;
        s_valid_stage4 <= 0;
    end else begin
        if (s_valid_stage3_s2) begin 
            rs_num        = (64'(avg_gain_next_s1) << 16);
            rs_temp        <= (avg_loss_next_s1 == 0) ? '0 : uq16_16_t'(rs_num / avg_loss_next_s1);
            s_valid_stage4 <= 1'b1;
        end else if (s_valid_stage3) begin
            s_valid_stage4 <= 1'b1;
            rs_num        = (64'(avg_gain) << 16);
            rs_temp        <= (avg_loss == 0) ? '0 : uq16_16_t'(rs_num / avg_loss);
        end else begin
            s_valid_stage4 <= 1'b0;
        end
    end
end

// bloque 5 : scale
logic   s_valid_stage5;

always_ff @(posedge i_clk) begin
    if (i_rst == G_POLARITY) begin
        s_rs_scaled      <= '0;
        s_valid_stage5 <= 0;
    end else begin
        s_rs_scaled      <= (rs_temp > {FIXED_WIDTH{1'b1}}) ? {FIXED_WIDTH{1'b1}} : uq16_16_to_uq8_8(rs_temp);
        s_valid_stage5 <= s_valid_stage4;
        // if (s_valid_stage4) 
        //     $strobe("rs_temp %0d",rs_temp);
    end
end

assign o_rs_valid  = s_valid_stage5;
assign o_rs_scaled = s_rs_scaled;
endmodule