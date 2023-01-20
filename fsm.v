module fsm
# (
	parameter en_width = 8
)

(
	input       clk,
	input       reset,
	input [3:0] key,
	input [3:0] letter0,
	input [3:0] letter1,
	input [3:0] letter2,
	input [3:0] letter3,
	
	//output [2:0] state_out, // *only for testbench*
	
	output     [3:0] stop_flag,
	output reg [4:0] message0,
	output reg [4:0] message1,
	output reg [4:0] message2,
	output reg [4:0] message3,
	output           end_flag

);


parameter [2:0] S0 = 0, S1 = 1, S2 = 2, S3 = 3, S4 = 4, S5 = 5, S6 = 6;

reg[2:0] state, next_state;

// state register

always @(posedge clk, posedge reset)
	if (reset)
		state <= S0;

	else
		state <= next_state;



// next state logic

always @*
	case (state)
	
	S0: 
		if (key[3])
			next_state = S1;
		else
			next_state = S0; // @loopback
	
	S1: 
		if (key[2])
			next_state = S2;
		else
			next_state = S1; // @loopback
	
	S2: 
		if (key[1])
			next_state = S3;
		else
			next_state = S2; // @loopback
	
	S3: 
		if (key[0])
			next_state = S4;
		else
			next_state = S3; // @loopback
	
	S4: 
		if ((letter0[3:0] == letter1[3:0]) && (letter1[3:0] == letter2[3:0]) && (letter2[3:0] == letter3[3:0]))
			next_state = S5;
		else
			next_state = S6;
	
	// WIN state
	S5:
		if (key[0] & key[1])
			next_state = S0;
		else
			next_state = S5;  // @loopback
	
	// LOSE state
	S6:
		if (key[0] & key[1])
			next_state = S0;
		else
			next_state = S6;  // @loopback

	default:
		next_state = S0;
	
	endcase

	
	
// output logic

assign stop_flag[0] = (state == S1 || state == S2 || state == S3 || state == S4 || state == S5 || state == S6) ? 1'b0 : 1'b1;
assign stop_flag[1] = (state == S2 || state == S3 || state == S4 || state == S5 || state == S6)                ? 1'b0 : 1'b1;
assign stop_flag[2] = (state == S3 || state == S4 || state == S5 || state == S6)                               ? 1'b0 : 1'b1;
assign stop_flag[3] = (state == S4 || state == S5 || state == S6)                                              ? 1'b0 : 1'b1;



always @*
	case(state)
	
	S5:
		begin
		message0 = 'h10; // 'G'
		message1 = 'h11; // 'O'
		message2 = 'h11; // 'O'
		message3 = 'h12; // 'D'
		end
	
	S6:
		begin
		message0 = 'h13; // 'L'
		message1 = 'h11; // 'O'
		message2 = 'h14; // 'S'
		message3 = 'h15; // 'E'
		end
	
	default:
		begin
		message0 = 'h00;
		message1 = 'h00;
		message2 = 'h00;
		message3 = 'h00;
		end
	
	endcase
	
	
//assign state_out = state; // *only for testbench*
	
assign end_flag = (state == S5 || state == S6) ? 1'b1 : 1'b0;

endmodule
