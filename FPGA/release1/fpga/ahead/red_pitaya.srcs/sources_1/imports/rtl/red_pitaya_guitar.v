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
    output     [14-1: 0] out_sound_o       ,

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

wire [32-1: 0] conf_dis_drive;
wire [ 8-1: 0] conf_dis_tone ;
wire [ 8-1: 0] conf_dis_vol  ; 
wire           conf_dis_asym ;

wire           conf_en_bypass;

wire [ 2-1: 0] conf_ef_sel   ;
wire           conf_bypass   ;

wire [16-1: 0] out_distortion;
wire [16-1: 0] out_delay     ;
wire [16-1: 0] out_octaver   ;

wire [ 8-1: 0]  conf_del_decay;
wire [16-1: 0]  conf_del_time ;

wire [16-1: 0]  conf_oct_vol ;

//always @ (*)
//begin
//    if (!rstn_i)
//    begin
//        out_sound_o <= 'h0;
//    end
//    else if (conf_bypass)
//        out_sound_o <= picked_in;
//    else
//    begin
//        case (conf_ef_sel)
//        2'b00 : out_sound_o <= out_delay[16:2]     ;
//        2'b01 : out_sound_o <= out_distortion[16:2]; //change conf_ef_sel as effects are added
//        2'b10 : out_sound_o <= out_octaver[16:2]   ;
//        default : out_sound_o <= picked_in[16:2];
//        endcase
//    end
//end

//input resolution extension
red_pitaya_guitar_maf i_maf
(
    .clk_i        ( clk_i      ),
    .rstn_i       ( rstn_i     ),
    .in_sound_i   ( in_sound_i ),
    .out_extd_o   ( extd       )
);


wire [16-1: 0] extd_out;

red_pitaya_bypass i_bypass
(
    .clk_i        (   clk_i                    ),
    .rstn_i       (   rstn_i                   ),
    
    .sig_i        (   extd                        ),
    .sig_o        (   extd_out                     ),
    
    .en_i         (   conf_en_bypass             )
    );
    
assign out_sound_o = extd_out[15:2];



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
    .conf_dis_tone_o   (  conf_dis_tone     ),
    .conf_dis_asym_o   (  conf_dis_asym     ),
    .conf_dis_vol_o    (  conf_dis_vol      ),
                          
    .conf_del_decay_o  (  conf_del_decay    ),
    .conf_del_time_o   (  conf_del_time     ),
                                            
    .conf_oct_vol_o    (  conf_oct_vol      )
    );



//red_pitaya_guitar_distortion i_distortion
//(
//    .clk_i           ( clk_i          ),
//    .rstn_i          ( rstn_i         ),
//                                     
//    .in_sound        ( picked_in     ),
//    .out_distortion  ( out_distortion ),
//                                   
//    .drive_i           ( conf_dis_drive ),
//    .tone_i            ( conf_dis_tone  ),
//    .asym_i            ( conf_dis_asym  ),
//    .vol_i             ( conf_dis_vol   ),
//                                     
//    .enable          ( conf_ef_sel    )
//);

//red_pitaya_guitar_delay i_delay

//(
//    .clk_i           ( clk_i          ),
//    .rstn_i          ( rstn_i         ),
                                     
//    .in_sound_i        ( picked_in      ),
//    .out_sound_o       ( out_delay      ),
    
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
//    .out_sound_o      ( out_octaver  )
//);
    
endmodule
    


