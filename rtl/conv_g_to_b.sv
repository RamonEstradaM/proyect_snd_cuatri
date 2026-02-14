module conv_g_to_b (
	input real grades,
	output logic [17:0] gtob_out
);

	always_comb begin
		if(grades >= 180)
			gtob_out = 18'd10000;
		else if (grades <=  0)
			gtob_out = 18'd5000;
		else
			gtob_out = 18'd5000 + $rtoi(grades*27.777777);//(10000-5000)/(180-0)=27.777777
	end
endmodule
