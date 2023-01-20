module strobe 
# (
    parameter strobe_width = 10
)

(
  input clk,
  input reset,
  
  output strobe
);
 
  reg [31:0] cnt;
  
  always @ (posedge clk, posedge reset)
    if (reset)
	   cnt <= 'b0;
	 else
	   cnt <= cnt + 1'b1;
		
  assign strobe = (cnt[strobe_width - 1:0] == 'b0);
  
endmodule