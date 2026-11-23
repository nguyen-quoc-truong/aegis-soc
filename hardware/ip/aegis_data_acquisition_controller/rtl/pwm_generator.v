module pwm_generator(
    input   iClock,
    input   iReset_n,
    input   iEnable,
    input   [15:0] iPeriod,
    input   [15:0] iDuty,
    input   iForceOff,
    output reg  oPwm
);

    reg [15:0] counter;
    reg [15:0] period_shadow;
    reg [15:0] duty_shadow;

    wire last_count = (period_shadow == 16'd0) || (counter >= period_shadow - 16'd1);

    always @(posedge iClock, negedge iReset_n)
    begin
        if (~iReset_n)
        begin
            counter <= 16'd0;
            period_shadow <= 16'd0;
            duty_shadow <= 16'd0;
            oPwm <= 1'b0;
        end
        else if (~iEnable)
        begin
            counter <= 16'd0;
            period_shadow <= iPeriod;
            duty_shadow <= iDuty;
            oPwm <= 1'b0;
        end
        else
        begin
            if (last_count)
            begin
                counter <= 16'd0;
                period_shadow <= iPeriod;
                duty_shadow <= iDuty;
            end
            else
            begin
                counter <= counter + 16'd1;
            end
            oPwm <= ~iForceOff && (period_shadow != 16'd0) && (counter < duty_shadow);
        end
    end
endmodule