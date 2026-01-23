module top_servo_tb();
	bit clk;
	logic rst_n;
	real grades;
	real measure_current;
	real measure_grades;
	logic pwm_out;

	//instansiation
	
	top_servo top_servo_sim(
		.clk(clk),
		.rst_n(rst_n),
		.grades(grades),
		.measure_current(measure_current),
		.measure_grades(measure_grades),
		.pwm_out(pwm_out)
	);

	always #5ns clk = ~clk;

		initial begin
			rst_n = 0;
			grades = 0;
			measure_current = 0;
			measure_grades = 0;
			#20ns;
			rst_n=1;

		end



		initial begin
			#50ns;
			$finish;
		end

		initial begin
			$shm_open("shm_db");
			$shm_probe("ASMTR");
		end


endmodule
