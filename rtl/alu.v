module alu #(parameter width=4) (
    input [width-1:0] a, b, 
    input [2:0] sel,
    output reg [width-1:0] out
);
    always @(*) begin
        case(sel)
            3'b000: out = a + b;
            3'b001: out = a - b;
            3'b010: out = a << 1;
            3'b011: out = a >> 1;
            3'b100: out = a & b;
            3'b101: out = a | b;
            3'b110: out = a ^ b;
            3'b111: out = ~(a | b);
            default: out = {width{1'b0}};
        endcase
    end
endmodule