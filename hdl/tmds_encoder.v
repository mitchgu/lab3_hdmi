`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
//
// Engineer: Mitchell Gu
// Module Name: tmds_encoder
// Description: Performs the 8b/10b TMDS encoding defined in the DVI spec on an
// 8-bit data channel
// 
//////////////////////////////////////////////////////////////////////////////////


module tmds_encoder(
    input wire clk,
    input wire reset,
    input wire [7:0] din, // 8 bit channel data
    input wire c0, // Control bit 0
    input wire c1, // Control bit 1
    input wire de, // Data enable

    output reg [9:0] dout // 10 bit encoded output
    );

	//////////////////////////////////////////////////////////////////////////////
	// STAGE 1: XOR or XNOR (8 bits to 9 bits)
	//////////////////////////////////////////////////////////////////////////////
	wire [8:0] s1; // Stage 1 result
	wire [3:0] high_count1 = din[0] + din[1] + din[2] + din[3] +
							 din[4] + din[5] + din[6] + din[7];
	// Determine if there are more 1's than 0's in the input bus
	wire condition1 = (high_count1 > 4) | (high_count1 == 4 && din[0] == 0);
	// If there's more 1's, use XNOR for stage 1, else XOR
	assign s1[0] = din[0];
	assign s1[7:1] = (condition1) ? s1[6:0] ^~ din[7:1] : s1[6:0] ^ din[7:1];
	assign s1[8] = ~condition1; // Add a 9th bit that represents condition1

	//////////////////////////////////////////////////////////////////////////////
	// STAGE 2: To invert or not (9 bits to 10 bits)
	//////////////////////////////////////////////////////////////////////////////
	reg signed [4:0] cnt = 0; // Disparity counter
	wire signed [4:0] next_cnt; // next value of counter
	wire [9:0] s2; // Stage 2 result
	// Two wires for number of 1's and number of 0's
	wire [3:0] high_count2 = s1[0] + s1[1] + s1[2] + s1[3] +
							 s1[4] + s1[5] + s1[6] + s1[7];
	wire [3:0] low_count2 = ~s1[0] + ~s1[1] + ~s1[2] + ~s1[3] +
							~s1[4] + ~s1[5] + ~s1[6] + ~s1[7];
	// Condition 2 is true when the balance of 0's and 1's is dead on
	wire condition2 = (cnt == 0) | (high_count2 == low_count2);
	// Condition 3 is true when the current input's 0 and 1 balance
	// would increase the current disparity (balance of 0's and 1's)
	// In which case we should invert the data output to restore balance
	wire condition3 = (cnt > 0 && high_count2 > low_count2) |
	                    (cnt < 0 && low_count2 > high_count2);
	wire invert = (condition2) ? condition1 : (condition3) ? 1 : 0;
	// Assign the final 10 bits
	assign s2[7:0] = (invert) ? ~s1[7:0] : s1[7:0];
	assign s2[8] = s1[8]; // Always preserve the 9th bit (~condition1)
	assign s2[9] = invert; // 10th bit represents inversion
	// Update the disparity counter
	assign next_cnt = (invert) 
		? cnt + {1'b0, low_count2} - {1'b0, high_count2} + {1'b0, s2[8]} + {1'b0, s2[9]}
		: cnt + {1'b0, high_count2} - {1'b0, low_count2} + {1'b0, s2[8]} + {1'b0, s2[9]};

	// Synchronous output stage
	always @(posedge clk) begin
		if (reset)
			dout <= 10'b0;
		else if (de) begin
			dout <= s2; // Clock in result of stage 2
			cnt <= (reset) ? 0 : next_cnt; // Clock in the new disparity
		end
		else begin // If no data enable (blanking), use control bits for dout
			case ({c1, c0})
				2'b00: dout <= 10'b1101010100;
				2'b01: dout <= 10'b0010101011;
				2'b10: dout <= 10'b0101010100;
				2'b11: dout <= 10'b1010101011;
			endcase
			cnt <= 0;
		end
	end

endmodule