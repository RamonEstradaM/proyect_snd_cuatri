module current_monitor(
	input logic clk,
	input logic rst_n,
	input real measure_current,
	output logic current_high
);
	logic [11:0] current_b_out;

	adc adc_current(
		.analog_in(measure_current),
		.digital_out(current_b_out)
	);

	current_process current_process_top(
		.clk(clk),
		.rst_n(rst_n),
		.current_b_out(current_b_out),
		.current_high(current_high)
	);

endmodule

