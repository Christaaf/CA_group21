module forwarding_unit 
(
    input wire WB__EX_MEM,
    input wire WB__MEM_WB,
    input wire [4:0] RD__EX_MEM,
    input wire [4:0] RD__MEM_WB,
    input wire [4:0] RS1__ID_EX,
    input wire [4:0] RS2__ID_EX,
    output reg [1:0] MUX_A,
    output reg [1:0] MUX_B
);

reg [1:0] reg_A;
reg [1:0] reg_B;

always @(*) begin
    //Forwarding for RS1
    //EX_MEM rerouting
    if((WB__EX_MEM == 1) && (RD__EX_MEM != 0) && (RD__EX_MEM == RS1__ID_EX)) begin
        reg_A = 2'b10;
    end
    //MEM_WB rerouting
    else if( (WB__MEM_WB == 1 ) && ( RD__MEM_WB != 0 ) && ( ~(WB__EX_MEM == 1 && (RD__EX_MEM != 0 )) ) && (RD__EX_MEM == RS1__ID_EX) && (RD__MEM_WB == RS1__ID_EX) ) 
    begin
        reg_A = 2'b01;
    end
    else begin
        reg_A = 2'b00;
    end

    //Forwarding for RS2
    //EX_MEM rerouting
    if((WB__EX_MEM == 1) && (RD__EX_MEM != 0) && (RD__EX_MEM == RS2__ID_EX)) begin
        reg_B = 2'b10;
    end
    //MEM_WB rerouting
    else if( (WB__MEM_WB == 1 ) && ( RD__MEM_WB != 0 ) && ( ~(WB__EX_MEM == 1 && (RD__EX_MEM != 0 )) ) && (RD__EX_MEM == RS2__ID_EX) && (RD__MEM_WB == RS2__ID_EX) ) 
    begin
        reg_B = 2'b01;
    end
    else begin
        reg_B = 2'b00;
    end
end


assign MUX_A = reg_A;
assign MUX_B = reg_B;

endmodule
