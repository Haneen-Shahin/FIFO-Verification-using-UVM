module FIFO(FIFO_if f_if);

always_ff @(posedge f_if.clk or negedge f_if.rst_n) begin
	if (!f_if.rst_n) begin
		f_if.wr_ptr <= 0;
		f_if.wr_ack <= 0; //---------------------------->added 
		f_if.overflow <= 0; //-------------------------->added
	end
	else if (f_if.wr_en && f_if.count < f_if.FIFO_DEPTH) begin
		f_if.mem[f_if.wr_ptr] <= f_if.data_in;
		f_if.wr_ack <= 1;
		f_if.wr_ptr <= f_if.wr_ptr + 1;
        f_if.overflow<=0;
	end
	else begin 
		f_if.wr_ack <= 0; 
		if (f_if.full && f_if.wr_en) //use " && " (bitwise and) instead of " & "-----------> Warning: this statement is not a bitwise operation 
			f_if.overflow <= 1;
		else
			f_if.overflow <= 0;
	end
end

always_ff @(posedge f_if.clk or negedge f_if.rst_n) begin
	if (!f_if.rst_n) begin
		f_if.rd_ptr <= 0;
		f_if.underflow<=0; //-------------------------------->fixed (handling sequentially)
	end
	else if (f_if.rd_en && f_if.count != 0) begin
		f_if.data_out <= f_if.mem[f_if.rd_ptr];
		f_if.rd_ptr <= f_if.rd_ptr + 1;
        f_if.underflow<=0; //-------------------------------->fixed (handling sequentially)
	end
	else begin
        if (f_if.empty && f_if.rd_en )begin
            f_if.underflow<=1; //-------------------------------->fixed (handling sequentially)
        end
        else begin
            f_if.underflow<=0; //-------------------------------->fixed (handling sequentially)
        end
	end
end

always_ff @(posedge f_if.clk or negedge f_if.rst_n) begin
	if (!f_if.rst_n) begin
		f_if.count <= 0;
	end
	else begin
		//write
		if	( ({f_if.wr_en, f_if.rd_en} == 2'b10) && !f_if.full) 
			f_if.count <= f_if.count + 1;
		//read
		else if ( ({f_if.wr_en, f_if.rd_en} == 2'b01) && !f_if.empty)
			f_if.count <= f_if.count - 1;
		//handling write and read together
		else if ({f_if.wr_en, f_if.rd_en} == 2'b11) begin //-------------------------------------->added
			if(f_if.full)begin
				f_if.count <= f_if.count - 1;
			end
			else if (f_if.empty) begin
				f_if.count <= f_if.count + 1;
			end
		end
	end
end

assign f_if.full = (f_if.count == f_if.FIFO_DEPTH)? 1 : 0;
assign f_if.empty = (f_if.count == 0)? 1 : 0;
//assign underflow = (f_if.empty && f_if.rd_en)? 1 : 0;   //-------------------------------->fixed (handling sequentially)
assign f_if.almostfull = (f_if.count == f_if.FIFO_DEPTH-1)? 1 : 0; //-------------------->fixed from (count == f_if.FIFO_DEPTH-2) to (count == f_if.FIFO_DEPTH-1)
assign f_if.almostempty = (f_if.count == 1)? 1 : 0;

endmodule