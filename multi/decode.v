module decode (
	clk,
	reset,
	Op,
	Funct,
	Rd,
	FlagW,
	PCS,
	NextPC,
	RegW,
	MemW,
	AuxW,
	Mul,
	IRWrite,
	AdrSrc,
	ResultSrc,
	ALUSrcA,
	ALUSrcB,
	ImmSrc,
	RegSrc,
	DPUSControl,
	Src2
);
	input wire clk;
	input wire reset;
	// ADDED: New input to detect MUL's
	input wire [11:0] Src2;
	// ADDED: New output to define if auxiliar output is used (written) and if Mul structure is required
	output reg AuxW;
	output reg Mul;
	// ADDED: Resized and renamed ALU related inputs/outputs for DPUS
	input wire [1:0] Op;
	input wire [5:0] Funct;
	input wire [3:0] Rd;
	//output wire [1:0] FlagW;
	output reg [1:0] FlagW;  // Modificado a REG para poder usar bloque @always()
	output wire PCS;
	output wire NextPC;
	output wire RegW;
	output wire MemW;
	output wire IRWrite;
	output wire AdrSrc;
	output wire [1:0] ResultSrc;
	output wire [1:0] ALUSrcA;
	output wire [1:0] ALUSrcB;
	output wire [1:0] ImmSrc;
	output reg [1:0] RegSrc;
	output reg [3:0] DPUSControl; 
	wire Branch;
	wire DPUSOp;

	// Main FSM
	mainfsm fsm(
		.clk(clk),
		.reset(reset),
		.Op(Op),
		.Funct(Funct),
		.IRWrite(IRWrite),
		.AdrSrc(AdrSrc),
		.ALUSrcA(ALUSrcA),
		.ALUSrcB(ALUSrcB),
		.ResultSrc(ResultSrc),
		.NextPC(NextPC),
		.RegW(RegW),
		.MemW(MemW),
		.Branch(Branch),
		.ALUOp(DPUSOp)
	);

	// ADD CODE BELOW
	// Add code for the ALU Decoder and PC Logic.
	// Remember, you may reuse code from previous labs.

	// ADDED: Change ALU Decoder for DPUS Decoder (Code adapted from Single Cycle without Mul signal)
	always @(*)
		if (DPUSOp) begin
			case (Src2[7:4])
				// ADDED: Updated cases for DPUS and added MUL's detection
				4'b1001:
				begin
					// MUL's 
					case (Funct[3:1])
						// Only UMULL and SMULL have AuxW on
						3'b000: begin DPUSControl = 4'b0100; AuxW = 1'b0; end // MUL
						3'b100: begin DPUSControl = 4'b0101; AuxW = 1'b1; end// UMULL
						3'b110: begin DPUSControl = 4'b0111; AuxW = 1'b1; end// SMULL
						3'b101: begin DPUSControl = 4'b1011; AuxW = 1'b0; end// MULL32
						3'b111: begin DPUSControl = 4'b1001; AuxW = 1'b0; end// MULL16
						default: begin DPUSControl = 4'bxxxx; AuxW = 1'b0; end// Default
					endcase
				end
				default: 
				begin
					// Standard
					AuxW = 1'b0; // Only MULs might use auxiliary output
					case (Funct[4:1])
						4'b0100: DPUSControl = 4'b0000; // ADD
						4'b0010: DPUSControl = 4'b0001; // SUB
						4'b0000: DPUSControl = 4'b0010; // AND (bitwise)
						4'b1100: DPUSControl = 4'b0011; // ORR (bitwise)
						4'b1010: DPUSControl = 4'b1010; // ADD32
						4'b1011: DPUSControl = 4'b1000; // ADD16
						default: DPUSControl = 4'bxxxx; // Default
					endcase					
				end
			endcase

			// FlagW[1]: NZ should be saved 
			// FlagW[0]: CV should be saved
			FlagW[1] = Funct[0]; // Siempre qe S este activo

			// ADDED: Updated FlagW to include also ADD16 and ADD32
			FlagW[0] = Funct[0] & ((DPUSControl == 4'b0000) | (DPUSControl == 4'b0001) | (DPUSControl == 4'b1000) |(DPUSControl == 4'b1010)); // Solo para ADD16, ADD32, ADD y SUBB
		end
		else begin
			DPUSControl = 2'b00; 
			FlagW = 2'b00; // No se escribe
		end


	// PC Logic
	assign PCS = ((Rd == 4'b1111) & RegW) | Branch; // PC set: Si es una instrucction Branch o si es un Write en R15

	// Instr Decoder
	assign ImmSrc = Op;

	// RegSrc Logic
	// ADDED: Mul logic extracted from previos block
	always @(*)
		casex (Op)
			// Data processing instructions
			2'b00:
				begin
					RegSrc = 2'b00;
					if (Src2[7:4] == 4'b1001) Mul = 1'b1;
					else Mul = 1'b0;
				end
			// Memory instructions
			2'b01: begin RegSrc = 2'b10; Mul=1'b0; end
			// Branch instructions
			2'b10: begin RegSrc = 2'bx1; Mul=1'b0; end
			default: begin RegSrc = 2'bxx; Mul=1'bx; end
		endcase
endmodule