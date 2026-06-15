module control_unit (
    input clk,
    input reset,
    
    // Status Flags
    input Z, N, C, V,
    
    // Control Signals
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

    reg [2:0] pc;
    reg [12:0] ir; 
    
    // Instruction ROM
    reg [12:0] rom [0:7];
    reg saved_Z;
    
   initial begin
        // Format: {alu_sel[2:0], w_addr[2:0], r_addr1[2:0], r_addr2[2:0], we}
        rom[0] = 13'b001_000_001_010_0; // SUB R1, R2 
        rom[1] = 13'b101_000_000_000_0; // JZ 0              
        rom[2] = 13'b000_000_101_110_0; // ADD (Unreachable)
        rom[3] = 13'd0; 
        rom[4] = 13'd0; 
        rom[5] = 13'd0; 
        rom[6] = 13'd0; 
        rom[7] = 13'd0;
    end

    // Sequential State Update
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= FETCH;
            pc <= 3'd0;
            saved_Z <= 1'b0; 
        end else begin
            current_state <= next_state;
            
            if (current_state == EXECUTE) begin
                // Update status register on non-jump instructions
                if (ir[12:10] != 3'b101) begin
                    saved_Z <= Z; 
                end
                
                // Control Flow evaluation
                if (ir[12:10] == 3'b101 && saved_Z == 1'b1) begin
                    pc <= ir[9:7]; 
                end else begin
                    pc <= pc + 1;  
                end
            end
        end
    end

    // Next State Logic
    always @(*) begin
        case (current_state)
            FETCH:   next_state = DECODE;
            DECODE:  next_state = EXECUTE;
            EXECUTE: next_state = FETCH;
            default: next_state = FETCH;
        endcase
    end

    // Output Decoding Logic
    always @(*) begin
        alu_sel = ir[12:10];
        w_addr  = ir[9:7];
        r_addr1 = ir[6:4];
        r_addr2 = ir[3:1];
        
        we = 0;
        
        case (current_state)
            FETCH: begin
                ir = rom[pc]; 
            end
            DECODE: begin
                we = 0; 
            end
            EXECUTE: begin
                we = ir[0]; 
            end
        endcase
    end

endmodule