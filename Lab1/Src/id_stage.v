`include "defines.v"

module id_stage(
    input  wire                     cpu_rst_n,
    
    input  wire [`INST_ADDR_BUS]    id_pc_i,

    // 从指令存储器读出的指令字
    input  wire [`INST_BUS     ]    id_inst_i,

    // 从通用寄存器堆读端口1读出的数据, 我们端口1来读rs寄存器的值
    input  wire [`REG_BUS      ]    rd1,
    
     // 从通用寄存器堆读端口2读出的数据,我们端口2来读rt寄存器的值
    input  wire [`REG_BUS      ]    rd2,
    
    // 输出译码信息
    // alu运算类型
    output wire [`ALUTYPE_BUS  ]    id_alutype_o,
    
    // alu operation code : alu操作码
    output wire [`ALUOP_BUS    ]    id_aluop_o,
    
    // whilo -> write hi lo : 是否写hi lo寄存器
    output wire                     id_whilo_o,
    
    // 是否是load指令, 如load byte, load word
    output wire                     id_mreg_o,
    
    // write address : 处于译码阶段的,待写入的目的寄存器的地址
    output wire [`REG_ADDR_BUS ]    id_wa_o,
    
    // wreg -> write reg : 是否要写目的寄存器
    output wire                     id_wreg_o,
    
    // din -> data input : 处于译码阶段的,待写入data_ram的数据
    output wire [`REG_BUS      ]    id_din_o,
    
    // 译码阶段的源操作数1
    output wire [`REG_BUS      ]    id_src1_o,
    
    // 译码阶段的源操作数2
    output wire [`REG_BUS      ]    id_src2_o,
    
    // regfile的读使能信号, 端口1
    output wire                     rreg1,
    
    // regfile的读地址信号, 端口1
    output wire [`REG_ADDR_BUS ]    ra1,
    
    // regfile的读使能信号, 端口2
    output wire                     rreg2,
    
    // regfile的读地址信号, 端口2
    output wire [`REG_ADDR_BUS ]    ra2
    );
    // 在这里我们采取小端序, 原书的做法是大端序! 不是小端序.原书中弄混了大端和小端的概念
    // 小端序: 字节中least significant byte -> lowest address
    // 即byte offset 2'b00 对应Least significant byte
    wire [`INST_BUS] id_inst = id_inst_i;

    // 指令的各个字段, op func rd rs rt sa imm
    wire [5 :0] op   = id_inst[31:26];
    wire [5 :0] func = id_inst[5 : 0];
    wire [4 :0] rd   = id_inst[15:11];
    wire [4 :0] rs   = id_inst[25:21];
    wire [4 :0] rt   = id_inst[20:16];
    wire [4 :0] sa   = id_inst[10: 6];
    wire [15:0] imm  = id_inst[15: 0]; 

    //译码逻辑,确定当前是哪一条指令
    //TODO: 跳转到"指令是如何译码的"
     /*-------------------------译码级内部的第一级逻辑------------------------------
    wire inst_reg  = ~|op;
    wire inst_add  = inst_reg& func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_subu = inst_reg& func[5]&~func[4]&~func[3]&~func[2]& func[1]& func[0];
    wire inst_slt  = inst_reg& func[5]&~func[4]& func[3]&~func[2]& func[1]&~func[0];
    wire inst_and  = inst_reg& func[5]&~func[4]&~func[3]& func[2]&~func[1]&~func[0];
    wire inst_mult = inst_reg&~func[5]& func[4]& func[3]&~func[2]&~func[1]&~func[0];
    wire inst_mfhi = inst_reg&~func[5]& func[4]&~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_mflo = inst_reg&~func[5]& func[4]&~func[3]&~func[2]& func[1]&~func[0];
    wire inst_sll  = inst_reg&~func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_ori  =~op[5]&~op[4]& op[3]& op[2]&~op[1]& op[0];
    wire inst_lui  =~op[5]&~op[4]& op[3]& op[2]& op[1]& op[0];
    wire inst_addiu=~op[5]&~op[4]& op[3]&~op[2]&~op[1]& op[0];
    wire inst_sltiu=~op[5]&~op[4]& op[3]&~op[2]& op[1]& op[0];
    wire inst_lb   = op[5]&~op[4]&~op[3]&~op[2]&~op[1]&~op[0];
    wire inst_lw   = op[5]&~op[4]&~op[3]&~op[2]& op[1]& op[0];
    wire inst_sb   = op[5]&~op[4]& op[3]&~op[2]&~op[1]&~op[0];
    wire inst_sw   = op[5]&~op[4]& op[3]&~op[2]& op[1]& op[0];
    ------------------------------------------------------------------------------*/
    
    //TODO: 跳转到指令的译码示意图
    wire inst_reg  = (op!=6'd0);
    wire inst_add  = inst_reg&(func==6'b100_000);
    wire inst_subu = inst_reg&(func==6'b100_011);
    wire inst_slt  = inst_reg&(func==6'b101_010);
    wire inst_and  = inst_reg&(func==6'b100_100);
    wire inst_mult = inst_reg&(func==6'b011_000);
    wire inst_mfhi = inst_reg&(func==6'b010_000);
    wire inst_mflo = inst_reg&(func==6'b010_010);
    wire inst_sll  = inst_reg&(func==6'b000_000);
    wire inst_ori  = (op==6'b001_101);
    wire inst_lui  = (op==6'b001_111);
    wire inst_addiu= (op==6'b001_001);
    wire inst_sltiu= (op==6'b001_011);
    wire inst_lb   = (op==6'b100_000);
    wire inst_lw   = (op==6'b100_011);
    wire inst_sb   = (op==6'b101_000);
    wire inst_sw   = (op==6'b101_011);
    

    //译码级内部的第二级逻辑
    /*-------------------- 生成具体的内部控制信号 --------------------*/
    //操作类型alutype
    
    /* 原书中的按每一位表达的方式
    assign id_alutype_o[2] = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : inst_sll;
    assign id_alutype_o[1] = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_and | inst_mfhi | inst_mflo | inst_ori | inst_lui);
    assign id_alutype_o[0] = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_add | inst_subu | inst_slt | inst_mfhi | inst_mflo | 
                             inst_addiu | inst_sltiu | inst_lb |inst_lw | inst_sb | inst_sw);
    */
    
    /*没有宏定义情况下的表达方式
    assign id_alutype_o = (inst_add | inst_subu | inst_slt | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw) ? 3'b001 :
                          (inst_ori | inst_lui | inst_and) ? 3'b010 :
                          (inst_mfhi|inst_mflo) ? 3'b011 :
                          (inst_sll) ? 3'b100 : 3'b000;
    */
    //TODO:跳转到控制信号真值表
    //TODO: 这种写法会导致过于冗长,最好是定义几个中间变量,代码会更清晰,这些中间变量也可以传递给下一级,这都是可以优化的方向!
    //利用alutype宏定义的表达方式
    assign id_alutype_o = (inst_add|inst_subu|inst_slt|inst_addiu|inst_sltiu|inst_lb|inst_lw|inst_sb|inst_sw) ? `ARITH :
                          (inst_ori|inst_lui|inst_and) ? `LOGIC :
                          (inst_mfhi|inst_mflo) ? `MOVE :
                          (inst_sll) ? `SHIFT : `NOP;
    
    
    
    // 内部操作码aluop
    // TODO: 跳转看aluop定义
    // 注意: aluop的定义具有很大的随意性,我们在defines.v中补全了新增的两条指令的定义
    // 内部的aluop 只需要8bit位来区分不同的80+条指令  
    // 注意理解这里的aluop每一个bit位背后的真值表
    // 理解了每一位背后的真值表就能知道为什么这里要这样assign
    
    /*原书中按位进行定义的方式
    assign id_aluop_o[7]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_lb | inst_lw | inst_sb | inst_sw);
    assign id_aluop_o[6]   = 1'b0;
    assign id_aluop_o[5]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_slt | inst_sltiu);
    assign id_aluop_o[4]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_add | inst_subu | inst_and | inst_mult | inst_sll |
                             inst_ori | inst_addiu | inst_lb | inst_lw | inst_sb | inst_sw);
    assign id_aluop_o[3]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_add | inst_subu | inst_and | inst_mfhi | inst_mflo | 
                             inst_ori | inst_addiu | inst_sb | inst_sw);
    assign id_aluop_o[2]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_slt | inst_and | inst_mult | inst_mfhi | inst_mflo | 
                             inst_ori | inst_lui | inst_sltiu);
    assign id_aluop_o[1]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_subu | inst_slt | inst_sltiu | inst_lw | inst_sw);
    assign id_aluop_o[0]   = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_subu | inst_mflo | inst_sll |
                             inst_ori | inst_lui | inst_addiu | inst_sltiu);
    */
    
    //使用宏定义之后的表达方式
    assign id_aluop_o = inst_add    ?    `MINIMIPS32_ADD   :
                        inst_subu   ?    `MINIMIPS32_SUBU  :
                        inst_slt    ?    `MINIMIPS32_SLT   :
                        inst_and    ?    `MINIMIPS32_AND   :
                        inst_mult   ?    `MINIMIPS32_MULT  :
                        inst_mfhi   ?    `MINIMIPS32_MFHI  :
                        inst_mflo   ?    `MINIMIPS32_MFLO  :
                        inst_sll    ?    `MINIMIPS32_SLL   :
                        inst_ori    ?    `MINIMIPS32_ORI   :
                        inst_lui    ?    `MINIMIPS32_LUI   :
                        inst_addiu  ?    `MINIMIPS32_ADDIU :
                        inst_sltiu  ?    `MINIMIPS32_SLTIU :
                        inst_lb     ?    `MINIMIPS32_LB    :
                        inst_lw     ?    `MINIMIPS32_LW    :
                        inst_sb     ?    `MINIMIPS32_SB    :
                        inst_sw     ?    `MINIMIPS32_SW    :
                        8'b0;
                        

    // write reg output : 译码级的当前指令是否会在写回级进行 写寄存器 的操作
    assign id_wreg_o       = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_add | inst_subu | inst_slt | inst_and | inst_mfhi | inst_mflo | inst_sll | 
                             inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_lb | inst_lw);
    // 目前只有mult指令会写Hi Lo这两个特殊寄存器
    assign id_whilo_o      = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : inst_mult;
    // 当前指令是否是移位指令,该信号用于选择源操作数,
    // 因为移位指令的源操作数1来自于指令中的Sa字段
    wire shift = inst_sll;
    // 当前指令的源操作数2是否来自立即数扩展得到
    wire immsel = inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw;
    // rtsel : register target selection, 目标寄存器的选择
    // 当前指令是否会写入目的寄存器
    wire rtsel  = inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_lb | inst_lw;
    // 当前指令需要将16位宽度的立即数字段进行有符号扩展至32位
    wire sext   = inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw;
    // 专门用于LUI指令的信号,当前指令是LUI指令时,控制立即数扩展imm_ext的值为立即数左移16位
    wire upper  = inst_lui;
    // mreg -> memory to register : 意思是该指令需要从内存中读取数据到寄存器中,这在MIPS中就是load加载指令
    assign id_mreg_o       = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_lb | inst_lw);
    // 通用寄存器堆的端口1的读使能信号
    assign rreg1 = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                   (inst_add | inst_subu | inst_slt | inst_and | inst_mult | 
                   inst_ori | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw);
    // 通用寄存器堆的端口2的读使能信号
    assign rreg2 = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                   (inst_add | inst_subu | inst_slt | inst_and | inst_mult | inst_sll | 
                   inst_sb | inst_sw);
    /*------------------------------------------------------------------------------*/

    // 访问通用寄存器堆端口1的读地址,我们将他用来读GPR[rs]的值
    assign ra1   = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : rs;
    // 访问通用寄存器堆端口2的读地址,我们将他用来读GPR[rt]的值
    assign ra2   = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : rt;
    
    // 对于一些指令的源操作数是立即数扩展得到的,这里的mux实现不同情况下的立即数扩展
    // 包括: LUI指令 有符号扩展的指令 无符号扩展的指令
    wire [31:0] imm_ext = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
                          (upper == `UPPER_ENABLE  ) ? (imm << 16) :
                          (sext  == `SIGNED_EXT    ) ? {{16{imm[15]}}, imm} : {{16{1'b0}}, imm};
                                            
    // 得到待写入目的寄存器的地址,可能是rt字段也可能是rd字段                                         
    assign id_wa_o      = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : 
                          (rtsel == `RT_ENABLE     ) ? rt : rd;
    
    // store指令要存储的数据来自rt,而rt的值来自通用寄存器读端口2                   
    // 这里将获得访存阶段store存储指令要存入数据寄存器的数据
    assign id_din_o     = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : rd2;

    // 如果shift信号有效, 表明是移位指令, 源操作数来自sa字段扩展得到, 若rreg1信号拉高, 则源操作数取rd1的值
    // rd1是寄存器读端口1的读数据, 读端口1被用来读取GPR[rs]的值
    // 否则将源操作数1默认设置为0
    // 获得源操作数1
    assign id_src1_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
                       (shift == `SHIFT_ENABLE  ) ? {27'b0, sa} :
                       (rreg1 == `READ_ENABLE   ) ? rd1 : `ZERO_WORD;

    // 如果immsel信号有效, 表明是I型指令, 源操作数来自imm字段扩展得到, 若rreg2信号拉高, 则源操作数取rd2的值
    // rd2是寄存器读端口2的读数据, 读端口2被用来读取GPR[rt]的值
    // 否则将源操作数2默认设置为0
    // 获得源操作数2,可能来自立即数扩展,也可能来自rd2,即GPR[rt]
    assign id_src2_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
                       (immsel == `IMM_ENABLE   ) ? imm_ext : 
                       (rreg2 == `READ_ENABLE   ) ? rd2 : `ZERO_WORD;

endmodule
