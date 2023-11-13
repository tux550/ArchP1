module dmem (
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
	initial $readmemb("memfile_fp.dat", RAM);
	// Muls
	//initial $readmemb("memfile_mul.dat", RAM);
	// Output de data en adress actual de memoria a rd (ReadData)
	assign rd = RAM[a[31:2]];
	// Write en adress actual de memoria el valor wd (WriteData)
	always @(posedge clk)
		if (we)
			RAM[a[31:2]] <= wd;
endmodule