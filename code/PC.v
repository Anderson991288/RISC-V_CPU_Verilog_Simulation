module PC(

	input	wire 		clk,
	input	wire		rst,
	input 	wire		Branch,  // if branch or not
	input 	wire[31:0] 	Addr,	 // target address
	output 	reg 	 	ce,
	output	reg [31:0] 	PC

);

/*
 * This always part controls the signal ce.
 */
always @ (posedge clk) begin
	if (rst)
		ce <= 1'b0;
	else
		ce <= 1'b1;
end

/*
 * This always part controls the signal PC.
 */
always @ (posedge clk) begin
	if (!ce)
		PC <= 32'b0;
	else if (Branch)
		PC <= Addr;
	else
		PC <= PC + 4'h4;  // New PC equals ((old PC) + 4) per cycle.
end

endmodule
