/**
 * $Id: red_pitaya_guitar_amp.v$
 *
 * @brief Red Pitaya guitar amplification and overflow handle module.
 *
 * @Author Eva Šegatin
 *
 * (c) Red Pitaya  http://www.redpitaya.com
 *
 * This part of code is written in Verilog hardware description language (HDL).
 * Please visit http://en.wikipedia.org/wiki/Verilog
 * for more details on the language used herein.
 */
module red_pitaya_guitar_amp
(
    input clk_i ,
    input rstn_i,
    
    //samples
    input  [16-1: 0] in_sound_i,
    output [16-1: 0] out_amp_o,

    
     // parameter
    input [16-1: 0] drive_i      
);


//preamplify by drive parameter

reg  [16-1: 0] preamp;
wire [32-1: 0] unnorm;

assign unnorm = $signed(drive_i) * $signed(in_sound_i);
//assign unnorm = $signed(unnorm);

//handle overflow

always @ (clk_i)
begin
        
        if (unnorm[31] == 1'b0)
        begin
            if (unnorm[30:15] == 16'h0000) // sign extended to valid signal part = no overflow
                preamp <= {1'b0, unnorm[14:0]};
            else
                preamp <= 'h7fff;       
        end
        
        if (unnorm[31] == 1'b1)
        begin
            if (unnorm[30:15] == 16'hffff)
                preamp <= {1'b1, unnorm[14:0]};
            else
                preamp <= 'h8000;
        end       
end

assign out_amp_o = $signed(preamp);

endmodule
