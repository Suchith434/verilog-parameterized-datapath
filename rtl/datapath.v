module datapath #(parameter DATA_width=4, ADDR_width=2)(
    input clk, we, 
    input [ADDR_width-1:0] w_addr1, r_addr1, r_addr2, 
    input [2:0] alu_sel, 
    output [DATA_width-1:0] alu_out
);
    wire [DATA_width-1:0] r_data1, r_data2;
    
    reg_file #(DATA_width, ADDR_width) regfile(
        .clk(clk), .we(we), .w_addr1(w_addr1), .w_data(alu_out),
        .r_data1(r_data1), .r_addr1(r_addr1), 
        .r_addr2(r_addr2), .r_data2(r_data2)
    );
    
    alu #(DATA_width) alu(
        .a(r_data1), .b(r_data2), 
        .sel(alu_sel), .out(alu_out)
    );
endmodule