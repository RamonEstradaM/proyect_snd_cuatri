`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2026 10:45:00 PM
// Design Name: 
// Module Name: top_servo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_servo(
	input logic clk,
	input logic rst_n,
	input logic [7:0] grades,
	input logic [4:0] measure_current,
	input logic [7:0] measure_grades,
	output logic pwm_out,
	output logic [17:0] duty_out

);
	logic current_high;
	
	logic [17:0] pwm_in;
	

	control_pid pid_top(
		.clk(clk),
		.rst_n(rst_n),
		.grades(grades),
		.measure_grades(measure_grades),
		.duty_out(duty_out)
	);

	mux mux_top(
		.current_high(current_high),
		.duty_out(duty_out),
		.pwm_in(pwm_in)
	);

	pwm pwm_top(
		.clk(clk),
		.rst_n(rst_n),
		.duty(pwm_in),
		.pwm_out(pwm_out)
	);

	current_monitor current_top(
		.clk(clk),
		.rst_n(rst_n),
		.measure_current(measure_current),
		.current_high(current_high)
	);
endmodule

