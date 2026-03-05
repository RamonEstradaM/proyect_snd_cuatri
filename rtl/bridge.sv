`timescale 1ns / 1ps

module bridge (
    input  logic        clk,
    input  logic        rst_n,

    // ---- Wishbone ports
    input  logic [15:0] wb_adr,   
    input  logic [31:0] wb_dat_i, 
    input  logic        wb_we,    
    input  logic        wb_stb,    
    input  logic        wb_cyc,    
    output logic        wb_ack,  
    output logic [31:0] wb_dat_o,  

    // ---- Interface with Servo ----
    output real         grades_cmd,  
    input  real         pos_actual, 
    input  real         current_val,
    input  logic [17:0] duty_val,    
    input  logic [3:0]  status_bits 
);
    real setpoint_reg;

    assign wb_ack = wb_stb && wb_cyc;

    // ---------------------------------------------------------
    //write master to bridge
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            setpoint_reg <= 0.0;
        end else if (wb_cyc && wb_stb && wb_we) begin
            case (wb_adr)           
                16'h00: setpoint_reg <= real'(wb_dat_i); 
                //add others values            
            endcase
        end
    end
    //read bridge to master
   
    always_comb begin
      
        if (wb_cyc && wb_stb && !wb_we) begin
            case (wb_adr)
                16'h00: wb_dat_o = 32'($rtoi(setpoint_reg)); // read setpoint
                16'h04: wb_dat_o = 32'($rtoi(pos_actual));   // read currently position
                16'h08: wb_dat_o = 32'($rtoi(current_val));  // read current
                16'h0C: wb_dat_o = {14'b0, duty_val};        // read duty
                16'h10: wb_dat_o = {28'b0, status_bits};     // read states
                default: wb_dat_o = 32'hDEADBEEF;            // directional error
            endcase
        end else begin
            wb_dat_o = 32'h0;
        end
    end

    assign grades_cmd = setpoint_reg;
    

endmodule
