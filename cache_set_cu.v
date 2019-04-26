// Cache Set COntroller Unit.
//This unit takes address as an input from CPU to find the tag bits, index bits and the offset bits
// and a 2 bit selection signal to choose DM mode, 2-way , 4-way, and 8-way

module cache_set_cu  
#(parameter WIDTH = 32,
  parameter MODES = 4,
 parameter SETS = 8)

( input [WIDTH-1:0] address,
input reset, 
input clk,                                           
  input [MODES-3:0] selection_signal,
  output reg [SETS-1:0] set,
  output reg [18:0] tag,
  output reg [3:0] offset,
  output reg [11:0] index);

	always @ (posedge clk)
begin
if(!reset)
begin
 index <= 12'b0;
tag <= 19'b0;		
set <= 8'b0;
offset <= 8'b0;

end
else
begin
	case(selection_signal)
		
		2'b00: begin
		       index <= address[15:4];
			tag <= {3'b000, address[31:16]};		
			set <= {8'b 10000000};
			end
		2'b01: begin
		       index <= {1'b0, address[14:4]};
			tag<= {2'b00, address[31:15]};
			set <= {8'b 11000000};		
			end
		2'b10: begin
		       index <= {2'b00, address[13:4]};
			tag <= {1'b0, address[31:14]};
			set <= {8'b 11110000};		
			end
		2'b11: begin
		       index <= {3'b000, address[12:4]};
			tag <=  address[31:13];
			set <= {8'b 11111111};		
			end
		 default: begin
			index <= address[15:4];
			tag <= {3'b000, address[31:16]};
			//set <= {8'b zzzzzzzz};
			  end
		
	endcase
offset = address[3:0];
end
end

endmodule
