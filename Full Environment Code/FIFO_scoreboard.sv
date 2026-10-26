package FIFO_scoreboard_pkg;
    import uvm_pkg::*;
    import shared_pkg::*;
    import FIFO_seq_item_pkg::*;
    import FIFO_config_pkg::*;
    `include "uvm_macros.svh"

    class FIFO_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(FIFO_scoreboard)

    uvm_analysis_export #(FIFO_seq_item) sb_export;
    uvm_tlm_analysis_fifo #(FIFO_seq_item) sb_fifo;
    FIFO_seq_item seq_item_sb;

    logic [FIFO_WIDTH-1:0] mem_ref [FIFO_DEPTH-1:0];
    logic [FIFO_WIDTH-1:0] data_out_ref;
    logic wr_ack_ref, overflow_ref;
    logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;

    int error_count=0;
    int correct_count=0;

    function new(string name = "FIFO_scoreboard",uvm_component parent =null);
        super.new(name,parent);
    endfunction    

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sb_export=new("sb_export",this);
        sb_fifo=new("sb_fifo",this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        sb_export.connect(sb_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        forever begin
            sb_fifo.get(seq_item_sb);
            ref_model(seq_item_sb);
            if(seq_item_sb.data_out !== data_out_ref || seq_item_sb.wr_ack !== wr_ack_ref || seq_item_sb.overflow !== overflow_ref || seq_item_sb.full !== full_ref || seq_item_sb.empty !== empty_ref || seq_item_sb.almostfull !== almostfull_ref || seq_item_sb.almostempty !== almostempty_ref || seq_item_sb.underflow !== underflow_ref)begin
                `uvm_error("run_phase",$sformatf("Comparison failed, Transaction recieved by the DUT:%s While the reference out:0b%0b" , seq_item_sb.convert2string(),data_out_ref,wr_ack_ref,overflow_ref,full_ref,empty_ref,almostfull_ref,almostempty_ref,underflow_ref));
                error_count++;
            end
            else begin
                `uvm_info("run_phase",$sformatf("Correct data_out:%s",seq_item_sb.convert2string()),UVM_HIGH);
                correct_count++;
            end
        end
    endtask


    function void ref_model(FIFO_seq_item FIFO_seq_item_chk);
        static logic [max_fifo_addr-1:0] wr_ptr;
        static logic [max_fifo_addr-1:0] rd_ptr;
        static bit [max_fifo_addr:0] count;
        bit read;

        if(!FIFO_seq_item_chk.rst_n)begin
            wr_ptr=0;
            rd_ptr=0;
            count=0;
            wr_ack_ref=0;
            overflow_ref=0;
            underflow_ref=0;
            read=0;
        end
        else begin
            wr_ack_ref=0;
            overflow_ref=0;
            underflow_ref=0;
            //handling write and read operations together
            if(FIFO_seq_item_chk.wr_en && FIFO_seq_item_chk.rd_en)begin
                //read only
                if(full_ref)begin
                    data_out_ref = mem_ref[rd_ptr];
                    rd_ptr = (rd_ptr + 1)% FIFO_DEPTH;
                    count = count - 1;
                    overflow_ref = 1;
                    read=1;
                end
                //write only
                else if(empty_ref)begin
                    mem_ref[wr_ptr] = FIFO_seq_item_chk.data_in;
                    wr_ack_ref = 1;
                    wr_ptr = (wr_ptr + 1)% FIFO_DEPTH;
                    count = count + 1;
                    underflow_ref=1;
                    read=0;
                    
                end
                else begin
                    mem_ref[wr_ptr] = FIFO_seq_item_chk.data_in;
                    wr_ack_ref = 1;
                    wr_ptr = (wr_ptr + 1)% FIFO_DEPTH;
                    data_out_ref = mem_ref[rd_ptr];
                    rd_ptr = (rd_ptr + 1)% FIFO_DEPTH;
                    read=1;
                end
            end
            //write 
            else if (FIFO_seq_item_chk.wr_en) begin
                read = 0;
                if(!full_ref)begin
                    mem_ref[wr_ptr] = FIFO_seq_item_chk.data_in;
                    wr_ack_ref = 1;
                    wr_ptr = (wr_ptr + 1)% FIFO_DEPTH;
                    count = count + 1;
                end
                else begin
                    overflow_ref=1;
                end
            end
            //read
            else if (FIFO_seq_item_chk.rd_en) begin
                if(!empty_ref)begin
                    data_out_ref = mem_ref[rd_ptr];
                    rd_ptr = (rd_ptr + 1)% FIFO_DEPTH;
                    count = count - 1; 
                    read=1;
                end
                else begin
                    underflow_ref=1;
                    read=0;
                end
            end
            else begin
                read=0;
            end
        end
    
        full_ref        = (count == FIFO_DEPTH);
        empty_ref       = (count == 0);
        almostfull_ref  = (count == FIFO_DEPTH - 1);
        almostempty_ref = (count == 1);
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("report_phase",$sformatf("Total successful transactions:%0d",correct_count),UVM_MEDIUM);
        `uvm_info("report_phase",$sformatf("Total failed transactions:%0d",error_count),UVM_MEDIUM);
    endfunction

    endclass
endpackage