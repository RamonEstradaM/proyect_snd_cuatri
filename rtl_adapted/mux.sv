`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2026 10:56:26 PM
// Design Name: 
// Module Name: mux
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


module mux(

	input logic current_high,
	input logic [17:0] duty_out,
	output logic [17:0] pwm_in
);


	always_comb begin
		if (current_high)
			pwm_in = 18'b0;
		else
			pwm_in = duty_out;
	end
endmodule
