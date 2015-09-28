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
module red_pitaya_guitar_dist
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
        
        if (unnorm[31] == 1'b0) // negative result
        begin
            if (unnorm[30:15] == 16'h0000) // sign extended to valid signal part = no overflow
            begin
                if (unnorm[14:0] >= 15'h190)
                   preamp <= 16'h190;
                else
                    preamp <= {1'b0, unnorm[14:0]};
                    
            end
//            else                        // negative overflow
//                preamp <= 16'h8000;
        end
        
        if (unnorm[31] == 1'b1) // result positive
        begin
            if (unnorm[30:15] == 16'hffff)
            begin
                if (unnorm[14:0] <= 15'h7e70)
                    preamp <= 16'hfe70;                    
                else
                    preamp <= {1'b1, unnorm[14:0]};
                    
            end
        end       
end

assign out_amp_o = $signed(preamp);

endmodule
