module decode (
	Op,
	Funct,
	Rd,
	Src2,
	FlagW,
	PCS,
	RegW,
	MemW,
	AuxW,
	Mul,
	MemtoReg,
	DPUSSrc,
	ImmSrc,
	RegSrc,
	DPUSControl
);
	// ADDED: New input to detect MUL's
	input wire [11:0] Src2;
	// ADDED: New output to define if auxiliar output is used (written) and if Mul structure is required
	output reg AuxW;
	output reg Mul;
	// ADDED: Resized and renamed ALU related inputs/outputs for DPUS
	input wire [1:0] Op;
	input wire [5:0] Funct;
	input wire [3:0] Rd;
	output reg [1:0] FlagW;
	output wire PCS;
	output wire RegW;
	output wire MemW;
	output wire MemtoReg;
	output wire DPUSSrc;
	output wire [1:0] ImmSrc;
	output wire [1:0] RegSrc;
	output reg [3:0] DPUSControl;
	reg [9:0] controls;
	wire Branch;
	wire DPUSOp;


	always @(*)		
		casex (Op)
			// Data processing instructions
			2'b00:
				// Settear controls en base a I (si la fuente es inmediate o no) 
				if (Funct[5])
					controls = 10'b0000101001;
				else
					controls = 10'b0000001001;
			// Memory instructions
			2'b01:
				// Settear controls en base a L (si es un Load o Store)
				if (Funct[0])
					controls = 10'b0001111000;
				else
					controls = 10'b1001110100;
			// Branch instructions
			2'b10: controls = 10'b0110100010;
			default: controls = 10'bxxxxxxxxxx;
		endcase
	assign {RegSrc, ImmSrc, DPUSSrc, MemtoReg, RegW, MemW, Branch, DPUSOp} = controls;
	
	
	always @(*)
		if (DPUSOp) begin
			// ADDED: Updated cases for DPUS and added MUL's detection
			case (Src2[7:4])
				4'b1001:
				begin
					// MUL's 
					Mul = 1'b1;
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
					Mul = 1'b0;
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
			// FlagW[1]: CV should be saved
			FlagW[1] = Funct[0]; // Siempre qe S este activo

			// ADDED: Updated FlagW to include also ADD16 and ADD32
			FlagW[0] = Funct[0] & ((DPUSControl == 4'b0000) | (DPUSControl == 4'b0001) | (DPUSControl == 4'b1000) |(DPUSControl == 4'b1010)); // Solo para ADD16, ADD32, ADD y SUBB
		end
		else begin
			DPUSControl = 4'b0000; 
			FlagW = 2'b00; // No se escribe
		end
	assign PCS = ((Rd == 4'b1111) & RegW) | Branch; // PC set: Si es una instrucction Branch o si es un Write en R15
endmodule