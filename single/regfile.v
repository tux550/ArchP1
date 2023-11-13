module regfile (
	clk,
	we3,
	ra1,
	ra2,
	wa3,
	wd3,
	wa4,
	wd4,
	we4,
	r15,
	rd1,
	rd2
);
	input wire clk;
	input wire we3;
	input wire [3:0] ra1;
	input wire [3:0] ra2;
	input wire [3:0] wa3;
	input wire [31:0] wd3;
	input wire [31:0] r15;
	// ADDED: Input wires for auxiliar register writing
	input wire [3:0] wa4;
	input wire [31:0] wd4;
	input wire we4;
	output wire [31:0] rd1;
	output wire [31:0] rd2;
	reg [31:0] rf [14:0];
	always @(posedge clk)
		if (we3 & we4) begin
			rf[wa3] <= wd3;
			rf[wa4] <= wd4;
		end
		else if (we3) begin
			rf[wa3] <= wd3;
		end
		else if (we4) begin
			rf[wa4] <= wd4;
		end
	assign rd1 = (ra1 == 4'b1111 ? r15 : rf[ra1]);
	assign rd2 = (ra2 == 4'b1111 ? r15 : rf[ra2]);
endmodule