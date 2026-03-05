module sample_tick_gen #(
    parameter CLK_FREQ_HZ     = 100_000_000,
    parameter SAMPLE_RATE_HZ  = 1_000
)(
    input  wire clk,
    input  wire rst_n,
    output reg  sample_tick
);

    localparam integer TICKS_PER_SAMPLE =
        CLK_FREQ_HZ / SAMPLE_RATE_HZ;

    reg [$clog2(TICKS_PER_SAMPLE)-1:0] cnt;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cnt <= 0;
            sample_tick <= 1'b0;
        end else begin
            if (cnt == TICKS_PER_SAMPLE-1) begin
                cnt <= 0;
                sample_tick <= 1'b1;
            end else begin
                cnt <= cnt + 1'b1;
                sample_tick <= 1'b0;
            end
        end
    end

endmodule