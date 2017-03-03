`default_nettype none

module main (
    input wire sysclk, // 125 MHz external clock
    // Button and switch inputs
    input wire [3:0] btn,
    input wire [1:0] sw, 
    // LED outputs
    output wire [3:0] led,
    output wire [2:0] rgb_led_l,
    output wire [2:0] rgb_led_r,
    // HDMI source
    output wire hdmi_tx_clk_p,
    output wire hdmi_tx_clk_n,
    output wire [2:0] hdmi_tx_d_p,
    output wire [2:0] hdmi_tx_d_n,
    input wire hdmi_tx_hpdn,
    output wire hdmi_tx_cec,
    output wire hdmi_tx_scl,
    output wire hdmi_tx_sda
    );

    // Clock generation
    wire clk_65mhz;
    wire clk_325mhz;
    clkgen clkgen1(
        .clk_125mhz(sysclk),
        .clk_65mhz(clk_65mhz),
        .clk_325mhz(clk_325mhz));

    // Debounce all buttons and switches
    wire [3:0] btn_clean;
    wire [1:0] sw_clean;
    wire hdmi_hpd_clean;
    debounce #(.COUNT(7)) debouncer(
        .clk(clk_65mhz),
        .reset(1'b0),
        .noisy({btn, sw, ~hdmi_tx_hpdn}),
        .clean({btn_clean, sw_clean, hdmi_hpd_clean}));

    // XVGA video signals
    wire [10:0] hcount;
    wire [9:0] vcount;
    wire hsync, vsync, blank;
    xvga xvga1(
        .vclock(clk_65mhz),
        .hcount(hcount),
        .vcount(vcount),
        .vsync(vsync),
        .hsync(hsync),
        .blank(blank));

    // Instantiate your pong game module
    wire pg_reset = btn_clean[1];
    wire up = btn_clean[3];
    wire down = btn_clean[2];
    wire [3:0] pspeed = 4'd4;
    wire [23:0] pg_pixel;
    wire phsync, pvsync, pblank;
    pong_game pg(
        .vclock(clk_65mhz),
        .reset(pg_reset),
        .up(up),
        .down(down),
        .pspeed(pspeed),
        .hcount(hcount),
        .vcount(vcount),
        .hsync(hsync),
        .vsync(vsync),
        .blank(blank),
        .phsync(phsync),
        .pvsync(pvsync),
        .pblank(pblank),
        .pixel(pg_pixel));

    // sw_clean[1:0] selects which video generator to use:
    // 00: user's pong game
    // 01: 1 pixel outline of active video area (adjust screen controls)
    // 10: color bars
    reg [23:0] pixel_out;
    reg hsync_out, vsync_out, blank_out;
    wire border = (hcount==0 | hcount==1023 | vcount==0 | vcount==767);
    always @(posedge clk_65mhz) begin
        case (sw_clean[1:0])
            2'b01: begin
                // 1 pixel outline of visible area (white)
                hsync_out <= hsync;
                vsync_out <= vsync;
                blank_out <= blank;
                pixel_out <= {24{border}};
            end
            2'b10: begin
                // color bars
                hsync_out <= hsync;
                vsync_out <= vsync;
                blank_out <= blank;
                pixel_out <= {{8{hcount[8]}}, {8{hcount[7]}}, {8{hcount[6]}}} ;
            end
            default: begin
                // default: pong game
                hsync_out <= phsync;
                vsync_out <= pvsync;
                blank_out <= pblank;
                pixel_out <= pg_pixel;
            end
        endcase
    end

    // HDMI output
    reg last_hpd; // hot-plug detect
    reg hdmi_reset = 0;
    always @(posedge clk_65mhz) begin
        // Reset output on rising edge (HDMI cable inserted)
        hdmi_reset = (hdmi_hpd_clean & ~last_hpd) ? 1'b1 : 1'b0;
        last_hpd <= hdmi_hpd_clean;
    end
    hdmi_source hdmi_source1(
        .clk(clk_65mhz),
        .clk_5x(clk_325mhz),
        .reset(hdmi_reset),
        .red(pixel_out[23:16]),
        .green(pixel_out[15:8]),
        .blue(pixel_out[7:0]),
        .hsync(hsync_out),
        .vsync(vsync_out),
        .de(~blank_out),
        .oe(hdmi_hpd_clean),
        .hdmi_tx_clk_p(hdmi_tx_clk_p),
        .hdmi_tx_clk_n(hdmi_tx_clk_n),
        .hdmi_tx_d_p(hdmi_tx_d_p),
        .hdmi_tx_d_n(hdmi_tx_d_n));
    assign hdmi_tx_cec = 1'bZ;
    assign hdmi_tx_scl = 1'bZ;
    assign hdmi_tx_sda = 1'bZ;

    // LED Outputs
    // Will be purple if no cable is connected
    assign rgb_led_l = {~hdmi_hpd_clean, sw_clean[0], ~hdmi_hpd_clean};
    assign rgb_led_r = {~hdmi_hpd_clean, sw_clean[1], ~hdmi_hpd_clean};
    assign led = btn_clean;

endmodule