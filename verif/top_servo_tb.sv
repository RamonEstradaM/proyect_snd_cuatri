module top_servo_tb();
    bit clk;
    
    
    always #10ns clk = ~clk; //clock generate

    // instantiation interface
    servo_interface intf(clk);//

    // instantiation to top_servo_interface
    top_servo top_servo_sim(
        .clk(clk),
        .rst_n(intf.rst_n),
        .grades(intf.grades),
        .measure_current(intf.measure_current),
        .measure_grades(intf.measure_grades),
        .pwm_out(intf.pwm_out)
    );

 
    initial begin
        $shm_open("shm_db");
        $shm_probe("ASMTR");
    end

    
    initial begin
        //intital in signals in zero
        intf.measure_current = 0;
        intf.measure_grades = 0;
        intf.reset_dut();
        
        // motor simulation
        fork
            intf.run_motor_sim(0.1);
        join_none

        //Movement to 90 grades
        intf.move_to(90.0);
        #100ms;

        // test failed current
        intf.force_fault(5.0);
        #30ms; 

        $finish;
    end

    // assertions for position
    `define DUTY_REG top_servo_sim.control_pid_inst.duty_out
    
    property p_pwm_range;
        @(posedge clk) (intf.rst_n) |-> (`DUTY_REG >= 50000 && `DUTY_REG <= 100000);
    endproperty
    assert property (p_pwm_range);

endmodule
