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

endinterface
