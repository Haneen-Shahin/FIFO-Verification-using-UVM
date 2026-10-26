package FIFO_seq_item_pkg;
    import uvm_pkg::*;
    import shared_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_seq_item extends uvm_sequence_item;
        `uvm_object_utils(FIFO_seq_item)
        
        rand logic [FIFO_WIDTH-1:0] data_in;
        rand logic rst_n, wr_en, rd_en;
        
        logic [FIFO_WIDTH-1:0] data_out;
        logic  wr_ack, overflow;
        logic full, empty, almostfull, almostempty, underflow;

        function new(string name="FIFO_seq_item");
            super.new(name);
        endfunction

        function string convert2string();
            return $sformatf("%s rst_n=0b%0b data_in=0b%0b wr_en=0b%0b rd_en=0b%0b data_out=0b%0b wr_ack=0b%0b overflow=0b%0b full=0b%0b empty=0b%0b almostfull=0b%0b almostempty=0b%0b underflow=0b%0b",super.convert2string(),rst_n,data_in,wr_en,rd_en,data_out,wr_ack,overflow,full,empty,almostfull,almostempty,underflow);
        endfunction

        function string convert2string_stimulus();
           return $sformatf("rst_n=0b%0b data_in=0b%0b wr_en=0b%0b rd_en=0b%0b ",rst_n,data_in,wr_en,rd_en);
        endfunction

        
        //-----------------------------constraints-------------------------------------------------------//
        
        constraint rst_n_c{
            rst_n dist {1:=98,0:=2};
        }
        
        constraint wr_en_c {
            wr_en dist{1:=WR_EN_ON_DIST,0:=100-WR_EN_ON_DIST};
        }
        
        constraint rd_en_c {
            rd_en dist{1:=RD_EN_ON_DIST,0:=100-RD_EN_ON_DIST};
        }
        
    
    
    endclass:FIFO_seq_item
endpackage