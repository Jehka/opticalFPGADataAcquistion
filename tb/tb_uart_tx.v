`timescale 1ns/1ps

module tb_uart_tx;

reg clk = 0;
reg rst_n = 0;
reg tx_start = 0;
reg [7:0] tx_data = 8'hA5;

wire tx;
wire tx_busy;

always #5 clk = ~clk;   // 100 MHz clock

uart_tx #(
    .CLK_FREQ_HZ(10_000_000),
    .BAUD_RATE(1_000_000)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(tx),
    .tx_busy(tx_busy)
);

initial begin

    rst_n = 0;
    #50;
    rst_n = 1;

    #20;

    tx_start = 1;
    #10;
    tx_start = 0;

    #2000;

    $finish;

end

endmodule