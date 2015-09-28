/**
 * $Id: red_pitaya_guitar_top.v$
 *
 * @brief Red Pitaya guitar effects module. It takes signal from ADCs and processes 
 * it as sound effects common for guitar.
 *
 * @Author Eva Šegatin
 *
 * (c) Red Pitaya  http://www.redpitaya.com
 *
 * This part of code is written in Verilog hardware description language (HDL).
 * Please visit http://en.wikipedia.org/wiki/Verilog
 * for more details on the language used herein.
 */
 
 module red_pitaya_guitar_top
 (
    input                clk_i           ,
    input                rstn_i          ,
    
    //samples
    input      [14-1: 0] in_sound_i        , // adc input
    input      [14-1: 0] in_gen_i          , // generated input
    output reg [16-1: 0] out_sound_o       ,

    // System bus
   input                 sys_clk_i       ,  //!< bus clock
   input                 sys_rstn_i      ,  //!< bus reset - active low
   input      [ 32-1: 0] sys_addr_i      ,  //!< bus address
   input      [ 32-1: 0] sys_wdata_i     ,  //!< bus write data
   input      [  4-1: 0] sys_sel_i       ,  //!< bus write byte select
   input                 sys_wen_i       ,  //!< bus write enable
   input                 sys_ren_i       ,  //!< bus read enable
   output     [ 32-1: 0] sys_rdata_o     ,  //!< bus read data
   output                sys_err_o       ,  //!< bus error indicator
   output                sys_ack_o          //!< bus acknowledge signal
);

//input selector
wire [16-1: 0] picked_in  ;
wire [16-1: 0] extd       ; 
wire           conf_input ;

assign picked_in = conf_input  ? extd : {in_gen_i, 2'b0}; //generated input crudely extended to the same bit width
  



//bypass and device selector

wire [16-1: 0] conf_dis_drive;
wire [16-1: 0] conf_amp_drive;

wire [ 8-1: 0] conf_dis_tone ;
wire [ 8-1: 0] conf_dis_vol  ; 
wire           conf_dis_asym ;

wire           conf_en_bypass;

wire [ 2-1: 0] conf_ef_sel   ;
wire           conf_bypass   ;

wire [16-1: 0] distortion_out;
//wire [16-1: 0] delay_out     ;
//wire [16-1: 0] octaver_out   ;

wire [ 8-1: 0]  conf_del_decay;
wire [16-1: 0]  conf_del_time ;

wire [16-1: 0]  conf_oct_vol ;

wire [16-1: 0] extd_out;
wire [16-1: 0] amp_out;

always @ (*)
begin
    if (conf_bypass)
        out_sound_o <= picked_in;
    else
    begin
        case (conf_ef_sel)  //change conf_ef_sel as effects are added
        2'b01 : out_sound_o <= distortion_out   ;
        2'b10 : out_sound_o <= amp_out; 
        default : out_sound_o <= picked_in   ;
        endcase
    end
end


//input resolution extension
red_pitaya_guitar_maf i_maf
(
    .clk_i        ( clk_i      ),
    .rstn_i       ( rstn_i     ),
    .in_sound_i   ( in_sound_i   ),
    .out_extd_o   ( extd       )
);


red_pitaya_guitar_dist i_dist
(
    .clk_i      ( clk_i  ),  
    .rstn_i     ( rstn_i ),  

    .in_sound_i ( extd      ),
    .out_amp_o  ( distortion_out),

    .drive_i    ( conf_dis_drive )
);

red_pitaya_guitar_amp i_amp
(
    .clk_i      ( clk_i  ),  
    .rstn_i     ( rstn_i ),  

    .in_sound_i ( extd      ),
    .out_amp_o  ( amp_out   ),

    .drive_i    ( conf_amp_drive )
);


red_pitaya_guitar_conf i_guitar_conf
(
    .clk_i       (  clk_i       ),
    .rstn_i      (  rstn_i      ),
                    
    .sys_clk_i   (  sys_clk_i   ),
    .sys_rstn_i  (  sys_rstn_i  ),
    .sys_addr_i  (  sys_addr_i  ),
    .sys_wdata_i (  sys_wdata_i ),
    .sys_sel_i   (  sys_sel_i   ),
    .sys_wen_i   (  sys_wen_i   ),
    .sys_ren_i   (  sys_ren_i   ),
    .sys_rdata_o (  sys_rdata_o ),
    .sys_err_o   (  sys_err_o   ),
    .sys_ack_o   (  sys_ack_o   ),
    
    .conf_en_bypass_o      (  conf_en_bypass),
                              
    .conf_guitar_input_o   (  conf_input    ),
    .conf_guitar_ef_sel_o  (  conf_ef_sel   ),
    .conf_guitar_bypass_o  (  conf_bypass   ),
    
    .conf_dis_drive_o  (  conf_dis_drive    ),
    .conf_amp_drive_o  (  conf_amp_drive    ),
    .conf_dis_tone_o   (  conf_dis_tone     ),
    .conf_dis_asym_o   (  conf_dis_asym     ),
    .conf_dis_vol_o    (  conf_dis_vol      ),
                          
    .conf_del_decay_o  (  conf_del_decay    ),
    .conf_del_time_o   (  conf_del_time     ),
                                            
    .conf_oct_vol_o    (  conf_oct_vol      )
    );





//red_pitaya_guitar_delay i_delay

//(
//    .clk_i           ( clk_i          ),
//    .rstn_i          ( rstn_i         ),
                                     
//    .in_sound_i        ( picked_in      ),
//    .out_sound_o       ( delay_out      ),
    
//    .decay           ( conf_del_decay ),
//    .delay_time      ( conf_del_time  )
//);

//red_pitaya_guitar_octaver i_octaver
//(
//    .clk_i            ( clk_i        ),
//    .rstn_i           ( rstn_i       ),
//    .in_sound_i       ( picked_in    ),
//    
//    .vol_i            ( conf_oct_vol ), 
//       
//    .out_sound_o      ( octaver_out  )
//);
    
endmodule
    


