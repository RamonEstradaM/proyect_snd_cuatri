module control_pid #(
    parameter int KP = 30,  //proportional gain
    parameter int KI = 0,    //integral gain
    parameter int KD = 5   //derivative gain
)(
    input logic clk, 
    input logic rst_n,
    input logic [11:0] gtob_out, //desired position
    input logic [11:0] position_b_out, //current position 
    output logic [17:0] duty_out //final value for the input of PWM
);

    // control signals or states
    logic signed [31:0] error_reg;
  	logic signed [31:0] error_comb;  
 
        logic signed [31:0] control_val; 
	logic signed [31:0] integral;
    logic signed [31:0] derivative;
    logic signed [31:0] next_control_val;

    // position parameters in the 0, 90 and 180 grades
    localparam signed [31:0] MIN_DUTY = 5000, OFFSET = 7500, MAX_DUTY = 10000;
    //maximum and minimum limits for the integrated or acumulate error
    localparam signed [31:0] INT_MAX = 200000, INT_MIN = -200000;

    assign error_comb = $signed({1'b0, gtob_out}) - $signed({1'b0, position_b_out});

    // combinational logic for the obtention of control PID
    always_comb begin
        next_control_val = OFFSET + (KP * error_reg) + (KI * integral) + (KD * derivative);
    end

    // secuential logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            integral   <= 0;
           
            error_reg      <= 0;
            derivative <= 0;
            duty_out   <= OFFSET[17:0]; // reset to center
        end else begin
            // calculated derivative error and currently error
            error_reg  <= error_comb;
            derivative <= error_comb - error_reg;

	    //calculated integral error and anti-windup
            if (next_control_val < MAX_DUTY && next_control_val > MIN_DUTY) begin
                if (integral + error_comb <= INT_MAX && integral + error_comb >= INT_MIN)
                    integral <= integral + error_comb;
            end

            //aplication limits and assign of duty out
            if (next_control_val > MAX_DUTY)      duty_out <= MAX_DUTY[17:0];
            else if (next_control_val < MIN_DUTY) duty_out <= MIN_DUTY[17:0];
            else                                 duty_out <= next_control_val[17:0];
        end
    end
endmodule
