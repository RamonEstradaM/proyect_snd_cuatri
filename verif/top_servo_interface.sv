interface top_servo_interface(input logic clk);
    logic        rst_n;
    real         grades;
    real         measure_current;
    real         measure_grades;
    logic        pwm_out;

    task rst_n_dut();
        rst_n <= 1'b0;
        #100ns;
        rst_n <= 1'b1;
    endtask

    task move_to(input real target);
        @(posedge clk);
        grades <= target;
    endtask

    task value_current(input real value);
        @(posedge clk);
        measure_current <= value;
    endtask

    task run_motor_sim(input real speed);
        forever begin
            @(posedge clk);
            if (rst_n) begin
                if (measure_grades < grades - 0.5)      measure_grades <= measure_grades + speed;
                else if (measure_grades > grades + 0.5) measure_grades <= measure_grades - speed;
            end
        end
    endtask
endinterface
