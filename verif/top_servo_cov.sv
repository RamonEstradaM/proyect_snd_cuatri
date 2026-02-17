module top_servo_cov(
	top_servo_interface intf  // se instancian los puertos de la interfaz
);

    covergroup cg_servo @(posedge intf.clk);
        option.per_instance = 1;
        option.name = "Reporte_Cobertura_Servo";

        // Cobertura de Grados Solicitados
        cp_consigna: coverpoint int'(intf.grades) {
            bins extremos[] = {0, 180};
            bins medio     = {90};
            bins rangos[6] = {[0:180]};
        }

        // Cobertura de Posición Real (ADC)
        cp_pos_real: coverpoint int'(intf.measure_grades) {
            bins rangos[6] = {[0:180]};
        }

        // Cobertura de Corriente
        cp_corriente: coverpoint intf.measure_current {
            bins normal = {[0 : 3.0]};
            bins falla  = {[3.1 : 5.0]};
        }

        // Transiciones críticas para validar el PID
        cp_saltos: coverpoint int'(intf.grades) {
            bins min_a_max = (0 => 180);
            bins max_a_min = (180 => 0);
        }
    endgroup

    // Instancia obligatoria del covergroup
    cg_servo cvr = new();

endmodule: top_servo_cov
