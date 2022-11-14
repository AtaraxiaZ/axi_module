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
// valid和ready都需要打拍的代码

`timescale  1ns/1ps

// 将前面2种情况结合起来
// 似乎axi_module就是对valid打一拍的情况了，毕竟题目原本就没说模块内要啥操作
// 同样，可以用valid_i和ready_i
module axi_module_all #(
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
reg  valid_i_reg, ready_i_reg;
reg  [DWIDTH-1:0] data_i_reg;
reg  [DWIDTH-1:0] data_temp;
reg  ready_flag;

assign input_trig   = ready_o & valid_i_reg;
assign output_trig  = ready_i & valid_o;

assign ready_o = ~valid_o | ready_i_reg;



always @(posedge aclk_i) begin
    valid_i_reg <= valid_i;
    ready_i_reg <= ready_i;
end

always @(posedge aclk_i) begin
    // 这里可以添加其他运算，尽量将此1个时钟周期的延时利用起来
    if(ready_o)
        data_i_reg <= data_i + 1'b1;
    else 
        data_i_reg <= data_i_reg;
end

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
        data_o  <= data_i_reg + 1'b1;            
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
            data_o  <= data_i_reg + 1'b1;
            valid_o <= 1'b1;
        end
    end
    else if(~valid_i)begin
        valid_o <= 1'b0;
        data_o  <= data_o;
    end
end



endmodule