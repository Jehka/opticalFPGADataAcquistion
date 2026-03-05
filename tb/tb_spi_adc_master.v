module tb_adc_interface;

    // ================================
    // Clock and Reset
    // ================================
    reg clk = 0;
    reg rst_n = 0;

    always #5 clk = ~clk;   // 100 MHz clock

    // ================================
    // ADC Interface Signals
    // ================================
    reg  miso = 0;
    wire cs_n;
    wire sclk;

    wire [11:0] sample;
    wire sample_valid;

    wire sample_tick;

    // ================================
    // FIFO Signals
    // ================================
    wire [11:0] fifo_rd_data;
    wire fifo_empty;
    wire fifo_full;
    reg  fifo_rd_en = 0;

    // ================================
    // Instantiate Sample Tick Generator
    // ================================
    sample_tick_gen #(
        .CLK_FREQ_HZ(100_000_000),
        .SAMPLE_RATE_HZ(1_000)   // 1 kHz sampling
    ) tick_gen (
        .clk(clk),
        .rst_n(rst_n),
        .sample_tick(sample_tick)
    );

    // ================================
    // Instantiate ADC Interface
    // ================================
    adc_interface adc (
        .clk(clk),
        .rst_n(rst_n),
        .sample_tick(sample_tick),
        .miso(miso),
        .sample(sample),
        .sample_valid(sample_valid),
        .cs_n(cs_n),
        .sclk(sclk)
    );

    // ================================
    // Instantiate FIFO
    // ================================
    fifo_buffer #(
        .DATA_WIDTH(12),
        .DEPTH(16)
    ) fifo_inst (
        .clk(clk),
        .rst_n(rst_n),

        // Write side (ADC → FIFO)
        .wr_en(sample_valid),
        .wr_data(sample),
        .full(fifo_full),

        // Read side (FIFO → TB)
        .rd_en(fifo_rd_en),
        .rd_data(fifo_rd_data),
        .empty(fifo_empty)
    );

    // ================================
    // Reset Sequence
    // ================================
    initial begin
        rst_n = 0;
        #50;
        rst_n = 1;
    end

    // ================================
    // Fake ADC Model (SPI Mode 0)
    // ================================
    reg [11:0] adc_data = 12'b1010_1100_1111;
    integer bit_index;

    // When CS goes low, preload MSB
    always @(negedge cs_n) begin
        miso <= adc_data[11];
        bit_index <= 10;
    end

    // Shift out remaining bits on falling edge of sclk
    always @(negedge sclk) begin
        if (!cs_n) begin
            miso <= adc_data[bit_index];
            bit_index <= bit_index - 1;
        end
    end

    // ================================
    // FIFO Auto-Read Logic
    // ================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            fifo_rd_en <= 0;
        else
            fifo_rd_en <= !fifo_empty;
    end

    // ================================
    // Monitor FIFO Output
    // ================================
    always @(posedge clk) begin
        if (fifo_rd_en && !fifo_empty) begin
            $display("Time %0t : FIFO OUT = %b", $time, fifo_rd_data);
        end
    end

    // ================================
    // End Simulation After 10 ms
    // ================================
    initial begin
        #10_000_000;   // 10 ms simulation
        $finish;
    end

endmodule
