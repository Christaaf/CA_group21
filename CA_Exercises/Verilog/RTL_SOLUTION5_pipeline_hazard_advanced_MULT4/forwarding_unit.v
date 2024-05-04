module forwarding_unit 
(
    input wire WB__EX_MEM,
    input wire WB__MEM_WB,
    input wire mem_2_reg_EX_MEM,
    input wire [4:0] RD__EX_MEM,
    input wire [4:0] RD__MEM_WB,
    input wire [4:0] RS1__ID_EX,
    input wire [4:0] RS2__ID_EX,
    output reg [1:0] MUX_A,
    output reg [1:0] MUX_B
);


   // MEM hazards
   wire hazard_rs1_MEM = (WB__EX_MEM & ~mem_2_reg_EX_MEM & RS1__ID_EX == RD__EX_MEM & RD__EX_MEM != 5'b0);
   wire hazard_rs2_MEM = (WB__EX_MEM & ~mem_2_reg_EX_MEM & RS2__ID_EX == RD__EX_MEM & RD__EX_MEM != 5'b0);


   // WB hazards
   wire hazard_rs1_WB  = (~hazard_rs1_MEM & WB__MEM_WB & RS1__ID_EX == RD__MEM_WB & RD__MEM_WB != 5'b0);
   wire hazard_rs2_WB = (~hazard_rs2_MEM & WB__MEM_WB & RS2__ID_EX == RD__MEM_WB & RD__MEM_WB != 5'b0);


   assign MUX_A = {hazard_rs1_MEM, hazard_rs1_WB};
   assign MUX_B = {hazard_rs2_MEM, hazard_rs2_WB};


// assign MUX_A = reg_A;
// assign MUX_B = reg_B;

endmodule
