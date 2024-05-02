

module hazard_detection_unit(
      input  wire [4:0] RS1__IF_ID,
      input  wire [4:0] RS2__IF_ID,
      input  wire [4:0] RD__ID_EX,
      input  wire       mem_read__ID_EX,
      //input  wire       mem_read_ex, ?????????????????
      output reg        pc_write,
      output reg        enable__IF_ID,
      output reg        flush_pipeline
   );

    always @(*) begin
        if (mem_read__ID_EX && ((RD__ID_EX == RS1__IF_ID) || (RD__ID_EX == RS2__IF_ID))) begin
            flush_pipeline <= 1'b1;
            pc_write <= 1'b0;
            enable__IF_ID <= 1'b0;
        end 
        
        else begin
            flush_pipeline <= 1'b0;
            pc_write <= 1'b1;
            enable__IF_ID <= 1'b1;
        end
    end
  
endmodule