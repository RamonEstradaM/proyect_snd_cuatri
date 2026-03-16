`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2026 10:57:56 PM
// Design Name: 
// Module Name: current_monitor
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


module current_monitor#(
	parameter [4:0] CURRENT_MAX = 5'd16, //overcurrent in 2.5V
	parameter TIME_LIMIT = 100000 //cycles of wait before of off 20ms
)(
	input logic clk,
	input logic rst_n,
	input logic [4:0] measure_current,
	output logic current_high
);
	logic [($clog2(TIME_LIMIT + 1))-1 : 0] time_current_high;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			time_current_high <= 0;
			current_high <= 1'b0;
		end else begin
			//there is overcurrent
			if (measure_current > CURRENT_MAX) begin
				if(TIME_LIMIT > time_current_high) begin
					time_current_high <= time_current_high + 1'b1;
					current_high <= 1'b0;
				end else begin
					current_high <= 1'b1;
				end
				//dont overcurrent
			end else begin
				time_current_high <= '0;
				current_high <= 1'b0;
			end
		end
	end
endmodule
