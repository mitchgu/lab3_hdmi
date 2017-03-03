`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
//
// Engineer: Mitchell Gu
// Module Name: tmds_serializer
// Description: Serializes 10-bit parallel TMDS data into a serial output using
// the OSERDESE2 primitive
// 
//////////////////////////////////////////////////////////////////////////////////

module tmds_serializer(
    input wire clk,
    input wire clk_5x,
    input wire reset,
    input wire [9:0] din,
    input wire oce,

    output wire dout
    );
    
    wire shift1, shift2;
    wire serdes_out;
    // Serialization primitive in width expansion configuration with data width of 10
    OSERDESE2
      # (
        .DATA_RATE_OQ   ("DDR"),
        .DATA_RATE_TQ   ("SDR"),
        .DATA_WIDTH     (10),
        .TRISTATE_WIDTH (1),
        .SERDES_MODE    ("MASTER"))
      oserdese2_master (
        .D1             (din[0]),
        .D2             (din[1]),
        .D3             (din[2]),
        .D4             (din[3]),
        .D5             (din[4]),
        .D6             (din[5]),
        .D7             (din[6]),
        .D8             (din[7]),
        .T1             (1'b0),
        .T2             (1'b0),
        .T3             (1'b0),
        .T4             (1'b0),
        .SHIFTIN1       (shift1),
        .SHIFTIN2       (shift2),
        .SHIFTOUT1      (),
        .SHIFTOUT2      (),
        .OCE            (oce),
        .CLK            (clk_5x),
        .CLKDIV         (clk),
        .OQ             (dout),
        .TQ             (),
        .OFB            (),
        .TFB            (),
        .TBYTEIN        (1'b0),
        .TBYTEOUT       (),
        .TCE            (1'b0),
        .RST            (reset));

    OSERDESE2
      # (
        .DATA_RATE_OQ   ("DDR"),
        .DATA_RATE_TQ   ("SDR"),
        .DATA_WIDTH     (10),
        .TRISTATE_WIDTH (1),
        .SERDES_MODE    ("SLAVE"))
      oserdese2_slave (
        .D1             (1'b0), 
        .D2             (1'b0),
        .D3             (din[8]),
        .D4             (din[9]),
        .D5             (1'b0),
        .D6             (1'b0),
        .D7             (1'b0),
        .D8             (1'b0),
        .T1             (1'b0),
        .T2             (1'b0),
        .T3             (1'b0),
        .T4             (1'b0),
        .SHIFTOUT1      (shift1),
        .SHIFTOUT2      (shift2),
        .SHIFTIN1       (1'b0),
        .SHIFTIN2       (1'b0),
        .OCE            (oce),
        .CLK            (clk_5x),
        .CLKDIV         (clk),
        .OQ             (), //data_out_to_pins_predelay[pin_count]),
        .TQ             (),
        .OFB            (),
        .TFB            (),
        .TBYTEIN        (1'b0),
        .TBYTEOUT       (),
        .TCE            (1'b0),
        .RST            (reset));
    
endmodule
