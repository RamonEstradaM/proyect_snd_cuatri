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
