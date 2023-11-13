/*
Encoding | Operacion | Flags Afectadas
000:      sum         NZCV
001:      sub         NZ
010:      and         NZ
011:      or          NZ
100:      mul         NZ
101:      umull       NZ
111:      smull       NZ
*/

module ALU(a,b,Result,ALUFlags,ALUControl, Auxiliar);
  input [31:0] a;
  input [31:0] b;
  input [2:0] ALUControl;
  output reg [31:0] Result;
  output wire [3:0] ALUFlags;
  // ADDED: Auxiliar output for long multiplication
  output wire [31:0] Auxiliar;

  // ADDED: Modified type of neg & zero for use of always block
  reg neg, zero;
  wire carry, overflow;
  wire [32:0] sum;
  // ADDED: Multiplication unifying wire
  wire [63:0] mull;

  // ADDED: Singed multiplication calculation
  wire signed [31:0]sa,sb;
  wire signed [63:0]smull;
  assign sa = a;
  assign sb = b;
  assign smull = sa*sb;

  // ADDED: Unsinged multiplication calculation
  wire [63:0]umull;
  assign umull = a*b;
  
  // ADDED: Assign to mull
  assign mull = (ALUControl[1]?smull:umull);
  assign sum = a + (ALUControl[0]? ~b: b) + ALUControl[0]; // 2's complement
  
  // Result selection
  always @(*)
    casex (ALUControl[2:0]) //case, casex, casez
      3'b00?: Result=sum;
      3'b010: Result=a&b;//and
      3'b011: Result=a|b;//or
      // ADDED MUL CASES
      3'b1??: Result=mull[31:0];
    endcase
  
  // ADDED: Assign of auxiliar
  assign Auxiliar = mull[63:32];
  
  //Flags
  // NZ: Afectadas por todas las operaciones
  // ADDED: always block for cases of neg and zero
  always @(*) begin
    casex (ALUControl[2:0])
      3'b1?1: // SMULL & UMULL
        zero = (Result == 32'b0) & (Auxiliar == 32'b0);
      default: // All other operations
        zero = (Result == 32'b0);
    endcase
  end
  always @(*) begin
    casex(ALUControl[2:0])
      3'b10?: // MUL & UMULL 
        neg = 1'b0;
      3'b111: // SMULL
        neg = Auxiliar[31];
      default: // All other operations
        neg = Result[31];  
    endcase  
  end
  // CV: Solo afectadas por ADD y SUB
  assign carry = (ALUControl[2:1] == 2'b00) & sum[32];
  assign overflow = (ALUControl[2:1] == 2'b00) & (sum[31] ^ a[31]) & ~(ALUControl[0] ^ a[31] ^ b[31]);
  
  // ALUFlags collection
  assign ALUFlags = {neg, zero, carry, overflow};
endmodule  