/*
INSTRUCCIONES PARA TESTING:
Descomentar: initial $readmemb("memfile_mul.dat", RAM); en mem.v
Comentar:    initial $readmemb("memfile_fp.dat", RAM); en mem.v
Descomentar el modulo testbench_fp en este archivo
Comentar el modulo testbench_mul en testbench_mul.v
*/

/*
module testbench_fp;
	reg clk;
	reg reset;
	wire [31:0] WriteData;
	wire [31:0] DataAdr;
	wire MemWrite;
	top dut(
		.clk(clk),
		.reset(reset),
		.WriteData(WriteData),
		.Adr(DataAdr),
		.MemWrite(MemWrite)
	);
	initial begin
		reset <= 1;
		#(22)
			;
		reset <= 0;
	end
	always begin
		clk <= 1;
		#(5)
			;
		clk <= 0;
		#(5)
			;
	end
	always @(negedge clk)
		if (MemWrite)
			if (DataAdr === 160) begin
    			$display("wd=%h", WriteData);
				if (WriteData == 32'h4202a40b) begin
					$display("Simulation succeeded");
					$stop;	
				end
				else begin
					$display("Simulation failed");
					$stop;	
				end				
			end
	initial begin
        $dumpfile("arm_multi_fp.vcd");
        $dumpvars();
    end
endmodule
*/