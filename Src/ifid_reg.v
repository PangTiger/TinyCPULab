`include "defines.v"
//if_stage -> id_stage流水线寄存器
module ifid_reg (
	input  wire 						cpu_clk_50M,
	input  wire 						cpu_rst_n,

	// 来自if_stage的pc
	input  wire [`INST_ADDR_BUS]       if_pc,
	
  //送至id_stage的pc
	output reg  [`INST_ADDR_BUS]       id_pc
	);

	always @(posedge cpu_clk_50M) begin
    //当cpu复位时,将流水线寄存器里保存的信息清零
		if (cpu_rst_n == `RST_ENABLE) begin
			id_pc 	<= `PC_INIT;
		end
    //不复位的正常情况下,流水线寄存器传递if_pc -> id_pc
		else begin
			id_pc	<= if_pc;		
		end
	end
  //注意:在这里没有将取到的指令存到流水线寄存器之中.
  //这是由于我们的Inst_rom是一个同步存储器,当前第1个周期pc_1发出取指令地址,只有到第2个周期才能得到inst_1
  //而在第2个周期时,pc_1,或者说是if_pc已经存入了流水线寄存器中,赋给了id_pc
  //这就意味着:此时id_pc和inst_1是一一对应的,不需要再将inst_1存入流水线寄存器中
  //也可以理解为,同步存储器的读取相当于自带了一级"隐形的"流水线寄存器,帮助我们把指令保存住了一个周期
endmodule