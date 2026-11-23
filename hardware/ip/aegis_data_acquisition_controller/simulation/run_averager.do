vlib work
vlog ../rtl/averager.v
vlog tb_averager.v
vsim work.tb_averager

add wave -divider "Clock and reset"
add wave -label clock          /tb_averager/clock
add wave -label reset_n        /tb_averager/reset_n

add wave -divider "Input"
add wave -label clear          /tb_averager/clear
add wave -label exponent       -radix unsigned /tb_averager/exponent
add wave -label valid          /tb_averager/valid
add wave -label sample_value   -radix unsigned /tb_averager/sample_value

add wave -divider "Internal state"
add wave -label accumulator    -radix unsigned /tb_averager/device_under_test/accumulator
add wave -label sample_counter -radix unsigned /tb_averager/device_under_test/sample_counter

add wave -divider "Output"
add wave -label average_valid  /tb_averager/average_valid
add wave -label average        -radix unsigned /tb_averager/average

run -all
wave zoom full