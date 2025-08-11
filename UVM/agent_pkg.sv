package agent_pkg;
  `include "uvm_macros.svh"
  import transaction_pkg::*;
  import uvm_pkg::*;
    import driver_pkg::*;
    import monitor_pkg::*;
class agent extends uvm_agent;
    `uvm_component_utils(agent)

    driver d;
    monitor m;
    uvm_sequencer#(transaction) seqr;
    function new(input string inst="AGENT", uvm_component parent=null);
        super.new(inst,parent);
    endfunction 

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        d=driver::type_id::create("d",this);
        m=monitor::type_id::create("m",this);
        seqr = uvm_sequencer#(transaction)::type_id::create("seqr",this);

    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        d.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass 
endpackage