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
// ready需要打拍的代码

`timescale  1ns/1ps
// ready_i打拍进来，但仍然可用ready_i
// 反压无法立即传到到上个模块，必须逐级打拍反压了
// 输出是一级级出的，去已经发送出去的就找不回来
module axi_module_ready #(
    parameter DWIDTH = 8
)
(
    input                   aclk_i,
    input                   areset_i,

    // down-stream
    input                   ready_i,
    output                  valid_o,
    output  [DWIDTH-1:0]    data_o,

    // up-stream
    output                  ready_o,
    input                   valid_i,
    input  [DWIDTH-1:0]     data_i   
);

reg [DWIDTH-1:0]    expansion_data_reg;
reg                 expansion_valid_reg;
reg                 ready_i_reg;
reg [DWIDTH-1:0]    data_reg;
reg                 valid_reg;

// 不再是用之前的~valid_o | ready_i
assign  ready_o = ~expansion_valid_reg;
assign  data_o  = expansion_valid_reg ? expansion_data_reg : data_reg;
// 只要expansion里有valid数据或上游有valid数据，输出就是valid
assign  valid_o = expansion_valid_reg | valid_reg;

always @(posedge aclk_i) begin
    if(areset_i) begin
        data_reg            <= 'd0;
        valid_reg           <= 'd0;
        expansion_data_reg  <= 'd0;
        expansion_valid_reg <= 'd0;
    end
    else begin
        if(ready_o) begin
            data_reg    <= data_i + 1'b1;
            valid_reg     <= valid_i;
            if(~ready_i) begin
                expansion_data_reg  <= data_reg;
                expansion_valid_reg <= valid_reg;
            end
        end
        // 当下游准备好接收时，需要清空expansion valid
        if(ready_i)
            expansion_valid_reg <= 'd0;
    end
end






endmodule