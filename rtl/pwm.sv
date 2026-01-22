module pwm #(
	parameter CLK_IN = 50_000_000, //Input clock(50MHz)
	parameter FREQ_SERVO = 50     //Pulse time of 20ms, for that 1/20ms = 50Hz

)(
	input logic clk,         //System clock
	input logic rst_n,       //Reset
       	input logic [17:0] duty, //Total pulse width or maximum
	output logic pwm_out     //Out direct to servo

);

	localparam TOTAL_PERIOD = CLK_IN/FREQ_SERVO;  //50MHz/50Hz = Number of cycles = 1,000,000 cycles, for created pulse of 20ms i
	
	logic [19:0] counter; //bits for counter until 1,000,000

	always_ff@(posedge clk or negedge rst_n)begin
		if (!rst_n) begin                   //if counter in zero each reset low
			counter <= '0;
			pwm_out <= 1'b0;
		end else begin
			if (counter < TOTAL PERIOD - 1)begin
				counter <= counter + 1;
			end else begin
				counter <= '0;
			end

  		pwm_out <= (counter < duty); //if duty is mayor that counter pwm_out=1, else pwm_out=0

         	end

	end

endmodule

