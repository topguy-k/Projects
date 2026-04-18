`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.03.2026 23:27:48
// Design Name: 
// Module Name: ALU_main
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
module ALU_main (
    input  [3:0] a, b,
    input  [2:0] op,        // 3-bit opcode
    output reg [7:0] result=0 // wide enough for multiplication
);

always @(*) begin
    case(op)
        3'b000: result = a + b;   // ADD
        3'b001: result = a - b;   // SUB
        3'b010: result = a * b;   // MUL
        3'b011: result = a & b;   // AND
        3'b100: result = a | b;   // OR
        3'b101: result = a ^ b;   // XOR
        3'b110: result = a % b;   // REMAINDER
        default: result = 0;
    endcase
end

endmodule
