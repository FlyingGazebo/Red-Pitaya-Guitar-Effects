`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/21/2015 11:13:53 AM
// Design Name: 
// Module Name: red_pitaya_bypass_tb
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


module red_pitaya_bypass_tb(

    );

reg              sys_clk         ;
reg              sys_rstn        ;
wire  [ 32-1: 0] sys_addr        ;
wire  [ 32-1: 0] sys_wdata       ;
wire  [  4-1: 0] sys_sel         ;
wire             sys_wen         ;
wire             sys_ren         ;
wire  [ 32-1: 0] sys_rdata       ;
wire             sys_err         ;
wire             sys_ack         ;

reg [ 14-1: 0] in_sig;
wire [ 14-1: 0]out_sig;
reg            adc_clk    ;
reg            adc_rstn   ;    
    
red_pitaya_bypass i_bypass
(
    .clk_i        (   adc_clk                    ),
    .rstn_i       (   adc_rstn                   ),
    
    .sig_i   (   in_sig                     ),
    .sig_o   (   out_sig                    ),
    
    //axi                                                                    
    .sys_clk_i       (  sys_clk                 ),  // clock              
    .sys_rstn_i      (  sys_rstn                ),  // reset - active low 
    .sys_addr_i      (  sys_addr                ),  // address            
    .sys_wdata_i     (  sys_wdata               ),  // write data         
    .sys_sel_i       (  sys_sel                 ),  // write byte select  
    .sys_wen_i       (  sys_wen                 ),  // write enable       
    .sys_ren_i       (  sys_ren                 ),  // read enable        
    .sys_rdata_o     (  sys_rdata               ),  // read data          
    .sys_err_o       (  sys_err                 ),  // error indicator    
    .sys_ack_o       (  sys_ack                 )   // acknowledge signal 
    );

sys_bus_model i_bus
(
  .sys_clk_i      (  sys_clk      ),
  .sys_rstn_i     (  sys_rstn     ),
  .sys_addr_o     (  sys_addr     ),
  .sys_wdata_o    (  sys_wdata    ),
  .sys_sel_o      (  sys_sel      ),
  .sys_wen_o      (  sys_wen      ),
  .sys_ren_o      (  sys_ren      ),
  .sys_rdata_i    (  sys_rdata    ),
  .sys_err_i      (  sys_err      ),
  .sys_ack_i      (  sys_ack      ) 
    );
    
    
    initial begin
       sys_clk  <= 1'b0 ;
       sys_rstn <= 1'b0 ;
       repeat(10) @(posedge sys_clk);
          sys_rstn <= 1'b1  ;
    end
    
    always begin
       #5  sys_clk <= !sys_clk ;
    end
    
    initial begin
       adc_clk  <= 1'b0  ;
       adc_rstn <= 1'b0  ;
       repeat(10) @(posedge adc_clk);
          adc_rstn <= 1'b1  ;
    end
    
    always begin
       #4  adc_clk <= !adc_clk ;
    end
    
        //execute bench
    initial begin
    fork
        sine();
        begin
        wait (sys_rstn)
        
        //system
        @(posedge sys_clk)
            i_bus.bus_write(32'h8, 32'h1);
        @(posedge sys_clk)
            i_bus.bus_read(32'h8);
        @(posedge sys_clk)
                        i_bus.bus_read(32'h0);
        #50000;
        
        @(posedge sys_clk)
            i_bus.bus_write(32'h8, 32'h0);
        
        end
    join
end
    
    //input sine
    task sine;
        reg     [31: 0] cnt        ;
        reg     [31: 0] sin_cnt    ;
        real            sin_time   ;
        real            sin_a      ;
        integer         sin_aa     ;
        real            sin_cnta   ;
        reg    [31: 0] freq       ;
        //wire     [31: 0] freq = 32'd979553945
    begin
        freq     <= 32'h20000;
        cnt      <= 32'h0   ;
        sin_cnt  <= 0       ;
    
        #20
    
        while ( cnt < 100000 ) 
        begin
    
            @(posedge sys_clk) 
            begin
                cnt <= cnt + 1  ;
                if (cnt > 32'd10) 
                begin
                    sin_cnt  = sin_cnt + freq         ;
    //                $display("sin_cnt %b", sin_cnt);
                    sin_cnta = {1'b0,sin_cnt[31:22]} ;
    //                $display("sin_cnta %d", sin_cnt[31:22])       ;
                    sin_time = sin_cnta/1024 * 2 *  3.141592           ;
                    sin_a    = $sin(sin_time) * 10000  ;
                    sin_aa   = sin_a ;
                end
    
               in_sig <= $signed(sin_aa[13:0]);
           end
        end
    end
    endtask
 
endmodule
