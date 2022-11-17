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
// valid需要打拍时的模块代码


// valid_i如要打拍，则data_i也需要打拍
// ready_o不需要打拍，因为与输入无关
`timescale  1ns/1ps

module axi_module_valid #(
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

reg                 valid_i_reg;
reg [DWIDTH-1:0]    data_reg;

assign ready_o = ~valid_o | ready_i;

always @(posedge aclk_i) begin
    data_reg    <= data_i + 1'b1;
    valid_i_reg <= valid_i;
end

always @(posedge aclk_i) begin
    if(areset_i) begin
        valid_o <= 'd0;
        data_o  <= 'd0;
    end
    else begin
        valid_o <= valid_i_reg;
        data_o  <= data_reg + 1'b1;
    end
end




endmodule