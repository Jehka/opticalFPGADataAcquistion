module uart_tx #(
    parameter CLK_FREQ_HZ = 100_000_000,
    parameter BAUD_RATE   = 115200
)(
    input  wire clk,
    input  wire rst_n,
    input  wire tx_start,
    input  wire [7:0] tx_data,

    output reg  tx,
    output reg  tx_busy
);

    localparam CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;

    localparam IDLE  = 3'd0;
    localparam START = 3'd1;
    localparam DATA  = 3'd2;
    localparam STOP  = 3'd3;

    reg [2:0] state;
    reg [12:0] clk_cnt;
    reg [2:0] bit_index;
    reg [7:0] data_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            tx        <= 1'b1;
            tx_busy   <= 1'b0;
            clk_cnt   <= 0;
            bit_index <= 0;
            data_reg  <= 0;
        end else begin

            case (state)

                IDLE: begin
                    tx <= 1'b1;
                    tx_busy <= 1'b0;
                    clk_cnt <= 0;
                    bit_index <= 0;

                    if (tx_start) begin
                        tx_busy <= 1'b1;
                        data_reg <= tx_data;
                        state <= START;
                    end
                end

                START: begin
                    tx <= 1'b0;  // start bit

                    if (clk_cnt < CLKS_PER_BIT-1)
                        clk_cnt <= clk_cnt + 1;
                    else begin
                        clk_cnt <= 0;
                        state <= DATA;
                    end
                end

                DATA: begin
                    tx <= data_reg[bit_index];

                    if (clk_cnt < CLKS_PER_BIT-1)
                        clk_cnt <= clk_cnt + 1;
                    else begin
                        clk_cnt <= 0;
                        if (bit_index < 7)
                            bit_index <= bit_index + 1;
                        else begin
                            bit_index <= 0;
                            state <= STOP;
                        end
                    end
                end

                STOP: begin
                    tx <= 1'b1;  // stop bit

                    if (clk_cnt < CLKS_PER_BIT-1)
                        clk_cnt <= clk_cnt + 1;
                    else begin
                        clk_cnt <= 0;
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule