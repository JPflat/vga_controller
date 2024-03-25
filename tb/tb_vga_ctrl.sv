`timescale 1ns / 1ps

module tb_vga_ctrl;
  // テストベンチのモジュールにはポートリストはない

  parameter STEP = 20; // 10ナノ秒：100MHz
  parameter TICKS = 1000;

  reg TEST_CLK;
  reg TEST_RESET;
  wire [31:0] TEST_COUNT;


  logic o_hsync;
  logic o_vsync;
  logic o_analog_r;
  logic o_analog_g;
  logic o_analog_b;
  // 各 initial ブロックは並列に実行される

  // シミュレーション設定
  initial
    begin
      // wave.vcd という名前で波形データファイルを出力
      $dumpfile("tb_seg7_top.vcd");
      // counter_1 に含まれる全てのポートを波形データに含める
      $dumpvars(0, dut);
      // シミュレータ実行時に counter_1 のポート COUNT を     
      // モニタする（値が変化した時に表示）
      //$monitor("COUNT: %d", counter_1.COUNT);
    end

  // クロックを生成
  initial
    begin
      TEST_CLK = 1'b1;
      forever
        begin
          // #数値 で指定時間遅延させる
          // ~ でビット反転
          #(STEP / 2) TEST_CLK = ~TEST_CLK;
        end
    end

  // 同期リセット信号を生成
  initial
    begin
      TEST_RESET = 1'b0;
      // 2クロックの間リセット
      #(35);
      TEST_RESET = 1'b1;
    end
/*
  initial
    begin
      repeat (TICKS) @(posedge TEST_CLK);
      $finish;
    end
*/
  logic [7:0] shift;
  // counter_1 という名前で counter モジュールをインスタンス化
  vga_ctrl
    dut    (
    .i_clk(TEST_CLK),
    .i_rst_n(TEST_RESET),

    .o_hsync,
    .o_vsync,
    .o_analog_r,
    .o_analog_g,
    .o_analog_b
  );


endmodule