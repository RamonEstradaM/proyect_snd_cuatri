`timescale 1ns / 1ps

module control_pid #(
    parameter int KP = 10,  // proportional
    parameter int KI = 0,    // integrated
    parameter int KD = 2    // deriavtive
)(
    input  logic clk, 
    input  logic rst_n,
    input  logic [7:0]  grades,         // Setpoint deseado (0 - 180)
    input  logic [7:0]  measure_grades, // Posición actual (0 - 180)
    output logic [17:0] duty_out        // Salida al PWM
);

    // Señales de control
    logic signed [31:0] error_reg;
    logic signed [31:0] error_prev;
    logic signed [31:0] error_comb;   
    logic signed [31:0] integral;
    logic signed [31:0] derivative;
    logic signed [31:0] next_control_val;
    logic signed [31:0] duty_base;

    // Límites del PWM para un reloj de 50MHz (1ms a 2ms)
    localparam signed [31:0] MIN_DUTY = 50000;
    localparam signed [31:0] MAX_DUTY = 100000;
    
    // Límites para el error acumulado
    localparam signed [31:0] INT_MAX = 200000;
    localparam signed [31:0] INT_MIN = -200000;

    // 1. Mapeo de grados a Duty Cycle (Feed-Forward)
    // Se multiplica por 278 ya que el rango es 50,000 y hay 180 grados.
    assign duty_base = MIN_DUTY + (grades * 278);

    // 2. Cálculo del error en grados
    assign error_comb = $signed({1'b0, grades}) - $signed({1'b0, measure_grades});

    // 3. Lógica combinacional para la ecuación PID
    // Se utiliza duty_base (equivalente a tu gtob_out mapeado) como punto de partida
    always_comb begin
        next_control_val = duty_base + (KP * error_reg) + (KI * integral) + (KD * derivative);
    end
    
    // 4. Lógica secuencial
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            integral   <= 0;      
            error_reg  <= 0;
            error_prev <= 0;
            derivative <= 0;
            duty_out   <= 18'd50000; // Reset a 90 grados (posición central)
        end else begin
            
            // Cálculo del error derivativo y actualización de errores
            derivative <= error_comb - error_prev;
            error_prev <= error_reg;
            error_reg  <= error_comb;

            // Cálculo del error integral con Anti-Windup
            if (next_control_val <= MAX_DUTY && next_control_val >= MIN_DUTY) begin
                if (integral + error_comb <= INT_MAX && integral + error_comb >= INT_MIN)
                    integral <= integral + error_comb;
            end

            // Aplicación de límites de saturación y asignación de salida
            if (next_control_val > MAX_DUTY)      
                duty_out <= MAX_DUTY[17:0];
            else if (next_control_val < MIN_DUTY) 
                duty_out <= MIN_DUTY[17:0];
            else                                 
                duty_out <= next_control_val[17:0];
        end
    end

endmodule
