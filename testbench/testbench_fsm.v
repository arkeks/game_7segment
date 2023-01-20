// testbench for FSM testing

`timescale 1ns / 1ps
module testbench;

	// i/o signals
	reg       clk;
	reg       reset;
   reg [3:0] key;
   reg [3:0] letter0;
	reg [3:0] letter1;
	reg [3:0] letter2;
	reg [3:0] letter3;
	
	wire [1:0] state;
	wire [3:0] stop_flag;
	wire [4:0] message0;
	wire [4:0] message1;
	wire [4:0] message2;
	wire [4:0] message3;
	wire       end_flag;
	
	
	fsm uut (
		clk, 
		reset, 
		key, 
		letter0, 
		letter1, 
		letter2, 
		letter3, 
		
		state, 
		stop_flag, 
		message0, 
		message1,
		message2,
		message3,
		end_flag);
		
		
	always begin
		#1 clk = ~clk;
	end
	
	initial
		begin
			reset = 1'b1;
			letter0 = 4'b0;
			letter1 = 4'b0;
			letter2 = 4'b0;
			letter3 = 4'b0;
			
			key = 4'b0001;
			#10;
			key = 4'b0010;
			#10;
			key = 4'b0100;
			#10;
			key = 4'b1000;
			#10;
			key = 4'b0011;
		end
		
		initial
			begin
				$monitor("key=%b, state=%d, end_flag=%b", key, state, end_flag);
				$dumpvars;
				#50
				$finish;
			end
endmodule
		
			