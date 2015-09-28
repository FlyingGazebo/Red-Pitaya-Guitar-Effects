`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2015 07:57:24 AM
// Design Name: 
// Module Name: red_pitaya_guitar_octaver
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module red_pitaya_guitar_octaver
(
    input            clk_i,
    input            rstn_i,
    input  [16-1: 0] in_sound_i,
    
    input  [16-1: 0] vol_i,
       
    output [16-1: 0] out_sound_o
);

reg [16-1: 0] prev_in;
reg           up_sig ;
reg [16-1: 0] out_reg;
reg           prev_up;
reg [16-1: 0] statica;

assign out_sound_o = out_reg;

always @ (posedge clk_i)
begin
    if (!rstn_i)
    begin
        out_reg <= 'h0;
        up_sig  <= 'h0;
    end
    else
    begin
        prev_in <= in_sound_i;
        prev_up <= up_sig    ;
        out_reg <= vol_i * statica; 
        
        //detect zero crossing
        if (prev_in <= 'h8 && in_sound_i >= 'h8) 
            up_sig <= 1'b1;
        else if (prev_in >= 'h18 && in_sound_i <= 'h18) //set for test signal that lacks signed interpretation
            up_sig <= 1'b0;
        else
            up_sig <= up_sig;
            
        if (prev_up == 1'b0 && up_sig == 1'b1)
        begin
            if (statica == 'h7fff)  //invert signal
                statica <= 'h8000;
            else 
                statica <= 'h7fff;
        end
    end   
end
   
    
endmodule
