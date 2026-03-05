module top (
    input  wire clk,          // 100 MHz board clock
    input  wire rst_n,        // active low reset

    // SPI ADC pins
    input  wire adc_miso,
    output wire adc_cs_n,
    output wire adc_sclk,

    // UART output
    output wire uart_tx
);

    // =====================================
    // Internal Signals
    // =====================================
    wire sample_tick;
    wire [11:0] sample;
    wire sample_valid;

    wire [11:0] fifo_data;
    wire fifo_empty;
    wire fifo_full;
    wire fifo_rd_en;

    wire tx_start;
    wire [7:0] tx_data;
    wire tx_busy;

    // =====================================
    // Sample Tick Generator
    // =====================================
    sample_tick_gen #(
        .CLK_FREQ_HZ(100_000_000),
        .SAMPLE_RATE_HZ(1_000)
    ) tick_gen (
        .clk(clk),
        .rst_n(rst_n),
        .sample_tick(sample_tick)
    );

    // =====================================
    // ADC Interface
    // =====================================
    adc_interface adc_inst (
        .clk(clk),
        .rst_n(rst_n),
        .sample_tick(sample_tick),
        .miso(adc_miso),
        .sample(sample),
        .sample_valid(sample_valid),
        .cs_n(adc_cs_n),
        .sclk(adc_sclk)
    );

    // =====================================
    // FIFO
    // =====================================
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

    // =====================================
    // UART Controller
    // =====================================
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

    // =====================================
    // UART TX (REAL BAUD)
    // =====================================
    uart_tx #(
        .CLK_FREQ_HZ(100_000_000),
        .BAUD_RATE(115200)
    ) uart_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(uart_tx),
        .tx_busy(tx_busy)
    );

endmodule