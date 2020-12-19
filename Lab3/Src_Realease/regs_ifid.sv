//

import mips_cpu_pkg::*;

module regs_ifid
  (
    input  logic     cpu_clk_50M,
    input  logic     cpu_rst_n,
    input  inst_t    inst,
    input  im_addr_t if_o_pc,
    output im_addr_t id_i_pc,
    output inst_t    id_i_inst
  );

  always_ff @ (posedge cpu_clk_50M) begin
    if(!cpu_rst_n) begin
      id_i_pc <= 32'h0;
    end
    else begin
      id_i_pc <= if_o_pc;
    end
  end

// passthrough
  assign id_i_inst = inst;

endmodule