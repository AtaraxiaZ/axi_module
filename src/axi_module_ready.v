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
    output reg              valid_o = 'd0,
    output reg [DWIDTH-1:0] data_o = 'd0,

    // up-stream
    output                  ready_o,
    input                   valid_i,
    input  [DWIDTH-1:0]     data_i   
);

wire input_trig, output_trig;
reg  ready_i_reg;
reg  [DWIDTH-1:0] data_temp;
reg  ready_flag;

assign input_trig   = ready_o & valid_i;
assign output_trig  = ready_i & valid_o;

assign ready_o = ~valid_o | ready_i_reg;

always @(posedge aclk_i) begin
    ready_i_reg <= ready_i;
end

// 出现ready_i_reg = 1，ready_i = 0的处理
always @(posedge aclk_i) begin
    if(input_trig && ~ready_i) begin
        ready_flag  <= 1'b1;
        data_temp   <= data_i;
    end
    else if(ready_i) begin
        ready_flag  <= 1'b0;
        data_temp   <= 'd0;
    end
end

always @(posedge aclk_i) begin
    if(input_trig && ready_i) begin
        valid_o <= 1'b1;
        data_o  <= data_i + 1'b1;            
    end
    else if(input_trig && ~ready_i) begin
        data_o  <= data_o;
        valid_o <= valid_o;
    end
    else if(~ready_i_reg && ready_i) begin
        if(ready_flag) begin
            data_o  <= data_temp + 1'b1;
            valid_o <= 1'b1;
        end
        else begin
            data_o  <= data_i + 1'b1;
            valid_o <= 1'b1;
        end
    end
    else if(~valid_i)begin
        valid_o <= 1'b0;
        data_o  <= data_o;
    end
end



endmodule