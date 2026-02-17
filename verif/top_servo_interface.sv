interface top_servo_interface(input logic clk);
    logic        rst_n;
    real         grades;
    real         measure_current;
    real         measure_grades;
    logic        pwm_out;

    //task for reset function
    task rst_n_dut();
        rst_n <= 1'b0;
        #100ns;
        rst_n <= 1'b1;
    endtask

    //task for indicated desire position
    task move_to(input real target); 
        @(posedge clk);
        grades <= target;
    endtask

    //task for indicated current value
    task value_current(input real value);
        @(posedge clk);
        measure_current <= value;
    endtask

    //task for indicated the movement speed of motor 
    task run_motor_sim(input real speed);
        forever begin
            #10us;
            if (rst_n) begin
                if (measure_grades < grades - 0.5)      
			measure_grades <= measure_grades + speed;
                else if (measure_grades > grades + 0.5) 
			measure_grades <= measure_grades - speed;
		else 
			measure_grades <= grades;
            end
        end
    endtask

  task wait_position_desire(input real target);
	  do begin
		@(posedge clk);
	end while (measure_grades < target - 1.5 || measure_grades > target + 1.5);
  endtask

  	task over_current();
	  $display("Test Case Over Current");
	  intf.move_to(90);
	  intf.wait_position_desire(90);

	  intf.value_current(5.5);
	  #5ms;

	  if(intf.pwm_out == 0)
		  $display("Test Case Over Current completed");
	  else
		  $error("Test Case Over Current Failed");
	  intf.value_current(0.0);
	endtask

	task over_limit();
		$display("Test Case Over Limit");
		intf.move_to(200.0);
		intf.wait_position_desire(200.0);
		#15ms;
		if(intf.measure_grades <= 181.0)
			$display("Test Case Over Limit completed");
		else
			$error("Test Case Over Limit Failed");

	endtask

	task under_limit();
                $display("Test Case Under Limit");
                intf.move_to(200.0);
                intf.wait_position_desire(-10.0);
                #15ms;
                if(intf.measure_grades >= -0.5)
                        $display("Test Case Under Limit completed");
                else
                        $error("Test Case Under Limit Failed");

        endtask

	task medium_point();
                $display("Test Case Medium Point");
                intf.move_to(90);
                intf.wait_position_desire(90);
                #15ms;
                if(intf.measure_grades >= 89.5 && intf.measure_grades <= 90.5)
                        $display("Test Case Medium Point completed");
                else
                        $error("Test Case Medium Point Failed");

        endtask


	task position_zero_stable();
		$display("Test Case Position Zero");
		intf.move_to(0.0);
		intf.wait_position_desire(0.0);
		#15ms;
		if(intf,measure_grades <= 0.5);
			$display("Test Case Position Zero Completed");
		else
			$error("Test Case Position Zero Failed");


	endtask

	task positive_negative_jump();
		$display("Test Case Positive Jump");
		intf.move_to(45.0);
		intf.wait_position_desire(45.0);
		intf.move_to(150.0);
                intf.wait_position_desire(150.0);
		intf.move_to(30.0);
                intf.wait_position_desire(30.0);
	endtask

	task movement_max();
		$display("Test Case Movement Task");
                intf.move_to(0.0);
                intf.wait_position_desire(0.0);
		#2ms;
                intf.move_to(180.0);
                intf.wait_position_desire(180.0);
		#2ms;
                intf.move_to(0.0);
                intf.wait_position_desire(0.0);
	endtask

	task current_peaks();
		$display("Test Case Current Peaks");
		intf.move_to(90.0);
                intf.wait_position_desire(90.0);
		#1ms;
		repeat(10) begin
			real random_current_value;
			random_current_value = $urandom_range(2,6);
			intf.value_current(random_current_value);
			#1ms;
			intf.value_current(2.0);
			#2ms;
			if(top_servo_sim.current_high == 0)
                   	     	$display("Test Case Current Peaks Completed");
                	else
                        	$error("Test Case Current Peaks Failed");
		end
	endtask







endinterface
