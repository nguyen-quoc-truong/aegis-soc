module synchronous_fifo
#(
    parameter DEPTH = 256,
    parameter WIDTH = 15,
    parameter ADDRESS_WIDTH = 8
)(
    input   iClock,
    input   iReset_n,
    input   iWriteEnable,
    input   [WIDTH-1:0] iWriteData,
    input   iReadEnable,
    output  [WIDTH-1:0] oReadData,
    output  [ADDRESS_WIDTH:0]   oCount,
    output  oEmpty,
    output  oHalfFull,
    output  oFull
);
    reg [WIDTH-1:0] memory [0:DEPTH-1];
    reg [ADDRESS_WIDTH-1:0] write_pointer;
    reg [ADDRESS_WIDTH-1:0] read_pointer;
    reg [ADDRESS_WIDTH:0]   count;
    wire write_allowed = iWriteEnable && !oFull;
    wire read_allowed = iReadEnable && !oEmpty;
    assign oCount = count;
    assign oEmpty = (count == 0);
    assign oFull = (count == DEPTH);
    assign oHalfFull = (count >= DEPTH/2);
    assign oReadData = oEmpty ? {WIDTH{1'b0}} : memory[read_pointer];
    initial
    begin
        if ((1<<ADDRESS_WIDTH) != DEPTH)
        begin
            $display("ERROR synchronous_fifo: DEPTH (%0d) must equal 2^ADDRESS_WIDTH (%0d)", DEPTH, 1 << ADDRESS_WIDTH);
        end
    end
    always @(posedge iClock, negedge iReset_n)
    begin
        if (~iReset_n)
        begin
            write_pointer <= {ADDRESS_WIDTH{1'b0}};
            read_pointer <= {ADDRESS_WIDTH{1'b0}};
            count <= {(ADDRESS_WIDTH + 1){1'b0}};
        end
        else
        begin
            if (write_allowed)
            begin
                memory[write_pointer] <= iWriteData;
                write_pointer <= write_pointer + 1'b1;
            end
            if (read_allowed)
            begin
                read_pointer <= read_pointer + 1'b1;
            end
            if (write_allowed && !read_allowed)
            begin
                count <= count + 1'b1;
            end
            else if (!write_allowed && read_allowed)
            begin
                count <= count - 1'b1;
            end
        end
    end
endmodule