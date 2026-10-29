module control_unit (
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,
    output reg        reg_write,
    output reg        mem_write,
    output reg        mem_to_reg,
    output reg        alu_src_imm,
    output reg        branch,
    output reg        jump,
    output reg        lui,
    output reg        auipc,
    output reg [3:0]  alu_ctrl,
    output reg        illegal_instruction
);
    localparam ALU_ADD = 4'd0;
    localparam ALU_SUB = 4'd1;
    localparam ALU_AND = 4'd2;
    localparam ALU_OR  = 4'd3;
    localparam ALU_XOR = 4'd4;
    localparam ALU_SLT = 4'd5;

    always @* begin
        reg_write = 1'b0;
        mem_write = 1'b0;
        mem_to_reg = 1'b0;
        alu_src_imm = 1'b0;
        branch = 1'b0;
        jump = 1'b0;
        lui = 1'b0;
        auipc = 1'b0;
        alu_ctrl = ALU_ADD;
        illegal_instruction = 1'b0;

        case (opcode)
            7'b0110011: begin // R-type: ADD, SUB, AND, OR, XOR, SLT
                reg_write = 1'b1;
                case (funct3)
                    3'b000: begin
                        if (funct7 == 7'b0000000)
                            alu_ctrl = ALU_ADD;
                        else if (funct7 == 7'b0100000)
                            alu_ctrl = ALU_SUB;
                        else
                            illegal_instruction = 1'b1;
                    end
                    3'b111: begin
                        if (funct7 == 7'b0000000) alu_ctrl = ALU_AND;
                        else illegal_instruction = 1'b1;
                    end
                    3'b110: begin
                        if (funct7 == 7'b0000000) alu_ctrl = ALU_OR;
                        else illegal_instruction = 1'b1;
                    end
                    3'b100: begin
                        if (funct7 == 7'b0000000) alu_ctrl = ALU_XOR;
                        else illegal_instruction = 1'b1;
                    end
                    3'b010: begin
                        if (funct7 == 7'b0000000) alu_ctrl = ALU_SLT;
                        else illegal_instruction = 1'b1;
                    end
                    default: illegal_instruction = 1'b1;
                endcase
            end

            7'b0010011: begin // I-type: ADDI, ANDI, ORI, XORI, SLTI
                reg_write = 1'b1;
                alu_src_imm = 1'b1;
                case (funct3)
                    3'b000: alu_ctrl = ALU_ADD;
                    3'b111: alu_ctrl = ALU_AND;
                    3'b110: alu_ctrl = ALU_OR;
                    3'b100: alu_ctrl = ALU_XOR;
                    3'b010: alu_ctrl = ALU_SLT;
                    default: illegal_instruction = 1'b1;
                endcase
            end

            7'b0000011: begin // LW only
                if (funct3 == 3'b010) begin
                    reg_write = 1'b1;
                    mem_to_reg = 1'b1;
                    alu_src_imm = 1'b1;
                    alu_ctrl = ALU_ADD;
                end else illegal_instruction = 1'b1;
            end

            7'b0100011: begin // SW only
                if (funct3 == 3'b010) begin
                    mem_write = 1'b1;
                    alu_src_imm = 1'b1;
                    alu_ctrl = ALU_ADD;
                end else illegal_instruction = 1'b1;
            end

            7'b1100011: begin // BEQ and BNE
                if (funct3 == 3'b000 || funct3 == 3'b001) begin
                    branch = 1'b1;
                    alu_ctrl = ALU_SUB;
                end else illegal_instruction = 1'b1;
            end

            7'b1101111: begin // JAL
                reg_write = 1'b1;
                jump = 1'b1;
            end

            7'b0110111: begin // LUI
                reg_write = 1'b1;
                lui = 1'b1;
            end

            7'b0010111: begin // AUIPC
                reg_write = 1'b1;
                auipc = 1'b1;
            end

            7'b0001111: begin // FENCE treated as no-op for this educational core
                // No side effects.
            end

            default: illegal_instruction = 1'b1;
        endcase
    end
endmodule
