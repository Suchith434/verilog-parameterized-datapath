module cpu_top (
    input clk,
    input reset,
    output [3:0] debug_alu_out
);

    wire internal_we;
    wire [2:0] internal_alu_sel, internal_w_addr, internal_r_addr1, internal_r_addr2;
    wire internal_Z, internal_N, internal_C, internal_V;
  
    // Control Unit Instantiation
    control_unit cu (
        .clk(clk),
        .reset(reset),
        .Z(internal_Z), .N(internal_N), .C(internal_C), .V(internal_V),
        .we(internal_we), .alu_sel(internal_alu_sel), .w_addr(internal_w_addr), 
        .r_addr1(internal_r_addr1), .r_addr2(internal_r_addr2)
    );

    // Datapath Instantiation
    datapath #(4, 3) dp (
        .clk(clk),
        .we(internal_we), .alu_sel(internal_alu_sel), .w_addr1(internal_w_addr), 
        .r_addr1(internal_r_addr1), .r_addr2(internal_r_addr2),
        .alu_out(debug_alu_out),
        .Z(internal_Z), .N(internal_N), .C(internal_C), .V(internal_V)
    );

endmodule