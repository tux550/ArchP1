module mem (
	clk,
	we,
	a,
	wd,
	rd
);
	input wire clk;
	input wire we;
	input wire [31:0] a;
	input wire [31:0] wd;
	output wire [31:0] rd;
	reg [31:0] RAM [511:0];
	// Inicializacion con archivo memfile.dat
	// Floating point:
	//initial $readmemb("memfile_fp.dat", RAM);
	// Muls
	initial $readmemb("memfile_mul.dat", RAM);
	assign rd = RAM[a[31:2]]; // word aligned
	always @(posedge clk)
		if (we)
			RAM[a[31:2]] <= wd;
endmodule
