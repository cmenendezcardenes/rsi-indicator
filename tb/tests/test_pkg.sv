package test_pkg;
`timescale 1ns/1ps
`include "uvm_macros.svh"
import uvm_pkg::*;
import env_pkg::*;
import generator_pkg::*;
class test extends uvm_test;
    `uvm_component_utils(test)

    env e; 
    generator gen;    
    function new(input string inst="test", uvm_component parent=null);
        super.new(inst,parent);
    endfunction 

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        e=env::type_id::create("e",this);
        gen=generator::type_id::create("gen",this);
    endfunction

    virtual task run_phase (uvm_phase phase);
        phase.raise_objection(this);
        gen.start(e.a.seqr);
        #2000;
        phase.drop_objection(this);
    endtask
endclass 
endpackage