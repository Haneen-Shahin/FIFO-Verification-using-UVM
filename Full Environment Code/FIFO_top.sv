import uvm_pkg::*;
import shared_pkg::*;
import FIFO_test_pkg::*;
`include "uvm_macros.svh"

module FIFO_top();
    bit clk;
    initial begin
        clk=0;
        forever#5 clk=~clk;
    end

    FIFO_if f_if(clk);
    FIFO dut(f_if);
    
    bind FIFO FIFO_sva sva(f_if);

    // run test using run_test task
    initial begin
        uvm_config_db #(virtual FIFO_if)::set(null,"uvm_test_top","FIFO_if",f_if);
        run_test("FIFO_test");
    end

    
endmodule