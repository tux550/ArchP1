module imem (
	a,
	rd
);
	input wire [31:0] a;
	output wire [31:0] rd;
	reg [31:0] RAM [63:0];
	// Inicializacion con archivo memfile.dat
	// Floating point:
	initial $readmemb("memfile_fp.dat", RAM);
	// Muls
	//initial $readmemb("memfile_mul.dat", RAM);
	// Output de data en adress actual de memoria
	assign rd = RAM[a[31:2]];
endmodule