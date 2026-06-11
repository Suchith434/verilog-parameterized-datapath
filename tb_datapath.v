module tb_datapath;
parameter TB_DATA_width=4,TB_ADDR_width=2;
reg clk_tb,we_tb;
reg [TB_ADDR_width-1:0] tb_w_addr1,tb_r_addr1,tb_r_addr2;
reg [2:0] tb_alu_sel;
wire [TB_DATA_width-1:0] tb_alu_out;
datapath #(.DATA_width(TB_DATA_width),.ADDR_width(TB_ADDR_width)) dut(.clk(clk_tb),.we(we_tb),.w_addr1(tb_w_addr1),.r_addr1(tb_r_addr1),.r_addr2(tb_r_addr2),.alu_sel(tb_alu_sel),.alu_out(tb_alu_out));
always #5 clk_tb=~clk_tb;
initial begin
    $dumpfile("datapath.vcd");
    $dumpvars(0,tb_datapath);
    clk_tb=0;we_tb=0;
    dut.regfile.memory_array[1]=4'd5;
    dut.regfile.memory_array[2]=4'd3;
    $monitor("Time=%0t, WE=%b, W_Addr=%b, R_Addr1=%b, R_Addr2=%b, ALU_Sel=%b, ALU_Out=%b",$time,we_tb,tb_w_addr1,tb_r_addr1,tb_r_addr2,tb_alu_sel,tb_alu_out);
    #10 tb_alu_sel=3'b000; 
    tb_r_addr1=2'd1;
    tb_r_addr2=2'd2; 
    tb_w_addr1=2'd3; 
    we_tb=1; 
    #10 we_tb=0;
$finish;
end
endmodule