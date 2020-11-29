`include "defines.v"

module if_stage (
    input 	wire 					cpu_clk_50M,
    input 	wire 					cpu_rst_n,
    
    output  reg                     ice,
    output 	reg  [`INST_ADDR_BUS] 	pc,
    output 	wire [`INST_ADDR_BUS]	iaddr
    );
    
    wire [`INST_ADDR_BUS] pc_next; 
    assign pc_next = pc + 4;    //计算下一条指令的地址,PC是字节寻址,最小寻址单元是字节,MIPS32是32bit指令长度,所以每次PC增加4              ַ
    always @(posedge cpu_clk_50M) begin
		if (cpu_rst_n == `RST_ENABLE) begin
			ice <= `CHIP_DISABLE;		      // 复位时,不取指令禁用指令存储器inst_rom 
		end else begin
			ice <= `CHIP_ENABLE; 		      // 复位结束,可以取指令,指令存储器使能
		end
	end

    always @(posedge cpu_clk_50M) begin
        if (ice == `CHIP_DISABLE)
            pc <= `PC_INIT;                   // 当指令rom禁用时,PC保持初始值(在本次设计中定义为0X0000_0000)
        else begin
            pc <= pc_next;                    //ָ 指令存储器使能后,将pc_next的值上升沿时赋给pc寄存器 
        end
    end
    
    //指令存储器禁用时,保持访问inst_rom的地址为0x0000_0000
    //其他情况下,将pc的值作为访问inst_rom的地址
    assign iaddr = (ice == `CHIP_DISABLE) ? `PC_INIT : pc;    
endmodule