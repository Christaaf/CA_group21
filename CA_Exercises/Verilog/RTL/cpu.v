//Module: CPU
//Function: CPU is the top design of the RISC-V processor

//Inputs:
//	clk: main clock
//	arst_n: reset 
// enable: Starts the execution
//	addr_ext: Address for reading/writing content to Instruction Memory
//	wen_ext: Write enable for Instruction Memory
// ren_ext: Read enable for Instruction Memory
//	wdata_ext: Write word for Instruction Memory
//	addr_ext_2: Address for reading/writing content to Data Memory
//	wen_ext_2: Write enable for Data Memory
// ren_ext_2: Read enable for Data Memory
//	wdata_ext_2: Write word for Data Memory

// Outputs:
//	rdata_ext: Read data from Instruction Memory
//	rdata_ext_2: Read data from Data Memory



module cpu(
		input  wire			  clk,
		input  wire         arst_n,
		input  wire         enable,
		input  wire	[63:0]  addr_ext,
		input  wire         wen_ext,
		input  wire         ren_ext,
		input  wire [31:0]  wdata_ext,
		input  wire	[63:0]  addr_ext_2,
		input  wire         wen_ext_2,
		input  wire         ren_ext_2,
		input  wire [63:0]  wdata_ext_2,
		
		output wire	[31:0]  rdata_ext,
		output wire	[63:0]  rdata_ext_2

   );


// Hazard detection
wire              pc_write, enable_pipeline__IF_ID, flush_pipeline;


// IF STAGE WIRES
wire [      31:0] instruction;
wire [      63:0] updated_pc,current_pc;

// IF_ID REG WIRES
wire  [63:0]   pc_IF_ID;
wire [31:0]    instruction_IF_ID;

// ID STAGE WIRES
wire              reg_dst,branch,mem_read,mem_2_reg,
                  mem_write,alu_src, reg_write, jump;
wire [       1:0] alu_op;
wire [      63:0] regfile_rdata_1,regfile_rdata_2;
wire signed [63:0] immediate_extended;

//ID_EX WIRES
wire [       1:0] alu_op_ID_EX;
wire           reg_dst_ID_EX;
wire           branch_ID_EX;
wire           mem_read_ID_EX;
wire           mem_2_reg_ID_EX;
wire           mem_write_ID_EX;
wire           alu_src_ID_EX;
wire           reg_write_ID_EX;
wire           jump_ID_EX;
wire  [63:0]   pc_ID_EX;
wire [      63:0] regfile_rdata_1_ID_EX;
wire [      63:0] regfile_rdata_2_ID_EX;
wire signed [63:0] immediate_extended_ID_EX;
wire           func75_ID_EX;
wire           func70_ID_EX;
wire [      2:0] func3_ID_EX;
wire [      4:0] waddr_ID_EX;


// EX STAGE WIRES
wire [      63:0] branch_pc;
wire [      63:0] jump_pc;
wire [      63:0] alu_operand_2;
wire [      63:0] alu_out;
wire              zero_flag;
wire [       3:0] alu_control;

// EX_MEM REG WIRES
wire           reg_dst_EX_MEM;
wire           branch_EX_MEM;
wire           mem_read_EX_MEM;
wire           mem_2_reg_EX_MEM;
wire           mem_write_EX_MEM;
wire           reg_write_EX_MEM;
wire           jump_EX_MEM;
wire  [63:0]   pc_EX_MEM;
wire           zero_flag_EX_MEM;
wire [      63:0] alu_out_EX_MEM;
wire [      63:0] regfile_rdata_2_EX_MEM;
wire [      4:0] waddr_EX_MEM;

// MEM STAGE WIRES
wire [      63:0] mem_data_MEM;

// MEM_WB REG WIRES
wire           reg_dst_MEM_WB;
wire           mem_2_reg_MEM_WB;
wire           reg_write_MEM_WB;
wire [   63:0] mem_data_MEM_WB;
wire [   63:0] alu_out_MEM_WB;
wire [    4:0] waddr_MEM_WB;

// WB STAGE WIRES
wire [      63:0] regfile_wdata_WB;


// Forwarding unit outputs
wire [1:0]        MUX_A;
wire [1:0]        MUX_B;

// Forwarding MUXs outputs
wire [63:0] MUX_A_out;
wire [63:0] MUX_B_out;

//RS1 and RS2 ID_EX
wire  [4:0] RS1_ID_EX;
wire  [4:0] RS2_ID_EX;





//IF STAGE BEGIN
pc #(
   .DATA_W(64)
) program_counter (
   .clk       (clk       ),
   .arst_n    (arst_n    ),
   .branch_pc (branch_pc ),
   .jump_pc   (jump_pc   ),
   .zero_flag (zero_flag_EX_MEM ),
   .branch    (branch_EX_MEM     ),
   .jump      (jump_EX_MEM       ),
   .current_pc(current_pc),
   .enable    (enable    ),
   .updated_pc(updated_pc)
);

sram_BW32 #(
   .ADDR_W(9 )
) instruction_memory(
   .clk      (clk           ),
   .addr     (current_pc    ),
   .wen      (1'b0          ),
   .ren      (1'b1          ),
   .wdata    (32'b0         ),
   .rdata    (instruction   ),   
   .addr_ext (addr_ext      ),
   .wen_ext  (wen_ext       ), 
   .ren_ext  (ren_ext       ),
   .wdata_ext(wdata_ext     ),
   .rdata_ext(rdata_ext     )
);

//IF STAGE END




// IF_ID REG BEGIN
// IF_ID Pipeline register for instruction signal
reg_arstn_en#(
   .DATA_W(64) // width of the forwarded signal
)pc_pipe_IF_ID(
   .clk (clk),
   .arst_n (arst_n),
   .din (updated_pc),
   .en(enable),
   .dout(pc_IF_ID)
);

reg_arstn_en#(
   .DATA_W(32) // width of the forwarded signal
)signal_pipe_IF_ID(
   .clk (clk),
   .arst_n (arst_n),
   .din (instruction),
   .en(enable),
   .dout(instruction_IF_ID)
);
// IF_ID REG END




// ID STAGE BEGIN

control_unit control_unit(
   .opcode   (instruction_IF_ID[6:0]),
   .alu_op   (alu_op          ),
   .reg_dst  (reg_dst         ),
   .branch   (branch          ),
   .mem_read (mem_read        ),
   .mem_2_reg(mem_2_reg       ),
   .mem_write(mem_write       ),
   .alu_src  (alu_src         ),
   .reg_write(reg_write       ),
   .jump     (jump            )
);

register_file #(
   .DATA_W(64)
) register_file(
   .clk      (clk),
   .arst_n   (arst_n),
   .reg_write(reg_write_MEM_WB),
   .raddr_1  (instruction_IF_ID[19:15]),
   .raddr_2  (instruction_IF_ID[24:20]),
   .waddr    (waddr_MEM_WB),
   .wdata    (regfile_wdata_WB),
   .rdata_1  (regfile_rdata_1   ),
   .rdata_2  (regfile_rdata_2   )
);


immediate_extend_unit immediate_extend_u(
    .instruction         (instruction_IF_ID),
    .immediate_extended  (immediate_extended)
);


hazard_detection_unit hazard_detection_unit(
      .RS1__IF_ID       (instruction_IF_ID[19:15]  ),
      .RS2__IF_ID       (instruction_IF_ID[24:20]  ),
      .RD__ID_EX        (waddr_ID_EX               ),
      .mem_read__ID_EX  (mem_read_ID_EX            ),
   //   .mem_read_ex    (mem_read_EX               ),
      .pc_write         (pc_write                  ),
      .enable__IF_ID    (enable_pipeline__IF_ID    ),
      .flush_pipeline   (flush_pipeline            )
);

// ID STAGE END


// ID_EX_REG BEGIN

// REG aluop_ID_EX
reg_arstn_en#(
   .DATA_W(2) // width of the forwarded signal
)aluop_IDEX(
   .clk (clk),
   .arst_n (arst_n),
   .din (alu_op),
   .en(enable),
   .dout(alu_op_ID_EX)
);

// REG alusrc_ID_EX
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)alusrc_IDEX(
   .clk (clk),
   .arst_n (arst_n),
   .din (alu_src),
   .en(enable),
   .dout(alu_src_ID_EX)
);

// REG regdst_ID_EX
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)regdst_IDEX(
   .clk (clk),
   .arst_n (arst_n),
   .din (reg_dst),
   .en(enable),
   .dout(reg_dst_ID_EX)
);

// REG regwrite_ID_EX
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)regwrite_IDEX(
   .clk (clk),
   .arst_n (arst_n),
   .din (reg_write),
   .en(enable),
   .dout(reg_write_ID_EX)
);

// REG memwrite_ID_EX
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)memwrite_IDEX(
   .clk (clk),
   .arst_n (arst_n),
   .din (mem_write),
   .en(enable),
   .dout(mem_write_ID_EX)
);

// REG branch_ID_EX
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)branch_IDEX(
   .clk (clk),
   .arst_n (arst_n),
   .din (branch),
   .en(enable),
   .dout(branch_ID_EX)
);

// REG memread_ID_EX
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)memread_IDEX(
   .clk (clk),
   .arst_n (arst_n),
   .din (mem_read),
   .en(enable),
   .dout(mem_read_ID_EX)
);

// REG mem2reg_ID_EX
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)mem2reg_IDEX(
   .clk (clk),
   .arst_n (arst_n),
   .din (mem_2_reg),
   .en(enable),
   .dout(mem_2_reg_ID_EX)
);

// REG jump_ID_EX
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)jump_IDEX(
   .clk (clk),
   .arst_n (arst_n),
   .din (jump),
   .en(enable),
   .dout(jump_ID_EX)
);

// REG PC_ID_EX
reg_arstn_en#(
   .DATA_W(64) // width of the forwarded signal
)PC_IDEX(
   .clk (clk),
   .arst_n (arst_n),
   .din (pc_IF_ID),
   .en(enable),
   .dout(pc_ID_EX)
);

// REG readdata1_ID_EX
reg_arstn_en#(
   .DATA_W(64) // width of the forwarded signal
)readdata1_IDEX(
   .clk (clk),
   .arst_n (arst_n),
   .din (regfile_rdata_1),
   .en(enable),
   .dout(regfile_rdata_1_ID_EX)
);

// REG readdata2_ID_EX
reg_arstn_en#(
   .DATA_W(64) // width of the forwarded signal
)readdata2_IDEX(
   .clk (clk),
   .arst_n (arst_n),
   .din (regfile_rdata_2),
   .en(enable),
   .dout(regfile_rdata_2_ID_EX)
);

// REG immediate_ID_EX
reg_arstn_en#(
   .DATA_W(64) // width of the forwarded signal
)immediate_IDEX(
   .clk (clk),
   .arst_n (arst_n),
   .din (immediate_extended),
   .en(enable),
   .dout(immediate_extended_ID_EX)
);

// REG waddr_ID_EX
reg_arstn_en#(
   .DATA_W(5) // width of the forwarded signal
)waddr_IDEX(
   .clk (clk),
   .arst_n (arst_n),
   .din (instruction_IF_ID[11:7]),
   .en(enable),
   .dout(waddr_ID_EX)
);

// REG func75_ID_EX
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)func75_IDEX(
   .clk (clk),
   .arst_n (arst_n),
   .din (instruction_IF_ID[30]),
   .en(enable),
   .dout(func75_ID_EX)
);

// REG func70_ID_EX
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)func70_IDEX(
   .clk (clk),
   .arst_n (arst_n),
   .din (instruction_IF_ID[25]),
   .en(enable),
   .dout(func70_ID_EX)
);

// REG func3_ID_EX
reg_arstn_en#(
   .DATA_W(3) // width of the forwarded signal
)func3_IDEX(
   .clk (clk),
   .arst_n (arst_n),
   .din (instruction_IF_ID[14:12]),
   .en(enable),
   .dout(func3_ID_EX)
);

//RS1 and RS2 ID_EX
//Reg RS1 
reg_arstn_en#(
   .DATA_W(5) // width of the forwarded signal
)forwarding_MUX_A(
   .clk (clk),
   .arst_n (arst_n),
   .din (instruction_IF_ID[19:15]),
   .en(enable),
   .dout(RS1_ID_EX)
);

//Reg RS2
reg_arstn_en#(
   .DATA_W(5) // width of the forwarded signal
)forwarding_MUX_B(
   .clk (clk),
   .arst_n (arst_n),
   .din (instruction_IF_ID[24:20]),
   .en(enable),
   .dout(RS2_ID_EX)
);


// ID_EX_REG END




// EX STAGE BEGIN


mux_3 #(
   .DATA_W(64)
)ALU_forward_mux_operand0(
   .input_a(regfile_rdata_1_ID_EX),
   .input_b(regfile_wdata_WB),
   .input_c(alu_out_EX_MEM),
   .select(MUX_A),
   .mux_out(MUX_A_out)
);


mux_3 #(
   .DATA_W(64)
)ALU_forward_mux_operand1(
   .input_a(regfile_rdata_2_ID_EX),
   .input_b(regfile_wdata_WB),
   .input_c(alu_out_EX_MEM),
   .select(MUX_B),
   .mux_out(MUX_B_out)
);

alu_control alu_ctrl(
   .func7_5       (func75_ID_EX ),
   .func7_0       (func70_ID_EX   ),
   .func3          (func3_ID_EX),
   .alu_op         (alu_op_ID_EX            ),
   .alu_control    (alu_control       )
);

mux_2 #(
   .DATA_W(64)
) alu_operand_mux (
   .input_a (immediate_extended_ID_EX),
   .input_b (MUX_B_out    ),
   .select_a(alu_src_ID_EX           ),
   .mux_out (alu_operand_2     )
);

alu#(
   .DATA_W(64)
) alu(
   .alu_in_0 (MUX_A_out ),
   .alu_in_1 (alu_operand_2   ),
   .alu_ctrl (alu_control     ),
   .alu_out  (alu_out         ),
   .zero_flag(zero_flag       ),
   .overflow (                )
);


forwarding_unit forwarding_unitt(
      .WB__EX_MEM(reg_write_EX_MEM),
      .WB__MEM_WB(reg_write_MEM_WB),
      .RD__EX_MEM(waddr_EX_MEM),
      .RD__MEM_WB(waddr_MEM_WB),
      .RS1__ID_EX(RS1_ID_EX),
      .RS2__ID_EX(RS2_ID_EX),
      .MUX_A(MUX_A),
      .MUX_B(MUX_B)
   );

branch_unit#(
   .DATA_W(64)
)branch_unit(
   .updated_pc         (pc_ID_EX     ),
   .immediate_extended (immediate_extended_ID_EX),
   .branch_pc          (branch_pc         ),
   .jump_pc            (jump_pc           )
);

// EX STAGE END





// EX_MEM_REG BEGIN
// REG regdst_EX_MEM
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)regdst_EXMEM(
   .clk (clk),
   .arst_n (arst_n),
   .din (reg_dst_ID_EX), 
   .en(enable),
   .dout(reg_dst_EX_MEM)
);

// REG branch_EX_MEM
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)branch_EXMEM(
   .clk (clk),
   .arst_n (arst_n),
   .din (branch_ID_EX), 
   .en(enable),
   .dout(branch_EX_MEM)
);

// REG memread_EX_MEM
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)memread_EXMEM(
   .clk (clk),
   .arst_n (arst_n),
   .din (mem_read_ID_EX), 
   .en(enable),
   .dout(mem_read_EX_MEM)
);

// REG mem2reg_EX_MEM
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)mem2reg_EXMEM(
   .clk (clk),
   .arst_n (arst_n),
   .din (mem_2_reg_ID_EX), 
   .en(enable),
   .dout(mem_2_reg_EX_MEM)
);

// REG memwrite_EX_MEM
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)memwrite_EXMEM(
   .clk (clk),
   .arst_n (arst_n),
   .din (mem_write_ID_EX), 
   .en(enable),
   .dout(mem_write_EX_MEM)
);

// REG regwrite_EX_MEM
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)regwrite_EXMEM(
   .clk (clk),
   .arst_n (arst_n),
   .din (reg_write_ID_EX), 
   .en(enable),
   .dout(reg_write_EX_MEM)
);

// REG jump_EX_MEM
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)jump_EXMEM(
   .clk (clk),
   .arst_n (arst_n),
   .din (jump_ID_EX), 
   .en(enable),
   .dout(jump_EX_MEM)
);

// REG PC_EX_MEM
reg_arstn_en#(
   .DATA_W(64) // width of the forwarded signal
)PC_EXMEM(
   .clk (clk),
   .arst_n (arst_n),
   .din (pc_ID_EX), 
   .en(enable),
   .dout(pc_EX_MEM)
);

// REG zero_EX_MEM
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)zero_EXMEM(
   .clk (clk),
   .arst_n (arst_n),
   .din (zero_flag), 
   .en(enable),
   .dout(zero_flag_EX_MEM)
);

// REG aluout_EX_MEM
reg_arstn_en#(
   .DATA_W(64) // width of the forwarded signal
)aluout_EXMEM(
   .clk (clk),
   .arst_n (arst_n),
   .din (alu_out), 
   .en(enable),
   .dout(alu_out_EX_MEM)
);

// REG readdata2_EX_MEM
reg_arstn_en#(
   .DATA_W(64) // width of the forwarded signal
)readdata2_EXMEM(
   .clk (clk),
   .arst_n (arst_n),
   .din (regfile_rdata_2_ID_EX), 
   .en(enable),
   .dout(regfile_rdata_2_EX_MEM)
);

// REG waddr_EX_MEM
reg_arstn_en#(
   .DATA_W(5) // width of the forwarded signal
)waddr_EXMEM(
   .clk (clk),
   .arst_n (arst_n),
   .din (waddr_ID_EX), 
   .en(enable),
   .dout(waddr_EX_MEM)
);


//EX_MEM_REG END





// MEM STAGE BEGIN
sram_BW64 #(
   .ADDR_W(10)
) data_memory(
   .clk      (clk            ),
   .addr     (alu_out_EX_MEM        ),
   .wen      (mem_write_EX_MEM      ),
   .ren      (mem_read_EX_MEM       ),
   .wdata    (regfile_rdata_2_EX_MEM),
   .rdata    (mem_data_MEM       ),   
   .addr_ext (addr_ext_2     ),
   .wen_ext  (wen_ext_2      ),
   .ren_ext  (ren_ext_2      ),
   .wdata_ext(wdata_ext_2    ),
   .rdata_ext(rdata_ext_2    )
);

// MEM STAGE END






// MEM_WB_REG BEGIN
// REG regdst_MEM_WB
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)regdst_MEMWB(
   .clk (clk),
   .arst_n (arst_n),
   .din (reg_dst_EX_MEM),
   .en(enable),
   .dout(reg_dst_MEM_WB)
);

// REG mem2reg_MEM_WB
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)mem2reg_MEMWB(
   .clk (clk),
   .arst_n (arst_n),
   .din (mem_2_reg_EX_MEM),
   .en(enable),
   .dout(mem_2_reg_MEM_WB)
);

// REG regwrite_MEM_WB
reg_arstn_en#(
   .DATA_W(1) // width of the forwarded signal
)regwrite_MEMWB(
   .clk (clk),
   .arst_n (arst_n),
   .din (reg_write_EX_MEM),
   .en(enable),
   .dout(reg_write_MEM_WB)
);

// REG mem_data_MEM_WB
reg_arstn_en#(
   .DATA_W(64) // width of the forwarded signal
)mem_data_MEMWB(
   .clk (clk),
   .arst_n (arst_n),
   .din (mem_data_MEM),
   .en(enable),
   .dout(mem_data_MEM_WB)
);

// REG aluout_MEM_WB
reg_arstn_en#(
   .DATA_W(64) // width of the forwarded signal
)aluout_MEMWB(
   .clk (clk),
   .arst_n (arst_n),
   .din (alu_out_EX_MEM),
   .en(enable),
   .dout(alu_out_MEM_WB)
);

// REG waddr_MEM_WB
reg_arstn_en#(
   .DATA_W(5) // width of the forwarded signal
)waddr_MEMWB(
   .clk (clk),
   .arst_n (arst_n),
   .din (waddr_EX_MEM),
   .en(enable),
   .dout(waddr_MEM_WB)
);
// MEM_WB_REG END







// WB STAGE BEGIN
mux_2 #(
   .DATA_W(64)
) regfile_data_mux (
   .input_a  (mem_data_MEM_WB     ),
   .input_b  (alu_out_MEM_WB      ),
   .select_a (mem_2_reg_MEM_WB    ),
   .mux_out  (regfile_wdata_WB)
);

// WB STAGE END 




endmodule


