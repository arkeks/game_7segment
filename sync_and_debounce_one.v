`include "config.vh"

module sync_and_debounce_one
# (
    parameter depth = 8
)
(   
    input      clk,
    input      reset,
    input      sw_in,
    output reg sw_out
);

    reg  [depth - 1:0] cnt;
    reg  [        2:0] sync;  // 3 registers for synchronization
    wire               sw_in_s;

    assign sw_in_s = sync [2];

    always @ (posedge clk or posedge reset)
        if (reset)
            sync <= 3'b0;
        else
            sync <= { sync [1:0], sw_in }; // shift register, in which comes current sw_in's value
				                               // if its' value gets into sync[2] bit, it means it's not a noise


    // counter of button pressings
    always @ (posedge clk or posedge reset)
        if (reset)
            cnt <= { depth { 1'b0 } };
        else if (sw_out ^ sw_in_s)
            cnt <= cnt + 1'b1;
        else
            cnt <= { depth { 1'b0 } };

    always @ (posedge clk or posedge reset)
        if (reset)
            sw_out <= 1'b0;
        else if (cnt == { depth { 1'b1 } })  // if counter is equal to 255 pressings, button is pressed (debounce)
            sw_out <= sw_in_s;

endmodule
