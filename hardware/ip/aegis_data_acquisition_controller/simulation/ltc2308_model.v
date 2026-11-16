`timescale 1ns/1ps
module ltc2308_model
#(
    parameter MINIMUM_CONVERSION_TIME_NANOSECONDS = 1600
)(
    input iCONVST,
    input iSCK,
    input iSDI,
    output oSDO
);
    reg [5:0] received_configuration;
    reg [5:0] previous_configuration;
    reg [2:0] received_bit_count;
    reg [2:0] conversion_channel;
    reg [11:0] output_shift_register;
    reg conversion_in_progress;
    time conversion_start_time;

    assign oSDO = output_shift_register[11];
    initial
    begin
        received_configuration = 6'b100010;
        previous_configuration = 6'b100010;
        received_bit_count = 3'd0;
        conversion_channel = 3'd0;
        output_shift_register = 12'd0;
        conversion_start_time = 0;
        conversion_in_progress = 1'b0;
    end
    function [2:0] decode_channel;
        input [5:0] configuration;
        begin
            decode_channel = {configuration[3], configuration[2], configuration[4]};
        end
    endfunction

    function [11:0] sample_for_channel;
        input [2:0] channel;
        begin
            sample_for_channel = 12'd1000 + channel*12'd100;
        end
    endfunction
    always @(posedge iCONVST)
    begin
        previous_configuration = received_configuration;
        conversion_channel = decode_channel(received_configuration);
        conversion_start_time = $time;
        conversion_in_progress = 1'b1;
        received_bit_count = 3'd0;
        if (received_configuration[5] != 1'b1 || received_configuration[1] != 1'b1)
        begin
            $display("[%0t] LTC2308 MODEL: configuration %b is not single-ended unipolar", $time, received_configuration);
        end
    end
    always @(negedge iCONVST)
    begin
        if (conversion_in_progress)
        begin
            if ($time - conversion_start_time < MINIMUM_CONVERSION_TIME_NANOSECONDS)
            begin
                $display("[%0t] LTC2308 MODEL ERROR: CONVST high for %0t ns, minimum is %0d ns", $time, $time - conversion_start_time, MINIMUM_CONVERSION_TIME_NANOSECONDS);
            end
            output_shift_register = sample_for_channel(conversion_channel);
            conversion_in_progress = 1'b0;
        end
    end
    always @(posedge iSCK)
    begin
        if (received_bit_count < 3'd6)
        begin
            received_configuration = {received_configuration[4:0], iSDI};
            received_bit_count = received_bit_count + 3'd1;
        end
    end
    always @(negedge iSCK)
    begin
        output_shift_register = {output_shift_register[10:0], 1'b0};
    end
endmodule
