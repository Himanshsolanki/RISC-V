`timescale 1ns/1ps
module tb_rv32i;
 reg clk=0,reset=1; always #5 clk=~clk;
 wire [31:0] pc,ia,ma,mwd; wire mv,mw,halted; wire [31:0] ins; reg [31:0] mr;
 reg [31:0] imem[0:31]; reg [31:0] dmem[0:31]; integer i,cycles=0;
 assign ins=imem[ia[6:2]]; assign mr=dmem[ma[6:2]];
 rv32i_core dut(clk,reset,pc,ia,ins,mv,mw,ma,mwd,mr,halted);
 always @(posedge clk) if(mv&&mw) dmem[ma[6:2]]<=mwd;
 initial begin
  for(i=0;i<32;i=i+1)begin imem[i]=32'h00000013; dmem[i]=0;end
  imem[0]=32'h00500093; imem[1]=32'h00700113; imem[2]=32'h002081b3;
  imem[3]=32'h00302023; imem[4]=32'h00002203; imem[5]=32'h00000073;
  repeat(2) @(posedge clk); #1 reset=0;
  while(!halted && cycles<30)begin @(posedge clk); #1 cycles=cycles+1; end
  if(!halted) $fatal(1,"FAIL: core did not halt");
  if(dmem[0]!==12 || dut.rf.regs[4]!==12 || dut.rf.regs[0]!==0) $fatal(1,"FAIL: store=%0d x4=%0d",dmem[0],dut.rf.regs[4]);
  $display("PASS: addi/add/sw/lw/ecall; mem[0]=%0d x4=%0d cycles=%0d",dmem[0],dut.rf.regs[4],cycles); $finish;
 end
 initial begin #1000; $fatal(1,"FAIL: timeout"); end
endmodule
