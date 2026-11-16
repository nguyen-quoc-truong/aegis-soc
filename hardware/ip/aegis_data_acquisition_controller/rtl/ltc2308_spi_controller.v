module ltc2308_spi_controller
#(
    parameter CONVERSION_CYCLES = 90,
    parameter SCK_HALF_PERIOD_CYCLES = 2
)(
    input iClock,
    input iReset_n,
    input iStart,
    input [2:0] iChannel,
    input iADC_SDO,
    output reg oADC_CONVST,
    output reg oADC_SCK,
    output reg oADC_SDI,
    output reg [11:0] oSample,
    output reg [2:0] oChannel,
    output reg oDone,
    output oBusy
);
    localparam BIT_COUNT = 12;
    localparam CONFIGURATION_BIT_COUNT = 6;
    localparam STATE_IDLE = 2'd0;
    localparam STATE_CONVERT = 2'd1;
    localparam STATE_TRANSFER = 2'd2;
    localparam STATE_DONE = 2'd3;

    reg [1:0] state;
    reg [7:0] conversion_counter;
    reg [3:0] half_period_counter;
    reg [3:0] bit_counter;
    reg [11:0] receive_shift_register;
    reg [5:0] configuration_word;
    reg [2:0] requested_channel;
    reg [2:0] configured_channel;

    assign oBusy = (state != STATE_IDLE);

    wire [5:0] next_configuration_word = {1'b1, iChannel[0], iChannel[2], iChannel[1], 1'b1, 1'b0};
    always @(posedge iClock, negedge iReset_n)
    begin
    if (~iReset_n)
    begin
        state <= STATE_IDLE;
        oADC_CONVST <= 1'b0;
        oADC_SCK <= 1'b0;
        oADC_SDI <= 1'b0;
        oSample <= 12'd0;
        oChannel <= 3'd0;
        oDone <= 1'b0;
        conversion_counter <= 8'd0;
        half_period_counter <= 4'd0;
        bit_counter <= 4'd0;
        receive_shift_register <= 12'd0;
        configuration_word <= 6'd0;
        requested_channel <= 3'd0;
        configured_channel <= 3'd0;
    end
    else
    begin
        oDone <= 1'b0;
        case (state)
            STATE_IDLE:
            begin
                oADC_SCK <= 1'b0;
                if (iStart)
                begin
                    requested_channel <= iChannel;
                    configuration_word <= next_configuration_word;
                    oADC_CONVST <= 1'b1;
                    conversion_counter <= 8'd0;
                    state <= STATE_CONVERT;
                end
            end
            STATE_CONVERT:
            begin
                if (conversion_counter == CONVERSION_CYCLES - 1)
                begin
                    oADC_CONVST <= 1'b0;
                    oADC_SDI <= configuration_word[5];
                    half_period_counter <= 4'd0;
                    bit_counter <= 4'd0;
                    state <= STATE_TRANSFER;
                end
                else
                begin
                    conversion_counter <= conversion_counter + 8'd1;
                end
            end
            STATE_TRANSFER:
            begin
                if (half_period_counter == SCK_HALF_PERIOD_CYCLES - 1)
                begin
                    half_period_counter <= 4'd0;
                    if (oADC_SCK == 1'b0)
                    begin
                        oADC_SCK <= 1'b1;
                        receive_shift_register <= {receive_shift_register[10:0], iADC_SDO};
                    end
                    else
                    begin
                        oADC_SCK <= 1'b0;
                        if (bit_counter == BIT_COUNT - 1)
                        begin
                            state <= STATE_DONE;
                        end
                        else
                        begin
                            bit_counter <= bit_counter + 4'd1;
                            oADC_SDI <= configuration_word[4];
                            configuration_word <= {configuration_word[4:0], 1'b0};
                        end
                    end
                end
                else
                begin
                    half_period_counter <= half_period_counter + 4'd1;
                end
            end
                STATE_DONE:
                begin
                    oSample <= receive_shift_register;
                    oChannel <= configured_channel;
                    configured_channel <= requested_channel;
                    oDone <= 1'b1;
                    oADC_SDI <= 1'b0;
                    state <= STATE_IDLE;
                end
                default:
                begin
                    state <= STATE_IDLE;
                end
            endcase
        end
    end
endmodule
