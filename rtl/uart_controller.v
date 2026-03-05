module uart_controller (
    input  wire clk,
    input  wire rst_n,

    // FIFO side
    input  wire [11:0] fifo_data,
    input  wire fifo_empty,
    output reg  fifo_rd_en,

    // UART side
    input  wire tx_busy,
    output reg  tx_start,
    output reg  [7:0] tx_data
);

    localparam IDLE      = 3'd0;
    localparam READ_FIFO = 3'd1;
    localparam SEND_HIGH = 3'd2;
    localparam WAIT_HIGH = 3'd3;
    localparam SEND_LOW  = 3'd4;
    localparam WAIT_LOW  = 3'd5;

    reg [2:0] state;
    reg [11:0] sample_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            fifo_rd_en <= 0;
            tx_start <= 0;
            tx_data <= 0;
            sample_reg <= 0;
        end else begin

            // default pulses
            fifo_rd_en <= 0;
            tx_start <= 0;

            case (state)

                IDLE: begin
                    if (!fifo_empty)
                        state <= READ_FIFO;
                end

                READ_FIFO: begin
                    fifo_rd_en <= 1;      // 1-cycle read
                    state <= SEND_HIGH;
                end

                SEND_HIGH: begin
                    sample_reg <= fifo_data;
                    if (!tx_busy) begin
                        tx_data <= {4'b0000, fifo_data[11:8]};
                        tx_start <= 1;
                        state <= WAIT_HIGH;
                    end
                end

                WAIT_HIGH: begin
                    if (!tx_busy)
                        state <= SEND_LOW;
                end

                SEND_LOW: begin
                    if (!tx_busy) begin
                        tx_data <= sample_reg[7:0];
                        tx_start <= 1;
                        state <= WAIT_LOW;
                    end
                end

                WAIT_LOW: begin
                    if (!tx_busy)
                        state <= IDLE;
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule