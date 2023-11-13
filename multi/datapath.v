// ADD CODE BELOW
// Complete the datapath module below for Lab 11.
// You do not need to complete this module for Lab 10.
// The datapath unit is a structural SystemVerilog module. That is,
// it is composed of instances of its sub-modules. For example,
// the instruction register is instantiated as a 32-bit flopenr.
// The other submodules are likewise instantiated. 
module datapath (
	clk,
	reset,
	Adr,
	WriteData,
	ReadData,
	Instr,
	ALUFlags,
	PCWrite,
	RegWrite,
	IRWrite,
	AdrSrc,
	RegSrc,
	ALUSrcA,
	ALUSrcB,
	ResultSrc,
	ImmSrc,
	ALUControl,
	AuxW,
	Mul
);
	input wire clk;
	input wire reset;
	output wire [31:0] Adr;
	output wire [31:0] WriteData;
	input wire [31:0] ReadData;
	output wire [31:0] Instr;
	output wire [3:0] ALUFlags;
	input wire PCWrite;
	input wire RegWrite;
	input wire IRWrite;
	input wire AdrSrc;
	input wire [1:0] RegSrc;
	input wire [1:0] ALUSrcA;
	input wire [1:0] ALUSrcB;
	input wire [1:0] ResultSrc;
	input wire [1:0] ImmSrc;
	//ADDED: Resize control
	input wire [3:0] ALUControl;
	// ADDED: input AuxW and Mul
	input wire AuxW;
	input wire Mul;
	wire [31:0] PCNext;
	wire [31:0] PC;
	wire [31:0] ExtImm;
	wire [31:0] SrcA;
	wire [31:0] SrcB;
	wire [31:0] Result;
	wire [31:0] Data;
	wire [31:0] RD1;
	wire [31:0] RD2;
	wire [31:0] A;
	wire [31:0] ALUResult;
	wire [31:0] ALUOut;
	wire [3:0] RA1;
	wire [3:0] RA2;
	// Wire agregado para delay
	wire [3:0] ALUFlagsDelay;
    // ADDED: Auxiliar Wire for DPUS
	wire [31:0] AuxiliarOut;
	// ADDED: Wire para Write address 3
	wire [3:0] WA3;

	// FLUJO DE PC
	// Registro de PC
	flopenr #(32) pcreg(
		.clk(clk),
		.reset(reset),
		.en(PCWrite),
		.d(Result), // PC'
		.q(PC)
	);

	// FLUJO DE LECTURA DE MEMORIA
	// Mux de Adr 
	mux2 #(32) adrmux(
		.d0(PC),
		.d1(Result),
		.s(AdrSrc),
		.y(Adr)
	);

	// Instruction Register. Solo modificado cuando IRWrite
	flopenr #(32) instrreg(
		.clk(clk),
		.reset(reset),
		.en(IRWrite),
		.d(ReadData),
		.q(Instr)
	);

	// Data Register. Data leida de memoria.
	flopr #(32) datareg(
		.clk(clk),
		.reset(reset),
		.d(ReadData),
		.q(Data)
	);

	// FLUJO DE DATA LECTURA Y ESCRITURA DE REGISTROS


	// ADDED: Modificacion de Register Address a mux 3 para incluir logica de Mul (reutilizacion de codigo de Single Cycle)

	// Mux de RegSrcA => Seleccion de RegisterAdrress1
	mux3 #(4) ra1mux(
		.d0(Instr[19:16]), // Rn (Src1)
		.d1(4'b1111), // PC
		.d2(Instr[3:0]), // Rn (Mul)
		.s({Mul, RegSrc[0]}),
		.y(RA1)
	);
	// Mux de RegSrcB => Seleccion de RegisterAddress2
	mux3 #(4) ra2mux(
		.d0(Instr[3:0]), // Rm (Src2) 
		.d1(Instr[15:12]), // Rd (#NOTE: para STR)
		.d2(Instr[11:8]), // Rm (Mul)
		.s({Mul,RegSrc[1]}),
		.y(RA2)
	);


	// ADDED: Logica para seleccion de output de escritura para incluir logica de Mul (reutilizacion de codigo de Signle Cycle)
	mux2 #(4) wa3mux(
		.d0(Instr[15:12]), // Rd (Src2) 
		.d1(Instr[19:16]), // Rd (Mul)
		.s(Mul),
		.y(WA3)
	);

	// ADDED: Delay de AuxW y AuxiliarOut
	wire AuxWrite;
	wire [31:0] AuxiliarResult;
	flopr #(1) auxwdelay(
		.clk(clk),
		.reset(reset),
		.d(AuxW),
		.q(AuxWrite)
	);
	flopr #(32) auxoutdelay(
		.clk(clk),
		.reset(reset),
		.d(AuxiliarOut),
		.q(AuxiliarResult)
	);

	// Register File
	regfile rf(
		.clk(clk),
		.we3(RegWrite),
		.ra1(RA1),
		.ra2(RA2),
		.wa3(WA3), // Rd (Register de resultado)
		.wd3(Result),
		// ADDED: Write de data auxiliar (codigo reutilizado de Single Cycle)
		.wa4(Instr[15:12]), // Ra
		.wd4(AuxiliarResult), // Auxiliar Data
		.we4(RegWrite & AuxWrite), // Auxiliar Write Enable
		.r15(Result), 
		.rd1(RD1),
		.rd2(RD2)
	);

	// Register (Read) Data Hold.
	flopr #(32) rd1reg(
		.clk(clk),
		.reset(reset),
		.d(RD1),
		.q(A)
	);
	flopr #(32) rd2reg(
		.clk(clk),
		.reset(reset),
		.d(RD2),
		.q(WriteData)
	);

	// FLUJO DE EXTENSION DE INMEDIATE
	// Extension de inmidiate: Codigo de Lab04 (Incluido nuevo archivo extend.v)
	extend ext(
		.Instr(Instr[23:0]),
		.ImmSrc(ImmSrc),
		.ExtImm(ExtImm)
	);	


	// FLUJO DE DATA ALU
	// SrcA Selector
	mux3 #(32) srcamux(
		.d0(A),
		.d1(PC),
		.d2(ALUOut),
		.s(ALUSrcA),
		.y(SrcA)
	);
	// SrcB Selector
	mux3 #(32) srcbmux(
		.d0(WriteData),
		.d1(ExtImm),
		.d2(32'b100), // 4
		.s(ALUSrcB),
		.y(SrcB)
	);

	// ADDED: ALU replace with DPUS
	DPUS dpus(
		SrcA,
		SrcB,
		ALUControl,
		ALUResult,
		AuxiliarOut,
		ALUFlagsDelay //ALUFlags
	);

	// ALUResult => ALUOut. Hold de 1 ciclo mediante flopr
	flopr #(32) aluresultreg(
		.clk(clk),
		.reset(reset),
		.d(ALUResult),
		.q(ALUOut)
	);

	// Delay de Flags
	flopr #(4) flagsdelayreg(
		.clk(clk),
		.reset(reset),
		.d(ALUFlagsDelay),
		.q(ALUFlags)
	);

	// FLUJO DE RESULT
	// Result Mux
	mux3 #(32) resmux(
		.d0(ALUOut),
		.d1(Data),
		.d2(ALUResult),
		.s(ResultSrc),
		.y(Result)
	);
endmodule