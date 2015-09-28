/**
 * $Id: red_pitaya_guitar_maf.v$
 *
 * @brief Red Pitaya moving average filter for improved resolution for guitar effects module. 
 *
 * @Author Eva Šegatin
 *
 * (c) Red Pitaya  http://www.redpitaya.com
 *
 * This part of code is written in Verilog hardware description language (HDL).
 * Please visit http://en.wikipedia.org/wiki/Verilog
 * for more details on the language used herein.
 */
 
 module red_pitaya_guitar_maf
 (
    //necessities
    input                clk_i           ,
    input                rstn_i          ,
    
    //samples
    input      [14-1: 0] in_sound_i        , // adc input
    output     [16-1: 0] out_extd_o
);

//totally naive implementation of averaging the oversampled input to decimate to about 50kHz

reg [16-1: 0] ext;
reg [14-1: 0] avg;
reg [25-1: 0] sum;
reg [12-1:0] i;
wire [14-1: 0] in_corr = $signed(in_sound_i) + 'd28;

always @ (posedge clk_i)
begin
    if (!rstn_i)
    begin
        sum <= 'h0;
        i <= 12'd2048;
    end
    else
    begin
        if (i > 0)
        begin
            sum <= $signed(sum) + $signed(in_corr);
            i <= i-1;
        end
        else
        begin
            ext <= $signed(sum) >> 9;
            avg <= $signed(sum) >> 11;
            sum <= 'h0;
            i <= 12'd2048;
        end
    end
end

//assign exit and minimize offset by adding an arbitrary value
assign out_extd_o = ext; //- avg;

endmodule


