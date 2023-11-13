//fpu_tb
module fpu_tb();
  reg  [31:0] a,b;
  wire [3:0] FPUFlags;
  wire [31:0] Result;
  reg  [1:0] FPUControl;
  reg  clk, reset;
  
  reg [101:0] testvector[15:0]; // 103:0 - 10:0
  reg [31:0] Result_expected;
  reg [3:0] FPUFlags_expected;
  reg [31:0] vectornum;
  reg [31:0] errors;
  
  FPU fpu_dut (.a(a), .b(b), .Result(Result), .FPUFlags(FPUFlags),  .FPUControl(FPUControl));

  always 
    begin
      clk=1; #5; clk=0; #5;
    end

	initial
     begin
       $readmemh("fpu_tv.tv",testvector);
       errors=0;
       vectornum=0;
       reset =1; #27; reset = 0;
     end
  
  always @(posedge clk)
    begin
      FPUFlags_expected=testvector[vectornum][3:0];
      Result_expected=testvector[vectornum][35:4];
      a=testvector[vectornum][67:36];
      b=testvector[vectornum][99:68];
      FPUControl=testvector[vectornum][101:100];
    end
  
  always @(negedge clk)
    begin
      if (~reset)
        begin
          // ==, ===
          if ((Result!==Result_expected) || (FPUFlags!==FPUFlags_expected))
            begin
              $display("Vectornum=%d",vectornum);
              // $multiple displays with outputs, inputs and expected values
              $display("For: a=%h",a," b=%h",b, " Control=%b",FPUControl);
              $display ("Got: Res=%h", Result, " Flags=%b",FPUFlags);
              $display ("Exp: Res=%h", Result_expected, " Flags=%b",FPUFlags_expected, "\n");
              errors = errors+1;
            end
          vectornum=vectornum+1;
          if (testvector[vectornum][0] === 1'bx)
            begin
              $display("errors :%d",errors);
              $dumpfile("test.vcd");
              $dumpvars();
              $finish;
            end
        end
    end
endmodule