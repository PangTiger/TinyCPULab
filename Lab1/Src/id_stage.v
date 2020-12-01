`include "defines.v"

module id_stage(
    input  wire                     cpu_rst_n,
    
    input  wire [`INST_ADDR_BUS]    id_pc_i,

    // ��ָ��洢��������ָ����
    input  wire [`INST_BUS     ]    id_inst_i,

    // ��ͨ�üĴ����Ѷ��˿�1����������, ���Ƕ˿�1����rs�Ĵ�����ֵ
    input  wire [`REG_BUS      ]    rd1,
    
     // ��ͨ�üĴ����Ѷ��˿�2����������,���Ƕ˿�2����rt�Ĵ�����ֵ
    input  wire [`REG_BUS      ]    rd2,
    
    // ���������Ϣ
    // alu��������
    output wire [`ALUTYPE_BUS  ]    id_alutype_o,
    
    // alu operation code : alu������
    output wire [`ALUOP_BUS    ]    id_aluop_o,
    
    // whilo -> write hi lo : �Ƿ�дhi lo�Ĵ���
    output wire                     id_whilo_o,
    
    // �Ƿ���loadָ��, ��load byte, load word
    output wire                     id_mreg_o,
    
    // write address : ��������׶ε�,��д���Ŀ�ļĴ����ĵ�ַ
    output wire [`REG_ADDR_BUS ]    id_wa_o,
    
    // wreg -> write reg : �Ƿ�ҪдĿ�ļĴ���
    output wire                     id_wreg_o,
    
    // din -> data input : ��������׶ε�,��д��data_ram������
    output wire [`REG_BUS      ]    id_din_o,
    
    // ����׶ε�Դ������1
    output wire [`REG_BUS      ]    id_src1_o,
    
    // ����׶ε�Դ������2
    output wire [`REG_BUS      ]    id_src2_o,
    
    // regfile�Ķ�ʹ���ź�, �˿�1
    output wire                     rreg1,
    
    // regfile�Ķ���ַ�ź�, �˿�1
    output wire [`REG_ADDR_BUS ]    ra1,
    
    // regfile�Ķ�ʹ���ź�, �˿�2
    output wire                     rreg2,
    
    // regfile�Ķ���ַ�ź�, �˿�2
    output wire [`REG_ADDR_BUS ]    ra2
    );
    // ���������ǲ�ȡС����, ԭ��������Ǵ����! ����С����.ԭ����Ū���˴�˺�С�˵ĸ���
    // С����: �ֽ���least significant byte -> lowest address
    // ��byte offset 2'b00 ��ӦLeast significant byte
    wire [`INST_BUS] id_inst = id_inst_i;

    // ָ��ĸ����ֶ�, op func rd rs rt sa imm
    wire [5 :0] op   = id_inst[31:26];
    wire [5 :0] func = id_inst[5 : 0];
    wire [4 :0] rd   = id_inst[15:11];
    wire [4 :0] rs   = id_inst[25:21];
    wire [4 :0] rt   = id_inst[20:16];
    wire [4 :0] sa   = id_inst[10: 6];
    wire [15:0] imm  = id_inst[15: 0]; 

    //�����߼�,ȷ����ǰ����һ��ָ��
    //TODO: ��ת��"ָ������������"
     /*-------------------------���뼶�ڲ��ĵ�һ���߼�------------------------------
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
    
    //TODO: ��ת��ָ�������ʾ��ͼ
    wire inst_reg  = (op==6'd0);
    wire inst_add  = inst_reg&(func==6'b100_000);
    wire inst_subu = inst_reg&(func==6'b100_011);
    wire inst_slt  = inst_reg&(func==6'b101_010);
    wire inst_slti = (op==6'b001_010);
    
    wire inst_nor =  inst_reg&(func==6'b100_111);
    
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
    

    //���뼶�ڲ��ĵڶ����߼�
    /*-------------------- ���ɾ�����ڲ������ź� --------------------*/
    //��������alutype
    
    /* ԭ���еİ�ÿһλ���ķ�ʽ
    assign id_alutype_o[2] = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : inst_sll;
    assign id_alutype_o[1] = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_and | inst_mfhi | inst_mflo | inst_ori | inst_lui);
    assign id_alutype_o[0] = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_add | inst_subu | inst_slt | inst_mfhi | inst_mflo | 
                             inst_addiu | inst_sltiu | inst_lb |inst_lw | inst_sb | inst_sw);
    */
    
    /*û�к궨������µı�﷽ʽ
    assign id_alutype_o = (inst_add | inst_subu | inst_slt | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw) ? 3'b001 :
                          (inst_ori | inst_lui | inst_and) ? 3'b010 :
                          (inst_mfhi|inst_mflo) ? 3'b011 :
                          (inst_sll) ? 3'b100 : 3'b000;
    */
    //TODO:��ת�������ź���ֵ��
    //TODO: ����д���ᵼ�¹����߳�,����Ƕ��弸���м����,����������,��Щ�м����Ҳ���Դ��ݸ���һ��,�ⶼ�ǿ����Ż��ķ���!
    //����alutype�궨��ı�﷽ʽ
    assign id_alutype_o = (inst_add|inst_subu|inst_slt|inst_slti|inst_addiu|inst_sltiu|inst_lb|inst_lw|inst_sb|inst_sw) ? `ARITH :
                          (inst_ori|inst_lui|inst_and|inst_nor) ? `LOGIC :
                          (inst_mfhi|inst_mflo) ? `MOVE :
                          (inst_sll) ? `SHIFT : `NOP;
    
    
    
    // �ڲ�������aluop
    // TODO: ��ת��aluop����
    // ע��: aluop�Ķ�����кܴ��������,������defines.v�в�ȫ������������ָ��Ķ���
    // �ڲ���aluop ֻ��Ҫ8bitλ�����ֲ�ͬ��80+��ָ��  
    // ע����������aluopÿһ��bitλ�������ֵ��
    // �����ÿһλ�������ֵ�����֪��Ϊʲô����Ҫ����assign
    
    /*ԭ���а�λ���ж���ķ�ʽ
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
    
    //ʹ�ú궨��֮��ı�﷽ʽ
    assign id_aluop_o = inst_add    ?    `MINIMIPS32_ADD   :
                        inst_subu   ?    `MINIMIPS32_SUBU  :
                        inst_slt    ?    `MINIMIPS32_SLT   :
                        inst_slti    ?    `MINIMIPS32_SLTI   :
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
                        inst_nor    ?    `MINIMIPS32_NOR   :
                        8'b0;
                        

    // write reg output : ���뼶�ĵ�ǰָ���Ƿ����д�ؼ����� д�Ĵ��� �Ĳ���
    assign id_wreg_o       = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                             (inst_add | inst_subu | inst_slt | inst_slti | inst_and | inst_mfhi | inst_mflo | inst_sll | 
                             inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_nor);
    // Ŀǰֻ��multָ���дHi Lo����������Ĵ���
    assign id_whilo_o      = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : inst_mult;
    // ��ǰָ���Ƿ�����λָ��,���ź�����ѡ��Դ������,
    // ��Ϊ��λָ���Դ������1������ָ���е�Sa�ֶ�
    wire shift = inst_sll;
    // ��ǰָ���Դ������2�Ƿ�������������չ�õ�
    wire immsel = inst_ori | inst_lui | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw |inst_slti;
    // rtsel : register target selection, Ŀ��Ĵ�����ѡ��
    // ��ǰָ���Ƿ��д��rt����rd�ֶζ�Ӧ�ļĴ���
    wire rtsel  = inst_ori | inst_lui | inst_addiu | inst_sltiu |inst_slti | inst_lb | inst_lw;
    // ��ǰָ����Ҫ��16λ��ȵ��������ֶν����з�����չ��32λ
    wire sext   = inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw | inst_slti;
    // ר������LUIָ����ź�,��ǰָ����LUIָ��ʱ,������������չimm_ext��ֵΪ����������16λ
    wire upper  = inst_lui;
    // mreg -> memory to register : ��˼�Ǹ�ָ����Ҫ���ڴ��ж�ȡ���ݵ��Ĵ�����,����MIPS�о���load����ָ��
    assign id_mreg_o       = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : (inst_lb | inst_lw);
    // ͨ�üĴ����ѵĶ˿�1�Ķ�ʹ���ź�
    assign rreg1 = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                   (inst_add | inst_subu | inst_slt | inst_and | inst_mult | inst_slti |
                   inst_ori | inst_addiu | inst_sltiu | inst_lb | inst_lw | inst_sb | inst_sw | inst_nor);
    // ͨ�üĴ����ѵĶ˿�2�Ķ�ʹ���ź�
    assign rreg2 = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                   (inst_add | inst_subu | inst_slt | inst_and | inst_mult | inst_sll | 
                   inst_sb | inst_sw | inst_nor);
    /*------------------------------------------------------------------------------*/

    // ����ͨ�üĴ����Ѷ˿�1�Ķ���ַ,���ǽ���������GPR[rs]��ֵ
    assign ra1   = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : rs;
    // ����ͨ�üĴ����Ѷ˿�2�Ķ���ַ,���ǽ���������GPR[rt]��ֵ
    assign ra2   = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : rt;
    
    // ����һЩָ���Դ����������������չ�õ���,�����muxʵ�ֲ�ͬ����µ���������չ
    // ����: LUIָ�� �з�����չ��ָ�� �޷�����չ��ָ��
    wire [31:0] imm_ext = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
                          (upper == `UPPER_ENABLE  ) ? (imm << 16) :
                          (sext  == `SIGNED_EXT    ) ? {{16{imm[15]}}, imm} : {{16{1'b0}}, imm};
                                            
    // �õ���д��Ŀ�ļĴ����ĵ�ַ,������rt�ֶ�Ҳ������rd�ֶ�                                         
    assign id_wa_o      = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : 
                          (rtsel == `RT_ENABLE     ) ? rt : rd;
    
    // storeָ��Ҫ�洢����������rt,��rt��ֵ����ͨ�üĴ������˿�2                   
    // ���ｫ��÷ô�׶�store�洢ָ��Ҫ�������ݼĴ���������
    assign id_din_o     = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : rd2;

    // ���shift�ź���Ч, ��������λָ��, Դ����������sa�ֶ���չ�õ�, ��rreg1�ź�����, ��Դ������ȡrd1��ֵ
    // rd1�ǼĴ������˿�1�Ķ�����, ���˿�1��������ȡGPR[rs]��ֵ
    // ����Դ������1Ĭ������Ϊ0
    // ���Դ������1
    assign id_src1_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
                       (shift == `SHIFT_ENABLE  ) ? {27'b0, sa} :
                       (rreg1 == `READ_ENABLE   ) ? rd1 : `ZERO_WORD;

    // ���immsel�ź���Ч, ������I��ָ��, Դ����������imm�ֶ���չ�õ�, ��rreg2�ź�����, ��Դ������ȡrd2��ֵ
    // rd2�ǼĴ������˿�2�Ķ�����, ���˿�2��������ȡGPR[rt]��ֵ
    // ����Դ������2Ĭ������Ϊ0
    // ���Դ������2,����������������չ,Ҳ��������rd2,��GPR[rt]
    assign id_src2_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
                       (immsel == `IMM_ENABLE   ) ? imm_ext : 
                       (rreg2 == `READ_ENABLE   ) ? rd2 : `ZERO_WORD;

endmodule
