module aegis_top(
	input CLOCK_50,
	input [3:0] KEY,
	input [3:0] SW,
	output [9:0] LEDR
);

	aegis_system u0(
		.clk_clk	(CLOCK_50),
		.reset_reset_n	(KEY[0]),
		.led_external_connection_export (LEDR),
		.sw_external_connection_export (SW)
	);

endmodule
