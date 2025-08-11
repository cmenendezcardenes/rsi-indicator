import fixed_pkg::*;

module tree_adder_14 
#(
    parameter N=14,
    parameter G_POLARITY=0
)
(
    input  logic        i_clk,    
    input  logic        i_rst,
    input  logic        i_valid,
    input  uq8_8_t      i_values [N],
    output uq16_16_t    o_sum,
    output logic        o_valid
);

    function automatic int log2ceil(input int val);
        int i; 
        begin 
            for (i=0;2**i<val;i++);
            return i; 
        end
    endfunction

localparam int MAX_LEVELS = log2ceil(N)-1;//+ 1;
uq16_16_t data_levels [0:MAX_LEVELS][N-1];
logic [MAX_LEVELS:0] s_valid_tab;


genvar j;
generate
    for (j=0;j<=MAX_LEVELS;j++) begin : level_gen
        localparam int v_num_elem=(N+(1<<(j+1))-1)>> (j+1);
        always_ff @(posedge i_clk) begin
            if (i_rst==G_POLARITY) begin
                for (int i = 0; i< v_num_elem; i++) begin
                    data_levels[j][i] <= '0;
                end    
            end else begin

                for (int k=0;k<v_num_elem;k++) begin 
                    uq16_16_t first_op,second_op;
                    if (j==0) begin 
                        first_op=uq16_16_t'(i_values[2*k])   << FIXED_FRAC_BITS;
                        second_op=((2*k+1) < N) ? (uq16_16_t'(i_values[2*k+1]) << FIXED_FRAC_BITS):'0;
                    end else begin
                        localparam int v_num_elem_in = (N + (1 << j) - 1) >> j;
                        first_op=(data_levels[j-1][2*k]);
                        // second_op=((2*k+1) < v_num_elem) ? data_levels[j-1][2*k+1]:'0;
                        second_op = (2*k+1 < v_num_elem_in) ? (data_levels[j - 1][2*k+1]) : '0;
                    end
                    data_levels [j][k]<=first_op+second_op;
                end
            end
        end
    end
endgenerate


always_ff@(posedge i_clk) begin
    if (i_rst==G_POLARITY) begin
        for(int m=0;m<MAX_LEVELS;m++)
            s_valid_tab[m]<='0;
    end else begin
        s_valid_tab<={s_valid_tab[MAX_LEVELS - 1:0] , i_valid};

        if (s_valid_tab == 4'b1000) begin
            $display("%p",data_levels);
        end
        
        

    end
end

assign o_sum = data_levels[MAX_LEVELS][0];
assign o_valid = s_valid_tab[MAX_LEVELS];
endmodule