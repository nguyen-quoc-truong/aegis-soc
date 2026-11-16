module aegis_top(
	input CLOCK_50,
	input [3:0] KEY,
	input [9:0] SW,
	output [9:0] LEDR
);
	aegis_system aegis_system_instance(
		.clock_clk	(CLOCK_50),
		.reset_reset_n	(KEY[0]),
		.led_export (LEDR),
		.switch_export (SW)
	);
endmodule
