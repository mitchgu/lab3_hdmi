module pong_game (
    input wire vclock,          // 65MHz clock
    input wire reset,           // 1 to initialize module
    input wire up,              // 1 when paddle should move up
    input wire down,            // 1 when paddle should move down
    input wire [3:0] pspeed,    // puck speed in pixels/tick 
    input wire [10:0] hcount,   // horizontal index of current pixel (0..1023)
    input wire [9:0] vcount,    // vertical index of current pixel (0..767)
    input wire hsync,           // XVGA horizontal sync signal (active low)
    input wire vsync,           // XVGA vertical sync signal (active low)
    input wire blank,           // XVGA blanking (1 means output black pixel)

    output wire phsync,         // pong game's horizontal sync
    output wire pvsync,         // pong game's vertical sync
    output wire pblank,         // pong game's blanking
    output wire [23:0] pixel    // pong game's pixel (r=23:16, g=15:8, b=7:0 )
    );

    wire [2:0] checkerboard;

    // REPLACE ME! The code below just generates a color checkerboard
    // using 64 pixel by 64 pixel squares.

    // Send hsync, vsync, blank straight through (no pipelining)
    assign phsync = hsync;
    assign pvsync = vsync;
    assign pblank = blank;

    // here we use three bits from hcount and vcount to generate the
    // checkerboard
    assign checkerboard = hcount[8:6] + vcount[8:6];
    assign pixel = {{8{checkerboard[2]}}, {8{checkerboard[1]}}, {8{checkerboard[0]}}} ;
     
endmodule