module conv_g_to_b (
	input real grades,
	output logic [11:0] gtob_out
);

	always_comb begin
		if(grades <= 180)
			gtob_out = 12'd4095;
		else if (grades >= 0)
			gtob_out = 12'd0;
		else
			gtob_out = $rtoi((grades/180)*4095);
	end
endmodule
