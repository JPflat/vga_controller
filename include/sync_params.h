  
  `ifdef VGA_FORMAT_640X480_60HZ
    localparam P_HSYNC_ACTIVE_VIDEO = 640; // +640
    localparam P_HSYNC_FRONT_PORCH  = 656; // +16
    localparam P_HSYNC_SYNC_PULSE   = 752;  // +96
    localparam P_HSYNC_BACK_PORCH   = 800;
    //localparam P_HSYNC_BACK_PORCH   = 800;
    localparam P_VSYNC_ACTIVE_VIDEO = 480; // 480
    localparam P_VSYNC_FRONT_PORCH  = 490;  // +10
    localparam P_VSYNC_SYNC_PULSE   = 492;    // +2
    localparam P_VSYNC_BACK_PORCH   = 525;//+33
  /*
  `elsif VGA_FORMAT_640X350_70HZ
    localparam P_HSYNC_ACTIVE_VIDEO = 640; // 
    localparam P_HSYNC_FRONT_PORCH  = 656; // 
    localparam P_HSYNC_SYNC_PULSE   = 752; // 
    localparam P_HSYNC_BACK_PORCH   = 800;
    localparam P_VSYNC_ACTIVE_VIDEO = 350;  //
    localparam P_VSYNC_FRONT_PORCH  = 387; //
    localparam P_VSYNC_SYNC_PULSE   = 389; //
    localparam P_VSYNC_BACK_PORCH   = 449; // 
    */
`elsif VGA_FORMAT_640X350_70HZ
    localparam P_HSYNC_ACTIVE_VIDEO = 643; // 
    localparam P_HSYNC_FRONT_PORCH  = 659; // 
    localparam P_HSYNC_SYNC_PULSE   = 755; // 
    localparam P_HSYNC_BACK_PORCH   = 803;
    localparam P_VSYNC_ACTIVE_VIDEO = 350;  //
    localparam P_VSYNC_FRONT_PORCH  = 387; //
    localparam P_VSYNC_SYNC_PULSE   = 389; //
    localparam P_VSYNC_BACK_PORCH   = 449; // 
  `elsif DBG
    localparam P_HSYNC_ACTIVE_VIDEO = 3; // +23
    localparam P_HSYNC_FRONT_PORCH  = 4; // +3
    localparam P_HSYNC_SYNC_PULSE   = 5; // +8
    localparam P_HSYNC_BACK_PORCH   = 6;
    localparam P_VSYNC_ACTIVE_VIDEO = 5; // +23
    localparam P_VSYNC_FRONT_PORCH  = 6; // +3
    localparam P_VSYNC_SYNC_PULSE   = 7; // +2
    localparam P_VSYNC_BACK_PORCH   = 8; // 
  `elsif DBG1
    localparam P_HSYNC_ACTIVE_VIDEO = 64; // +23
    localparam P_HSYNC_FRONT_PORCH  = 66; // +3
    localparam P_HSYNC_SYNC_PULSE   = 75; // +8
    localparam P_HSYNC_BACK_PORCH   = 80;
    localparam P_VSYNC_ACTIVE_VIDEO = 35; // +23
    localparam P_VSYNC_FRONT_PORCH  = 38; // +3
    localparam P_VSYNC_SYNC_PULSE   = 40; // +2
    localparam P_VSYNC_BACK_PORCH   = 45; // 
  `else
    localparam P_HSYNC_ACTIVE_VIDEO = 640;
    localparam P_HSYNC_FRONT_PORCH  = 16;
    localparam P_HSYNC_SYNC_PULSE   = 96;
    localparam P_HSYNC_BACK_PORCH   = 48;
    localparam P_VSYNC_ACTIVE_VIDEO = 480;
    localparam P_VSYNC_FRONT_PORCH  = 11;
    localparam P_VSYNC_SYNC_PULSE   = 2;
    localparam P_VSYNC_BACK_PORCH   = 31;
  `endif




  localparam LP_HSYNC_CNT_BIT = $clog2(P_HSYNC_BACK_PORCH + 1);
  localparam LP_VSYNC_CNT_BIT = $clog2(P_VSYNC_BACK_PORCH + 1);

  localparam LP_HSYNC_ACTIVE_VIDEO_BITS = $clog2(P_HSYNC_ACTIVE_VIDEO + 1);
  localparam LP_HSYNC_FRONT_PORCH_BITS  = $clog2(P_HSYNC_FRONT_PORCH  + 1);
  localparam LP_HSYNC_SYNC_PULSE_BITS   = $clog2(P_HSYNC_SYNC_PULSE   + 1);
  localparam LP_HSYNC_BACK_PORCH_BITS   = $clog2(P_HSYNC_BACK_PORCH   + 1);
  localparam LP_VSYNC_FRONT_PORCH_BITS  = $clog2(P_VSYNC_FRONT_PORCH  + 1);
  localparam LP_VSYNC_SYNC_PULSE_BITS   = $clog2(P_VSYNC_SYNC_PULSE   + 1);
  localparam LP_VSYNC_BACK_PORCH_BITS   = $clog2(P_VSYNC_BACK_PORCH   + 1);