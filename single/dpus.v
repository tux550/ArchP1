// Data Processor Unit Selector

module DPUS (
  input [31:0] a,
  input [31:0] b,
  input [3:0] DPUSControl,
  output reg [31:0] Result,
  output reg [31:0] Auxiliar,
  output reg [3:0] DPUSFlags
);
    wire [31:0]AuxiliarALU;
    wire [31:0]ResultALU;
    wire [3:0] FlagsALU;
    wire [31:0]ResultFPU;
    wire [3:0] FlagsFPU;

    ALU alu(.a(a), .b(b), .ALUControl(DPUSControl[2:0]), .Result(ResultALU), .ALUFlags(FlagsALU) , .Auxiliar(AuxiliarALU) );
    FPU fpu(.a(a), .b(b), .FPUControl(DPUSControl[1:0]), .Result(ResultFPU), .FPUFlags(FlagsFPU) );

    always @(*) begin
        if (DPUSControl[3]) begin
            Result=ResultFPU;
            DPUSFlags=FlagsFPU;
            Auxiliar=32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        end
        else begin 
            Result=ResultALU;
            DPUSFlags=FlagsALU;
            Auxiliar=AuxiliarALU;
        end
    end
endmodule