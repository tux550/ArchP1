/*
//controller_tb
module controller_tb();
  // Inputs
  reg [19:0] Instr;
  reg [3:0] ALUFlags;
  // Outputs
  wire PCWrite;
  wire MemWrite;
  wire RegWrite;
  wire IRWrite;
  wire AdrSrc;
  wire [1:0] RegSrc;
  wire [1:0] ALUSrcA;
  wire [1:0] ALUSrcB;
  wire [1:0] ResultSrc;
  wire [1:0] ImmSrc;
  wire [1:0] ALUControl;

  // Inputs
  reg clk, reset;
  
  // Test vector
  reg [23:0] testvector[11:0]; 

  reg [31:0] vectornum;
  reg [31:0] errors;


  reg [16:0] expectedvector[33:0]; 
  reg [31:0] expectednum;

  // Expected vector
  reg [1:0] expected_ALUControl;
  reg [1:0] expected_ImmSrc;
  reg [1:0] expected_ResultSrc;
  reg [1:0] expected_ALUSrcB;
  reg [1:0] expected_ALUSrcA;
  reg [1:0] expected_RegSrc;
  reg expected_AdrSrc;
  reg expected_IRWrite;
  reg expected_RegWrite;
  reg expected_MemWrite;
  reg expected_PCWrite;


  controller controller_dut (.clk(clk), .reset(reset), .Instr(Instr), .ALUFlags(ALUFlags), .PCWrite(PCWrite), .MemWrite(MemWrite), .RegWrite(RegWrite), .IRWrite(IRWrite), .AdrSrc(AdrSrc), .RegSrc(RegSrc), .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB), .ResultSrc(ResultSrc), .ImmSrc(ImmSrc), .ALUControl(ALUControl) );

  always 
    begin
      clk=1; #5; clk=0; #5;
    end

	initial
     begin
       $readmemb("controller_inp_tv.tv",testvector);
       errors=0;
       vectornum=0;
       $readmemb("controller_out_tv.tv",expectedvector);
       expectednum = 0;
       reset =1; #10; reset = 0;
     end

  always @(posedge clk)
    begin
      ALUFlags=testvector[vectornum][3:0];
      Instr=testvector[vectornum][23:4];

      expected_ALUControl=expectedvector[expectednum][1:0];
      expected_ImmSrc=expectedvector[expectednum][3:2];
      expected_ResultSrc=expectedvector[expectednum][5:4];
      expected_ALUSrcB=expectedvector[expectednum][7:6];
      expected_ALUSrcA=expectedvector[expectednum][9:8];
      expected_RegSrc=expectedvector[expectednum][11:10];
      expected_AdrSrc=expectedvector[expectednum][12];
      expected_IRWrite=expectedvector[expectednum][13];
      expected_RegWrite=expectedvector[expectednum][14];
      expected_MemWrite=expectedvector[expectednum][15];
      expected_PCWrite=expectedvector[expectednum][16];
    end
  
  always @(negedge clk)
    begin
      if (~reset)
        begin          
          // Next Operation
          if (IRWrite)
              vectornum=vectornum+1;
          if (vectornum != 0)
            begin 
           
            // Exit
            if (testvector[vectornum][0] === 1'bx)
                begin
                $display("====== TEST BENCH ENDED ======");
                $display("RESULTADOS");
                $display("----------");
                $display("errors :%d",errors);
                $display("==============================");
                $finish;
                end

            // Error Finder
            if (
                    (ALUControl!==expected_ALUControl) || (ImmSrc!==expected_ImmSrc) ||
                    (ResultSrc!==expected_ResultSrc) || (ALUSrcB!==expected_ALUSrcB) ||
                    (ALUSrcA!==expected_ALUSrcA) || (RegSrc!==expected_RegSrc) || 
                    (AdrSrc!==expected_AdrSrc) || (IRWrite!==expected_IRWrite) ||
                    (RegWrite!==expected_RegWrite) || (MemWrite!==expected_MemWrite) ||
                    (PCWrite!==expected_PCWrite)
            ) begin
                errors = errors+1;
                $display("num: %d", vectornum);
                $display("expnum: %d", expectednum);
                $display("instr: %B",testvector[vectornum]);
                $display("expected: %B",expectedvector[expectednum]);
                $display("result: %B", {PCWrite, MemWrite, RegWrite, IRWrite, AdrSrc, RegSrc, ALUSrcA, ALUSrcB, ResultSrc, ImmSrc, ALUControl}) ;
                $display("state: %d", controller_dut.dec.fsm.state);
                end


            // Next Expected
            expectednum = expectednum+1;

            
            end
        end
    end

  initial begin
    $dumpfile("controller.vcd");
    $dumpvars();
  end
endmodule
*/