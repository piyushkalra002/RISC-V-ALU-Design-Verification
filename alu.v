module alu #(
    parameter WIDTH = 32
) (
    input  [WIDTH-1:0] a,
    input  [WIDTH-1:0] b,
    input  [2:0]        alu_ctrl,
    output reg [WIDTH-1:0] result,
    output zero,
    output reg overflow
);

always @(*) begin
    overflow = 1'b0;
    case (alu_ctrl)
        3'b000: begin // ADD
            result = a + b;
            // Signed overflow: both operands same sign, but result flips sign
            overflow = (a[WIDTH-1] == b[WIDTH-1]) && (result[WIDTH-1] != a[WIDTH-1]);
        end
        3'b001: begin // SUB
            result = a - b;
            // Signed overflow: operands differ in sign, result doesn't match a's sign
            overflow = (a[WIDTH-1] != b[WIDTH-1]) && (result[WIDTH-1] != a[WIDTH-1]);
        end
        3'b010: result = a & b;                                           // AND
        3'b011: result = a | b;                                           // OR
        3'b100: result = a ^ b;                                           // XOR
        3'b101: result = ($signed(a) < $signed(b)) ? {{WIDTH-1{1'b0}}, 1'b1} : {WIDTH{1'b0}}; // SLT
        default: result = {WIDTH{1'b0}};
    endcase
end

assign zero = (result == {WIDTH{1'b0}});

endmodule