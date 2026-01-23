module top_servo(
	input logic clk,
	input logic rst_n,
	input real grades,
	input real measure_current,
	input real measure_grades,
	output logic pwm_out

);


	logic [11:0] gtob_out;
	logic [11:0] position_b_out;
	logic current_high;
	logic [17:0] duty_out;
	logic [17:0] pwm_in;
	

	conv_g_to_b grades_top(
		.grades(grades),
		.gtob_out(gtob_out)
	);

	control_pid pid_top(
		.clk(clk),
		.rst_n(rst_n),
		.gtob_out(gtob_out),
		.position_b_out(position_b_out),
		.duty_out(duty_out)
	);

	mux mux_top(
		.current_high(current_high),
		.duty_out(pid_out),
		.pwm_in(pwm_in)
	);

	pwm pwm_top(
		.clk(clk),
		.rst_n(rst_n),
		.pwm_in(duty),
		.pwm_out(pwm_out)
	);

	current_monitor current_top(
		.clk(clk),
		.rst_n(rst_n),
		.measure_current(measure_current),
		.current_high(current_high)
	);

	adc #(.VMAX(180)) adc_position(
		.analog_in(measure_grades),
		.digital_out(position_b_out)
	);
endmodule
