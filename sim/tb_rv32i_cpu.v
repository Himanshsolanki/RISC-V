`timescale 1ns/1ps

module tb_rv32i_cpu;
    reg clk = 1'b0;
    reg reset = 1'b1;
    wire halted;
    integer cycles;

    always #5 clk = ~clk;

    rv32i_cpu #(
        .IMEM_ADDR_WIDTH(10),
        .DMEM_ADDR_WIDTH(10),
        .IMEM_FILE("programs/program.hex")
    ) dut (
        .clk(clk),
        .reset(reset),
        .halted(halted)
    );

    initial begin
        $dumpfile("riscv.vcd");
        $dumpvars(0, tb_rv32i_cpu);

        repeat (2) @(posedge clk);
        #1 reset = 1'b0;

        cycles = 0;
        while (!halted && cycles < 30) begin
            @(posedge clk);
            #1 cycles = cycles + 1;
        end

        if (!halted) begin
            $display("FAIL: CPU did not halt on the illegal-instruction sentinel.");
            $finish;
        end

        if (dut.regs.regs[1] !== 32'd5) begin
            $display("FAIL: x1 expected 5, got %0d", dut.regs.regs[1]);
            $finish;
        end
        if (dut.regs.regs[2] !== 32'd7) begin
            $display("FAIL: x2 expected 7, got %0d", dut.regs.regs[2]);
            $finish;
        end
        if (dut.regs.regs[3] !== 32'd12) begin
            $display("FAIL: x3 expected 12, got %0d", dut.regs.regs[3]);
            $finish;
        end
        if (dut.dmem.memory[0] !== 32'd12) begin
            $display("FAIL: memory[0] expected 12, got %0d", dut.dmem.memory[0]);
            $finish;
        end
        if (dut.regs.regs[4] !== 32'd12) begin
            $display("FAIL: x4 expected 12, got %0d", dut.regs.regs[4]);
            $finish;
        end
        if (dut.regs.regs[5] !== 32'd9) begin
            $display("FAIL: x5 expected 9 after BEQ branch, got %0d", dut.regs.regs[5]);
            $finish;
        end

        $display("PASS: RISC-V subset program produced expected register and memory values.");
        $display("x1=%0d x2=%0d x3=%0d x4=%0d x5=%0d memory[0]=%0d",
                 dut.regs.regs[1], dut.regs.regs[2], dut.regs.regs[3],
                 dut.regs.regs[4], dut.regs.regs[5], dut.dmem.memory[0]);
        $finish;
    end
endmodule
