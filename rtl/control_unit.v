module control_unit (
    input clk,
    input reset,
    
    // Status Flags (Inputs from Datapath)
    input Z, N, C, V,
    
    // Control Signals (Outputs to Datapath)
    output reg we,
    output reg [2:0] alu_sel,
    output reg [2:0] w_addr,
    output reg [2:0] r_addr1,
    output reg [2:0] r_addr2
);

    // FSM State Encoding
    localparam FETCH   = 2'd0;
    localparam DECODE  = 2'd1;
    localparam EXECUTE = 2'd2;
    
    reg [1:0] current_state, next_state;

    // Program Counter & Instruction Register
    reg [2:0] pc;
    reg [12:0] ir; // Holds the current 13-bit instruction
    // 13 bits are divided into: {alu_sel[2:0], w_addr[2:0], r_addr1[2:0], r_addr2[2:0], we}
    // The Instruction ROM (Hardcoded program)
    reg [12:0] rom [0:7];
    reg saved_Z;
    
   initial begin
        // Instruction Mapping: {alu_sel[2:0], w_addr[2:0], r_addr1[2:0], r_addr2[2:0], we}
        // Opcode 3'b101 = JZ (Jump if Zero). Target address goes in the w_addr[2:0] slot.
        
        rom[0] = 13'b001_000_001_010_0; // Line 0: Subtract R1 from R2. Z flag triggers!
        rom[1] = 13'b101_000_000_000_0;               // Line 1: YOUR TURN (Jump to Line 0)
        
        rom[2] = 13'b000_000_101_110_0; // Line 2: A random Add instruction. (The CPU should NEVER reach this line!)
        rom[3] = 13'd0; 
        rom[4] = 13'd0; 
        rom[5] = 13'd0; 
        rom[6] = 13'd0; 
        rom[7] = 13'd0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= FETCH;
            pc <= 3'd0;
            saved_Z <= 1'b0; // Initialize the status register
        end else begin
            current_state <= next_state;
            
            if (current_state == EXECUTE) begin
                
                // 1. UPDATE STATUS REGISTER (Only if it's a math operation)
                if (ir[12:10] != 3'b101) begin
                    saved_Z <= Z; // Latch the physical wire into memory!
                end
                
                // 2. CONTROL FLOW (Check the saved flag, not the physical wire)
                if (ir[12:10] == 3'b101 && saved_Z == 1'b1) begin
                    pc <= ir[9:7]; // Jump
                end else begin
                    pc <= pc + 1;  // Increment
                end
                
            end
        end
    end

    // ---------------------------------------------------------
    // BLOCK 2: Next State Logic (Combinational)
    // ---------------------------------------------------------
    always @(*) begin
        case (current_state)
            FETCH:   next_state = DECODE;
            DECODE:  next_state = EXECUTE;
            EXECUTE: next_state = FETCH;
            default: next_state = FETCH;
        endcase
    end

        // ---------------------------------------------------------
    // BLOCK 3: Output Logic (Combinational)
    // ---------------------------------------------------------
    always @(*) begin
        // 1. HARDWIRE THE INSTRUCTION REGISTER TO THE DATAPATH
        // These wires should never disconnect. Whatever is in IR drives the datapath.
        alu_sel = ir[12:10];
        w_addr  = ir[9:7];
        r_addr1 = ir[6:4];
        r_addr2 = ir[3:1];
        
        // Default WE to 0 for safety
        we = 0;
        
        case (current_state)
            FETCH: begin
                // In Fetch, we just load the ROM data into the IR.
                // Notice we are NOT assigning 'ir' in DECODE or EXECUTE, 
                // so it will naturally hold its value!
                ir = rom[pc]; 
            end
            
            DECODE: begin
                // The Datapath is passively reading the addresses and doing the math.
                // We just wait here for 1 clock cycle to let the voltage settle.
                we = 0; 
            end
            
            EXECUTE: begin
                // In Execute, we assert the write enable if the instruction says to write.
                we = ir[0]; 
            end
        endcase
    end

endmodule