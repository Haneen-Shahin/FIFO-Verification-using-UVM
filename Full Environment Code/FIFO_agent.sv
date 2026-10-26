package FIFO_agent_pkg;
    import uvm_pkg::*;
    import FIFO_seq_item_pkg::*;
    import FIFO_config_pkg::*;
    import FIFO_driver_pkg::*;
    import FIFO_sequencer_pkg::*;
    import FIFO_monitor_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_agent extends uvm_agent;
        `uvm_component_utils(FIFO_agent)
        
        FIFO_driver drv;
        FIFO_sequencer sqr;
        FIFO_monitor mon;
        FIFO_config cfg;
        //analysis port
        uvm_analysis_port #(FIFO_seq_item) agt_ap;

        function new(string name = "FIFO_agent",uvm_component parent=null);
            super.new(name,parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!(uvm_config_db #(FIFO_config)::get(this,"","CFG",cfg)))begin
                `uvm_fatal("build_phase","Unable to get configuration object")
            end

            //create drv,sqr,mon
            drv = FIFO_driver::type_id::create("drv",this);
            sqr = FIFO_sequencer::type_id::create("sqr",this);
            mon = FIFO_monitor::type_id::create("mon",this);
            agt_ap = new("agt_ap",this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            drv.FIFO_vif=cfg.FIFO_vif;
            mon.FIFO_vif=cfg.FIFO_vif;
            drv.seq_item_port.connect(sqr.seq_item_export);
            mon.mon_ap.connect(agt_ap);
        endfunction

    endclass:FIFO_agent
endpackage