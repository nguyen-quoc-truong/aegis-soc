module averager(
    input   iClock,
    input   iReset_n,
    input   iClear,
    input   [2:0]   iExponent,
    input   iValid,
    input   [11:0]  iSample,
    output  reg [11:0]  oAverage,
    output  reg oAverageValid
);
    reg [18:0] accumulator;
    reg [7:0]  sample_counter;
    wire [18:0] sum_next = accumulator + {7'd0, iSample};
    wire [7:0]  last_sample_index = (8'd1 << iExponent) - 8'd1;
    wire [18:0] shifted_sum = sum_next >> iExponent;
    
    always @(posedge iClock, negedge iReset_n)
    begin
        if (~iReset_n)
        begin
            accumulator <= 19'd0;
            sample_counter <= 8'd0;
            oAverage <= 12'd0;
            oAverageValid <= 1'b0;
        end
        else
        begin
            oAverageValid <= 1'b0;
            if (iClear)
            begin
                accumulator <= 19'd0;
                sample_counter <= 8'd0;
            end
            else if (iValid)
            begin
                if (sample_counter >= last_sample_index)
                begin
                    oAverage <= shifted_sum[11:0];
                    oAverageValid <= 1'b1;
                    accumulator <= 19'd0;
                    sample_counter <= 8'd0;
                end
                else
                begin
                    accumulator <= sum_next;
                    sample_counter <= sample_counter + 8'd1;
                end
            end
        end
    end
endmodule