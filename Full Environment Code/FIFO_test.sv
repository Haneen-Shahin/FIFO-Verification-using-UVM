package FIFO_test_pkg;
  import uvm_pkg::*;
  import FIFO_env_pkg::*;
  import FIFO_config_pkg::*;
  import FIFO_rst_seq_pkg::*;
  import FIFO_wr_seq_pkg::*;
  import FIFO_rd_seq_pkg::*;
  import FIFO_wr_rd_seq_pkg::*;
 `include "uvm_macros.svh"


  class FIFO_test extends uvm_test;
    `uvm_component_utils(FIFO_test)
    FIFO_env env;
    FIFO_config cfg;
    virtual FIFO_if FIFO_vif;
    FIFO_rst_seq rst_seq;
    FIFO_wr_seq wr_seq;
    FIFO_rd_seq rd_seq;
    FIFO_wr_rd_seq1 wr_rd_seq1;
    FIFO_wr_rd_seq2 wr_rd_seq2;

    function new (string name="FIFO_test",uvm_component parent=null);
      super.new(name,parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env=FIFO_env::type_id::create("env",this);
      cfg=FIFO_config::type_id::create("cfg");
      rst_seq=FIFO_rst_seq::type_id::create("rst_seq");
      wr_seq=FIFO_wr_seq::type_id::create("wr_seq");
      rd_seq=FIFO_rd_seq::type_id::create("rd_seq");
      wr_rd_seq1=FIFO_wr_rd_seq1::type_id::create("wr_rd_seq1");
      wr_rd_seq2=FIFO_wr_rd_seq2::type_id::create("wr_rd_seq2");

      if(!(uvm_config_db #(virtual FIFO_if)::get(this,"","FIFO_if",cfg.FIFO_vif)))begin
        `uvm_fatal("build_phase","TEST-Unable to get virtual interface of the FIFO from uvm_config_db")
      end

      uvm_config_db #(FIFO_config)::set(this,"*","CFG",cfg);
    endfunction
    
    task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this);
      //reset sequence
      `uvm_info("run_phase","Reset Asserted",UVM_LOW);
      rst_seq.start(env.agt.sqr);
      `uvm_info("run_phase","Reset Deasserted",UVM_LOW);
      //main sequence
      `uvm_info("run_phase","Stimulus Generation Started",UVM_LOW);
      //write
      `uvm_info("run_phase","Writing Started",UVM_LOW);
      wr_seq.start(env.agt.sqr);
      //read
      `uvm_info("run_phase","Reading Started",UVM_LOW);
      rd_seq.start(env.agt.sqr);
      //write and read simultaneously
      `uvm_info("run_phase","Writing and Reading simultaneously Started",UVM_LOW);
      wr_rd_seq2.start(env.agt.sqr);
      //write and read 
      `uvm_info("run_phase","Writing and Reading Started",UVM_LOW);
      wr_rd_seq1.start(env.agt.sqr);
      //end stimulus
      `uvm_info("run_phase","Stimulus Generation Ended",UVM_LOW);
      phase.drop_objection(this);
    endtask
    
  endclass: FIFO_test
endpackage
