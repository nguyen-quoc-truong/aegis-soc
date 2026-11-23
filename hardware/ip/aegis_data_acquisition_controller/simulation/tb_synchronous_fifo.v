`timescale 1ns/1ps
module tb_synchronous_fifo();
    localparam CLOCK_PERIOD_NANOSECONDS = 20;
    localparam DEPTH = 256;
    localparam WIDTH = 15;
    reg clock;
    reg reset_n;
    reg write_enable;
    reg [WIDTH-1:0] write_data;
    reg read_enable;
    wire [WIDTH-1:0] read_data;
    wire [8:0]  count;
    wire empty;
    wire half_full;
    wire full;
    integer pass_count;
    integer fail_count;
    integer index;
    integer order_errors;
    reg [WIDTH-1:0] read_value;

    synchronous_fifo device_under_test(
        .iClock (clock),
        .iReset_n (reset_n),
        .iWriteEnable (write_enable),
        .iWriteData (write_data),
        .iReadEnable (read_enable),
        .oReadData (read_data),
        .oCount (count),
        .oEmpty (empty),
        .oHalfFull (half_full),
        .oFull (full)
    );
    initial
    begin
        clock = 1'b0;
        forever #(CLOCK_PERIOD_NANOSECONDS/2) clock = ~clock;
    end
        task check;
        input [8*48-1:0] name;
        input integer    actual;
        input integer    expected;
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
    task write_entry;
        input [WIDTH-1:0] value;
        begin
            @(negedge clock);
            write_data = value;
            write_enable = 1'b1;
            @(negedge clock);
            write_enable = 1'b0;
        end
    endtask
    task read_entry;
        output [WIDTH-1:0] value;
        begin
            @(negedge clock);
            value = read_data;
            read_enable = 1'b1;
            @(negedge clock);
            read_enable = 1'b0;
        end
    endtask
        initial
    begin
        pass_count   = 0;
        fail_count   = 0;
        order_errors = 0;
        reset_n      = 1'b0;
        write_enable = 1'b0;
        read_enable  = 1'b0;
        write_data   = 0;
        repeat (5) @(negedge clock);
        check("TC1 empty after reset", empty, 1);
        check("TC1 full after reset", full, 0);
        check("TC1 half full after reset", half_full, 0);
        check("TC1 count after reset", count, 0);
        check("TC1 read data when empty", read_data, 0);
        reset_n = 1'b1;
        write_entry(100);
        check("TC2 count after one write", count, 1);
        check("TC2 not empty after one write", empty, 0);
        check("TC2 show-ahead read data", read_data, 100);
        read_entry(read_value);
        for (index=0; index<DEPTH; index=index + 1)
        begin
            write_entry(index*3);
            if (index == 126)
            begin
                check("TC3 half full at 127 entries", half_full, 0);
            end
            if (index == 127)
            begin
                check("TC3 half full at 128 entries", half_full, 1);
            end
            if (index == 254)
            begin
                check("TC3 full at 255 entries", full, 0);
            end
        end
        check("TC3 full at 256 entries", full, 1);
        check("TC3 count at 256 entries", count, 256);
        write_entry(9999);
        check("TC4 write when full is ignored", count, 256);
        for (index=0; index<DEPTH; index=index + 1)
        begin
            read_entry(read_value);
            if (read_value != index*3)
            begin
                order_errors = order_errors + 1;
            end
        end
        check("TC4 data order after draining", order_errors, 0);
        check("TC4 empty after draining", empty, 1);
        read_entry(read_value);
        check("TC5 read when empty returns 0", read_value, 0);
        check("TC5 count stays 0", count, 0);
        write_entry(10);
        write_entry(20);
        write_entry(30);
        order_errors = 0;
        for (index=0; index<10; index=index + 1)
        begin
            @(negedge clock);
            if (read_data != 10*(index + 1))
            begin
                order_errors = order_errors + 1;
            end
            write_data   = 10*(index + 4);
            write_enable = 1'b1;
            read_enable  = 1'b1;
        end
        @(negedge clock);
        write_enable = 1'b0;
        read_enable  = 1'b0;
        check("TC6 count during simultaneous access", count, 3);
        check("TC6 data order during simultaneous access", order_errors, 0);
        $display("");
        $display("synchronous_fifo: %0d PASS, %0d FAIL", pass_count, fail_count);
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