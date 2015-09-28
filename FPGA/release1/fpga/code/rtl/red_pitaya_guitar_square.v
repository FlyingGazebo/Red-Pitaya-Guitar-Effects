// generate square signal for testing the dac - just push it to drive parameter

module red_pitaya_guitar_square
(
    input                clk_i           ,
    input                rstn_i          ,
    input  [16-1: 0]     drive_i         ,
    
    output reg [16-1: 0]     square_o
);


reg [32-1: 0] i;

always @ (posedge clk_i)
begin
    if (!rstn_i)
    begin
        i <= 32'h0;
        square_o <= 16'h0;
    end
    else
    begin
        i <= i+1;
        if (i == 32'h1e848)
            square_o <= drive_i;
        else if (i == 2* 32'h1e848)
        begin
            square_o <= -drive_i;
            i <= 32'h0;
        end
    end
end

endmodule
                        