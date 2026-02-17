module top_servo_cov(
	top_servo_interface intf  // se instancian los puertos de la interfaz
);

    covergroup cg_servo @(posedge intf.clk);
        option.per_instance = 1;

        cp_consigna: coverpoint int'(intf.grades) {
            bins extreme[] = {0, 180};
            bins medium_grades = {90};
            bins ranges[6] = {[0:180]};
        }

        cp_pos_real: coverpoint int'(intf.measure_grades) {
            bins ranges[6] = {[0:180]};
       }

        cp_current: coverpoint intf.measure_current {
            bins normal_current = {[0 : 3.0]};
            bins fail_ current  = {[3.1 : 5.0]};
        }

        cp_jumps: coverpoint int'(intf.grades) {
            bins min_a_max = (0 => 180);
            bins max_a_min = (180 => 0);
        }
    endgroup

    //instanstiation covergroup
    cg_servo cvr = new();

endmodule: top_servo_cov
