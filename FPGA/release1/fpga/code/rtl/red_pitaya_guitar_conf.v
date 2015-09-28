/**
 * $Id: red_pitaya_guitar.v$
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
 
 module red_pitaya_guitar_conf
(
    //adc signals
    input clk_i                         ,
    input rstn_i                        ,
    
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
    output                sys_ack_o       ,  //!< bus acknowledge signal
    
    output                conf_en_bypass_o,
    
    //set parameters
    output          conf_guitar_input_o   ,
    output [2-1: 0] conf_guitar_ef_sel_o  ,
    output          conf_guitar_bypass_o  ,
    
    output [16-1: 0] conf_dis_drive_o        ,
    output [16-1: 0] conf_amp_drive_o        ,
    output [ 8-1: 0] conf_dis_tone_o         ,
    output           conf_dis_asym_o         ,
    output [ 8-1: 0] conf_dis_vol_o          ,
    
    output [ 8-1: 0] conf_del_decay_o        ,
    output [16-1: 0] conf_del_time_o         ,
    
    output [16-1: 0] conf_oct_vol_o
);

//synced signals
wire            adc_write ;
wire            adc_read  ;
wire  [32-1: 0] adc_ofs   ;
wire  [32-1: 0] adc_wdat  ;
reg   [32-1: 0] adc_rdat  ;
reg             adc_ack   ;
reg             adc_err   ;

bus_clk_bridge i_bridge
(
   .sys_clk_i     (  sys_clk_i      ),
   .sys_rstn_i    (  sys_rstn_i     ),
   .sys_addr_i    (  sys_addr_i     ),
   .sys_wdata_i   (  sys_wdata_i    ),
   .sys_sel_i     (  sys_sel_i      ),
   .sys_wen_i     (  sys_wen_i      ),
   .sys_ren_i     (  sys_ren_i      ),
   .sys_rdata_o   (  sys_rdata_o    ),
   .sys_err_o     (  sys_err_o      ),
   .sys_ack_o     (  sys_ack_o      ),

   .clk_i         (  clk_i       ),
   .rstn_i        (  rstn_i      ),
   .addr_o        (  adc_ofs     ),
   .wdata_o       (  adc_wdat    ),
   .wen_o         (  adc_write   ),
   .ren_o         (  adc_read    ),
   .rdata_i       (  adc_rdat    ),
   .err_i         (  adc_err     ),
   .ack_i         (  adc_ack     )
);



//setup parameters
//input
reg            guitar_input_reg  ;

//bypass
reg            guitar_bypass_reg  ;

//select effect
reg  [ 2-1: 0] guitar_ef_sel_reg  ;

//effect parameters
//distortion
reg  [16-1: 0] dis_drive_reg  ;
reg  [16-1: 0] amp_drive_reg  ;
reg            dis_asyn_reg  ;

//delay
reg  [ 8-1:0]  del_decay_reg  ;
reg  [16-1: 0] del_time_reg  ;

//octaver
reg  [16-1: 0] oct_vol_reg  ;


//simplified for bypass
reg             en_reg   ;


always @ (posedge clk_i)
begin
    if (!rstn_i)
    begin
        en_reg            <= 'b0;
        guitar_input_reg  <= 'h0;
        guitar_ef_sel_reg <= 'h0;
        guitar_bypass_reg <= 'h0;
        dis_drive_reg     <= 'h1;
        dis_asyn_reg      <= 'h0;
        del_decay_reg     <= 'h0;
        del_time_reg      <= 'h0;
        oct_vol_reg       <= 'h0;
    end
    else
    begin
        if (adc_write)
        begin
            if (adc_ofs[15:3] == 'h03) en_reg            <= adc_wdat[0];
            if (adc_ofs[15:3] == 'h00) guitar_input_reg  <= adc_wdat[0];
            if (adc_ofs[15:3] == 'h01) guitar_ef_sel_reg <= adc_wdat[1:0];
            if (adc_ofs[15:3] == 'h02) guitar_bypass_reg <= adc_wdat[0];  
            if (adc_ofs[15:3] == 'h11) dis_drive_reg     <= adc_wdat[15:0];
            if (adc_ofs[15:3] == 'h12) amp_drive_reg     <= adc_wdat[15:0];
//            if (adc_ofs[15:3] == 'h12) dis_asyn_reg      <= adc_wdat[0]  ; 
            if (adc_ofs[15:3] == 'h20) del_decay_reg     <= adc_wdat[7:0]; 
            if (adc_ofs[15:3] == 'h21) del_time_reg      <= adc_wdat[15:0];
            if (adc_ofs[15:3] == 'h30) oct_vol_reg       <= adc_wdat[16-1:0];
        end
    end
end



always @ (*)
begin
    adc_err <= 1'b0;
    casez (adc_ofs[15:3])
        'h03 : begin adc_ack <= 1'b1; adc_rdat <= {{32- 1{1'b0}}, en_reg           }; end
        'h00 : begin adc_ack <= 1'b1; adc_rdat <= {{32- 1{1'b0}}, guitar_input_reg }; end
        'h01 : begin adc_ack <= 1'b1; adc_rdat <= {{32- 2{1'b0}}, guitar_ef_sel_reg}; end
        'h02 : begin adc_ack <= 1'b1; adc_rdat <= {{32- 1{1'b0}}, guitar_bypass_reg}; end
        'h11 : begin adc_ack <= 1'b1; adc_rdat <= {{32-16{1'b0}}, dis_drive_reg    }; end
        'h12 : begin adc_ack <= 1'b1; adc_rdat <= {{32-16{1'b0}}, amp_drive_reg    }; end
//        'h12 : begin adc_ack <= 1'b1; adc_rdat <= {{32- 1{1'b0}}, dis_asyn_reg     }; end
        'h20 : begin adc_ack <= 1'b1; adc_rdat <= {{32- 8{1'b0}}, del_decay_reg    }; end
        'h21 : begin adc_ack <= 1'b1; adc_rdat <= {{32-16{1'b0}}, del_time_reg     }; end
        'h30 : begin adc_ack <= 1'b1; adc_rdat <= {{32-16{1'b0}}, oct_vol_reg      }; end
        
        default : begin adc_ack <= 1'b1; adc_rdat <= {32{1'b0}}; end
    endcase
end

assign conf_en_bypass_o = en_reg;
assign conf_guitar_input_o = guitar_input_reg;
assign conf_guitar_ef_sel_o = guitar_ef_sel_reg;
assign conf_guitar_bypass_o = guitar_bypass_reg;
assign conf_dis_drive_o = dis_drive_reg;
assign conf_amp_drive_o = amp_drive_reg;
assign conf_dis_asym_o  = dis_asyn_reg ;
assign conf_del_decay_o = del_decay_reg;
assign conf_del_time_o  = del_time_reg ;
assign conf_oct_vol_o = oct_vol_reg;


endmodule





