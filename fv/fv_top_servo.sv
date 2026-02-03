module fv_top_servo(
	input logic clk, 
	input logic rst_n,
	input logic grades,
	input real  measure_current,
	input real  measure_grades,
	input logic pwm_out
);

	test_cases : assert property(@(posedge clk) full |-> wren == 1'b0);

	test_cases_1 : assert property(@(posedge clk) empty |-> wren == 1'b1);

	test_cases_2 : assert property(@(posedge clk) full |-> wren == 1'b1);


endmodule
