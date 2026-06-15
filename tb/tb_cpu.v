module tb_cpu_top;
    reg clk;
    reg reset;
    wire [3:0] debug_alu_out;

    // Instantiate the Top-Level CPU
    cpu_top dut (
        .clk(clk),
        .reset(reset),
        .debug_alu_out(debug_alu_out)
    );

    // Generate the Clock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu_tapeout.vcd");
        $dumpvars(0, tb_cpu_top);
        
        // Backdoor Memory Pre-load
        // We still need to load the data into the SRAM array so our ROM instructions have data to calculate!
        dut.dp.regfile.memory_array[1] = 4'd5;
        dut.dp.regfile.memory_array[2] = 4'd5;
        dut.dp.regfile.memory_array[3] = 4'd3;
        dut.dp.regfile.memory_array[4] = 4'd6;
        dut.dp.regfile.memory_array[5] = 4'd15;
        dut.dp.regfile.memory_array[6] = 4'd2;
        dut.dp.regfile.memory_array[7] = 4'd7;

        // Monitor the internal CPU wires to watch the brain and muscle talk to each other
        $monitor("Time=%0t | State=%d | PC=%d | ALU_Out=%b | Z=%b N=%b C=%b V=%b",
                 $time, dut.cu.current_state, dut.cu.pc, debug_alu_out,
                 dut.internal_Z, dut.internal_N, dut.internal_C, dut.internal_V);

        // System Boot Sequence
        clk = 0;
        reset = 1;  // Hold processor in reset
        #15;
        reset = 0;  // Release reset, let the CPU execute its ROM!

        // Let the clock run long enough for the FSM to cycle through the 4 instructions
        #200;   
        $finish;
    end
endmodule