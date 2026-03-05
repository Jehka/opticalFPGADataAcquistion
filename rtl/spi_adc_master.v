module spi_adc_master (
    input  wire clk,
    input  wire rst_n,

    input  wire start,
    input  wire miso,

    output reg  cs_n,
    output reg  sclk,
    output reg [11:0] sample,
    output reg  sample_valid
);

    // FSM states
    localparam IDLE        = 3'd0;
    localparam ASSERT_CS   = 3'd1;
    localparam SHIFT_LOW   = 3'd2;
    localparam SHIFT_HIGH  = 3'd3;
    localparam DEASSERT_CS = 3'd4;
    localparam DONE        = 3'd5;

    reg [2:0] state;
    reg [3:0] bit_cnt;
    reg [11:0] shift_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= IDLE;
            cs_n         <= 1'b1;
            sclk         <= 1'b0;
            bit_cnt      <= 4'd0;
            shift_reg    <= 12'd0;
            sample       <= 12'd0;
            sample_valid <= 1'b0;
        end else begin

            sample_valid <= 1'b0; // default

            case (state)

                IDLE: begin
                    cs_n    <= 1'b1;
                    sclk    <= 1'b0;
                    bit_cnt <= 4'd0;
                    if (start)
                        state <= ASSERT_CS;
                end

                ASSERT_CS: begin
                    cs_n      <= 1'b0;
                    sclk      <= 1'b0;
                    shift_reg <= 12'd0;
                    bit_cnt   <= 4'd0;
                    state     <= SHIFT_LOW;
                end

                SHIFT_LOW: begin
                    cs_n  <= 1'b0;
                    sclk  <= 1'b0;
                    state <= SHIFT_HIGH;
                end

                SHIFT_HIGH: begin
                    cs_n <= 1'b0;
                    sclk <= 1'b1;

                    shift_reg <= {shift_reg[10:0], miso};
                    bit_cnt   <= bit_cnt + 1'b1;

                    if (bit_cnt == 4'd11)
                        state <= DEASSERT_CS;
                    else
                        state <= SHIFT_LOW;
                end

                DEASSERT_CS: begin
                    cs_n   <= 1'b1;
                    sclk   <= 1'b0;
                    sample <= shift_reg;
                    state  <= DONE;
                end

                DONE: begin
                    sample_valid <= 1'b1;
                    state        <= IDLE;
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule