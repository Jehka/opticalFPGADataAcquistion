`timescale 1ns/1ps

module tb_full_system;

reg clk = 0;
reg rst_n = 0;

always #5 clk = ~clk;   // 100 MHz

initial begin
    rst_n = 0;
    #50;
    rst_n = 1;
end

wire sample_tick;

wire [11:0] sample;
wire sample_valid;

reg miso = 0;
wire cs_n;
wire sclk;

wire [11:0] fifo_data;
wire fifo_empty;
wire fifo_full;
wire fifo_rd_en;

wire tx;
wire tx_busy;
wire tx_start;
wire [7:0] tx_data;

sample_tick_gen #(
    .CLK_FREQ_HZ(100_000_000),
    .SAMPLE_RATE_HZ(1000)
) tick_gen (
    .clk(clk),
    .rst_n(rst_n),
    .sample_tick(sample_tick)
);

adc_interface adc_inst (
    .clk(clk),
    .rst_n(rst_n),
    .sample_tick(sample_tick),
    .miso(miso),
    .sample(sample),
    .sample_valid(sample_valid),
    .cs_n(cs_n),
    .sclk(sclk)
);

fifo_buffer #(
    .DATA_WIDTH(12),
    .DEPTH(16)
) fifo_inst (
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(sample_valid),
    .wr_data(sample),
    .full(fifo_full),
    .rd_en(fifo_rd_en),
    .rd_data(fifo_data),
    .empty(fifo_empty)
);

uart_controller uart_ctrl (
    .clk(clk),
    .rst_n(rst_n),
    .fifo_data(fifo_data),
    .fifo_empty(fifo_empty),
    .fifo_rd_en(fifo_rd_en),
    .tx_busy(tx_busy),
    .tx_start(tx_start),
    .tx_data(tx_data)
);

uart_tx #(
    .CLK_FREQ_HZ(10_000_000),
    .BAUD_RATE(1_000_000)
) uart_inst (
    .clk(clk),
    .rst_n(rst_n),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(tx),
    .tx_busy(tx_busy)
);

reg [11:0] adc_data = 12'b1010_1100_1111;
integer bit_index;

always @(negedge cs_n) begin
    miso <= adc_data[11];
    bit_index <= 10;
end

always @(negedge sclk) begin
    if (!cs_n) begin
        miso <= adc_data[bit_index];
        bit_index <= bit_index - 1;
    end
end

initial begin
    #5_000_000;
    $finish;
end

endmodule