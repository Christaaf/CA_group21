module mux_3 
  #(
   parameter integer DATA_W = 16
   )(
      input  wire [DATA_W-1:0] input_a,
      input  wire [DATA_W-1:0] input_b,
      input  wire [DATA_W-1:0] input_c,
      input  wire [1:0]         select,
      output reg  [DATA_W-1:0] mux_out
   );

   always@(*)begin
 //     if(select == 2'b0)begin
 //        mux_out = input_a;
 //     end 
   //   else if(select == 2'b1)begin
     //    mux_out = input_b;
      //end  
     // else begin
       //  mux_out = input_c;
    //  end 
      case(select)

         2'b00: mux_out = input_a;
         2'b01: mux_out = input_b;

         default: mux_out = input_c;
      endcase
   end
endmodule
