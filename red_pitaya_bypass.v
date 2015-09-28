module  red_pitaya_bypass(
input rst_i,
input clk_i,

input [14-1: 0] sig_i,
input [14-1: 0] sig_o,


 // System bus
input                 sys_clk_i       ,  //!< bus clock
input                 sys_rstn_i      ,  //!< bus reset - active low
input      [ 32-1: 0] sys_addr_i      ,  //!< bus address
input      [ 32-1: 0] sys_wdata_i     ,  //!< bus write data
input      [  4-1: 0] sys_sel_i       ,  //!< bus write byte select
input                 sys_wen_i       ,  //!< bus write enable
input                 sys_ren_i       ,  //!< bus read enable
output reg [ 32-1: 0] sys_rdata_o     ,  //!< bus read data
output reg            sys_err_o       ,  //!< bus error indicator
output reg            sys_ack_o          //!< bus acknowledge signal
);

reg en;

always @ (posedge sys_clk_i)
begin
    if (!sys_rstn_i)
        en <= 1'b0;
    else if (sys_addr_i[0] == 1 && sys_wen_i)
    begin
        en <= sys_wdata_i;
        sys_ack_o <= 1'b1;
    end
    else if (sys_addr_i[0] == 1 && sys_ren_i)
    begin
        sys_rdata_o <= {{32-1{1'b0}}, en};
        
    end
    else
        sys_ack_o <= 1'b0;
end


assign  sig_o = en ? sig_i : 14'h0;

endmodule
