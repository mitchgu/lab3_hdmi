`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// 
// Engineer: Mitchell Gu
// Module Name: hdmi_source
// Description: Takes 8-bit RGB pixel data and video timing signals and encodes
// them for output to an HDMI source.
// 
//////////////////////////////////////////////////////////////////////////////////

module hdmi_source
 	#(parameter IOSTANDARD = "TMDS_33") (
    input wire clk,
    input wire clk_5x,
    input wire reset,
    input wire [7:0] red,
    input wire [7:0] green,
    input wire [7:0] blue,
    input wire hsync,
    input wire vsync,
    input wire de,
    input wire oe,

    output wire hdmi_tx_clk_p,
    output wire hdmi_tx_clk_n,
    output wire [2:0] hdmi_tx_d_p,
    output wire [2:0] hdmi_tx_d_n
    );

	wire [9:0] red_encoded;
	wire [9:0] green_encoded;
	wire [9:0] blue_encoded;
	wire clk_serialized, red_serialized, green_serialized, blue_serialized;

    tmds_encoder red_encoder(
    	.clk(clk),
    	.reset(reset),
    	.din(red),
    	.c0(1'b0),
    	.c1(1'b0),
    	.de(de),
    	.dout(red_encoded)
    );
    tmds_encoder green_encoder(
    	.clk(clk),
    	.reset(reset),
    	.din(green),
    	.c0(1'b0),
    	.c1(1'b0),
    	.de(de),
    	.dout(green_encoded)
    );
    tmds_encoder blue_encoder(
    	.clk(clk),
    	.reset(reset),
    	.din(blue),
    	.c0(hsync),
    	.c1(vsync),
    	.de(de),
    	.dout(blue_encoded)
    );

    tmds_serializer red_serializer(
    	.clk(clk),
    	.clk_5x(clk_5x),
    	.reset(reset),
    	.din(red_encoded),
        .oce(oe),
    	.dout(red_serialized)
    );
    tmds_serializer green_serializer(
    	.clk(clk),
    	.clk_5x(clk_5x),
    	.reset(reset),
    	.din(green_encoded),
        .oce(oe),
    	.dout(green_serialized)
    );
    tmds_serializer blue_serializer(
    	.clk(clk),
    	.clk_5x(clk_5x),
    	.reset(reset),
    	.din(blue_encoded),
        .oce(oe),
    	.dout(blue_serialized)
    );
    tmds_serializer clk_serializer(
    	.clk(clk),
    	.clk_5x(clk_5x),
    	.reset(reset),
    	.din(10'b0000011111),
        .oce(oe),
    	.dout(clk_serialized)
    );

    // Output buffers
    OBUFDS #(.IOSTANDARD(IOSTANDARD)) obufds_clk (
        .I(clk_serialized),
    	.O(hdmi_tx_clk_p),
        .OB(hdmi_tx_clk_n)
    );
    OBUFDS #(.IOSTANDARD(IOSTANDARD)) obufds_red (
        .I(red_serialized),
    	.O(hdmi_tx_d_p[2]),
        .OB(hdmi_tx_d_n[2])
    );
    OBUFDS #(.IOSTANDARD(IOSTANDARD)) obufds_green (
        .I(green_serialized),
    	.O(hdmi_tx_d_p[1]),
        .OB(hdmi_tx_d_n[1])
    );
    OBUFDS #(.IOSTANDARD(IOSTANDARD)) obufds_blue (
        .I(blue_serialized),
    	.O(hdmi_tx_d_p[0]),
        .OB(hdmi_tx_d_n[0])
    );

endmodule
