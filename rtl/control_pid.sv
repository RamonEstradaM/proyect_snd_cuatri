module control_pid #(
	//coeficients control PID 
	parameter int KP = 100,
	parameter int KI = 1,
	parameter int KD = 10

)(

	input logic clk,
	input logic rst_n,
	input logic [11:0] gtob_out,  //position desire
	input logic [11:0] position_b_out,           //feedback
	output logic [17:0] duty_out    //value for the pwm
);

	logic signed [31:0] error;
	logic signed [31:0] last_error;
	logic signed [31:0] control_val;
	logic signed [31:0] integral;
	logic signed [31:0] derivative;

	localparam signed [31:0] MIN_DUTY = 32'd50000; //in grades = 0
	localparam signed [31:0] OFFSET = 32'd75000; //in grades = 90
	localparam signed [31:0] MAX_DUTY= 32'd100000; // in grades = 180

	always_ff @(posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			integral <= 0;
			last_error <= 0;
			duty_out <= 18'd0; //return to center
		end else begin 
			error = $signed({1'b0, gtob_out}) - $signed({1'b0, position_b_out});

			integral <= integral + error;  //calculated integral error
			
			derivative = error - last_error;   //calculated derivated error
			
			last_error <= error;   //currently error to last_error in the next cycle

			control_val = OFFSET + (KP * error) + (KI * integral) + (KD * derivative);  //PID equation

			if (control_val > MAX_DUTY)  //protection for position max or min
				duty_out <= MAX_DUTY;
			else if (control_val < MIN_DUTY)
				duty_out <= MIN_DUTY;
			else
				duty_out <= control_val[17:0];
		end
	end
endmodule

