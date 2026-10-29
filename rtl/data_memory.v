module data_memory #(
    parameter ADDR_WIDTH = 10
) (
    input  wire        clk,
    input  wire        mem_write,
    input  wire [31:0] address,
    input  wire [31:0] write_data,
    output wire [31:0] read_data
);
    localparam WORDS = (1 << (ADDR_WIDTH - 2));
    reg [31:0] memory [0:WORDS-1];
    integer i;

    initial begin
        for (i = 0; i < WORDS; i = i + 1)
            memory[i] = 32'd0;
    end

    assign read_data = memory[address[ADDR_WIDTH-1:2]];

    always @(posedge clk) begin
        if (mem_write)
            memory[address[ADDR_WIDTH-1:2]] <= write_data;
    end
endmodule
