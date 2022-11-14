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


// valid_i如要打拍，则data_i也需要打拍。每次valid_i_reg为1表示进来2个有效数据
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
    output reg              valid_o = 'd0,
    output reg [DWIDTH-1:0] data_o = 'd0,

    // up-stream
    output                  ready_o,
    input                   valid_i,
    input  [DWIDTH-1:0]     data_i   
);

wire input_trig, output_trig;
reg  valid_i_reg = 'd0;
reg  ready_o_reg = 'd0;
reg  [DWIDTH-1:0] data_i_reg;


assign input_trig   = ready_o & valid_i_reg;
assign output_trig  = ready_i & valid_o;
assign ready_o      = ~valid_o | ready_i;

always @(posedge aclk_i) begin
    valid_i_reg <= valid_i;
end

always @(posedge aclk_i) begin
    // 这里可以添加其他运算，尽量将此1个时钟周期的延时利用起来
    if(ready_o)
        data_i_reg <= data_i + 1'b1;
    else 
        data_i_reg <= data_i_reg;
end



always @(posedge aclk_i) begin
    if(input_trig) begin
        // 数据处理以加1为例，可扩展到其他功能，如是多周期的复杂逻辑，最好使用状态机实现
        data_o  <= data_i_reg + 1'b1;
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