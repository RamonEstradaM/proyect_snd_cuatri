module fv_top_servo(
	input logic clk, 
	input logic rst_n,
	input logic current_high,
	input logic [17:0] pwm_in,
	input logic [11:0] gtob_out
);

	assert_safety: assert property (@(posedge clk) disable iff (!rst_n)
		current_high|->(pwm_in == 18'b0)
	);

	assert_max_limit: assert property(@(posedge clk) disable iff (!rst_n)

		(pwm_in <= 18'd10000)
	);
	assert_reset_position: assert property(@(posedge clk)

		(!rst_n|->pwm_in == 18'b0 )
	);

endmodule
