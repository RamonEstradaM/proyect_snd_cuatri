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
        
        // Simulación del motor en background
        fork
            intf.run_motor_sim(0.1);
        join_none

        // TC-07: Movimiento a 90 grados
        intf.move_to(90.0);
        #100ms;

        // TC-18: Prueba de falla de corriente
        intf.force_fault(5.0);
        #30ms; // Tiempo suficiente para que actúe la protección de 20ms

        $finish;
    end

    // Aserciones de validación automática
    `define DUTY_REG top_servo_sim.control_pid_inst.duty_out
    
    property p_pwm_range;
        @(posedge clk) (intf.rst_n) |-> (`DUTY_REG >= 50000 && `DUTY_REG <= 100000);
    endproperty
    assert property (p_pwm_range);

endmodule
