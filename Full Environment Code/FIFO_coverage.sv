package FIFO_coverage_pkg;
    import uvm_pkg::*;
    import shared_pkg::*;
    import FIFO_seq_item_pkg::*;
    import FIFO_config_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_coverage extends uvm_component;
        `uvm_component_utils(FIFO_coverage)
        uvm_analysis_export #(FIFO_seq_item) cov_export;
        uvm_tlm_analysis_fifo #(FIFO_seq_item) cov_fifo;
        FIFO_seq_item seq_item_cov;

        bit full_gate, empty_gate, almostfull_gate, almostempty_gate;
        //  Covergroup: cg_wr_rd
        //
        covergroup cg_FIFO ;
            
            //coverpoints
            
            c_wr_en:       coverpoint seq_item_cov.wr_en;
            c_rd_en:       coverpoint seq_item_cov.rd_en;
            c_full:        coverpoint full_gate;
            c_almostfull:  coverpoint almostfull_gate;
            c_empty:       coverpoint empty_gate;
            c_almostempty: coverpoint almostempty_gate;
            c_overflow:    coverpoint seq_item_cov.overflow;
            c_underflow:   coverpoint seq_item_cov.underflow;
            c_wr_ack:      coverpoint seq_item_cov.wr_ack;

            // full/empty/almostfull/almostempty now correlate correctly with
            // wr_en/rd_en, so every bin is genuinely reachable -- no ignore_bins needed
            cross_full:         cross c_wr_en,c_rd_en,c_full;
            cross_almost_full:  cross c_wr_en,c_rd_en,c_almostfull;
            cross_empty:        cross c_wr_en,c_rd_en,c_empty;
            cross_almost_empty: cross c_wr_en,c_rd_en,c_almostempty;

            // overflow/underflow/wr_ack are registered outputs computed FROM
            // the pre-edge count in the same cycle as wr_en/rd_en, so they
            // were already correctly aligned -- no gating needed here
            cross_overflow: cross c_wr_en,c_rd_en,c_overflow{
                ignore_bins no_wr_overflow = binsof(c_wr_en) intersect {0} && binsof(c_overflow) intersect {1};
            }
            cross_underflow: cross c_wr_en,c_rd_en,c_underflow{
                ignore_bins no_rd_underflow = binsof(c_rd_en) intersect {0} && binsof(c_underflow) intersect {1};
            }
            cross_wr_ack: cross c_wr_en,c_rd_en,c_wr_ack{
                ignore_bins no_wr_ack = binsof(c_wr_en) intersect {0} && binsof(c_wr_ack) intersect {1};
            }

        endgroup: cg_FIFO
        
        covergroup cg_rst;
            c_rst_n: coverpoint seq_item_cov.rst_n {
                bins asserted      = {0};
                bins deasserted    = {1};
                bins assert_edge   = (1 => 0);
                bins deassert_edge = (0 => 1);
            }
        endgroup: cg_rst

        function new(string name = "FIFO_coverage",uvm_component parent = null);
            super.new(name,parent);
            cg_FIFO = new();
            cg_rst = new();
        endfunction
        
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            cov_export=new("cov_export",this);
            cov_fifo=new("cov_fifo",this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            cov_export.connect(cov_fifo.analysis_export);
        endfunction
        

        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                cov_fifo.get(seq_item_cov);
                cg_rst.sample();

                if (!seq_item_cov.rst_n) begin
                    // Initialize pre-edge state on active reset
                    full_gate        = 0;
                    empty_gate       = 1;
                    almostfull_gate  = 0;
                    almostempty_gate = 0;
                end
                else begin
                    // 1. Sample cg_FIFO with latched pre-edge state
                    cg_FIFO.sample();

                    // 2. Latch current state for the next transaction cycle
                    full_gate        = seq_item_cov.full;
                    empty_gate       = seq_item_cov.empty;
                    almostfull_gate  = seq_item_cov.almostfull;
                    almostempty_gate = seq_item_cov.almostempty;
                end
            end
        endtask
    endclass
endpackage