`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.01.2026 00:37:04
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module mainlogic_tb;

    // ---------------- CLOCK ----------------
    reg clk;
    always #5 clk = ~clk;   // 10 ns clock

    // ---------------- INPUTS ----------------
    reg reset;
    reg emergency;
    reg item_ready;
    reg item_type;     // 0 = LEFT, 1 = RIGHT
    reg item_at_end;

    // ---------------- OUTPUTS ----------------
    wire conveyor_on;
    wire push_left;
    wire push_right;
    wire packaging_active;
    wire safety_ok;

    // ---------------- DUT ----------------
    mainlogic DUT (
        .clk(clk),
        .reset(reset),
        .emergency(emergency),
        .item_ready(item_ready),
        .item_type(item_type),
        .item_at_end(item_at_end),
        .conveyor_on(conveyor_on),
        .push_left(push_left),
        .push_right(push_right),
        .packaging_active(packaging_active),
        .safety_ok(safety_ok)
    );

    // ---------------- TEST SEQUENCE ----------------
    initial begin
        // Initial values
        clk = 0;
        reset = 1;
        emergency = 0;
        item_ready = 0;
        item_type = 0;
        item_at_end = 0;

        // -------- RESET --------
        #20 reset = 0;

        // ==================================================
        // ITEM 1 : LEFT
        // ==================================================
        #10 item_ready = 1;
            item_type  = 0;   // LEFT
        #10 item_ready = 0;

        // Item moves through system
        #80 item_at_end = 1;
        #10 item_at_end = 0;

        // ==================================================
        // ITEM 2 : RIGHT
        // ==================================================
        #30 item_ready = 1;
            item_type  = 1;   // RIGHT
        #10 item_ready = 0;

        #80 item_at_end = 1;
        #10 item_at_end = 0;

        // ==================================================
        // EMERGENCY CASE
        // ==================================================
        #20 emergency = 1;    // emergency stop
        #30 emergency = 0;    // emergency cleared

        // New item after emergency
        #20 item_ready = 1;
            item_type  = 0;
        #10 item_ready = 0;

        #80 item_at_end = 1;
        #10 item_at_end = 0;

        // -------- END SIMULATION --------
        #50 $stop;
    end

endmodule

