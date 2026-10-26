interface FIFO_if(input bit clk);

    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;
    localparam max_fifo_addr = $clog2(f_if.FIFO_DEPTH);

    logic [FIFO_WIDTH-1:0] data_in;
    logic rst_n, wr_en, rd_en;
    
    logic [FIFO_WIDTH-1:0] data_out;
    logic  wr_ack, overflow;
    logic full, empty, almostfull, almostempty, underflow;

    //internal monitoring signals
    reg [f_if.FIFO_WIDTH-1:0] mem [f_if.FIFO_DEPTH-1:0];
    reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
    reg [max_fifo_addr:0] count;

endinterface