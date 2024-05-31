//~ `New testbench
`timescale  1ns / 1ps

module tb_cdc_4phase;

typedef logic [63:0] T;
// cdc_4phase Parameters
parameter SRC_PERIOD          = 10   ;
parameter DEST_PERIOD          = 16   ;
parameter DECOUPLED       = 1'b0 ;
parameter SEND_RESET_MSG  = 1'b0 ;
parameter RESET_MSG       = T'('0);


// cdc_4phase Inputs
reg   logic src_rst_ni                     = 0 ;
reg   logic src_clk_i                      = 0 ;
reg   T     src_data_i                     = 0 ;
reg   logic src_valid_i                    = 0 ;
reg   logic dst_rst_ni                     = 0 ;
reg   logic dst_clk_i                      = 0 ;
reg   logic dst_ready_i                    = 0 ;

// cdc_4phase Outputs
wire  logic src_ready_o                    ;
wire  T     dst_data_o                     ;
wire  logic dst_valid_o                    ;


initial begin
    $dumpfile("tb_cdc_4phase.vcd");
    $dumpvars(0, tb_cdc_4phase);
end


initial
begin
    forever #(SRC_PERIOD/2)  src_clk_i=~src_clk_i;
end
initial
begin
    forever #(DEST_PERIOD/2)  dst_clk_i=~dst_clk_i;
end

initial
begin
    src_clk_i <= 0;
    dst_clk_i <= 0;
    #(SRC_PERIOD*2) src_rst_ni  =  1; dst_rst_ni <= 1;
end

cdc_4phase #(
    .DECOUPLED      ( DECOUPLED      ),
    .SEND_RESET_MSG ( SEND_RESET_MSG ),
    .RESET_MSG      ( RESET_MSG      ))
 u_cdc_4phase (
    .src_rst_ni        ( src_rst_ni    ),
    .src_clk_i         ( src_clk_i     ),
    .src_data_i        ( src_data_i    ),
    .src_valid_i       ( src_valid_i   ),
    .dst_rst_ni        ( dst_rst_ni    ),
    .dst_clk_i         ( dst_clk_i     ),
    .dst_ready_i       ( dst_ready_i   ),

    .src_ready_o       ( src_ready_o   ),
    .dst_data_o        ( dst_data_o    ),
    .dst_valid_o       ( dst_valid_o   )
);

initial
begin
    src_data_i <= 64'h12345678;
    dst_ready_i <= 1;
    #32
    src_valid_i <= 1;
    #(SRC_PERIOD)
    src_valid_i <= 0;
    #(SRC_PERIOD*200) 
    $finish;
end

endmodule