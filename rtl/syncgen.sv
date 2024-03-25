/*
  Format: 640 x 350, 60Hz
  Pixcel clock: 25.125MHz
*/
`include "../include/vga_conf.h"

module syncgen (
  input wire clk,
  input wire rst_n,
  input wire vga_clk_en,

  output wire o_analog_r,
  output wire o_analog_g,
  output wire o_analog_b,
  output reg o_hsync,
  output reg o_vsync,
  output reg o_vga_act
);
  `include "../include/sync_params.h"
  `include "../include/color_params.h"
  `include "../include/ascii.h"

// state
  logic [LP_HSYNC_CNT_BIT-1:0] hsync_cnt;
  logic [LP_VSYNC_CNT_BIT-1:0] vsync_cnt;
// sync
  logic end_hbpor;
  logic end_vbpor;
  logic end_disp;
// vram
  logic rgb_on;
  logic [12:0] vram_rd_adr; // VRAM read address 
  logic [12:0] vram_rd_adr_lt; // VRAM read address 
  logic [71:0] vram_rd_data; //
  logic [7:0] vram_rd_data_line; //
  logic [7:0] vram_rd_data_color; //
  logic [11:0] vram_wr_adr;
  logic vram_wr_en;
  logic [71:0] vram_wr_data; //
  logic inc_vram_rd_adr;
  logic lat_vram_dat_line;
  logic lat_vram_dat_line_1;
// analog
  logic ana_chr_r;
  logic ana_chr_g;
  logic ana_chr_b;
  logic ana_bg_r;
  logic ana_bg_g;
  logic ana_bg_b;
// encoder
  logic [71:0] enc;
// timer
  logic [22:0] o_time;

  logic db_tri;


  assign o_vga_act = ~db_tri;

// VGA RGB
  assign rgb_on = (hsync_cnt >= 10'd3 && hsync_cnt <= (P_HSYNC_ACTIVE_VIDEO - 10'd1)) && (vsync_cnt <= (P_VSYNC_ACTIVE_VIDEO - 10'd1));
  assign ana_chr_r  = vram_rd_data_color[7] &  vram_rd_data_line[7];
  assign ana_bg_r   = vram_rd_data_color[3] & ~vram_rd_data_line[7];
  assign ana_chr_g  = vram_rd_data_color[6] &  vram_rd_data_line[7];
  assign ana_bg_g   = vram_rd_data_color[2] & ~vram_rd_data_line[7];
  assign ana_chr_b  = vram_rd_data_color[5] &  vram_rd_data_line[7];
  assign ana_bg_b   = vram_rd_data_color[1] & ~vram_rd_data_line[7];
  assign o_analog_r = rgb_on & (ana_chr_r | ana_bg_r);
  assign o_analog_g = rgb_on & (ana_chr_g | ana_bg_g);
  assign o_analog_b = rgb_on & (ana_chr_b | ana_bg_b);
// sync
  assign end_hfpor = (hsync_cnt == P_HSYNC_FRONT_PORCH - 10'd1) ? 1'b1 : 1'b0;
  assign end_hsync = (hsync_cnt == P_HSYNC_SYNC_PULSE - 10'd1)  ? 1'b1 : 1'b0;
  assign end_hbpor = (hsync_cnt >= P_HSYNC_BACK_PORCH - 10'd1)  ? 1'b1 : 1'b0;

  assign end_vfpor = (vsync_cnt == P_VSYNC_FRONT_PORCH - 10'd1) ? 1'b1 : 1'b0;
  assign end_vsync = (vsync_cnt == P_VSYNC_SYNC_PULSE - 10'd1)  ? 1'b1 : 1'b0;
  assign end_vbpor = (vsync_cnt >= P_VSYNC_BACK_PORCH - 10'd1)  ? 1'b1 : 1'b0;
  assign end_disp = end_hbpor & end_vbpor;
// VRAM
  assign inc_vram_rd_adr   = rgb_on & (hsync_cnt[2:0] == 3'd4);
  assign lat_vram_dat_line = (vram_rd_adr != vram_rd_adr_lt) ? 1'b1 : 1'b0;
  assign vram_wr_data = enc;

// 8bit to 64bit encoder with color information
  function [71:0] v_encode;
    input [7:0] color;
    input [3:0] din;
    begin
      case(din)
        4'd0: v_encode    = {color, 64'h003C24342C243C00};
        4'd1: v_encode    = {color, 64'h0018280808083C00};
        4'd2: v_encode    = {color, 64'h0018240418203C00};
        4'd3: v_encode    = {color, 64'h001C220E0E221E00};
        4'd4: v_encode    = {color, 64'h000818283C080800};
        4'd5: v_encode    = {color, 64'h003C203804043C00};
        4'd6: v_encode    = {color, 64'h003C20203C243C00};
        4'd7: v_encode    = {color, 64'h003C240408080800};
        4'd8: v_encode    = {color, 64'h003C243C3C243C00};
        4'd9: v_encode    = {color, 64'h003C243C04043C00};
        default: v_encode = {color, 64'hFFC3A59999A5C3FF};
      endcase
    end
  endfunction

  function [7:0] bin_to_ascii;
    input [3:0] din;
    begin
      case(din)
        4'd0: bin_to_ascii    = P_ASCII_0;
        4'd1: bin_to_ascii    = P_ASCII_1;
        4'd2: bin_to_ascii    = P_ASCII_2;
        4'd3: bin_to_ascii    = P_ASCII_3;
        4'd4: bin_to_ascii    = P_ASCII_4;
        4'd5: bin_to_ascii    = P_ASCII_5;
        4'd6: bin_to_ascii    = P_ASCII_6;
        4'd7: bin_to_ascii    = P_ASCII_7;
        4'd8: bin_to_ascii    = P_ASCII_8;
        4'd9: bin_to_ascii    = P_ASCII_9;
        default: bin_to_ascii = 8'h00;
      endcase
    end
  endfunction
// vram write data selecter
  always_comb begin
    case(vram_wr_adr)
      12'd1: enc = {P_VGA_COLOR_BL_MG, 64'h81A1A1BDA5A5BD81};
      12'd3: enc = {P_VGA_COLOR_GR_CY, 64'h818585BDA5A5BD81};
//      12'd4: enc = {P_VGA_COLOR__BKAN, 64'h003C24243C203C00};
      12'd5: enc = {P_VGA_COLOR_MG_YL, 64'h003C24243C203C00};
      12'd6: enc = {P_VGA_COLOR_WH_RD, 64'h001C103C10101000};
      12'd7: enc = {P_VGA_COLOR_YL_GR, 64'h041C24241C043800};
      12'd8: enc = {P_VGA_COLOR_WH_BK, 64'h0010001010101000};
      12'd9: enc = {P_VGA_COLOR_WH_BK, 64'h0008000808283800};
      
      12'd9:  enc = {P_VGA_COLOR_WH_BK, 64'h0008000808283800};
      12'd26: enc = {P_VGA_COLOR_RD_BL, 64'h81BD859DA5A59F81};
      12'd27: enc = {P_VGA_COLOR_YL_RD, 64'h81BD859DA5A59F81};
      12'd28: enc = {P_VGA_COLOR_GR_RD, 64'h81BD859DA5A59F81};

      12'd86: enc = {P_VGA_COLOR_BL_BK, 64'h00103C1010101800};
      12'd87: enc = {P_VGA_COLOR_BL_BK, 64'h0010001010101000};
      12'd88: enc = {P_VGA_COLOR_BL_BK, 64'h00203E2A2A2A2A00};
      12'd89: enc = {P_VGA_COLOR_BL_BK, 64'h003C24243C203C00};
      12'd90: enc = v_encode(P_VGA_COLOR_BL_BK, o_time[22:19]); 
      12'd91: enc = v_encode(P_VGA_COLOR_BL_BK, o_time[18:15]); 
      12'd92: enc = {P_VGA_COLOR_BL_BK, 64'h0018180000181800};
      12'd93: enc = v_encode(P_VGA_COLOR_BL_BK, o_time[14:11]); 
      12'd94: enc = v_encode(P_VGA_COLOR_BL_BK, o_time[10:7]); 
      12'd95: enc = {P_VGA_COLOR_BL_BK, 64'h0018180000181800};
      12'd96: enc = v_encode(P_VGA_COLOR_BL_BK, o_time[6:4]);
      12'd97: enc = v_encode(P_VGA_COLOR_BL_BK, o_time[3:0]);
      default enc = {P_VGA_COLOR_WH_BK, 64'h3333333333333333}; 
    endcase
  end


/* -----------------------------------------------------------------
 Horizon and Vertical sync control
-------------------------------------------------------------------- */
// horizon
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      hsync_cnt <= '0;
    else if(vga_clk_en)
      if(hsync_cnt >= (P_HSYNC_BACK_PORCH - 10'd1))
          hsync_cnt <= '0;
      else
        hsync_cnt <= hsync_cnt + 10'd1;
    else
      hsync_cnt <= hsync_cnt;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      o_hsync <= 1'b0;
    else if(vga_clk_en)
      if(end_hfpor)
        o_hsync <= 1'b1;
      else if(end_hsync)
        o_hsync <= 1'b0;
      else
        o_hsync <= o_hsync;
    else
      o_hsync <= o_hsync;
  end

// vertical
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      vsync_cnt <= '0;
    else if(vga_clk_en && (end_hbpor))
      if(end_vbpor) 
         vsync_cnt <= '0;
      else
        vsync_cnt <= vsync_cnt + {{LP_VSYNC_BACK_PORCH_BITS-1{1'b0}}, 1'b1};
    else
      vsync_cnt <= vsync_cnt;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      o_vsync <= 1'b0; // TBD
    else if(vga_clk_en & end_hfpor)
      if(end_vfpor)
        o_vsync <= 1'b1;
      else if(end_vsync)
        o_vsync <= 1'b0;
      else
        o_vsync <= o_vsync;
    else
      o_vsync <= o_vsync;
  end

/* -----------------------------------------------------------------
 VRAM address control
-------------------------------------------------------------------- */
// write
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n) begin
      vram_wr_adr <= '1;
      vram_wr_en  <= 1'b0;
    end
    else if(end_disp) begin
      vram_wr_adr <= '0;
      vram_wr_en  <= 1'b1;
    end
    else if(vram_wr_adr >= 12'd3520) begin
      vram_wr_adr <= vram_wr_adr;
      vram_wr_en  <= 1'b0;
    end
    else begin
      vram_wr_adr <= vram_wr_adr + 12'd1;
      vram_wr_en  <= 1'b1;
    end
  end

// read
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n) begin
      vram_rd_adr    <= '0;
      vram_rd_adr_lt <= '0;
    end
    else if(vga_clk_en) begin
      vram_rd_adr    <= (vsync_cnt[8:3] * 7'd80) + hsync_cnt[9:3];
      vram_rd_adr_lt <= vram_rd_adr; 
    end
    else begin
      vram_rd_adr    <= vram_rd_adr;
      vram_rd_adr_lt <= vram_rd_adr_lt;
    end
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      lat_vram_dat_line_1 <= '0;
    else if(vga_clk_en)
        lat_vram_dat_line_1 <= lat_vram_dat_line;
    else
        lat_vram_dat_line_1 <= lat_vram_dat_line_1;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      vram_rd_data_line <= vram_rd_data[63:56 ];
    else if(vga_clk_en)
      if(lat_vram_dat_line_1)
        case (vsync_cnt[2:0])
          3'd0 : vram_rd_data_line <= vram_rd_data[63:56 ];
          3'd1 : vram_rd_data_line <= vram_rd_data[55:48];
          3'd2 : vram_rd_data_line <= vram_rd_data[47:40];
          3'd3 : vram_rd_data_line <= vram_rd_data[39:32];
          3'd4 : vram_rd_data_line <= vram_rd_data[31:24];
          3'd5 : vram_rd_data_line <= vram_rd_data[23:16];
          3'd6 : vram_rd_data_line <= vram_rd_data[15:8 ];
          3'd7 : vram_rd_data_line <= vram_rd_data[7:0  ];
          default: vram_rd_data_line <= vram_rd_data[63:56 ];
        endcase
      else if(rgb_on)
        vram_rd_data_line <= {vram_rd_data_line[6:0], vram_rd_data_line[7]};
      else
        vram_rd_data_line <= vram_rd_data_line;
    else
        vram_rd_data_line <= vram_rd_data_line;
  end

  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      vram_rd_data_color <= P_VGA_COLOR_BK_BK;
    else if(vga_clk_en && lat_vram_dat_line_1)
      vram_rd_data_color <= vram_rd_data[71:64];
    else
      vram_rd_data_color <= vram_rd_data_color;
  end

/* -----------------------------------------------------------------
 IP
-------------------------------------------------------------------- */
  VRAM	VRAM_inst (
    .clock ( clk ),
    .data ( vram_wr_data ),
    .rdaddress ( vram_rd_adr[11:0] ),
    .wraddress ( vram_wr_adr ),
    .wren ( vram_wr_en ),
    .q ( vram_rd_data )
  );

  timer timer(
      .clk,
      .rst_n,
      .vga_clk_en,
      .cnt_up_pls(end_disp),
      .o_time(o_time)
  );

// debug trigger
  always_ff @( posedge clk, negedge rst_n ) begin
    if(~rst_n)
      db_tri <= 1'b0;
    else
        db_tri <= end_vbpor;

  end
endmodule