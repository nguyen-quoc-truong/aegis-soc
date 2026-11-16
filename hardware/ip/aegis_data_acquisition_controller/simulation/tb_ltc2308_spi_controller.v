`timescale 1ns/1ps

module tb_ltc2308_spi_controller();
    localparam CLOCK_PERIOD_NANOSECONDS = 20;
    reg clock;
    reg reset_n;
    reg start;
    reg [2:0] requested_channel;
    wire adc_convst;
    wire adc_sck;
    wire adc_sdi;
    wire adc_sdo;
    wire [11:0] sample;
    wire [2:0] sample_channel;
    wire done;
    wire busy;

    integer pass_count;
    integer fail_count;
    integer sck_rising_edge_count;
    integer done_pulse_cycles;
    time convst_rise_time;
    time convst_high_time;
    time first_sck_rise_time;
    time sck_period;

    ltc2308_spi_controller device_under_test(
        .iClock (clock),
        .iReset_n (reset_n),
        .iStart (start),
        .iChannel (requested_channel),
        .iADC_SDO (adc_sdo),
        .oADC_CONVST (adc_convst),
        .oADC_SCK (adc_sck),
        .oADC_SDI (adc_sdi),
        .oSample (sample),
        .oChannel (sample_channel),
        .oDone (done),
        .oBusy (busy)
    );
    ltc2308_model adc_model(
        .iCONVST (adc_convst),
        .iSCK (adc_sck),
        .iSDI (adc_sdi),
        .oSDO (adc_sdo)
    );

    initial
    begin
        clock = 1'b0;
        forever #(CLOCK_PERIOD_NANOSECONDS/2) clock = ~clock;
    end

    always @(posedge adc_convst)
    begin
        convst_rise_time = $time;
    end

    always @(negedge adc_convst)
    begin
        convst_high_time = $time - convst_rise_time;
    end

    always @(posedge adc_sck)
    begin
        sck_rising_edge_count = sck_rising_edge_count + 1;
        if (sck_rising_edge_count == 1)
        begin
            first_sck_rise_time = $time;
        end
        if (sck_rising_edge_count == 2)
        begin
            sck_period = $time - first_sck_rise_time;
        end
    end

    always @(posedge clock)
    begin
        if (done)
        begin
            done_pulse_cycles = done_pulse_cycles + 1;
        end
    end

    task check;
        input [8*48-1:0] name;
        input integer actual;
        input integer expected;
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

    task run_frame;
        input [2:0] channel;
        input insert_extra_start;
        begin
            sck_rising_edge_count = 0;
            done_pulse_cycles = 0;
            @(negedge clock);
            requested_channel = channel;
            start = 1'b1;
            @(negedge clock);
            start = 1'b0;
            if (insert_extra_start)
            begin
                repeat (20) @(negedge clock);
                requested_channel = 3'd2;
                start = 1'b1;
                @(negedge clock);
                start = 1'b0;
                requested_channel = channel;
            end
            @(posedge done);
            @(negedge clock);
            @(negedge clock);
        end
    endtask

    initial
    begin
        pass_count = 0;
        fail_count = 0;
        sck_rising_edge_count = 0;
        done_pulse_cycles = 0;
        reset_n = 1'b0;
        start = 1'b0;
        requested_channel = 3'd0;

        repeat (5) @(negedge clock);
        check("TC1 busy after reset", busy, 0);
		check("TC1 CONVST after reset", adc_convst, 0);
		check("TC1 SCK after reset", adc_sck, 0);
		reset_n = 1'b1;

        run_frame(3'd0, 1'b0);
		check("TC2 CONVST high time (nanoseconds)", convst_high_time, 1800);
		check("TC2 SCK rising edges per frame", sck_rising_edge_count, 12);
		check("TC2 SCK period (nanoseconds)", sck_period, 80);
		check("TC3 done pulse width (cycles)", done_pulse_cycles, 1);
		check("TC4 frame 1 sample", sample, 1000);
		check("TC4 frame 1 channel", sample_channel, 0);

        run_frame(3'd5, 1'b0);
		check("TC4 frame 2 sample (pipeline)", sample, 1000);
		check("TC4 frame 2 channel (pipeline)", sample_channel, 0);

        run_frame(3'd5, 1'b0);
		check("TC4 frame 3 sample", sample, 1500);
		check("TC4 frame 3 channel", sample_channel, 5);

        run_frame(3'd7, 1'b1);
		check("TC5 start while busy is ignored", done_pulse_cycles, 1);
		check("TC4 frame 4 sample", sample, 1500);
		check("TC4 frame 4 channel", sample_channel, 5);

        run_frame(3'd7, 1'b0);
		check("TC4 frame 5 sample", sample, 1700);
		check("TC4 frame 5 channel", sample_channel, 7);

        $display("\nltc2308_spi_controller: %0d PASS, %0d FAIL\n", pass_count, fail_count);
        $stop;
    end

    initial
	begin
        #100000;
        $display("TIMEOUT: done was never asserted");
        $stop;
    end
endmodule
