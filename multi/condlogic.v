// ADD CODE BELOW
// Add code for the condlogic and condcheck modules. Remember, you may
// reuse code from prior labs.
module condlogic (
	clk,
	reset,
	Cond,
	ALUFlags,
	FlagW,
	PCS,
	NextPC,
	RegW,
	MemW,
	PCWrite,
	RegWrite,
	MemWrite
);
	input wire clk;
	input wire reset;
	input wire [3:0] Cond;
	input wire [3:0] ALUFlags;
	input wire [1:0] FlagW;
	input wire PCS;
	input wire NextPC;
	input wire RegW;
	input wire MemW;
	output wire PCWrite;
	output wire RegWrite;
	output wire MemWrite;
	wire [1:0] FlagWrite;
	wire [3:0] Flags;
	wire CondEx;

	// Delay writing flags until ALUWB state
	flopr #(2) flagwritereg(
		clk,
		reset,
		FlagW & {2 {CondEx}},
		FlagWrite
	);

	// ADD CODE HERE
	// ADDED: Registro de Flags
	// Gate Enable/Reset para Flags (NZ)
	flopenr #(2) flagreg1(
		.clk(clk),
		.reset(reset),
		.en(FlagWrite[1] & FlagW[1]), // Addicion de &FlagW para limitar el enable a SOLO el ciclo de ALUWB 
		.d(ALUFlags[3:2]),
		.q(Flags[3:2])
	);
	// Gate Enable/Reset para Flags (CV)
	flopenr #(2) flagreg0(
		.clk(clk),
		.reset(reset),
		.en(FlagWrite[0] & FlagW[0]), // Addicion de &FlagW para limitar el enable a SOLO el ciclo de ALUWB
		.d(ALUFlags[1:0]),
		.q(Flags[1:0])
	);
	// ADDED: Modulo Condicional
	// Modulo condicional
	condcheck cc(
		.Cond(Cond),
		.Flags(Flags),
		.CondEx(CondEx)
	);
	// ADDED:  Write Enables (Usando diagrama)
	assign RegWrite = RegW & CondEx;
	assign MemWrite = MemW & CondEx;
	assign PCWrite  = (PCS & CondEx) | NextPC ;

endmodule