module control_pid #(
    parameter int KP = 100,
    parameter int KI = 1,
    parameter int KD = 10
)(
    input  logic clk, rst_n,
    input  logic [11:0] gtob_out, position_b_out,
    output logic [17:0] duty_out
);

    // Señales de control y estados
    logic signed [31:0] error, last_error, control_val, integral, derivative;
    logic signed [31:0] next_control_val;

    // Parámetros PWM y límites del integrador
    localparam signed [31:0] MIN_DUTY = 50000, OFFSET = 75000, MAX_DUTY = 100000;
    localparam signed [31:0] INT_MAX = 200000, INT_MIN = -200000;

    // Cálculo combinacional del PID
    always_comb begin
        next_control_val = OFFSET + (KP * error) + (KI * integral) + (KD * derivative);
    end

    // Lógica secuencial
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            integral   <= 0;
            last_error <= 0;
            error      <= 0;
            derivative <= 0;
            duty_out   <= OFFSET[17:0]; // Reset al centro (90°)
            control_val <= OFFSET;
        end else begin
            // 1. Actualizar Error y Derivada
            error      <= $signed({1'b0, gtob_out}) - $signed({1'b0, position_b_out});
            derivative <= error - last_error;
            last_error <= error;

            // 2. Anti-windup: Integrar solo si la salida no está saturada
            if (next_control_val < MAX_DUTY && next_control_val > MIN_DUTY) begin
                if (integral + error <= INT_MAX && integral + error >= INT_MIN)
                    integral <= integral + error;
            end

            // 3. Aplicar saturación y actualizar salida
            control_val <= next_control_val;
            if (next_control_val > MAX_DUTY)      duty_out <= MAX_DUTY[17:0];
            else if (next_control_val < MIN_DUTY) duty_out <= MIN_DUTY[17:0];
            else                                 duty_out <= next_control_val[17:0];
        end
    end
endmodule

