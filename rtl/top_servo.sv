module top_servo(
	input logic clk,
	input logic rst_n,
	input logic [7:0] position,
	output logic pwm_signal

);

	logic [7:0] currently_position;
	logic [15:0] pid_out;
	logic [15:0] duty_final;

	sensor_reader sensor();

	control_pid pid();
	
	pwm pwm _control();

	current_monitor detection();
		

endmodule
