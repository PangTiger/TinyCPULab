//

import mips_cpu_pkg::*;

module im (
        input  logic     cpu_clk_50M,
        input  logic     cpu_rst_n,

        input  im_addr_t imaddr_d4,
        input  logic     imwe,
        input  inst_t    imdin,
        input  logic     imce,
        output inst_t    inst
    );

    // 8K BRAM
    inst_t mem [IM_DEPTH];
    // sync write, sync read
    // ROM, no write

    initial begin
        mem[0] =(inst_t'({LUI,REG_ZERO, REG_T1, 16'hfedc}))                  ;
        mem[1] =(inst_t'({SLTI,REG_T1, REG_T2, 16'h0001}))                   ;
        mem[2] =(inst_t'({32'd0}))                                           ;
        mem[3] =(inst_t'({32'd0}))                                           ;
        mem[4] =(inst_t'({32'd0}))                                           ;
        mem[5] =(inst_t'({32'd0}))                                           ;
        mem[6] =(inst_t'({ORI,REG_T1, REG_AT, 16'h1234}))                    ;
        mem[7] =(inst_t'({XORI,REG_AT, REG_T3, 16'h5678}))                   ;
        mem[8] =(inst_t'({32'd0}))                                           ;
        mem[9] =(inst_t'({32'd0}))                                           ;
        mem[10]=(inst_t'({32'd0}))                                           ;
        mem[11]=(inst_t'({32'd0}))                                           ;
        mem[12]=(inst_t'({ ORI, REG_ZERO, REG_V0, 16'h2333}))                ;
        mem[13]=(inst_t'({ 6'h0, REG_V0, REG_AT, REG_ZERO, 5'h0, MULTU}))    ;
        mem[14]=(inst_t'({ 32'h0 }))                                         ;
        mem[15]=(inst_t'({ 32'h0 }))                                         ;
        mem[16]=(inst_t'({ 32'h0 }))                                         ;
        mem[17]=(inst_t'({ 32'h0 }))                                         ;
        mem[18]=(inst_t'({ 32'h0 }))                                         ;
        mem[19]=(inst_t'({ 16'h0, REG_T4,5'h0,MFHI}))                        ;
        mem[20]=(inst_t'({ 16'h0, REG_T5,5'h0,MFLO}))                        ;
        mem[21]=(inst_t'({ 6'h0, REG_AT, REG_V0, REG_T6, 5'h0, SUB}))        ;
        mem[22]=(inst_t'({ 32'h0 }))                                         ;
        mem[23]=(inst_t'({ 32'h0 }))                                         ;
        mem[24]=(inst_t'({ BLTZ, REG_T1,5'h0,16'h2}))                        ;
        mem[25]=(inst_t'({ 32'h0 }))                                         ;
        mem[26]=(inst_t'({ LUI, 5'h0, REG_T7, 16'h1111}))                    ;
        mem[27]=(inst_t'({ ORI, REG_ZERO, REG_T7, 16'h8888}))                ;
    end

    always_ff @(posedge cpu_clk_50M) begin
        if (imce) begin
            if (imwe)
                mem[imaddr_d4] <= imdin;
            if (!cpu_rst_n)
                inst        <= ZERO;
            else
                inst        <= mem[imaddr_d4];
        end
    end
endmodule
