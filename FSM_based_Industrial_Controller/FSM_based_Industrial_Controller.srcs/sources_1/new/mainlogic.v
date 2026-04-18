`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.01.2026 00:14:08
// Design Name: 
// Module Name: mainlogic
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


module safety_fsm (
    input  wire clk,
    input  wire reset,
    input  wire emergency,
    output reg  safety_ok
);

    parameter NORMAL = 1'b0, EMERGENCY = 1'b1;
    reg state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= NORMAL;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            NORMAL:    next_state = emergency ? EMERGENCY : NORMAL;
            EMERGENCY: next_state = emergency ? EMERGENCY : NORMAL;
            default:   next_state = NORMAL;
        endcase
    end

    always @(*) begin
        safety_ok = (state == NORMAL);
    end

endmodule


module conveyor_fsm (
    input  wire clk,
    input  wire reset,
    input  wire enable,
    input  wire item_at_end,
    input  wire safety_ok,
    output reg  conveyor_on,
    output reg  conv_done
);

    parameter IDLE = 1'b0, RUN = 1'b1;
    reg state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else if (!safety_ok)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            IDLE: next_state = enable ? RUN : IDLE;
            RUN:  next_state = item_at_end ? IDLE : RUN;
            default: next_state = IDLE;
        endcase
    end

    always @(*) begin
        conveyor_on = (state == RUN);
        conv_done   = (state == RUN && item_at_end);
    end

endmodule


module sorting_fsm (
    input  wire clk,
    input  wire reset,
    input  wire enable,
    input  wire item_type,
    input  wire safety_ok,
    output reg  push_left,
    output reg  push_right,
    output reg  sort_done
);

    parameter IDLE = 1'b0, SORT = 1'b1;
    reg state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else if (!safety_ok)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            IDLE: next_state = enable ? SORT : IDLE;
            SORT: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    always @(*) begin
        push_left  = (state == SORT && item_type == 0);
        push_right = (state == SORT && item_type == 1);
        sort_done  = (state == SORT);
    end

endmodule


module packaging_fsm (
    input  wire clk,
    input  wire reset,
    input  wire enable,
    input  wire safety_ok,
    output reg  packaging_active,
    output reg  pack_done
);

    parameter IDLE = 1'b0, PACK = 1'b1;
    reg state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else if (!safety_ok)
            state <= IDLE;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            IDLE: next_state = enable ? PACK : IDLE;
            PACK: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    always @(*) begin
        packaging_active = (state == PACK);
        pack_done = (state == PACK);
    end

endmodule


module mainlogic (
    input  wire clk,
    input  wire reset,
    input  wire emergency,
    input  wire item_ready,
    input  wire item_type,
    input  wire item_at_end,

    output wire conveyor_on,
    output wire push_left,
    output wire push_right,
    output wire packaging_active,
    output wire safety_ok
);

    // ---------------- SAFETY ----------------
    safety_fsm S1 (
        .clk(clk),
        .reset(reset),
        .emergency(emergency),
        .safety_ok(safety_ok)
    );

    // ---------------- PROCESS FSM ----------------
    parameter WAIT=3'b000, MOVE1=3'b001, SORT=3'b010,
              MOVE2=3'b011, PACK=3'b100, MOVE3=3'b101;

    reg [2:0] state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= WAIT;
        else if (!safety_ok)
            state <= WAIT;
        else
            state <= next_state;
    end

    always @(*) begin
        case (state)
            WAIT:  next_state = item_ready ? MOVE1 : WAIT;
            MOVE1: next_state = SORT;
            SORT:  next_state = MOVE2;
            MOVE2: next_state = PACK;
            PACK:  next_state = MOVE3;
            MOVE3: next_state = item_at_end ? WAIT : MOVE3;
            default: next_state = WAIT;
        endcase
    end

    wire conv_en  = (state == MOVE1 || state == MOVE2 || state == MOVE3);
    wire sort_en  = (state == SORT);
    wire pack_en  = (state == PACK);

    // ---------------- SUB FSMs ----------------
    conveyor_fsm C1 (
        .clk(clk),
        .reset(reset),
        .enable(conv_en),
        .item_at_end(item_at_end),
        .safety_ok(safety_ok),
        .conveyor_on(conveyor_on),
        .conv_done()
    );

    sorting_fsm S2 (
        .clk(clk),
        .reset(reset),
        .enable(sort_en),
        .item_type(item_type),
        .safety_ok(safety_ok),
        .push_left(push_left),
        .push_right(push_right),
        .sort_done()
    );

    packaging_fsm P1 (
        .clk(clk),
        .reset(reset),
        .enable(pack_en),
        .safety_ok(safety_ok),
        .packaging_active(packaging_active),
        .pack_done()
    );

endmodule
