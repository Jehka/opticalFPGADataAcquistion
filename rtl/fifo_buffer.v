module fifo_buffer #(
    parameter DATA_WIDTH = 12,
    parameter DEPTH = 16
)(
    input  wire                  clk,
    input  wire                  rst_n,

    // write side
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] wr_data,
    output wire                  full,

    // read side
    input  wire                  rd_en,
    output reg  [DATA_WIDTH-1:0] rd_data,
    output wire                  empty
);

    localparam ADDR_WIDTH = $clog2(DEPTH);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH:0] wr_ptr;
    reg [ADDR_WIDTH:0] rd_ptr;

    assign empty = (wr_ptr == rd_ptr);

    assign full =
        (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) &&
        (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);

    // Write logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            wr_ptr <= 0;
        else if (wr_en && !full) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
            wr_ptr <= wr_ptr + 1'b1;
        end
    end

    // Read logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr  <= 0;
            rd_data <= 0;
        end else if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr[ADDR_WIDTH-1:0]];
            rd_ptr  <= rd_ptr + 1'b1;
        end
    end

endmodule