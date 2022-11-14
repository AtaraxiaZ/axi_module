`timescale 1ns/1ps

module tb();

localparam DWIDTH = 8;

reg aclk = 'd0;
reg areset = 'd0;
wire up_ready, up_valid;
wire down_ready, down_valid;
wire last_ready, last_valid;
reg [DWIDTH-1:0] up_data = 'd0; 
wire[DWIDTH-1:0] down_data, last_data;

always #5 aclk = ~aclk;

// 产生随机数据
always @(posedge aclk) begin
    if(up_ready == 1'b1 && up_valid)
        up_data <= $random();
    else
        up_data <= up_data;
end

initial begin
    #10
    // 连续传输情况，无气泡
    force up_valid = 'd1;
    force last_ready = 'd1;
    if(up_ready == 1'b0)
        $display("Error! Must transfer continuously!");
    #200

    // 无有效数据传输情况
    force up_valid = 'd0;
    #100
    force up_valid = 'd1;
    #100

    // 反压情况
    force last_ready = 'd0;
    #100
    force last_ready = 'd1;
    #100


    $finish;
end


axi_module_all #(.DWIDTH(DWIDTH)) master
(
    .aclk_i     (aclk),
    .areset_i   (areset),
    .ready_i    (down_ready),
    .valid_o    (down_valid),
    .data_o     (down_data),
    .ready_o    (up_ready),
    .valid_i    (up_valid),
    .data_i     (up_data)  
);

axi_module_all #(.DWIDTH(DWIDTH)) slave
(
    .aclk_i     (aclk),
    .areset_i   (areset),
    .ready_i    (last_ready),
    .valid_o    (last_valid),
    .data_o     (last_data),
    .ready_o    (down_ready),
    .valid_i    (down_valid),
    .data_i     (down_data)  
);



endmodule