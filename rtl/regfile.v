`default_nettype none
module regfile(input wire clk,we,input wire [4:0] ra1,ra2,wa,input wire [31:0] wd,output wire [31:0] rd1,rd2);
 reg [31:0] regs[0:31]; integer i;
 initial for(i=0;i<32;i=i+1) regs[i]=0;
 always @(posedge clk) if(we && wa!=0) regs[wa]<=wd;
 assign rd1=(ra1==0)?32'b0:regs[ra1]; assign rd2=(ra2==0)?32'b0:regs[ra2];
endmodule
`default_nettype wire
