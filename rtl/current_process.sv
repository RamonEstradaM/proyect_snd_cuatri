module current_process#(
	parameter [11:0] CURRENT_MAX = 12'd2500, //current in 2V
	parameter int TIME_LIMIT = 5000 //cycles of wait before of off
)(
	input logic clk,
	input logic rst_n,
	input logic [11:0] current_b_out,
	output logic current_high
);
	int time_current_high;
	
	always_ff @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			time_current_high <= 0;
			current_high <= 1'b1;
		end else begin
			if (CURRENT_MAX > current_b_out)begin
				if(time_current_high > TIME_LIMIT)begin
					current_high <= 1'b1;
				end
			end else 
				time_current_high <= time_current_high + 1;
			end
	end
endmodule
