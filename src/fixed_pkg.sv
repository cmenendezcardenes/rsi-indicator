package fixed_pkg;

    parameter int FIXED_WIDTH=16;
    parameter int FIXED_FRAC_BITS=8;
    parameter int RESET_POLARITY=0;
    parameter int PARAM_N=14;

    typedef logic [FIXED_WIDTH-1:0] uq8_8_t; //unsigned-8bits-8bits frac
    typedef logic [FIXED_WIDTH*2-1:0] uq16_16_t;
    
    function automatic uq8_8_t real_to_uq8_8(input real val);
        return uq8_8_t'(val*(1<<FIXED_FRAC_BITS));
    endfunction

    function automatic real uq8_8_to_real(input uq8_8_t val);
        return val / real'(1 << FIXED_FRAC_BITS);
    endfunction

    function automatic uq16_16_t real_to_uq16_16(input real val);
        return uq16_16_t'(val*(1<<FIXED_FRAC_BITS*2));
    endfunction

    function automatic real uq16_16_to_real(input uq16_16_t val);
        return val / real'(1 << FIXED_FRAC_BITS*2);
    endfunction

    function automatic uq8_8_t uq16_16_to_uq8_8(input uq16_16_t val);
        return val[23:8];
    endfunction

endpackage