vlib work
vlog ../rtl/ltc2308_spi_controller.v
vlog ltc2308_model.v
vlog tb_ltc2308_spi_controller.v
vsim work.tb_ltc2308_spi_controller

add wave -divider "Clock and reset"
add wave -label clock                  /tb_ltc2308_spi_controller/clock
add wave -label reset_n                /tb_ltc2308_spi_controller/reset_n

add wave -divider "Control"
add wave -label start                  /tb_ltc2308_spi_controller/start
add wave -label requested_channel      -radix unsigned /tb_ltc2308_spi_controller/requested_channel
add wave -label busy                   /tb_ltc2308_spi_controller/busy
add wave -label done                   /tb_ltc2308_spi_controller/done

add wave -divider "LTC2308 SPI bus"
add wave -label adc_convst             /tb_ltc2308_spi_controller/adc_convst
add wave -label adc_sck                /tb_ltc2308_spi_controller/adc_sck
add wave -label adc_sdi                /tb_ltc2308_spi_controller/adc_sdi
add wave -label adc_sdo                /tb_ltc2308_spi_controller/adc_sdo

add wave -divider "Internal state"
add wave -label state                  -radix unsigned /tb_ltc2308_spi_controller/device_under_test/state
add wave -label bit_counter            -radix unsigned /tb_ltc2308_spi_controller/device_under_test/bit_counter
add wave -label receive_shift_register -radix binary   /tb_ltc2308_spi_controller/device_under_test/receive_shift_register

add wave -divider "Output"
add wave -label sample                 -radix unsigned /tb_ltc2308_spi_controller/sample
add wave -label sample_channel         -radix unsigned /tb_ltc2308_spi_controller/sample_channel

run -all
wave zoom full