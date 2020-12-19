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
      /*
        mem[0] = inst_t'({32'd0})                                       ;
        mem[1] = (inst_t'({ ORI, REG_ZERO, REG_AT, 16'h64})) ;
        mem[2] = (inst_t'({ LUI, 5'h0, REG_V0, 16'h6500})) ;
        mem[3] = (inst_t'({ 32'h0 })) ;
        mem[4] = (inst_t'({ 32'h0 })) ;
        mem[5] = (inst_t'({ ADDIU, REG_AT, REG_V1, 16'h4})) ;
        mem[6] = (inst_t'({ SLTIU, REG_AT, REG_A0, 16'h68})) ;
        mem[7] = (inst_t'({ 6'h0, REG_AT, REG_V0, REG_A1, 5'h0, ADD})) ;
        mem[8] = (inst_t'({ 6'h0, REG_V0, REG_AT, REG_A2, 5'h0, SUBU})) ;
        mem[9] = (inst_t'({ 6'h0, REG_AT, REG_V0, REG_A3, 5'h0, SLT})) ;
        mem[10]= (inst_t'({ 6'h0, REG_AT, REG_V0, REG_T0, 5'h0, AND})) ;
        mem[11]= (inst_t'({ ORI, REG_AT, REG_T1, 16'h65})) ;
        mem[12]= (inst_t'({ 6'h0, REG_ZERO, REG_AT, REG_T2, 5'h4, SLL})) ;
        mem[13]= (inst_t'({ 6'h0, REG_AT, REG_V0, REG_ZERO, 5'h0, MULT})) ;
        mem[14]= (inst_t'({ 32'h0 })) ;
        mem[15]= (inst_t'({ 32'h0 })) ;
        mem[16]= (inst_t'({ 16'h0, REG_T3,5'h0,MFHI})) ;
        mem[17]= (inst_t'({ 16'h0, REG_T4,5'h0,MFLO})) ;
        mem[18]= (inst_t'({ 32'h0 })) ;
        mem[19]= (inst_t'({ORI,REG_ZERO, REG_AT, 16'hff})) ;
        mem[20]= (inst_t'({32'd0})) ;
        mem[21]= (inst_t'({32'd0})) ;
        mem[22]= (inst_t'({32'd0})) ;
        mem[23]= (inst_t'({SB, REG_ZERO, REG_AT, 16'h03})) ;
        mem[24]= (inst_t'({ORI, REG_ZERO, REG_AT, 16'hee})) ;
        mem[25]= (inst_t'({32'd0})) ;
        mem[26]= (inst_t'({32'd0})) ;
        mem[27]= (inst_t'({32'd0})) ;
        mem[28]= (inst_t'({SB, REG_ZERO, REG_AT, 16'h02})) ;
        mem[29]= (inst_t'({ORI, REG_ZERO, REG_AT, 16'hdd})) ;
        mem[30]= (inst_t'({32'd0})) ;
        mem[31]= (inst_t'({32'd0})) ;
        mem[32]= (inst_t'({32'd0})) ;
        mem[33]= (inst_t'({SB, REG_ZERO, REG_AT, 16'h01})) ;
        mem[34]= (inst_t'({ORI, REG_ZERO, REG_AT, 16'hcc})) ;
        mem[35]= (inst_t'({32'd0})) ;
        mem[36]= (inst_t'({32'd0})) ;
        mem[37]= (inst_t'({32'd0})) ;
        mem[38]= (inst_t'({SB, REG_ZERO, REG_AT, 16'h00})) ;
        mem[39]= (inst_t'({LB, REG_ZERO, REG_V0, 16'h03})) ;
        mem[40]= (inst_t'({32'd0})) ;
        mem[41]= (inst_t'({LUI, REG_ZERO, REG_AT, 16'h4455})) ;
        mem[42]= (inst_t'({32'd0})) ;
        mem[43]= (inst_t'({32'd0})) ;
        mem[44]= (inst_t'({32'd0})) ;
        mem[45]= (inst_t'({ORI, REG_AT, REG_AT, 16'h6677})) ;
        mem[46]= (inst_t'({32'd0})) ;
        mem[47]= (inst_t'({32'd0})) ;
        mem[48]= (inst_t'({32'd0})) ;
        mem[49]= (inst_t'({SW, REG_ZERO, REG_AT, 16'h08})) ;
        mem[50]= (inst_t'({32'd0})) ;
        mem[51]= (inst_t'({32'd0})) ;
        mem[52]= (inst_t'({32'd0})) ;
        mem[53]= (inst_t'({LW, REG_ZERO, REG_V0, 16'h08})) ;
        mem[54]= (inst_t'({32'd0})) ;
      */
      
      //Data dependence test case begin
//      
//      mem[0] = inst_t'({32'd0})                                       ;
//      mem[1] = inst_t'({ LUI, 5'h0, REG_AT, 16'h1234})                ; 
//      mem[2] = inst_t'({ ORI, REG_AT, REG_AT, 16'habcd})              ;
//      mem[3] = inst_t'({ LUI, 5'h0, REG_V0, 16'h1230})                ;
//      mem[4] = inst_t'({ ORI, REG_V0, REG_V0, 16'habcd})              ;
//      mem[5] = inst_t'({ 6'h0, REG_AT, REG_V0, REG_V1, 5'h0, SUBU})   ;
//      mem[6] = inst_t'({ 6'h0, REG_V0, REG_V1, REG_ZERO, 5'h0, MULT}) ;
//      mem[7] = inst_t'({32'd0})                                       ;
      //mem[7] = inst_t'({ 16'h0, REG_A0,5'h0,MFHI})                    ;
      //mem[8] = inst_t'({ 16'h0, REG_A1,5'h0,MFLO})                    ;
      //mem[9] = inst_t'({32'd0})                                       ; 
      
      //Data dependence test case end
      
      //Simple jump inst test case begin
                              
//      mem[0] = inst_t'({ LUI, 5'h0, REG_AT, 16'h1})                   ;
//      mem[1] = inst_t'({ J, 26'h14})                                  ;
//      mem[2] = inst_t'({32'd0})                                       ;
//      mem[3] = inst_t'({ JAL, 26'h20})                                ;
//      mem[4] = inst_t'({ LUI, 5'h0, REG_AT, 16'h3})                   ;
//      mem[5] = inst_t'({ ADDI, REG_ZERO, REG_V0, 16'hc})              ;
//      mem[6] = inst_t'({ 6'h0, REG_V0, REG_ZERO, REG_ZERO, 5'h0, JR}) ;
//      mem[7] = inst_t'({ LUI, 5'h0, REG_AT, 16'h2})                   ;
//      mem[8] = inst_t'({ BNE, REG_V0, REG_AT, 16'h2})                 ;
//      mem[9]  = inst_t'({ LUI, 5'h0, REG_AT, 16'h4})                   ;
//      mem[10]= inst_t'({ LUI, 5'h0, REG_AT, 16'hA})                   ;
//      mem[11]= inst_t'({ LUI, 5'h0, REG_AT, 16'h5})                   ;
//      mem[12]= inst_t'({ LUI, 5'h0, REG_AT, 16'h6})                   ;
//      mem[13]= inst_t'({ BEQ, REG_V0, REG_AT, 16'hfffc})              ;
//      mem[14]= inst_t'({32'd0})                                       ;
//      mem[15]= inst_t'({ J, 26'h3c})                                  ;
//      mem[16]= inst_t'({32'd0})                                       ;
      
      //Simple jump inst test case end
      
      //load dependence test case begin
      /*
      mem[0] = inst_t'({ ORI, REG_ZERO, REG_AT, 16'habab})            ;
      mem[1] = inst_t'({ SW, REG_ZERO, REG_AT, 16'h1000})             ;
      mem[2] = inst_t'({ ORI, REG_ZERO, REG_V0, 16'habab})            ;
      mem[3] = inst_t'({ ORI, REG_ZERO, REG_AT, 16'h0})               ;
      mem[4] = inst_t'({ LW, REG_ZERO, REG_V1, 16'h1000})             ;
      mem[5] = inst_t'({ BEQ, REG_V1, REG_V0, 16'h4})                 ;
      mem[6] = inst_t'({ 32'd0})                                      ;
      mem[7] = inst_t'({ ORI, REG_ZERO, REG_AT, 16'h1234})            ;
      mem[8] = inst_t'({ 32'd0})                                      ;
      mem[9] = inst_t'({ J, 26'h30})                                  ;
      mem[10]= inst_t'({ ORI, REG_ZERO, REG_AT, 16'hfefe})            ;
      mem[11]= inst_t'({ 32'd0})                                      ;
      mem[12]= inst_t'({ ORI, REG_ZERO, REG_A0, 16'hffff})            ;
      mem[13]= inst_t'({ J, 26'h34})                                  ;
      mem[14]= inst_t'({ 32'd0})                                      ;
      //dependence test case end
      */
      
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
