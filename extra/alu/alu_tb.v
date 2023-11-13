//ALUControl_A_B_Resultexpected_ALUFLAGSexpected
//ADD 0+0:	0	00000000	00000000	00000000	4 (BECAUSE Z=1)
//ADD 0+(-1):	0	00000000	FFFFFFFF	FFFFFFFF	8
//ADD 1+(-1):	0	00000001	FFFFFFFF	00000000	6

//alu_tb
module alu_tb();
  reg [31:0] a,b;
  wire [3:0] ALUFlags;
  wire [31:0] Result;
  wire [31:0] Auxiliar;
  reg [2:0]ALUControl;
	reg clk, reset;
  
  reg [134:0] testvector[15:0]; // 103:0 - 10:0
  reg [31:0] Result_expected;
  reg [3:0] ALUFlags_expected;
  reg [31:0] Auxiliar_expected;
  reg [31:0] vectornum;
  reg [31:0] errors;
  
  ALU alu_dut (.a(a), .b(b), .Result(Result), .Auxiliar(Auxiliar), .ALUFlags(ALUFlags),  .ALUControl(ALUControl));

  always 
    begin
      clk=1; #5; clk=0; #5;
    end

	initial
     begin
       $readmemh("alu_tv.tv",testvector);
       errors=0;
       vectornum=0;
       reset =1; #27; reset = 0;
     end
  
  always @(posedge clk)
    begin
      ALUFlags_expected=testvector[vectornum][3:0];
      Result_expected=testvector[vectornum][35:4];
      Auxiliar_expected=testvector[vectornum][67:36];
      a=testvector[vectornum][99:68];
      b=testvector[vectornum][131:100];
      ALUControl=testvector[vectornum][134:132];
    end
  
  always @(negedge clk)
    begin
      if (~reset)
        begin
          // ==, ===
          if ((Result!==Result_expected) || (ALUFlags!==ALUFlags_expected) ||
          (Auxiliar!==Auxiliar_expected && Auxiliar_expected!==32'bx) )
            begin
              $display("Vectornum=%d",vectornum);
              // $multiple displays with outputs, inputs and expected values
              $display("For: a=%h",a," b=%h",b, " Control=%b",ALUControl);
              $display ("Got: Res=%h", Result, " Aux=%h", Auxiliar, " Flags=%b",ALUFlags);
              $display ("Exp: Res=%h", Result_expected, " Aux=%h", Auxiliar_expected, " Flags=%b",ALUFlags_expected, "\n");
              errors = errors+1;
            end
          vectornum=vectornum+1;
          if (testvector[vectornum][0] === 1'bx)
            begin
              $display("errors :%d",errors);
              $finish;
            end
        end
    end
endmodule