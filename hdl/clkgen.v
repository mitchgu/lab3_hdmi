// 6.111 note:
// This module uses the Xilinx 7-series FPGA MMCM primitive
// to generate a 65 MHz and 325 MHz (5x) clock from the
// external 125 MHz sysclk. It was generated automatically
// from the Clocking Wizard GUI in IP Wizard > FPGA Features
// and Design > Clocking > Clocking Wizard, then reformatted
// slightly.

// file: clkgen.v
// 
// (c) Copyright 2008 - 2013 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
//----------------------------------------------------------------------------
// User entered comments
//----------------------------------------------------------------------------
// None
//
//----------------------------------------------------------------------------
//  Output     Output      Phase    Duty Cycle   Pk-to-Pk     Phase
//   Clock     Freq (MHz)  (degrees)    (%)     Jitter (ps)  Error (ps)
//----------------------------------------------------------------------------
// clk_65mhz____65.000______0.000______50.0______237.179____240.486
// clk_325mhz___325.000______0.000______50.0______183.551____240.486
//
//----------------------------------------------------------------------------
// Input Clock   Freq (MHz)    Input Jitter (UI)
//----------------------------------------------------------------------------
// __primary_____________125____________0.010

`default_nettype none

module clkgen(
    input wire clk_125mhz,

    output wire clk_65mhz,
    output wire clk_325mhz);

    // Input buffering
    //------------------------------------
    wire clk_125mhz_clkgen;
    wire clk_in2_clkgen;
    IBUF clkin1_ibufg(
        .I (clk_125mhz),
        .O (clk_125mhz_clkgen));


    // Clocking PRIMITIVE
    //------------------------------------

    // Instantiation of the MMCM PRIMITIVE
    //    * Unused inputs are tied off
    //    * Unused outputs are labeled unused

    wire clk_65mhz_clkgen;
    wire clk_325mhz_clkgen;
    wire clk_out3_clkgen;
    wire clk_out4_clkgen;
    wire clk_out5_clkgen;
    wire clk_out6_clkgen;
    wire clk_out7_clkgen;

    wire [15:0] do_unused;
    wire drdy_unused;
    wire psdone_unused;
    wire locked_int;
    wire clkfbout_clkgen;
    wire clkfbout_buf_clkgen;
    wire clkfboutb_unused;
    wire clkout0b_unused;
    wire clkout1b_unused;
    wire clkout2_unused;
    wire clkout2b_unused;
    wire clkout3_unused;
    wire clkout3b_unused;
    wire clkout4_unused;
    wire clkout5_unused;
    wire clkout6_unused;
    wire clkfbstopped_unused;
    wire clkinstopped_unused;

    MMCME2_ADV #(
        .BANDWIDTH              ("OPTIMIZED"),
        .CLKOUT4_CASCADE        ("FALSE"),
        .COMPENSATION           ("ZHOLD"),
        .STARTUP_WAIT           ("FALSE"),
        .DIVCLK_DIVIDE          (5),
        .CLKFBOUT_MULT_F        (39.000),
        .CLKFBOUT_PHASE         (0.000),
        .CLKFBOUT_USE_FINE_PS   ("FALSE"),
        .CLKOUT0_DIVIDE_F       (15.000),
        .CLKOUT0_PHASE          (0.000),
        .CLKOUT0_DUTY_CYCLE     (0.500),
        .CLKOUT0_USE_FINE_PS    ("FALSE"),
        .CLKOUT1_DIVIDE         (3),
        .CLKOUT1_PHASE          (0.000),
        .CLKOUT1_DUTY_CYCLE     (0.500),
        .CLKOUT1_USE_FINE_PS    ("FALSE"),
        .CLKIN1_PERIOD          (8.0))
    mmcm_adv_inst (
        // Output clocks
        .CLKFBOUT               (clkfbout_clkgen),
        .CLKFBOUTB              (clkfboutb_unused),
        .CLKOUT0                (clk_65mhz_clkgen),
        .CLKOUT0B               (clkout0b_unused),
        .CLKOUT1                (clk_325mhz_clkgen),
        .CLKOUT1B               (clkout1b_unused),
        .CLKOUT2                (clkout2_unused),
        .CLKOUT2B               (clkout2b_unused),
        .CLKOUT3                (clkout3_unused),
        .CLKOUT3B               (clkout3b_unused),
        .CLKOUT4                (clkout4_unused),
        .CLKOUT5                (clkout5_unused),
        .CLKOUT6                (clkout6_unused),
        // Input clock control
        .CLKFBIN                (clkfbout_buf_clkgen),
        .CLKIN1                 (clk_125mhz_clkgen),
        .CLKIN2                 (1'b0),
        // Tied to always select the primary input clock
        .CLKINSEL               (1'b1),
        // Ports for dynamic reconfiguration
        .DADDR                  (7'h0),
        .DCLK                   (1'b0),
        .DEN                    (1'b0),
        .DI                     (16'h0),
        .DO                     (do_unused),
        .DRDY                   (drdy_unused),
        .DWE                    (1'b0),
        // Ports for dynamic phase shift
        .PSCLK                  (1'b0),
        .PSEN                   (1'b0),
        .PSINCDEC               (1'b0),
        .PSDONE                 (psdone_unused),
        // Other control and status signals
        .LOCKED                 (locked_int),
        .CLKINSTOPPED           (clkinstopped_unused),
        .CLKFBSTOPPED           (clkfbstopped_unused),
        .PWRDWN                 (1'b0),
        .RST                    (1'b0));

    // Clock Monitor clock assigning
    //--------------------------------------
    // Output buffering
    //-----------------------------------

    BUFG clkf_buf(
        .I (clkfbout_clkgen),
        .O (clkfbout_buf_clkgen));

    BUFG clkout1_buf(
        .I (clk_65mhz_clkgen),
        .O (clk_65mhz));

    BUFG clkout2_buf(
        .I(clk_325mhz_clkgen),
        .O(clk_325mhz));

endmodule
