`timescale 1ns / 1ps

module control_pid #(
    parameter int KP = 10,  // proportional
    parameter int KI = 0,    // integrated
    parameter int KD = 2    // deriavtive
)(
    input  logic clk, 
    input  logic rst_n,
    input  logic [7:0]  grades,         // Setpoint desired (0 - 180)
    input  logic [7:0]  measure_grades, // currently position (0 - 180)
    output logic [17:0] duty_out        // Out for pwm
);

    // Signals control
    logic signed [31:0] error_reg;
    logic signed [31:0] error_prev;
    logic signed [31:0] error_comb;   
    logic signed [31:0] integral;
    logic signed [31:0] derivative;
    logic signed [31:0] next_control_val;
    logic signed [31:0] duty_base;

    // Limits under and over
    localparam signed [31:0] MIN_DUTY = 50000;
    localparam signed [31:0] MAX_DUTY = 100000;
    
    // Límis for the acumulated error
    localparam signed [31:0] INT_MAX = 200000;
    localparam signed [31:0] INT_MIN = -200000;

    
    //Mapped of grades to duty cycle
    assign duty_base = MIN_DUTY + (grades * 278);

    //eror calculated
    assign error_comb = $signed({1'b0, grades}) - $signed({1'b0, measure_grades});

    
    // Calculated control PID
    always_comb begin
        next_control_val = duty_base + (KP * error_reg) + (KI * integral) + (KD * derivative);
    end
    
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            integral   <= 0;      
            error_reg  <= 0;
            error_prev <= 0;
            derivative <= 0;
            duty_out   <= 18'd50000; // Reset to 0
        end else begin
            
            // calculated derivative error
            derivative <= error_comb - error_prev;
            error_prev <= error_reg;
            error_reg  <= error_comb;

            //error integral
            if (next_control_val <= MAX_DUTY && next_control_val >= MIN_DUTY) begin
                if (integral + error_comb <= INT_MAX && integral + error_comb >= INT_MIN)
                    integral <= integral + error_comb;
            end

           //limits of saturation
            if (next_control_val > MAX_DUTY)      
                duty_out <= MAX_DUTY[17:0];
            else if (next_control_val < MIN_DUTY) 
                duty_out <= MIN_DUTY[17:0];
            else                                 
                duty_out <= next_control_val[17:0];
        end
    end

endmodule
