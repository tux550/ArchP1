/*
Encoding | Operacion | Flags Afectadas
00:      add (16)    NZCV
01:      mul (16)    NZ
10:      add (32)    NZCV
11:      mul (32)    NZ
*/

module FPU(a,b,Result,FPUFlags,FPUControl);
  input [31:0] a;
  input [31:0] b;
  input [1:0] FPUControl;
  output reg [31:0] Result;
  output reg [3:0] FPUFlags;

  // Single precision (32 bits)
  wire [31:0]single_add;
  wire [3:0]single_add_flags;
  add_fp #(.MANTISA_WIDTH(23), .EXPONENT_WIDTH(8)) single_fp_adder(.a(a), .b(b), .res_add(single_add), .flags_add(single_add_flags));

  wire [31:0]single_mult;
  wire [3:0]single_mult_flags;
  mult_fp #(.MANTISA_WIDTH(23), .EXPONENT_WIDTH(8)) single_fp_mult(.a(a), .b(b), .res_mult(single_mult), .flags_mult(single_mult_flags));

  // Half precision (16 bits)
  wire [15:0]half_add;
  wire [3:0]half_add_flags;
  add_fp #(.MANTISA_WIDTH(10), .EXPONENT_WIDTH(5)) half_fp_adder(.a(a[15:0]), .b(b[15:0]), .res_add(half_add), .flags_add(half_add_flags));

  wire [15:0]half_mult;
  wire [3:0]half_mult_flags;
  mult_fp #(.MANTISA_WIDTH(10), .EXPONENT_WIDTH(5)) half_fp_mult(.a(a[15:0]), .b(b[15:0]), .res_mult(half_mult), .flags_mult(half_mult_flags));
 
  // Selector de result y flags
  always @(*) begin
    casex (FPUControl[1:0])
      2'b10: begin
        Result = single_add;
        FPUFlags = single_add_flags;
      end 
      2'b11: begin
        Result = single_mult;
        FPUFlags = single_mult_flags;
      end
      2'b00: begin 
        Result = {16'b0000000000000000, half_add};
        FPUFlags = half_add_flags;
      end
      2'b01: begin
        Result = {16'b0000000000000000, half_mult};
        FPUFlags = half_mult_flags;
      end
    endcase
  end
endmodule  