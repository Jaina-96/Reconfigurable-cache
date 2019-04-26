module cache_memory
#(parameter WIDTH = 32,
  parameter MODES = 4,
  parameter SETS = 8)

( input [WIDTH-1:0] address, 
/* input [SETS-1:0] set,
  input [18:0] tag,
  input [3:0] offset,
  input [11:0] index,*/
    input [MODES-3:0] selection_signal,
  input clk,
  input reset,       // use
  input [31:0] data_in,
  input write,
   
  output [31:0] out,
  output reg hit,
  output reg miss
);

reg [160:0] data_out;
// take all inputs to the systme
//wire [SETS-1: 0]set;
// 1 valid and 19 bits tag
// 12 bits for lru
// 1 dirty bit
//valid dirty tag lru data
// 160 159 158-140    139-128  127-0
// 1 + 1 + 19 + 12 + 128
reg  [160:0] RMEM1  [0:4095];  
reg  [160:0] RMEM2  [0:4095];
reg  [160:0] RMEM3  [0:4095];
reg  [160:0] RMEM4  [0:4095];
reg  [160:0] RMEM5  [0:4095];
reg  [160:0] RMEM6  [0:4095];
reg  [160:0] RMEM7  [0:4095];
reg  [160:0] RMEM8  [0:4095];
reg [160:0]temp[0:4095];
// declare 8 reg's each of 64k
//reg [11:0] i;
reg [10:0] hit_counter;
reg [10:0] miss_counter;
//reg lru[12:0];
//integer start;
//integer stop;
reg match;
reg valid;

// 4 words = 32 32 32 32
//assign lru = counter;
reg [160:0] data_out1;
reg [160:0] data_out2;
reg [160:0] data_out3;
reg [160:0] data_out4;
reg [160:0] data_out5;
reg [160:0] data_out6;
reg [160:0] data_out7;
reg [160:0] data_out8;

reg [18:0] tag_out1;
reg [18:0] tag_out2;
reg [18:0] tag_out3;
reg [18:0] tag_out4;
reg [18:0] tag_out5;
reg [18:0] tag_out6;
reg [18:0] tag_out7;
reg [18:0] tag_out8;
reg memrd_1;
reg memrd_2;
reg memrd_3;
reg memrd_4;
reg memrd_5;
reg memrd_6;
reg memrd_7;
reg memrd_8;
reg hit_reg;
reg [31:0] out_reg;
reg [18:0] tag;
reg [3:0] offset;
reg [11:0] index;
reg [SETS-1:0] set;

assign out = out_reg;
//assign hit = hit_reg;
always @ *
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
			offset <= address[3:0];
			end
		2'b01: begin
		       index <= {1'b0, address[14:4]};
			tag<= {2'b00, address[31:15]};
			set <= {8'b 11000000};	
				offset <= address[3:0];
			end
		2'b10: begin
		       index <= {2'b00, address[13:4]};
			tag <= {1'b0, address[31:14]};
			set <= {8'b 11110000};	
				offset <= address[3:0];
			end
		2'b11: begin
		       index <= {3'b000, address[12:4]};
			tag <=  address[31:13];
			set <= {8'b 11111111};	
				offset <= address[3:0];
			end
		 default: begin
			index <= address[15:4];
			tag <= {3'b000, address[31:16]};
			//set <= {8'b zzzzzzzz};
			offset <= address[3:0];
			  end
		
	endcase

end
end

always @ (posedge clk)
begin

if(!reset)
begin
out_reg <= 32'b0;
hit_reg <= 0;
match<=0;
valid<=0;
data_out <=161'b0;
memrd_1 <= 0;
 memrd_2 <= 0;
memrd_3 <= 0;
 memrd_4 <= 0;
memrd_5<= 0;
memrd_6<= 0;
memrd_7<= 0;
memrd_8<= 0;
tag_out8<= 0;
tag_out1<= 0;
 tag_out2<= 0;
 tag_out3<= 0;
 tag_out4<= 0;
 tag_out5<= 0;
 tag_out6<= 0;
tag_out7<= 0;
data_out1<= 0;
 data_out2<= 0;
 data_out3<= 0;
 data_out4<= 0;
 data_out5<= 0;
 data_out6<= 0;
 data_out7<=0;
 data_out8<=0;
 hit_counter <=0;
	miss_counter<=0;

end

else
begin
case(set)
// use cases for 00 till 11
// for 00 use only r1 and so on
// at first just do the reading part for cache hit
// read
8'b10000000: begin
		//$display("ENtered1");
		valid = RMEM1[index][160];
		tag_out1 = RMEM1[index][158:140];
		match = (tag == tag_out1)? 1'b0: 1'b1;
			if((write == 1'b0) & ((tag == tag_out1) & ( valid == 1'b1)))
	    	begin
			data_out1 =RMEM1[index][160:0];
			hit_counter = hit_counter + 1;
			miss_counter = miss_counter;
			hit = 1'b1;
			miss = 1'b0;
			end
		else if  ((write == 1'b0) & ((tag != tag_out1) | ( valid == 1'b0)))
			begin
			miss_counter = miss_counter +1 ;
			hit_counter = hit_counter;
			memrd_1 = 1'b1; // may need awhile loop to consider necessary delay
			miss = 1'b1;
		    hit = 1'b0;
			RMEM1[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			end
		else if ((write == 1'b1) & ((tag == tag_out1) & ( valid == 1'b1)))
	        begin
			hit_counter = hit_counter + 1;
			miss_counter = miss_counter;
			hit = 1'b1;
			miss = 1'b0;
			memrd_1 = 1'b0;
			end  
		else if ((write == 1'b1) & ((tag != tag_out1) | ( valid == 1'b0)))
			begin
			RMEM1[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			miss_counter = miss_counter +1 ;
			hit_counter = hit_counter;
			miss = 1'b1;
			hit = 1'b0;
				end
	end
		
8'b11000000: begin
		//$display("ENtered2");
		valid = RMEM1[index][160];
		tag_out1 = RMEM1[index][158:140];
		tag_out2 = RMEM2[index][158:140];
		match = (tag_out1== tag | tag_out2 == tag);
		if((write == 1'b0) & ((tag == tag_out1) & ( valid == 1'b1)))
	    begin
			data_out1 =RMEM1[index][160:0];
			data_out2 =RMEM1[index][160:0];
			data_out = (tag_out1 == tag)? data_out1: data_out2;
			hit_counter = hit_counter + 1;
			miss_counter = miss_counter;
			hit = 1'b1;
			miss = 1'b0;
		end
		else if  ((write == 1'b0) & ((tag != tag_out1) | ( valid == 1'b0)))
		begin
			miss_counter = miss_counter +1 ;
			hit_counter = hit_counter;
			//memrd_1 = 1'b1; // may need awhile loop to consider necessary delay
			miss = 1'b1;
		    hit = 1'b0;
			if (tag <= 19'b0010000000000000000)
			RMEM1[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else 
			RMEM2[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			
		end
		else if ((write == 1'b1) & ((tag == tag_out1) & ( valid == 1'b1)))
	    begin
			hit_counter = hit_counter + 1;
			miss_counter = miss_counter;
			hit = 1'b1;
			miss = 1'b0;
			memrd_1 = 1'b0;
		end  
		else if ((write == 1'b1) & ((tag != tag_out1) | ( valid == 1'b0)))
		begin
			if (tag < 19'b0010000000000000000)
			RMEM1[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else 
			RMEM2[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			
			miss_counter = miss_counter +1 ;
			hit_counter = hit_counter;
			miss = 1'b1;
			hit = 1'b0;
		end
    end
		

8'b11110000: begin
		$display("ENtered3");
		valid = RMEM1[index][160];
		tag_out1 = RMEM1[index][158:140];
		tag_out2 = RMEM2[index][158:140];
		tag_out3 = RMEM3[index][158:140];
		tag_out4 = RMEM4[index][158:140];
		match = (tag_out1== tag | tag_out2 == tag | tag_out3 == tag | tag_out4 == tag); 
		if((write == 1'b0) & ((tag == tag_out1) & ( valid == 1'b1)))
	    	begin
			data_out1 =RMEM1[index][160:0];
			data_out2 =RMEM1[index][160:0];
			data_out3 =RMEM1[index][160:0];
			data_out4 =RMEM1[index][160:0];
			data_out = (tag_out1 == tag)? data_out1: (tag_out2 == tag)? data_out2: (tag_out3 == tag)? data_out3: data_out4;
			hit_counter = hit_counter + 1;
			miss_counter = miss_counter;
			hit = 1'b1;
			miss = 1'b0;
			end
			
		else if  ((write == 1'b0) & ((tag != tag_out1) | ( valid == 1'b0)))
			begin
			miss_counter = miss_counter +1 ;
			hit_counter = hit_counter;
			//memrd_1 = 1'b1; // may need awhile loop to consider necessary delay
			miss = 1'b1;
		    hit = 1'b0;
			if (19'b0 <= tag < 19'b0001000000000000000)
			RMEM1[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else if(19'b0001000000000000000 <= tag < 19'b0010000000000000000)
			RMEM2[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else if (19'b0010000000000000000 <= tag < 19'b0100000000000000000)
			RMEM3[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else 
			RMEM4[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			end
		else if ((write == 1'b1) & ((tag == tag_out1) & ( valid == 1'b1)))
	        begin
			hit_counter = hit_counter + 1;
			miss_counter = miss_counter;
			hit = 1'b1;
			miss = 1'b0;
			memrd_1 = 1'b0;
			end  
		else if ((write == 1'b1) & ((tag != tag_out1) | ( valid == 1'b0)))
			begin
			if (19'b0 <= tag < 19'b0001000000000000000)
			RMEM1[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else if(19'b0001000000000000000 <= tag < 19'b0010000000000000000)
			RMEM2[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else if (19'b0010000000000000000 <= tag < 19'b0100000000000000000)
			RMEM3[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else
			RMEM4[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			miss_counter = miss_counter +1 ;
			hit_counter = hit_counter;
			miss = 1'b1;
			hit = 1'b0;
				end
		
		end
8'b11111111: begin
		$display("ENtered8");
		valid = RMEM1[index][160];
		tag_out1 = RMEM1[index][158:140];
		tag_out2 = RMEM2[index][158:140];
		tag_out3 = RMEM3[index][158:140];
		tag_out4 = RMEM4[index][158:140];
		tag_out5 = RMEM5[index][158:140];
		tag_out6 = RMEM6[index][158:140];
		tag_out7 = RMEM7[index][158:140];
		tag_out8 = RMEM8[index][158:140];
		
		match = (tag_out1== tag | tag_out2 == tag | tag_out3 == tag | tag_out4 == tag | tag_out5== tag | tag_out6 == tag | tag_out7 == tag | tag_out8 == tag); 
		if((write == 1'b0) & ((match) & ( valid == 1'b1)))
	    	begin
			data_out1 =RMEM1[index][160:0];
			data_out2 =RMEM1[index][160:0];
			data_out3 =RMEM1[index][160:0];
			data_out4 =RMEM1[index][160:0];
			data_out5 = RMEM5[index][160:0];
			data_out6 = RMEM6[index][160:0];
			data_out7 = RMEM7[index][160:0];
			data_out8 = RMEM8[index][160:0];
		    data_out = (tag_out1 == tag)? data_out1: (tag_out2 == tag)? data_out2: (tag_out3 == tag)? data_out3: data_out4;
			hit_counter = hit_counter + 1;
			miss_counter = miss_counter;
			hit = 1'b1;
			miss = 1'b0;
			end
			
		else if  ((write == 1'b0) & ((!match) | ( valid == 1'b0)))
			begin
			miss_counter = miss_counter +1 ;
			hit_counter = hit_counter;
			//memrd_1 = 1'b1; // may need awhile loop to consider necessary delay
			miss = 1'b1;
		    hit = 1'b0;
			if (19'b0 <= tag < 19'b00000001000000000000)
			RMEM1[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else if(19'b00000001000000000000 <= tag < 19'b00000010000000000000)
			RMEM2[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else if (19'b00000010000000000000 <= tag <= 19'b00000100000000000000 )
			RMEM3[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else if( 19'b00000100000000000000 <= tag < 19'b0001000000000000000)
			RMEM4[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
		    else if (19'b0001000000000000000 <= tag < 19'b0010000000000000000)
			RMEM5[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else if(19'b0010000000000000000 <= tag < 19'b0100000000000000000)
			RMEM6[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else if (19'b0100000000000000000 <= tag < 19'b1000000000000000000)
			RMEM7[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else 
			RMEM8[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			end
		else if ((write == 1'b1) & ((match) & ( valid == 1'b1)))
	        begin
			hit_counter = hit_counter + 1;
			miss_counter = miss_counter;
			hit = 1'b1;
			miss = 1'b0;
			memrd_1 = 1'b0;
			end  
		
		else if ((write == 1'b1) & ((!match) | ( valid == 1'b0)))
			begin
			if (19'b0 <= tag < 19'b00000001000000000000)
			RMEM1[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else if(19'b00000001000000000000 <= tag < 19'b00000010000000000000)
			RMEM2[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else if (19'b00000010000000000000 <= tag <= 19'b00000100000000000000 )
			RMEM3[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else if( 19'b00000100000000000000 <= tag < 19'b0001000000000000000)
			RMEM4[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else if (19'b0001000000000000000 <= tag < 19'b0010000000000000000)
			RMEM5[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else if(19'b0010000000000000000 <= tag < 19'b0100000000000000000)
			RMEM6[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else if (19'b0100000000000000000 <= tag < 19'b1000000000000000000)
			RMEM7[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
			else 
			RMEM8[index][160:140] = {2'b11, tag[18],  tag[17], tag[16], tag[15], tag[14], tag[13],
									tag[12],tag[11],tag[8],tag[9],tag[8],tag[7],tag[6],
									tag[5],tag[4],tag[3],tag[2],tag[1],tag[0]};
									
			miss_counter = miss_counter +1 ;
			hit_counter = hit_counter;
			miss = 1'b1;
			hit = 1'b0;
				end
		end

endcase

out_reg <= (offset==4'b0000)? data_out[31:0]:(offset==4'b0001)? data_out[63:32]:(offset==4'b0010)?data_out[95:64]:(offset==4'b0011)?data_out[127:96]: 32'b0;
//hit_reg <= match & (reset) & valid;

end
end
