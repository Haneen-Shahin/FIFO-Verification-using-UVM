package shared_pkg;
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;
    localparam max_fifo_addr = $clog2(FIFO_DEPTH);
    int RD_EN_ON_DIST=30;
    int WR_EN_ON_DIST=70;

endpackage:shared_pkg