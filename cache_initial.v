module test
#(parameter WIDTH = 32,
  parameter MODES = 4,
  parameter SETS = 8)

( 
 input [WIDTH-1:0] address,
  input clk,
  input reset,      
  input [31:0] data_in,
  input write,
 input [MODES-3:0] selection_signal,
  output [31:0] out,
  output  hit,
  output  miss
);

reg [160:0] data_out;
reg  [160:0] RMEM1  [0:4095];  
reg [160:0]temp[0:4095];
reg match;
reg valid;
reg [160:0] data_out1;
reg [18:0] tag_out1;
reg memrd_1;
reg hit_reg;
reg miss_reg;
reg [31:0] out_reg;
reg [10:0] hit_counter;
reg [10:0] miss_counter;
reg [18:0] tag;
reg [3:0] offset;
reg [11:0] index;
reg [SETS-1:0] set;

always @ (posedge clk)
begin

if(!reset)
begin
index <= 12'b0;
tag <= 19'b0;		
set <= 8'b0;
offset <= 8'b0;
hit_counter <=0;
miss_counter<=0;
out_reg <= 32'b0;
hit_reg <= 0;
miss_reg <=0;
match<=0;
valid<=0;
data_out <=161'b0;
memrd_1 <= 0;
tag_out1<= 0;
data_out1<= 0;
end

else
begin
if(selection_signal == 2'b00)
begin
		       index <= address[15:4];
			tag <= {3'b000, address[31:16]};		
			set <= {8'b 10000000};
			offset = address[3:0];
			end

		valid <= RMEM1[index][160];
		//$display("valid1 is %d", valid);
		//$display("index1 is %d", index);
		tag_out1 <= RMEM1[index][158:140];
		match <= (tag == tag_out1);
		if(write == 1'b0 && match == 1'b1 && valid)
	    	begin
			data_out <=RMEM1[index][160:0];
			hit_counter <= hit_counter + 1;
			hit_reg <= 1'b1;
			end
		else if (write == 1'b0 && (match == 1'b0 | valid == 1'b0))
			/// read miss
			begin
			miss_counter <= miss_counter +1 ;
			memrd_1 <= 1'b1; // may need awhile loop to consider necessary delay
			miss_reg <= 1'b1;
			end
		else if (write == 1'b1 && match == 1'b1 && valid)
	        begin
			RMEM1[index][160:0] <= data_in;
			hit_counter <= hit_counter + 1;
			hit_reg <= 1'b1;
			end  
		else if (write == 1'b1 && (match == 1'b0 | valid == 1'b0))
			begin
			miss_counter = miss_counter +1 ;
			memrd_1 = 1'b1; // may need awhile loop to consider necessary delay
			miss_reg <= 1'b1;
			end
  		


if(memrd_1)
begin
	RMEM1[index][160] = 1'b1;
	RMEM1[index][158:140] = tag;
	//$display("valid2 is %d", RMEM1[index][160]);
	//$display("index2 is %d", index);
	RMEM1[index][139:128] = 12'd4095;
	RMEM1[index][159] =1'b1;
	RMEM1[index][127:0] = 128'd128;
	
	if(write !=1)
	data_out = RMEM1[index][160:0];
	else
	RMEM1[index][127:0] =data_in;		
	memrd_1 = 0;
end

out_reg <= (offset==4'b0000)? data_out[31:0]:(offset==4'b0001)? data_out[63:32]:(offset==4'b0010)?data_out[95:64]:(offset==4'b0011)?data_out[127:96]: 32'b0;
end
end
// lru find the block check its dirty bit and do wrtieback if it is set else just replace in cache
initial
begin
//$monitor("count is: %d", counter);

$monitor("RMEM is: %b", RMEM1[0][160:0]);
end

assign out = out_reg;
assign hit = hit_reg;
assign miss = miss_reg;
endmodule
