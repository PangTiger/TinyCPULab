`include "defines.v"

module exe_stage (
    input  wire 					cpu_rst_n,

    // 从译码阶段获得的信息
    input  wire [`ALUTYPE_BUS	] 	exe_alutype_i,
    input  wire [`ALUOP_BUS	    ] 	exe_aluop_i,
    input  wire [`REG_BUS 		] 	exe_src1_i,
    input  wire [`REG_BUS 		] 	exe_src2_i,
    input  wire [`REG_ADDR_BUS 	] 	exe_wa_i,
    input  wire 					exe_wreg_i,
    input  wire 					exe_mreg_i,
    input  wire [`REG_BUS 		] 	exe_din_i,
    input  wire                     exe_whilo_i,
    
    // 读取到的Hi Lo寄存器的数据
    input  wire [`REG_BUS 		] 	hi_i,
    input  wire [`REG_BUS 		] 	lo_i,

    // 执行级输出的信号
    // 执行级的aluop,传递给访存级用于区分load store指令
    output wire [`ALUOP_BUS	    ] 	exe_aluop_o,
    
    // 要写入的寄存器的地址
    output wire [`REG_ADDR_BUS 	] 	exe_wa_o,
    
    // 写寄存器使能信号
    output wire 					exe_wreg_o,
    
    // 写入寄存器堆的数据
    output wire [`REG_BUS 		] 	exe_wd_o,
    
    // 从译码级传递而来,区分是否是load指令
    output wire 					exe_mreg_o,
    
    // 从译码级得到的,将要在访存级写入内部的数据
    output wire [`REG_BUS 		] 	exe_din_o,
    
    // Hi Lo寄存器写使能信号
    output wire 					exe_whilo_o,
    
    // Hi Lo寄存器要写入的数据
    output wire [`DOUBLE_REG_BUS] 	exe_hilo_o
    );

    // 部分信号直接向后传递
    assign exe_aluop_o = (cpu_rst_n == `RST_ENABLE) ? 8'b0 : exe_aluop_i;
    assign exe_mreg_o  = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : exe_mreg_i;
    assign exe_din_o   = (cpu_rst_n == `RST_ENABLE) ? 32'b0 : exe_din_i;
    assign exe_whilo_o = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : exe_whilo_i;
    
    wire [`REG_BUS       ]      logicres;       // 逻辑指令的结果
    wire [`REG_BUS       ]      shiftres;       // 移位指令的结果
    wire [`REG_BUS       ]      moveres;        // 数据移动指令的结果
    wire [`REG_BUS       ]      hi_t;           // Hi的结果
    wire [`REG_BUS       ]      lo_t;           // Lo的结果
    wire [`REG_BUS       ]      arithres;       // 算数指令的结果
    wire [`DOUBLE_REG_BUS]      mulres;         // 乘法指令的结果
    
    // 根据内部操作码aluop,判断是何种逻辑指令,进行逻辑指令的运算
    assign logicres = (cpu_rst_n == `RST_ENABLE)  ? `ZERO_WORD : 
                      (exe_aluop_i == `MINIMIPS32_AND )  ? (exe_src1_i & exe_src2_i) :
                      (exe_aluop_i ==  `MINIMIPS32_NOR)  ? (~(exe_src1_i | exe_src2_i)) :
                      (exe_aluop_i == `MINIMIPS32_ORI )  ? (exe_src1_i | exe_src2_i) : 
                      (exe_aluop_i == `MINIMIPS32_LUI )  ? exe_src2_i : `ZERO_WORD;

    // 根据内部操作码aluop,判断是何种移位指令,执行移位指令
    assign shiftres = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : 
                      (exe_aluop_i == `MINIMIPS32_SLL )  ? (exe_src2_i << exe_src1_i) : `ZERO_WORD;
    
    // hi_t lo_t是hi lo寄存器的值
    assign hi_t     = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : hi_i;
    assign lo_t     = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : lo_i;
  
    // 执行数据移动指令
    assign moveres  = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : 
                      (exe_aluop_i == `MINIMIPS32_MFHI) ? hi_t :
                      (exe_aluop_i == `MINIMIPS32_MFLO) ? lo_t : `ZERO_WORD;
    
    // TODO:请想一想这里有没有可以优化的信号?是不是有的信号可以在译码级给出,传递到执行级?
    // 执行算数指令, 顺便计算出load store指令的存储地址
    assign arithres = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : 
                      (exe_aluop_i == `MINIMIPS32_ADD  )  ? (exe_src1_i + exe_src2_i) :
                      (exe_aluop_i == `MINIMIPS32_LB   )  ? (exe_src1_i + exe_src2_i) :
                      (exe_aluop_i == `MINIMIPS32_LW   )  ? (exe_src1_i + exe_src2_i) :
                      (exe_aluop_i == `MINIMIPS32_SB   )  ? (exe_src1_i + exe_src2_i) :
                      (exe_aluop_i == `MINIMIPS32_SW   )  ? (exe_src1_i + exe_src2_i) :
                      (exe_aluop_i == `MINIMIPS32_ADDIU)  ? (exe_src1_i + exe_src2_i) :
                      (exe_aluop_i == `MINIMIPS32_SUBU )  ? (exe_src1_i + (~exe_src2_i) + 1) :
                      (exe_aluop_i == `MINIMIPS32_SLT  )  ? (($signed(exe_src1_i) < $signed(exe_src2_i)) ? 32'b1 : 32'b0) :
                      (exe_aluop_i == `MINIMIPS32_SLTI  )  ? (($signed(exe_src1_i) < $signed(exe_src2_i)) ? 32'b1 : 32'b0) :
                      (exe_aluop_i == `MINIMIPS32_SLTIU)  ? ((exe_src1_i < exe_src2_i) ? 32'b1 : 32'b0) : `ZERO_WORD;
    
    // 利用系统函数有符号扩展和乘法运算符,执行乘法指令
    assign mulres = ($signed(exe_src1_i) * $signed(exe_src2_i));
  
    // 输出要写入Hilo的值
    assign exe_hilo_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_DWORD : 
                      (exe_aluop_i == `MINIMIPS32_MULT)  ? mulres : `ZERO_DWORD;
    
    // 继续传递写寄存器地址
    assign exe_wa_o   = (cpu_rst_n   == `RST_ENABLE ) ? 5'b0 	 : exe_wa_i;
    // 继续传递写寄存器使能信号
    assign exe_wreg_o = (cpu_rst_n   == `RST_ENABLE ) ? 1'b0 	 : exe_wreg_i;
    
    // 根据操作类型alutype确定执行阶段最终的运算结果（既可能是待写入目的寄存器的数据，也可能是访问数据存储器的地址）
    assign exe_wd_o = (cpu_rst_n   == `RST_ENABLE ) ? `ZERO_WORD : 
                      (exe_alutype_i == `LOGIC    ) ? logicres  :
                      (exe_alutype_i == `SHIFT    ) ? shiftres  :
                      (exe_alutype_i == `MOVE     ) ? moveres   :
                      (exe_alutype_i == `ARITH    ) ? arithres  : `ZERO_WORD;

endmodule