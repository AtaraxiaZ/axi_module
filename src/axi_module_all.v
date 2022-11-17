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

// 将前面2种情况结合起来，需要额外注意data_i_reg的条件
module axi_module_all #(
    parameter DWIDTH = 8
)
(
    input                   aclk_i,
    input                   areset_i,

    // down-stream
    input                   ready_i,
    output                  valid_o,
    output [DWIDTH-1:0]     data_o,

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
reg [DWIDTH-1:0]    data_i_reg;
reg                 valid_i_reg;


// 不再是用之前的~valid_o | ready_i
assign  ready_o = ~expansion_valid_reg;
assign  data_o  = expansion_valid_reg ? expansion_data_reg : data_reg;
// 只要expansion里有valid数据或上游有valid数据，输出就是valid
assign  valid_o = expansion_valid_reg | valid_reg;

// 只有ready_o的时候才可以冲掉数据！
always @(posedge aclk_i) begin
    if(ready_o) begin
        data_i_reg  <= data_i + 1'b1;
        valid_i_reg <= valid_i;
    end
    else begin
        data_i_reg  <= data_i_reg;
        valid_i_reg <= valid_i_reg;
    end
end

always @(posedge aclk_i) begin
    if(areset_i) begin
        data_reg            <= 'd0;
        valid_reg           <= 'd0;
        expansion_data_reg  <= 'd0;
        expansion_valid_reg <= 'd0;
    end
    else begin
        if(ready_o) begin
            data_reg    <= data_i_reg + 1'b1;
            valid_reg   <= valid_i_reg;
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