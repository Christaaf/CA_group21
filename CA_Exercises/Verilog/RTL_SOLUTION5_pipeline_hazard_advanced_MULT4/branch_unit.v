//Branch Unit
//Function: Calculate the next pc in the case of a control instruction (branch or jump).
//Inputs:
//instruction: Instruction currently processed. The least significant bits are used for the calcualting the target pc in the case of a jump instruction. 
//branch_offset: Offset for a branch instruction. 
//updated_pc:  Current PC + 4.
//Outputs: 
//branch_pc: Target PC in the case of a branch instruction.
//jump_pc: Target PC in the case of a jump instruction.

module branch_unit#(
   parameter integer DATA_W     = 16
   )(
      //inputs
      input  wire signed [DATA_W-1:0]  updated_pc,
      input  wire signed [DATA_W-1:0]  immediate_extended,
      output reg  signed [DATA_W-1:0]  branch_pc,
         //MULT4
      input  wire                      branch,
      input  wire signed [DATA_W-1:0]  rdata_1,
      input  wire signed [DATA_W-1:0]  rdata_2,

      //outputs
      output reg  signed [DATA_W-1:0]  jump_pc,
         //MULT4
      output reg                       pc_src
   );

   localparam  [DATA_W-1:0] PC_INCREASE= {{(DATA_W-3){1'b0}},3'd4};

   always@(*) branch_pc           = updated_pc + immediate_extended - PC_INCREASE;
   always@(*) jump_pc             = updated_pc + immediate_extended - PC_INCREASE;
   //MULT4
   always @(*) begin
      if (branch && (rdata_1 == rdata_2)) begin
          pc_src <= 1'b1;
      end else begin
         pc_src <= 1'b0;
      end
   end
  
endmodule



