/**
 * $Id: red_pitaya_guitar_delay.v$
 *
 * @brief Red Pitaya guitar delay module. Saves a number of samples and mixes them with 
 * later samples. Theoretically infinite but for decay.
 *
 * @Author Eva Šegatin
 *
 * (c) Red Pitaya  http://www.redpitaya.com
 *
 * This part of code is written in Verilog hardware description language (HDL).
 * Please visit http://en.wikipedia.org/wiki/Verilog
 * for more details on the language used herein.
 */
 
 module red_pitaya_guitar_delay
 (
    input                clk_i           ,
    input                rstn_i          ,
    
    //samples
    input      [16-1: 0] in_sound_i        , // adc input
    output     [16-1: 0] out_sound_o       ,
    
    //parameters
    input      [16-1: 0] delay_time        ,//in samples@44.1kHz
    input      [ 8-1: 0] decay

);
//naive ram, not sure if it can be implemented
reg [16-1: 0] saved_samples [0:13000];
reg [16-1: 0] fdb; //feedback signal
//wire [16-1: 0] sum_fdb;
reg [16-1: 0] buf_out;
reg [16-1: 0] buf_in;
reg [ 8-1: 0] cnt ;
reg [16-1: 0] rd  ;
reg [14-1: 0] addr;

reg out;

reg [16-1: 0] mix_out;
wire [17-1: 0] mix_out_sat;
wire [25-1: 0] delay_mult;

always @ (posedge clk_i)
begin
    if (!rstn_i)
    begin
        cnt <= 'd233;
        addr <= 'h0;
        out <= 1'b0;
        buf_in <= 'h0;
        fdb <= 'h0;
    end
    else
    begin
        if (|mix_out)
            fdb <= mix_out;
        else
            fdb <= 'h0;
            
        if (addr >= delay_time && delay_time > 'h0) // check if larger for case of shortening it
        begin
            if (rd == 'd0) //wait so that read position goes to previously recorded
            begin
                addr <= addr;
                out <= 1'b1;
            end
            else
                addr <= 16'h0;
        end 
        else if (cnt == 'd0)
        begin
            addr <= addr + 'b1;
        end
        
        if (cnt == 'd0)
            cnt <= 'd233;
        else
           cnt <= cnt - 1'd1;
           
        if (cnt == 'd0)
            buf_in <= in_sound_i;         
               
    
            if (|saved_samples[delay_time])
                saved_samples[addr] <= buf_in + fdb;
            else
                saved_samples[addr] <= buf_in; //initialize
    end
end

always @ (posedge clk_i)
begin
    if (!rstn_i)
    begin
        rd <= 'h0;
    end
    if (out) //read enable
    begin
        if (rd >= delay_time)
            rd <= 'd0;    
        else if (cnt == 'd0) 
            rd <= rd + 1'd1;
        else
            buf_out <= saved_samples[rd];
    end
end

assign delay_mult = buf_out * {1'b0, decay};
assign mix_out_sat = {delay_mult[24], delay_mult[24:9]} + {buf_in[15], buf_in};
//assign mix_out_sat = {buf_out[15], buf_out} + {buf_in[15], buf_in};
assign out_sound_o = (delay_time == 0) ? in_sound_i : mix_out;

//assign sum_fdb = fdb + in_sound_i;

always @ (*)
begin
    if (mix_out_sat[16:15] == 2'b01) //positive overflow
        mix_out <= 16'h7fff;
    else if (mix_out_sat[16:15] == 2'b10) //negative overflow
        mix_out <= 16'h8000;
    else
        mix_out <= mix_out_sat[15:0];
end

endmodule
    


