/**
 * $Id: red_pitaya_distortion.v$
 *
 * @brief Red Pitaya guitar distiortion module.
 *
 * @Author Eva Šegatin
 *
 * (c) Red Pitaya  http://www.redpitaya.com
 *
 * This part of code is written in Verilog hardware description language (HDL).
 * Please visit http://en.wikipedia.org/wiki/Verilog
 * for more details on the language used herein.
 */
 
 module red_pitaya_distortion
 (
    input clk_i ,
    input rstn_i,
    
    //samples
    input  [16-1: 0] in_sound,
    output [16-1: 0] out_distortion,

    
     // distortion parameters
    input [16-1: 0] drive_i      ,
    input [ 8-1: 0] tone_i       ,
    input           asym_i       ,
    input [ 8-1: 0] vol_i        ,
    
    input enable        
);


//preamplify by drive parameter

reg  [16-1: 0] preamp;
wire [32-1: 0] unnorm;

assign unnorm = $signed(drive_i) * $signed(in_sound);

//handle overflow

always @ (clk_i)
begin
    if (unnorm[31] == 1) //result negative
    begin
        if (unnorm <= -'d4294967295) // negative overflow
            preamp <= 16'h8000;
        else                   // no overflow
            preamp <= {1'b1, unnorm[22:8]};
    end
    else                //result positive
    begin
        if (unnorm >= 'd4294967295)
            preamp <= 16'hffff;
        else
            preamp <= {1'b0, unnorm[22:8]};
    end
end


//main effect

//construct look-up table and interpolate between points
reg [16-1: 0] abs_sound;
reg [16-1: 0] abs_out  ;
reg [ 7-1: 0] index    ;
reg [15-1: 0] table_y  ;
reg [ 7-1: 0] table_d  ;
reg [16-1: 0] mult_unn ;
reg [16-1: 0] neg_out  ;
reg [ 9-1: 0] ip       ;
reg [16-1: 0] big_out  ;
wire [16-1: 0] in_signed = ~in_sound + 1; //two's complement by hand

always @ (clk_i)
begin
    if (!rstn_i)
    begin
        big_out <= 'h0;
        neg_out <= 'h0;
        abs_out <= 'h0;
        abs_sound <= 'h0;
        mult_unn <= 'h0;
    end
    else
    begin
        // create absolute value of input to map to lookup table
        if (preamp == 16'h8000)
            abs_sound <= 16'hffff;
        else
        begin
            if (in_sound[15] == 1'b1)
                abs_sound <= in_signed;
            else
                abs_sound <= in_sound;
        end
            
        //create index and interpolation factor
        index <= {1'b0, abs_sound[14:9]}; //sets point in table
        ip    <= {1'b0, abs_sound[ 7:0]}; //sets distance from the point in table to actual used point
        
        case(index)
         0  : begin table_y <= 'd0; table_d <= 'd127; end
         1  : begin table_y <= 'd4768; table_d <= 'd123; end
         2  : begin table_y <= 'd8766; table_d <= 'd103; end
         3  : begin table_y <= 'd12117; table_d <= 'd86; end
         4  : begin table_y <= 'd14927; table_d <= 'd72; end
         5  : begin table_y <= 'd17283; table_d <= 'd61; end
         6  : begin table_y <= 'd19259; table_d <= 'd51; end
         7  : begin table_y <= 'd20916; table_d <= 'd43; end
         8  : begin table_y <= 'd22306; table_d <= 'd36; end
         9  : begin table_y <= 'd23472; table_d <= 'd30; end
        10  : begin table_y <= 'd24451; table_d <= 'd25; end
        11  : begin table_y <= 'd25272; table_d <= 'd21; end
        12  : begin table_y <= 'd25961; table_d <= 'd18; end
        13  : begin table_y <= 'd26540; table_d <= 'd15; end
        14  : begin table_y <= 'd27027; table_d <= 'd13; end
        15  : begin table_y <= 'd27436; table_d <= 'd11; end
        16  : begin table_y <= 'd27780; table_d <= 'd9; end
        17  : begin table_y <= 'd28070; table_d <= 'd8; end
        18  : begin table_y <= 'd28314; table_d <= 'd6; end
        19  : begin table_y <= 'd28520; table_d <= 'd5; end
        20  : begin table_y <= 'd28695; table_d <= 'd5; end
        21  : begin table_y <= 'd28842; table_d <= 'd4; end
        22  : begin table_y <= 'd28968; table_d <= 'd3; end
        23  : begin table_y <= 'd29074; table_d <= 'd3; end
        24  : begin table_y <= 'd29165; table_d <= 'd2; end
        25  : begin table_y <= 'd29243; table_d <= 'd2; end
        26  : begin table_y <= 'd29310; table_d <= 'd2; end
        27  : begin table_y <= 'd29369; table_d <= 'd2; end
        28  : begin table_y <= 'd29419; table_d <= 'd1; end
        29  : begin table_y <= 'd29463; table_d <= 'd1; end
        30  : begin table_y <= 'd29502; table_d <= 'd1; end
        31  : begin table_y <= 'd29537; table_d <= 'd1; end
        32  : begin table_y <= 'd29568; table_d <= 'd1; end
        33  : begin table_y <= 'd29596; table_d <= 'd1; end
        34  : begin table_y <= 'd29622; table_d <= 'd1; end
        35  : begin table_y <= 'd29646; table_d <= 'd1; end
        36  : begin table_y <= 'd29668; table_d <= 'd1; end
        37  : begin table_y <= 'd29689; table_d <= 'd1; end
        38  : begin table_y <= 'd29709; table_d <= 'd1; end
        39  : begin table_y <= 'd29728; table_d <= 'd1; end
        40  : begin table_y <= 'd29746; table_d <= 'd1; end
        41  : begin table_y <= 'd29763; table_d <= 'd1; end
        42  : begin table_y <= 'd29781; table_d <= 'd1; end
        43  : begin table_y <= 'd29798; table_d <= 'd1; end
        44  : begin table_y <= 'd29815; table_d <= 'd1; end
        45  : begin table_y <= 'd29831; table_d <= 'd1; end
        46  : begin table_y <= 'd29848; table_d <= 'd1; end
        47  : begin table_y <= 'd29864; table_d <= 'd1; end
        48  : begin table_y <= 'd29881; table_d <= 'd1; end
        49  : begin table_y <= 'd29898; table_d <= 'd1; end
        50  : begin table_y <= 'd29914; table_d <= 'd1; end
        51  : begin table_y <= 'd29931; table_d <= 'd1; end
        52  : begin table_y <= 'd29948; table_d <= 'd1; end
        53  : begin table_y <= 'd29965; table_d <= 'd1; end
        54  : begin table_y <= 'd29982; table_d <= 'd1; end
        55  : begin table_y <= 'd29999; table_d <= 'd1; end
        56  : begin table_y <= 'd30017; table_d <= 'd1; end
        57  : begin table_y <= 'd30034; table_d <= 'd1; end
        58  : begin table_y <= 'd30052; table_d <= 'd1; end
        59  : begin table_y <= 'd30070; table_d <= 'd1; end
        60  : begin table_y <= 'd30088; table_d <= 'd1; end
        61  : begin table_y <= 'd30106; table_d <= 'd1; end
        62  : begin table_y <= 'd30125; table_d <= 'd1; end
        63  : begin table_y <= 'd30143; table_d <= 'd1; end
        endcase
    end
    
    //interpolate by distance from last point and slope
    mult_unn <= table_d*ip;    
    abs_out <= table_y + {1'b0, mult_unn[15:4]};
    
    //recover the sign
    if (in_sound[15] == 1'b0)
        big_out <= {1'b0, abs_out};
    else
    begin
        neg_out <= {1'b1, abs_out};
        if (asym_i)
            big_out <= {2'b11, neg_out[14:1]};
        else
            big_out <= neg_out;
    end
end

assign out_distortion = enable ? big_out : 14'h0;


endmodule

