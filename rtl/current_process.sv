module current_process#(
	parameter [11:0] CURRENT_MAX = 12'd2500, //current in 2V
	parameter TIME_LIMIT = 1000000 //cycles of wait before of off 20ms
)(
	input logic clk,
	input logic rst_n,
	input logic [11:0] current_b_out,
	output logic current_high
);
	logic [($clog2(TIME_LIMIT + 1))-1 : 0] time_current_high;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			time_current_high <= 0;
			current_high <= 1'b0;
		end else begin
			//there is overcurrent
			if (current_b_out > CURRENT_MAX) begin
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
