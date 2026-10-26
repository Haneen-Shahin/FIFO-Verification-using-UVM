package FIFO_wr_rd_seq_pkg;
    import uvm_pkg::*;
    import shared_pkg::*;
    import FIFO_seq_item_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_wr_rd_seq1 extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_wr_rd_seq1)
        FIFO_seq_item seq_item;

        function new(string name="FIFO_wr_rd_seq1");
            super.new(name);
        endfunction

        task body;
            seq_item=FIFO_seq_item::type_id::create("seq_item");
                repeat(100)begin
                    repeat(10)begin
                        start_item(seq_item);
                        seq_item.wr_en=1;
                        seq_item.rd_en=0;
                        assert(seq_item.randomize());
                        finish_item(seq_item);
                    end
                    repeat(10)begin
                        start_item(seq_item);
                        seq_item.wr_en=0;
                        seq_item.rd_en=1;
                        assert(seq_item.randomize());
                        finish_item(seq_item);
                    end
                end
        endtask
    endclass:FIFO_wr_rd_seq1

    class FIFO_wr_rd_seq2 extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_wr_rd_seq2)
        FIFO_seq_item seq_item;

        function new(string name="FIFO_wr_rd_seq2");
            super.new(name);
        endfunction

        task body;
            seq_item=FIFO_seq_item::type_id::create("seq_item");
            repeat(100)begin
                start_item(seq_item);
                seq_item.wr_en=1;
                seq_item.rd_en=1;
                assert(seq_item.randomize());
                finish_item(seq_item);
            end
            
        endtask
    endclass:FIFO_wr_rd_seq2
endpackage