`timescale 1ns/1ps
module tb_rv32i_cpu;
 reg clk=0, reset=1; wire halted; integer cycles=0;
 always #5 clk=~clk;
 rv32i_cpu #(.IMEM_FILE("programs/smoke.hex")) dut(.clk(clk),.reset(reset),.halted(halted));
 initial begin
  repeat(2) @(posedge clk); #1 reset=0;
  while(!halted && cycles<30) begin @(posedge clk); #1 cycles=cycles+1; end
  if(!halted) $fatal(1,"FAIL: CPU did not halt");
  if(dut.regs.regs[4]!==32'd12 || dut.dmem.memory[0]!==32'd12 || dut.regs.regs[0]!==0) $fatal(1,"FAIL: expected x4=12, mem[0]=12, x0=0");
  $display("PASS: starter CPU; mem[0]=%0d x4=%0d cycles=%0d",dut.dmem.memory[0],dut.regs.regs[4],cycles); $finish;
 end
 initial begin #1000; $fatal(1,"FAIL: timeout"); end
endmodule
