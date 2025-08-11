package env_pkg;
`include "uvm_macros.svh"
import uvm_pkg::*;
import agent_pkg::*;
import scoreboard_pkg::*;
class env extends uvm_env;
    `uvm_component_utils(env)

    agent a;
    scoreboard sco;
    
    function new(input string inst="env", uvm_component parent=null);
        super.new(inst,parent);
    endfunction 

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a=agent::type_id::create("a",this);
        sco=scoreboard::type_id::create("sco",this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        a.m.send.connect(sco.recv);
    endfunction
endclass 
endpackage