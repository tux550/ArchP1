module controller (
	clk,
	reset,
	Instr,
	ALUFlags,
	RegSrc,
	RegWrite,
	ImmSrc,
	ALUSrc,
	ALUControl,
	MemWrite,
	MemtoReg,
	AuxW,
	Mul,
	PCSrc
);
	input wire clk;
	input wire reset;
	// ADDED: Resize
	input wire [31:0] Instr;
	input wire [3:0] ALUFlags;
	output wire [1:0] RegSrc;
	output wire RegWrite;
	output wire [1:0] ImmSrc;
	output wire ALUSrc;
	// ADDED: Resize
	output wire [3:0] ALUControl;
	// ADDED: AuxW and Mul output from decode
	output wire AuxW;
	output wire Mul;
	output wire MemWrite;
	output wire MemtoReg;
	output wire PCSrc;
	wire [1:0] FlagW;
	wire PCS;
	wire RegW;
	wire MemW;
	decode dec(
		// Inputs
		.Op(Instr[27:26]),
		.Funct(Instr[25:20]),
		.Rd(Instr[15:12]),
		// ADDED: Src2 input to decode
		.Src2(Instr[11:0]),
		// Outputs
		.FlagW(FlagW),
		.PCS(PCS),
		.RegW(RegW),
		.MemW(MemW),
		// ADDED: AuxW and Mul output to decode
		.AuxW(AuxW),
		.Mul(Mul),
		.MemtoReg(MemtoReg),
		// ADDED: Rename to match new decode
		.DPUSSrc(ALUSrc),
		.ImmSrc(ImmSrc),
		.RegSrc(RegSrc),
		.DPUSControl(ALUControl)
	);
	condlogic cl(
		.clk(clk),
		.reset(reset),
		.Cond(Instr[31:28]),
		.ALUFlags(ALUFlags),
		.FlagW(FlagW),
		.PCS(PCS),
		.RegW(RegW),
		.MemW(MemW),
		.PCSrc(PCSrc),
		.RegWrite(RegWrite),
		.MemWrite(MemWrite)
	);
endmodule