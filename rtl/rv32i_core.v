`default_nettype none
module rv32i_core(input wire clk, input wire reset, output reg [31:0] pc, output wire [31:0] instr_addr,input wire [31:0] instr, output wire mem_valid,output wire mem_write,output wire [31:0] mem_addr,mem_wdata,input wire [31:0] mem_rdata,output wire halted);
 reg halt_q; assign halted=halt_q; assign instr_addr=pc;
 wire [6:0] opcode=instr[6:0]; wire [4:0] rd=instr[11:7], rs1=instr[19:15],rs2=instr[24:20];
 wire [2:0] f3=instr[14:12]; wire [6:0] f7=instr[31:25];
 wire [31:0] imm_i={{20{instr[31]}},instr[31:20]}, imm_s={{20{instr[31]}},instr[31:25],instr[11:7]};
 wire [31:0] imm_b={{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
 wire [31:0] imm_u={instr[31:12],12'b0}; wire [31:0] imm_j={{11{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};
 wire [31:0] a,b,alu_b,alu_y; reg rf_we; reg [4:0] rf_wa; reg [31:0] rf_wd; reg [3:0] alu_op; reg use_imm,load,store,branch,jump,jalr,lui,auipc,ecall;
 regfile rf(clk,rf_we,rs1,rs2,rf_wa,rf_wd,a,b); assign alu_b=use_imm?imm_i:b; wire z;
 alu ualu(a,alu_b,alu_op,alu_y,z);
 assign mem_valid=load|store; assign mem_write=store; assign mem_addr=store?(a+imm_s):(a+imm_i); assign mem_wdata=b;
 reg take_branch; always @* begin
 rf_we=0; rf_wa=rd; rf_wd=0; alu_op=0; use_imm=0; load=0;store=0;branch=0;jump=0;jalr=0;lui=0;auipc=0;ecall=0;take_branch=0;
 case(opcode)
 7'h33: begin rf_we=1; case(f3) 0:alu_op=f7[5]?1:0; 1:alu_op=7; 2:alu_op=5; 3:alu_op=6; 4:alu_op=4; 5:alu_op=f7[5]?8:9; 6:alu_op=3; 7:alu_op=2; endcase rf_wd=alu_y; end
 7'h13: begin rf_we=1;use_imm=1;case(f3) 0:alu_op=0;2:alu_op=5;3:alu_op=6;4:alu_op=4;6:alu_op=3;7:alu_op=2;1:alu_op=7;5:alu_op=f7[5]?8:9;endcase rf_wd=alu_y; end
 7'h03: begin load=1;rf_we=1; rf_wd=mem_rdata; end
 7'h23: begin store=1; end
 7'h63: begin branch=1;case(f3) 0:take_branch=(a==b);1:take_branch=(a!=b);4:take_branch=($signed(a)<$signed(b));5:take_branch=($signed(a)>=$signed(b));6:take_branch=(a<b);7:take_branch=(a>=b);default:take_branch=0;endcase end
 7'h6f: begin jump=1;rf_we=1;rf_wd=pc+4; end
 7'h67: begin jalr=1;rf_we=1;rf_wd=pc+4; end
 7'h37: begin lui=1;rf_we=1;rf_wd=imm_u; end
 7'h17: begin auipc=1;rf_we=1;rf_wd=pc+imm_u; end
 7'h73: begin ecall=1; end
 endcase
 if(lui)rf_wd=imm_u; if(auipc)rf_wd=pc+imm_u;
 end
 always @(posedge clk) begin
  if(reset)begin pc<=0;halt_q<=0;end
  else if(!halt_q) begin
   if(ecall)halt_q<=1;
   if(jump)pc<=pc+imm_j; else if(jalr)pc<=(a+imm_i)&32'hffff_fffe; else if(branch&&take_branch)pc<=pc+imm_b; else pc<=pc+4;
  end
 end
endmodule
`default_nettype wire
