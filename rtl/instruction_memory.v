module instruction_memory #(
    parameter ADDR_WIDTH = 10,
    parameter INIT_FILE = "programs/program.hex"
) (
    input  wire [31:0] address,
    output wire [31:0] instruction
);
    localparam WORDS = (1 << (ADDR_WIDTH - 2));
    reg [31:0] memory [0:WORDS-1];
    integer i;

    initial begin
        for (i = 0; i < WORDS; i = i + 1)
            memory[i] = 32'h00000013; // ADDI x0, x0, 0 (NOP)
        $readmemh(INIT_FILE, memory);
    end

    assign instruction = memory[address[ADDR_WIDTH-1:2]];
endmodule
