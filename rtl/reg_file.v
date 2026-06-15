module reg_file #(parameter DATA_width=4, ADDR_width=2)(
    input clk, input we, 
    input [ADDR_width-1:0] w_addr1, input [DATA_width-1:0] w_data, 
    input [ADDR_width-1:0] r_addr1, output [DATA_width-1:0] r_data1, 
    input [ADDR_width-1:0] r_addr2, output [DATA_width-1:0] r_data2
);
    reg [DATA_width-1:0] memory_array [0:(1<<ADDR_width)-1]; 
    
    assign r_data1 = memory_array[r_addr1];
    assign r_data2 = memory_array[r_addr2];
    
    always @(posedge clk) begin
        if(we) begin
            memory_array[w_addr1] <= w_data;
        end
    end
endmodule