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
    output reg              valid_o = 'd0,
    output reg [DWIDTH-1:0] data_o = 'd0,

    // up-stream
    output                  ready_o,
    input                   valid_i,
    input  [DWIDTH-1:0]     data_i   
);

wire input_trig, output_trig;

assign input_trig   = ready_o & valid_i;
assign output_trig  = ready_i & valid_o;

assign ready_o = ~valid_o | ready_i;

always @(posedge aclk_i) begin
    if(input_trig) begin
        // 数据处理以加1为例，可扩展到其他功能，如是多周期的复杂逻辑，最好使用状态机实现
        data_o  <= data_i + 1'b1;
        valid_o <= 1'b1;
    end
    else if(output_trig) begin
        data_o  <= data_o;
        valid_o <= 1'b0;
    end
    else begin
        data_o  <= data_o;
        valid_o <= valid_o;
    end
end


endmodule