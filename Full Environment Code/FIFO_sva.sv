import shared_pkg::*;
module FIFO_sva(FIFO_if f_if);
 
`ifdef SIM
 
    //==========================================================================
    // Asynchronous (reset) and combinational checks
    // These signals do not wait for a clock edge, so they are checked in an
    // always_comb block with deferred immediate assertions (assert final).
    // assert final evaluates the expression at the final settled value of the
    // time step, after the async reset and the continuous assigns have updated.
    //==========================================================================
    always_comb begin : async_and_comb_checks
 
        //---------------- asynchronous reset assertions ----------------
        if (!f_if.rst_n) begin
            assert_reset_flags: assert final (f_if.empty == 1'b1 && f_if.full == 1'b0 && f_if.almostfull == 1'b0 && f_if.almostempty == 1'b0)
                else $error("Assertion reset_flags failed!");
            cover_reset_flags: cover final (f_if.empty == 1'b1 && f_if.full == 1'b0 && f_if.almostfull == 1'b0 && f_if.almostempty == 1'b0);
 
            assert_RST_wr_ptr: assert final (f_if.wr_ptr == 0)
                else $error("Assertion RST_wr_ptr failed!");
            cover_RST_wr_ptr: cover final (f_if.wr_ptr == 0);
 
            assert_RST_rd_ptr: assert final (f_if.rd_ptr == 0)
                else $error("Assertion RST_rd_ptr failed!");
            cover_RST_rd_ptr: cover final (f_if.rd_ptr == 0);
 
            assert_RST_count: assert final (f_if.count == 0)
                else $error("Assertion RST_count failed!");
            cover_RST_count: cover final (f_if.count == 0);
 
            assert_async_reset_seq: assert final (f_if.overflow == 1'b0 && f_if.underflow == 1'b0 && f_if.wr_ack == 1'b0)
                else $error("Async reset failed to clear sequential outputs!");
            cover_async_reset_seq: cover final (f_if.overflow == 1'b0 && f_if.underflow == 1'b0 && f_if.wr_ack == 1'b0);
        end
 
        //---------------- combinational flag assertions ----------------
        if (f_if.count == 0) begin
            assert_empty_flag: assert final (f_if.empty)
                else $error("Assertion empty_flag failed!");
            cover_empty_flag: cover final (f_if.empty);
        end
 
        if (f_if.count == f_if.FIFO_DEPTH) begin
            assert_full_flag: assert final (f_if.full)
                else $error("Assertion full_flag failed!");
            cover_full_flag: cover final (f_if.full);
        end
 
        if (f_if.count == (f_if.FIFO_DEPTH-1)) begin
            assert_almost_full: assert final (f_if.almostfull)
                else $error("Assertion almost_full failed!");
            cover_almost_full: cover final (f_if.almostfull);
        end
 
        if (f_if.count == 1) begin
            assert_almost_empty: assert final (f_if.almostempty)
                else $error("Assertion almost_empty failed!");
            cover_almost_empty: cover final (f_if.almostempty);
        end
    end
 
    //==========================================================================
    // Sequential assertions (clocked concurrent assertions)
    //==========================================================================
    property write_ack;
        @(posedge f_if.clk) disable iff (!f_if.rst_n) (f_if.wr_en) && (!f_if.full)  |=> (f_if.wr_ack);
    endproperty
 
    property overflow_detection;
        @(posedge f_if.clk) disable iff (!f_if.rst_n) (f_if.wr_en) && (f_if.full)  |=> (f_if.overflow);
    endproperty
 
    property underflow_detection;
        @(posedge f_if.clk) disable iff (!f_if.rst_n) (f_if.rd_en) && (f_if.empty)  |=> (f_if.underflow);
    endproperty
 
    //pointers assertions
    property wr_wraparound;
        @(posedge f_if.clk) disable iff (!f_if.rst_n) (f_if.wr_en && f_if.count < f_if.FIFO_DEPTH && f_if.wr_ptr == f_if.FIFO_DEPTH-1) |=> (f_if.wr_ptr == 0) ;
    endproperty
 
    property rd_wraparound;
        @(posedge f_if.clk) disable iff (!f_if.rst_n) (f_if.rd_en && f_if.count != 0 && f_if.rd_ptr == f_if.FIFO_DEPTH-1) |=> (f_if.rd_ptr==0);
    endproperty
 
    property threshold;
        @(posedge f_if.clk) disable iff (!f_if.rst_n) (f_if.wr_ptr < f_if.FIFO_DEPTH) && (f_if.rd_ptr < f_if.FIFO_DEPTH) && (f_if.count <= f_if.FIFO_DEPTH);
    endproperty
 
    //==========================================================================
    // Assertions & coverage for the sequential checks
    //==========================================================================
    assert_write_ack: assert property (write_ack)
        else $error("Assertion write_ack failed!");
 
    cover property(write_ack);
 
    assert_overflow_detection: assert property(overflow_detection)
        else $error("Assertion overflow_detection failed!");
 
    cover property(overflow_detection);
 
    assert_underflow_detection: assert property(underflow_detection)
        else $error("Assertion underflow_detection failed!");
 
    cover property(underflow_detection);
 
    assert_wr_wraparound: assert property(wr_wraparound)
        else $error("Assertion wr_wraparound failed!");
 
    cover property(wr_wraparound);
 
    assert_rd_wraparound: assert property(rd_wraparound)
        else $error("Assertion rd_wraparound failed!");
 
    cover property(rd_wraparound);
 
    assert_threshold: assert property(threshold)
        else $error("Assertion threshold failed!");
 
    cover property(threshold);
 
`endif
endmodule