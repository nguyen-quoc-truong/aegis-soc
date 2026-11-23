vlib work
vlog ../rtl/pwm_generator.v
vlog tb_pwm_generator.v
vsim work.tb_pwm_generator

add wave -divider "Clock and reset"
add wave -label clock         /tb_pwm_generator/clock
add wave -label reset_n       /tb_pwm_generator/reset_n

add wave -divider "Input"
add wave -label enable        /tb_pwm_generator/enable
add wave -label period        -radix unsigned /tb_pwm_generator/period
add wave -label duty          -radix unsigned /tb_pwm_generator/duty
add wave -label force_off     /tb_pwm_generator/force_off

add wave -divider "Internal state"
add wave -label counter       -radix unsigned /tb_pwm_generator/device_under_test/counter
add wave -label period_shadow -radix unsigned /tb_pwm_generator/device_under_test/period_shadow
add wave -label duty_shadow   -radix unsigned /tb_pwm_generator/device_under_test/duty_shadow

add wave -divider "Output"
add wave -label pwm           /tb_pwm_generator/pwm

run -all
wave zoom full