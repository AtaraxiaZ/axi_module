//////////////////////////////////////////////////////////////////////////////////
// Engineer:
// 
// Create Date: 2022/11/13 16:16:32
// Design Name: 
// Module Name: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 要求1的模块代码

`timescale  1ns/1ps

module axi_module #(
    parameter DWIDTH = 8
)
(
    input                   aclk_i,
    input                   areset_i,

    // down-stream
    input                   ready_i,
    output reg              valid_o,
    output reg [DWIDTH-1:0] data_o,

    // up-stream
    output                  ready_o,
    input                   valid_i,
    input  [DWIDTH-1:0]     data_i   
);

assign ready_o = ~valid_o | ready_i;

always @(posedge aclk_i) begin
    if(areset_i) begin
        valid_o <= 'd0;
        data_o  <= 'd0;
    end
    else begin
        valid_o <= valid_i;
        data_o  <= data_i + 1'b1;
    end
end


endmodule