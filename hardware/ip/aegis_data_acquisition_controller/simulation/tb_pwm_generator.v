`timescale 1ns/1ps
module tb_pwm_generator();
    localparam CLOCK_PERIOD_NANOSECONDS = 20;

    reg clock;
    reg reset_n;
    reg enable;
    reg [15:0] period;
    reg [15:0] duty;
    reg force_off;
    wire pwm;
    integer pass_count;
    integer fail_count;
    integer high_cycles;
    integer cycle_index;

    pwm_generator device_under_test(
        .iClock (clock),
        .iReset_n (reset_n),
        .iEnable (enable),
        .iPeriod (period),
        .iDuty (duty),
        .iForceOff (force_off),
        .oPwm (pwm)
    );

    initial
    begin
        clock = 1'b0;
        forever #(CLOCK_PERIOD_NANOSECONDS/2) clock = ~clock;
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
    task wait_for_period_start;
        begin
            @(negedge clock);
            while (device_under_test.counter != 16'd0)
            begin
                @(negedge clock);
            end
        end
    endtask
    task measure_one_period;
        input integer period_cycles;
        output integer measured_high_cycles;
        begin
            wait_for_period_start;
            measured_high_cycles = 0;
            for (cycle_index = 0; cycle_index < period_cycles; cycle_index = cycle_index + 1)
            begin
                @(negedge clock);
                if (pwm)
                begin
                    measured_high_cycles = measured_high_cycles + 1;
                end
            end
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
        reset_n = 1'b0;
        enable = 1'b0;
        force_off = 1'b0;
        period = 16'd100;
        duty = 16'd0;

        wait_cycles(5);
        reset_n = 1'b1;
        @(negedge clock);
        enable = 1'b1;

        wait_cycles(250);
        measure_one_period(100, high_cycles);
        check("TC1 duty 0 percent", high_cycles, 0);

        duty = 16'd50;
        wait_cycles(250);
        measure_one_period(100, high_cycles);
        check("TC2 duty 50 percent", high_cycles, 50);

        duty = 16'd100;
        wait_cycles(250);
        measure_one_period(100, high_cycles);
        check("TC3 duty 100 percent", high_cycles, 100);

        duty = 16'd150;
        wait_cycles(250);
        measure_one_period(100, high_cycles);
        check("TC4 duty greater than period", high_cycles, 100);

        duty = 16'd20;
        wait_cycles(250);
        wait_for_period_start;
        high_cycles = 0;
        for (cycle_index=0; cycle_index<100; cycle_index=cycle_index + 1)
        begin
            @(negedge clock);
            if (cycle_index == 50)
            begin
                duty = 16'd80;
            end
            if (pwm)
            begin
                high_cycles = high_cycles + 1;
            end
        end
        check("TC5 current period keeps old duty", high_cycles, 20);
        measure_one_period(100, high_cycles);
        check("TC5 next period uses new duty", high_cycles, 80);
        duty = 16'd100;
        wait_cycles(250);
        force_off = 1'b1;
        @(negedge clock);
        check("TC6 force off after one clock cycle", pwm, 0);
        wait_cycles(200);
        check("TC6 output stays low while forced off", pwm, 0);
        force_off = 1'b0;
        enable = 1'b0;
        wait_cycles(5);
        check("TC7 output low when disabled", pwm, 0);
        period = 16'd0;
        duty   = 16'd10;
        wait_cycles(5);
        enable = 1'b1;
        wait_cycles(50);
        check("TC8 output low when period is 0", pwm, 0);
        $display("");
        $display("pwm_generator: %0d PASS, %0d FAIL", pass_count, fail_count);
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