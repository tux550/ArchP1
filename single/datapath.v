module datapath (
	clk,
	reset,
	RegSrc,
	RegWrite,
	ImmSrc,
	ALUSrc,
	ALUControl,
	MemtoReg,
	PCSrc,
	ALUFlags,
	PC,
	Instr,
	ALUResult,
	WriteData,
	ReadData,
	AuxW,
	Mul
);
	input wire clk;
	input wire reset;
	input wire [1:0] RegSrc;
	input wire RegWrite;
	input wire [1:0] ImmSrc;
	input wire ALUSrc;
	//ADDED: Resize control
	input wire [3:0] ALUControl;
	input wire MemtoReg;
	input wire PCSrc;
	output wire [3:0] ALUFlags;
	output wire [31:0] PC;
	input wire [31:0] Instr;
	output wire [31:0] ALUResult;
	output wire [31:0] WriteData;
	input wire [31:0] ReadData;
	// ADDED: input AuxW and Mul
	input wire AuxW;
	input wire Mul;
	wire [31:0] PCNext;
	wire [31:0] PCPlus4;
	wire [31:0] PCPlus8;
	wire [31:0] ExtImm;
	wire [31:0] SrcA;
	wire [31:0] SrcB;
	wire [31:0] Result;
	wire [3:0] RA1;
	wire [3:0] RA2;
	// ADDED: Auxiliar Wire for DPUS
	wire [31:0] AuxiliarOut;
	// ADDED: Wire para Write address 3
	wire [3:0] WA3;

	// Seleccion de PC
	mux2 #(32) pcmux(
		.d0(PCPlus4),
		.d1(Result),
		.s(PCSrc),
		.y(PCNext)
	);
	// Actualizacion de PC (y reset)
	flopr #(32) pcreg(
		.clk(clk),
		.reset(reset),
		.d(PCNext),
		.q(PC)
	);
	// PC+4
	adder #(32) pcadd1(
		.a(PC),
		.b(32'b100),
		.y(PCPlus4)
	);
	// PC+8
	adder #(32) pcadd2(
		.a(PCPlus4),
		.b(32'b100),
		.y(PCPlus8)
	);

	// ADDED: Modificacion de Register Adress a mux3 para incluir logica de Mul
	// Seleccion de RegisterAdrress1
	mux3 #(4) ra1mux(
		.d0(Instr[19:16]), // Rn (Src1)
		.d1(4'b1111), // PC
		.d2(Instr[3:0]), // Rn (Mul)
		.s({Mul, RegSrc[0]}),
		.y(RA1)
	);

	// Seleccion de RegisterAddress2
	mux3 #(4) ra2mux(
		.d0(Instr[3:0]), // Rm (Src2) 
		.d1(Instr[15:12]), // Rd (#NOTE: para STR)
		.d2(Instr[11:8]), // Rm (Mul)
		.s({Mul,RegSrc[1]}),
		.y(RA2)
	);

	// ADDED: Logica para seleccion de output de escritura para incluir logica de Mul
	mux2 #(4) wa3mux(
		.d0(Instr[15:12]), // Rd (Src2) 
		.d1(Instr[19:16]), // Rd (Mul)
		.s(Mul),
		.y(WA3)
	);

	// Register file
	regfile rf(
		.clk(clk),
		.we3(RegWrite),
		.ra1(RA1),
		.ra2(RA2),
		.wa3(WA3), // Rd
		.wd3(Result),
		// ADDED: Write de data auxiliar
		.wa4(Instr[15:12]), // Ra
		.wd4(AuxiliarOut), // Auxiliar Data
		.we4(RegWrite & AuxW), // Auxiliar Write Enable
		.r15(PCPlus8),
		.rd1(SrcA),
		.rd2(WriteData)
	);
	// Seleccion de resultados entre ALU y ReadData (de memory)
	mux2 #(32) resmux(
		.d0(ALUResult),
		.d1(ReadData),
		.s(MemtoReg),
		.y(Result)
	);
	// Extension de inmidiate
	extend ext(
		.Instr(Instr[23:0]),
		.ImmSrc(ImmSrc),
		.ExtImm(ExtImm)
	);
	// Seleccion de segunda fuente para operacion en ALU
	mux2 #(32) srcbmux(
		.d0(WriteData),
		.d1(ExtImm),
		.s(ALUSrc),
		.y(SrcB)
	);
	// ADDED: Replace ALU with DPUS
	DPUS dpus(
		SrcA,
		SrcB,
		ALUControl,
		ALUResult,
		AuxiliarOut,
		ALUFlags
	);
endmodule