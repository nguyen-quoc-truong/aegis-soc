`timescale 1ns/1ps
module tb_averager();
    localparam CLOCK_PERIOD_NANOSECONDS = 20;
    reg clock;
    reg reset_n;
    reg clear;
    reg [2:0] exponent;
    reg valid;
    reg [11:0] sample_value;
    wire [11:0] average;
    wire average_valid;
    integer pass_count;
    integer fail_count;
    integer valid_count;
    integer last_average;
    integer index;
    
    averager device_under_test(
        .iClock (clock),
        .iReset_n   (reset_n),
        .iClear (clear),
        .iExponent  (exponent),
        .iValid (valid),
        .iSample    (sample_value),
        .oAverage   (average),
        .oAverageValid (average_valid)
    );
    initial
    begin
        clock = 1'b0;
        forever #(CLOCK_PERIOD_NANOSECONDS/2) clock = ~clock;
    end

    always @(posedge clock)
    begin
        if (average_valid)
        begin
            valid_count  = valid_count + 1;
            last_average = average;
        end
    end
    task check;
        input [8*48-1:0] name;
        input integer   actual;
        input integer   expected;
        begin
            if (actual == expected)
            begin
                $display("PASS  %0s : %0d", name, actual);
                pass_count = pass_count + 1;
            end
            else
            begin
                $display("FAIL  %0s : got %0d, expected %0d", name, actual, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask
    task send_sample;
        input [11:0] value;
        begin
            @(negedge clock);
            sample_value = value;
            valid = 1'b1;
            @(negedge clock);
            valid = 1'b0;
        end
    endtask
    task start_block;
        input [2:0] new_exponent;
        begin
            @(negedge clock);
            exponent = new_exponent;
            clear = 1'b1;
            @(negedge clock);
            clear = 1'b0;
            valid_count = 0;
            last_average = -1;
        end
    endtask
    task wait_cycles;
        input integer count;
        begin
            repeat (count) @(negedge clock);
        end
    endtask
    
    initial
    begin
        pass_count = 0;
        fail_count = 0;
        valid_count = 0;
        last_average = -1;
        reset_n = 1'b0;
        clear = 1'b0;
        exponent = 3'd0;
        valid = 1'b0;
        sample_value = 12'd0;
        wait_cycles(5);
        check("TC1 average after reset", average, 0);
        check("TC1 average valid after reset", average_valid, 0);
        reset_n = 1'b1;
        start_block(3'd0);
        send_sample(12'd100);
        send_sample(12'd2000);
        send_sample(12'd4095);
        wait_cycles(3);
        check("TC2 exponent 0: result count", valid_count, 3);
        check("TC2 exponent 0: last result", last_average, 4095);
        start_block(3'd2);
        for (index=0; index<4; index=index + 1)
        begin
            send_sample(12'd1234);
        end
        wait_cycles(3);
        check("TC3 exponent 2: average", last_average, 1234);
        check("TC3 exponent 2: result count", valid_count, 1);
        start_block(3'd4);
        for (index=0; index<16; index=index + 1)
        begin
            send_sample(12'd1234);
        end
        wait_cycles(3);
        check("TC4 exponent 4: average", last_average, 1234);
        check("TC4 exponent 4: result count", valid_count, 1);
        start_block(3'd7);
        for (index=0; index<128; index=index + 1)
        begin
            send_sample(12'd4095);
        end
        wait_cycles(3);
        check("TC5 exponent 7, maximum input: average", last_average, 4095);
        check("TC5 exponent 7: result count", valid_count, 1);

        start_block(3'd4);
        for (index=0; index<16; index=index + 1)
        begin
            if (index%2)
            begin
                send_sample(12'd3300);
            end
            else
            begin
                send_sample(12'd0);
            end
        end
        wait_cycles(3);
        check("TC6 alternating 0 and 3300: average", last_average, 1650);
        start_block(3'd1);
        send_sample(12'd1);
        send_sample(12'd2);
        wait_cycles(3);
        check("TC7 rounding down: average of 1 and 2", last_average, 1);
        start_block(3'd2);
        send_sample(12'd4000);
        send_sample(12'd4000);
        start_block(3'd2);
        for (index=0; index<4; index=index + 1)
        begin
            send_sample(12'd1000);
        end
        wait_cycles(3);
        check("TC8 clear in the middle: average", last_average, 1000);
        check("TC8 clear in the middle: result count", valid_count, 1);
        start_block(3'd3);
        for (index=0; index<16; index=index + 1)
        begin
            send_sample(12'd500);
        end
        wait_cycles(3);
        check("TC9 exponent 3, 16 samples: result count", valid_count, 2);
        $display("");
        $display("averager: %0d PASS, %0d FAIL", pass_count, fail_count);
        $display("");
        $stop;
    end
    initial
    begin
        #200000;
        $display("TIMEOUT");
        $stop;
    end

endmodule