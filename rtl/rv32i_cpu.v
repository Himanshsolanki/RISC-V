module rv32i_cpu #(
    parameter IMEM_ADDR_WIDTH = 10,
    parameter DMEM_ADDR_WIDTH = 10,
    parameter IMEM_FILE = "programs/program.hex"
) (
    input wire clk,
    input wire reset,
    output reg halted
);
    reg [31:0] pc;
    wire [31:0] instruction;
    wire [31:0] rs1_data, rs2_data;
    wire [31:0] immediate;
    wire [31:0] alu_b, alu_result;
    wire [31:0] data_mem_read;
    wire [31:0] writeback_data;
    wire [31:0] pc_plus4 = pc + 32'd4;
    wire [31:0] pc_branch = pc + immediate;
    wire [31:0] next_pc;
    wire [6:0] opcode = instruction[6:0];
    wire [4:0] rd = instruction[11:7];
    wire [2:0] funct3 = instruction[14:12];
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [6:0] funct7 = instruction[31:25];

    wire reg_write, mem_write, mem_to_reg, alu_src_imm;
    wire branch, jump, lui, auipc;
    wire [3:0] alu_ctrl;
    wire illegal_instruction;
    wire alu_zero;

    instruction_memory #(
        .ADDR_WIDTH(IMEM_ADDR_WIDTH),
        .INIT_FILE(IMEM_FILE)
    ) imem (
        .address(pc),
        .instruction(instruction)
    );

    register_file regs (
        .clk(clk),
        .reset(reset),
        .reg_write(reg_write && !halted),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(writeback_data),
        .read_data1(rs1_data),
        .read_data2(rs2_data)
    );

    immediate_generator imm_gen (
        .instruction(instruction),
        .immediate(immediate)
    );

    control_unit control (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .alu_src_imm(alu_src_imm),
        .branch(branch),
        .jump(jump),
        .lui(lui),
        .auipc(auipc),
        .alu_ctrl(alu_ctrl),
        .illegal_instruction(illegal_instruction)
    );

    assign alu_b = alu_src_imm ? immediate : rs2_data;

    alu alu_unit (
        .a(rs1_data),
        .b(alu_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(alu_zero)
    );

    data_memory #(
        .ADDR_WIDTH(DMEM_ADDR_WIDTH)
    ) dmem (
        .clk(clk),
        .mem_write(mem_write && !halted && !reset),
        .address(alu_result),
        .write_data(rs2_data),
        .read_data(data_mem_read)
    );

    assign writeback_data =
        lui   ? immediate :
        auipc ? pc + immediate :
        jump  ? pc_plus4 :
        mem_to_reg ? data_mem_read :
        alu_result;

    wire branch_taken = branch &&
        ((funct3 == 3'b000 && (rs1_data == rs2_data)) ||
         (funct3 == 3'b001 && (rs1_data != rs2_data)));

    assign next_pc = jump ? pc_branch :
                     branch_taken ? pc_branch :
                     pc_plus4;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'd0;
            halted <= 1'b0;
        end else if (!halted) begin
            if (illegal_instruction) begin
                halted <= 1'b1;
            end else begin
                pc <= next_pc;
            end
        end
    end
endmodule
