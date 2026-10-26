package FIFO_wr_seq_pkg;
    import uvm_pkg::*;
    import shared_pkg::*;
    import FIFO_seq_item_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_wr_seq extends uvm_sequence #(FIFO_seq_item);
        `uvm_object_utils(FIFO_wr_seq)
        FIFO_seq_item seq_item;

        function new(string name="FIFO_wr_seq");
            super.new(name);
        endfunction

        task body;
            seq_item=FIFO_seq_item::type_id::create("seq_item");
            repeat(100)begin
                start_item(seq_item);
                seq_item.wr_en=1;
                seq_item.rd_en=0;
                assert(seq_item.randomize());
                finish_item(seq_item);
            end
        endtask
    endclass
endpackage