module  red_pitaya_bypass(

input clk_i          ,
input rstn_i         ,

input [16-1: 0] sig_i,
output [16-1: 0] sig_o,

input en_i

);

assign sig_o = en_i ? sig_i : 14'h0;

endmodule
