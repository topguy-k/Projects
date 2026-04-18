`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.03.2026 00:01:02
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


module testbench;

reg [3:0] a, b;
reg [2:0] op;
wire [7:0] result;

ALU_main uut (.a(a), .b(b), .op(op), .result(result));

initial begin
    a = 4'd6; b = 4'd5;

    op = 3'b000; #10; // ADD
    op = 3'b001; #10; // SUB
    op = 3'b010; #10; // MUL
    op = 3'b110; #10; // REM

    $finish;
end

endmodule
