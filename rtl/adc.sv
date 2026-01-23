module adc #(
	parameter real V_MAX = 3.3, //3.3 for the current sensor and for sensor position 180
	parameter int BITS = 12 

)(
	input real analog_in,                 //input analogic of the sensors
	output logic [BITS-1:0] digital_out  // ADC output
);
	real scale_factor = 4095/V_MAX;
	always_comb begin
		if(analog_in >= V_MAX)
			digital_out = 12'd4095;
		else if (analog_in <= 0.0)
			digital_out = 12'd0;
		else
			digital_out = $rtoi(scale_factor*analog_in); //real to integer

	end

endmodule

