module adc_interface (
    input  wire clk,
    input  wire rst_n,
    input  wire sample_tick,
    input  wire miso,

    output wire [11:0] sample,
    output wire sample_valid,
    output wire cs_n,
    output wire sclk
);

    spi_adc_master spi_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(sample_tick),
        .miso(miso),
        .cs_n(cs_n),
        .sclk(sclk),
        .sample(sample),
        .sample_valid(sample_valid)
    );

endmodule