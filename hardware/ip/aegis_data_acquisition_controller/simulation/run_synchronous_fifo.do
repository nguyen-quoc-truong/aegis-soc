vlib work
vlog ../rtl/synchronous_fifo.v
vlog tb_synchronous_fifo.v
vsim work.tb_synchronous_fifo

add wave -divider "Clock and reset"
add wave -label clock         /tb_synchronous_fifo/clock
add wave -label reset_n       /tb_synchronous_fifo/reset_n

add wave -divider "Write"
add wave -label write_enable  /tb_synchronous_fifo/write_enable
add wave -label write_data    -radix unsigned /tb_synchronous_fifo/write_data

add wave -divider "Read"
add wave -label read_enable   /tb_synchronous_fifo/read_enable
add wave -label read_data     -radix unsigned /tb_synchronous_fifo/read_data

add wave -divider "Internal state"
add wave -label write_pointer -radix unsigned /tb_synchronous_fifo/device_under_test/write_pointer
add wave -label read_pointer  -radix unsigned /tb_synchronous_fifo/device_under_test/read_pointer

add wave -divider "Status"
add wave -label count         -radix unsigned /tb_synchronous_fifo/count
add wave -label empty         /tb_synchronous_fifo/empty
add wave -label half_full     /tb_synchronous_fifo/half_full
add wave -label full          /tb_synchronous_fifo/full

run -all
wave zoom full