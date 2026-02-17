module top_servo_tb();
    bit clk;
    
    
    always #10ns clk = ~clk; 

    // instantiation interface
    top_servo_interface intf(clk);//

    // instantiation to top_servo_interface
    top_servo top_servo_sim(
        .clk(clk),
        .rst_n(intf.rst_n),
        .grades(intf.grades),
        .measure_current(intf.measure_current),
        .measure_grades(intf.measure_grades),
        .pwm_out(intf.pwm_out)
    );

    top_servo_cov cov_inst (
        .intf(intf)
    );

    fv_top_servo fv_top(
    	.clk(clk),
	.rst_n(rst_n),
	.current_high(top_servo_sim.current_high),
	.pwm_in(intf.pwm_out),
	.gtob_out(top_servo_sim.gtob_out)
    );

 
    initial begin
        $shm_open("shm_db");
        $shm_probe("ASMTR");
    end

    
    initial begin
        //initial signals in zero
        intf.measure_current = 0;
        intf.measure_grades = 0;
	intf.grades = 0;
        intf.rst_n_dut();
        
        // motor simulation with changes of grades of 0.1
        fork
            intf.run_motor_sim(0.7);
        join_none

	intf.current_peaks();
	#10ns;

        $finish;
    end

endmodule
