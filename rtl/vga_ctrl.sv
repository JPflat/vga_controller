`include "../include/vga_conf.h"
module vga_ctrl (
  input wire i_clk,
  input wire i_rst_n,

  output wire o_hsync,
  output wire o_vsync,
  output wire o_analog_r,
  output wire o_analog_g,
  output wire o_analog_b,
  output wire o_vga_act
);

  logic clk50m;
  logic locked;
  logic rst_n;
  logic vga_clk_en;
// PLLs
  PLL	PLL_inst (
    .inclk0 ( i_clk ),
    .c0 ( clk50m ),
    .locked(locked)
    );
  assign rst_n = locked & i_rst_n;

  timgen timgen(
    .clk(clk50m),
    .rst_n,
    .o_tim_0(vga_clk_en)
  );

  syncgen syncgen(
    .clk(clk50m),
    .rst_n,
    .vga_clk_en,
    .o_analog_r,
    .o_analog_g,
    .o_analog_b,
    .o_hsync,
    .o_vsync,
    .o_vga_act
  );
endmodule