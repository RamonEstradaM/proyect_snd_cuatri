`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2026 06:01:08 PM
// Design Name: 
// Module Name: top_wishbone
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top_wishbone#(
    parameter DW = 32,
    parameter AW = 16

)(
    input  logic             clk,
    input  logic             rst_n,

    // ---- Command interface ----
    input  logic [AW-1:0]   cmd_addr,
    input  logic [DW-1:0]   cmd_wdata,
    input  logic             cmd_we,
    input  logic             cmd_valid,
    output logic             cmd_ready,

    // ---- Response interface ----
    output logic [DW-1:0]   rsp_rdata,
    output logic             rsp_valid,
    output logic pwm_out,
    input  real               measure_grades,  
    input  real               measure_current
    
    
    );
    
    logic [15:0] wb_adr;
    logic [31:0] wdata_to_slave; // Datos del Master al Bridge
    logic [31:0] rdata_to_master; // Datos del Bridge al Master 
    logic        wb_we;     
    logic        wb_stb;    
    logic        wb_cyc;    
    logic        wb_ack;    
    logic [3:0]  wb_sel;
    logic wb_err;

    // ---- Interface con el Servo ----
    real         grades_cmd; 
    real        pos_actual;
    real        current_val;
    assign pos_actual = measure_grades; 
    assign current_val = measure_current;
    logic [17:0] duty_val;   
    logic [3:0]  status_bits;
    
    top_servo top_servo_wb(
        .clk(clk),
        .rst_n(rst_n),
        .grades(grades_cmd),
	    .measure_current(current_val),
	    .measure_grades(pos_actual),
	    .pwm_out(pwm_out),
	    .duty_out(duty_val)
    );
    
    bridge bridge_wb(
        .clk(clk),
        .rst_n(rst_n),
        .wb_adr(wb_adr),   
        .wb_dat_i(wdata_to_slave),  
        .wb_we(wb_we),     
        .wb_stb(wb_stb),    
        .wb_cyc(wb_cyc),   
        .wb_ack(wb_ack),   
        .wb_dat_o(rdata_to_master),  
        .grades_cmd(grades_cmd), 
        .pos_actual(pos_actual),  
        .current_val(current_val), 
        .duty_val(duty_val),    
        .status_bits(status_bits)
    );
    
    wb_master wb_master_top(
        .clk(clk),
        .rst_n(rst_n),
        .cmd_addr(cmd_addr),
        .cmd_wdata(cmd_wdata),
        .cmd_we(cmd_we),
        .cmd_valid(cmd_valid),
        .cmd_ready(cmd_ready),
        .rsp_rdata(rsp_rdata),
        .rsp_valid(rsp_valid),
        .wbm_adr_o(wb_adr),
        .wbm_dat_o(wdata_to_slave),
        .wbm_dat_i(rdata_to_master),
        .wbm_we_o(wb_we),
        .wbm_stb_o(wb_stb),
        .wbm_cyc_o(wb_cyc),
        .wbm_ack_i(wb_ack),
        .wbm_err_i(wb_err),
        .wbm_sel_o(wb_sel)
    );
 
endmodule
