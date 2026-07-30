module testbench;

    localparam WIDTH = 32;

    reg  [WIDTH-1:0] a, b;
    reg  [2:0]        alu_ctrl;
    wire [WIDTH-1:0] result;
    wire             zero;
    wire             overflow;

    integer pass_count = 0;
    integer fail_count = 0;

    alu #(.WIDTH(WIDTH)) uut (
        .a(a), .b(b), .alu_ctrl(alu_ctrl),
        .result(result), .zero(zero), .overflow(overflow)
    );

    task check_result(input [WIDTH-1:0] expected, input [127:0] test_name);
        begin
            if (result === expected) begin
                pass_count = pass_count + 1;
            end else begin
                fail_count = fail_count + 1;
                $display("FAIL: %0s | got %0d, expected %0d", test_name, result, expected);
            end
        end
    endtask

    // Reference model: computes the CORRECT answer independently,
    // never calling the DUT's own logic - this is what makes randomized
    // testing meaningful instead of circular
    function [WIDTH-1:0] ref_model(input [WIDTH-1:0] ra, rb, input [2:0] ctrl);
        case (ctrl)
            3'b000: ref_model = ra + rb;
            3'b001: ref_model = ra - rb;
            3'b010: ref_model = ra & rb;
            3'b011: ref_model = ra | rb;
            3'b100: ref_model = ra ^ rb;
            3'b101: ref_model = ($signed(ra) < $signed(rb)) ? 1 : 0;
            default: ref_model = 0;
        endcase
    endfunction

    integer i;
    reg [WIDTH-1:0] expected_random;

    initial begin
        // ---- Directed tests (one per operation) ----
        a = 10; b = 5; alu_ctrl = 3'b000; #10; check_result(15, "ADD");
        a = 10; b = 5; alu_ctrl = 3'b001; #10; check_result(5, "SUB");
        a = 32'hF0F0F0F0; b = 32'h0F0F0F0F; alu_ctrl = 3'b010; #10; check_result(32'h00000000, "AND");
        a = 32'hF0F0F0F0; b = 32'h0F0F0F0F; alu_ctrl = 3'b011; #10; check_result(32'hFFFFFFFF, "OR");
        a = 32'hFF00FF00; b = 32'h0F0F0F0F; alu_ctrl = 3'b100; #10; check_result(32'hF00FF00F, "XOR");
        a = -3; b = 5; alu_ctrl = 3'b101; #10; check_result(1, "SLT (negative < positive)");

        // ---- Overflow edge case: two large positives, adding into overflow ----
        a = 32'h7FFFFFFF; // max positive signed 32-bit value
        b = 32'h00000001;
        alu_ctrl = 3'b000; #10;
        if (overflow === 1'b1) begin
            pass_count = pass_count + 1;
        end else begin
            fail_count = fail_count + 1;
            $display("FAIL: ADD overflow not detected");
        end

        // ---- Randomized testing: 200 random cases checked against reference model ----
        for (i = 0; i < 200; i = i + 1) begin
            a = $random;
            b = $random;
            alu_ctrl = $random % 6; // only valid opcodes 0-5
            #5;
            expected_random = ref_model(a, b, alu_ctrl);
            check_result(expected_random, "RANDOM");
        end

        $display("\n=== Results: %0d passed, %0d failed (out of %0d total) ===",
                  pass_count, fail_count, pass_count + fail_count);
        $finish;
    end

endmodule