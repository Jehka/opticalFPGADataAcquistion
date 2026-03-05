module tb_fifo_buffer;

    reg clk = 0;
    reg rst_n = 0;

    reg wr_en = 0;
    reg rd_en = 0;
    reg [11:0] wr_data = 0;

    wire [11:0] rd_data;
    wire full;
    wire empty;

    // 100 MHz clock
    always #5 clk = ~clk;

    // Instantiate FIFO
    fifo_buffer #(
        .DATA_WIDTH(12),
        .DEPTH(16)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .full(full),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .empty(empty)
    );

    // Test sequence
    initial begin
        // Reset
        rst_n = 0;
        #20;
        rst_n = 1;

        // -----------------------
        // WRITE 4 VALUES
        // -----------------------
        repeat (4) begin
            @(posedge clk);
            wr_en = 1;
            wr_data = wr_data + 1;
        end

        @(posedge clk);
        wr_en = 0;

        // -----------------------
        // READ 4 VALUES
        // -----------------------
        repeat (4) begin
            @(posedge clk);
            rd_en = 1;
        end

        @(posedge clk);
        rd_en = 0;

        #50;
        $finish;
    end

endmodule
