module top

# (
    parameter debounce_depth         = 8,
              letter_strobe_width    = 24,  // frequency of changing letters
              indicator_strobe_width = 10   // PWM frequency for shift register, which chooses the turned ON indicator
)

(
  input       clk,
  input       reset_n, // if reset_n == 0 => reset == 1 
  input [3:0] key_sw,  // when key_sw[0] is NOT pressed - key_sw[0] = 1; when key_sw[0] IS pressed, key_sw[0] = 0
  
  //*** FOR TESTBENCH ***
  /*
  output [3:0] letter0,
  output [3:0] letter1,
  output [3:0] letter2,
  output [3:0] letter3,
  output [2:0] state_out,
  output letter_strobe_out,
  output end_flag_out,
  */
  //*********************
  
  
  output [7:0] abcdefgh, // displayed letter
  output [3:0] digit,    // indicator which is turned ON
  output buzzer,         // no need in this project
  output [3:0] led       // leds for visualizing the pressing of buttons
);


  wire reset = ~reset_n;
  
  assign buzzer = 1'b1;
  
  wire end_flag; // connects to FSM and tells whether the game is over
  
  //----------------------------------------------------------------
  
  
  // connecting module for synchronization and debouncing buttons
  
  wire [3:0] key_db; // key_db[i] is 1 when pressed
  
  sync_and_debounce # ( .w(4), .depth(debounce_depth) )
  
    sync_and_debounce_keys 
	   (
		 // inputs
		 clk, 
		 reset, 
		 ~key_sw,
		
		 // outputs
		 key_db      // ~key_sw => key_sw[i] is 1 when pressed
	    );
	 
  assign led = ~key_db;
  
  
  // *** FOR TESTBENCH ***
  // assign key_db = ~key_sw;
  // *********************
  
  
  //----------------------------------------------------------------
  
  
  // strobe for PWM
  wire digit_strobe;
  
  strobe # ( .strobe_width(indicator_strobe_width) )
    dig_strobe
	   (
		  // inputs
		  clk,
		  reset,
		  
		  // outputs
		  digit_strobe
		);

		
  //----------------------------------------------------------------

  // shift register for PWM (choosing what indicator must be ON in this moment)
  reg [3:0] ind_shift_reg;
 
  always @ (posedge clk, posedge reset)
    if (reset)
	   ind_shift_reg <= 4'b0111;
		
    else if (digit_strobe)
      ind_shift_reg <= { ind_shift_reg [0], ind_shift_reg[3:1] };

  //----------------------------------------------------------------


  // general strobe for all the indicators (for changing letters)
  wire general_letter_strobe;
  
  strobe # ( .strobe_width(letter_strobe_width) )
    let_strobe
	   (
		  // inputs
		  clk, 
		  reset,
		  
		  // outputs
		  general_letter_strobe
		);
		
		
	// *** FOR TESTBENCH ***
	//assign letter_strobe_out = general_letter_strobe;
	// *********************
 
  //----------------------------------------------------------------
  
  
  // own strobe for every indicator (for changing letters);
  // if stop_flag == 0, then strobe (frequency) of changing letter -> 0 and it stops,
  // otherwise letters on indicator are changing according to general strobe
  wire [3:0] letter_strobe;
  
  wire [3:0] stop_flag;
  
  assign letter_strobe[0] = general_letter_strobe & stop_flag[0];
  
  assign letter_strobe[1] = general_letter_strobe & stop_flag[1];
  
  assign letter_strobe[2] = general_letter_strobe & stop_flag[2];
  
  assign letter_strobe[3] = general_letter_strobe & stop_flag[3];
  
	
  //----------------------------------------------------------------
  
  
  reg [3:0] letter[3:0]; // array of displayed letters
  
  // changing letter of every indicator depending on their strobe
  always @ (posedge clk, posedge reset, posedge end_flag)
  
     if (reset || end_flag)
	    begin
	    letter[0] <= 8'b0;
		 letter[1] <= 8'b0;
		 letter[2] <= 8'b0;
		 letter[3] <= 8'b0;
		 end
		
	  else
	    begin
	    if (letter_strobe[0])
		   letter[0] <= letter[0] + 1'b1;
			
		 if (letter_strobe[1])
		   letter[1] <= letter[1] + 1'b1;
			
		 if (letter_strobe[2])
		   letter[2] <= letter[2] + 1'b1;
			
		 if (letter_strobe[3])
		   letter[3] <= letter[3] + 1'b1;
		 end
	
	
	//*** FOR TESTBENCH ***
	/*
	assign letter0 = letter[0];
	assign letter1 = letter[1];
	assign letter2 = letter[2];
	assign letter3 = letter[3];
	*/
   //*********************
	
	//----------------------------------------------------------------
  
  // function which chooses right number/letter to display depending on current letter[i] value
  function [7:0] letter_to_ind (input [4:0] letter);
    case (letter)
	   'h00: letter_to_ind = 'b00000011;  // a b c d e f g
      'h01: letter_to_ind = 'b10011111;
      'h02: letter_to_ind = 'b00100101;  //   --a--
      'h03: letter_to_ind = 'b00001101;  //  |     |
      'h04: letter_to_ind = 'b10011001;  //  f     b
      'h05: letter_to_ind = 'b01001001;  //  |     |
      'h06: letter_to_ind = 'b01000001;  //   --g--
      'h07: letter_to_ind = 'b00011111;  //  |     |
      'h08: letter_to_ind = 'b00000001;  //  e     c
      'h09: letter_to_ind = 'b00011001;  //  |     |
      'h0a: letter_to_ind = 'b00010001;  //   --d-- .
      'h0b: letter_to_ind = 'b11000001;
      'h0c: letter_to_ind = 'b01100011;
      'h0d: letter_to_ind = 'b10000101;
      'h0e: letter_to_ind = 'b01100001;
      'h0f: letter_to_ind = 'b01110001;
		
		'h10: letter_to_ind = 'b00001001;  // "G"
		'h11: letter_to_ind = 'b11000101;  // "O"
		'h12: letter_to_ind = 'b10000101;  // "D"
		'h13: letter_to_ind = 'b11100011;  // "L"
		'h14: letter_to_ind = 'b01001001;  // "S"
		'h15: letter_to_ind = 'b01100001;  // "E"
		
		default: letter_to_ind = 'b00000000;
        endcase
  endfunction
  
  //----------------------------------------------------------------
  
  // connecting FSM
  wire [4:0] message [3:0];
  
  fsm #(.en_width(8))
	fsm_main
		(
			// inputs
			.clk(clk),
			.reset(reset),
			.key(key_db),
			.letter0(letter[0]),
			.letter1(letter[1]),
			.letter2(letter[2]),
			.letter3(letter[3]),
			
			// outputs
			
			//.state_out(state_out), // FOR TESTBENCH
			
			.stop_flag(stop_flag),
			.message0(message[0]),
			.message1(message[1]),
			.message2(message[2]),
			.message3(message[3]),
			.end_flag(end_flag)
		);
  
  //----------------------------------------------------------------
  
  
  // choosing what letter to display depending on current indicator shift register
  reg [7:0] out_letter;
  
  always @*
    case (ind_shift_reg)
	 
	   4'b0111:
			if (end_flag == 1'b1)
				out_letter = letter_to_ind(message[0]);
				
			else
				out_letter = letter_to_ind({1'b0, letter[0]});
		
		4'b1011: 
			if (end_flag == 1'b1)
				out_letter = letter_to_ind(message[1]);
				
			else
				out_letter = letter_to_ind({1'b0, letter[1]});
	  
		4'b1101:
			if (end_flag == 1'b1)
				out_letter = letter_to_ind(message[2]);
				
			else
				out_letter = letter_to_ind({1'b0, letter[2]});
		
		4'b1110: 
			if (end_flag == 1'b1)
				out_letter = letter_to_ind(message[3]);
				
			else
				out_letter = letter_to_ind({1'b0, letter[3]});
         
	   default: out_letter = letter_to_ind('h00);
    
	 endcase

	 
	//----------------------------------------------------------------
	
   assign digit = ind_shift_reg;
	
	assign abcdefgh = out_letter;
	
	
	// *** FOR TESTBENCH ***
	// assign end_flag_out = end_flag;
	// *********************
	
	
endmodule