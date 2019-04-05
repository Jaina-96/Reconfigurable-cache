// cache module // data_out is in bytes

module cache_memory
#(parameter WIDTH = 32,
  parameter MODES = 4,
  parameter SETS = 8)

( //input [SETS-1:0] set,
 // input [18:0] tag,
  //input [3:0] offset,
  //input [11:0] index,
 input [WIDTH-1:0] address,
  input clk,
  input reset,       // use
  input [31:0] data_in,
  input write,
     input [MODES-3:0] selection_signal,
  output [31:0] out,
  output  hit,
  output  miss
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
reg [11:0] j;
//reg [11:0] index;
reg [11:0]counter;
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
reg miss_reg;
reg [31:0] out_reg;
integer i;
reg [18:0] mini_rmem1;
integer location;
reg [10:0] hit_counter;
reg [10:0] miss_counter;

   reg [18:0] tag;
   reg [3:0] offset;
   reg [11:0] index;
reg [SETS-1:0] set;
assign out = out_reg;
assign hit = hit_reg;
assign miss = miss_reg;

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
/*always @ (posedge clk)
begin

	if (hit_reg & reset )begin
	hit_counter = hit_counter + 1;
	miss_counter = miss_counter;
	end
	else
	begin
	hit_counter = hit_counter;
	miss_counter = miss_counter +1 ;
	end
end*/
/*always @ (hit_reg, miss_reg)
begin
if(reset & clk)
begin
	if(hit_reg == 1'b1)
	hit_counter = hit_counter + 1;
	else if(hit_reg == 1'b0)
	hit_counter = hit_counter ;
	else if(miss_reg == 1'b1)
	miss_counter = miss_counter +1 ;
	else if(miss_reg == 1'b0)
	miss_counter = miss_counter;
end
end*/

always @ (posedge clk)
begin

if(!reset)
begin
hit_counter <=0;
miss_counter<=0;
out_reg <= 32'b0;
hit_reg <= 0;
miss_reg <=0;
match<=0;
valid<=0;
counter<=12'b0;
//i<= 12'b0;
j<= 12'b0;
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
//location <=0;
mini_rmem1<=0;


end

else
begin
case(set)
// use cases for 00 till 11
// for 00 use only r1 and so on
// at first just do the reading part for cache hit
// read
8'b10000000: begin
		valid <= RMEM1[index][160];
		$display("valid1 is %d", valid);
		$display("index1 is %d", index);
		tag_out1 <= RMEM1[index][158:140];
		match <= (tag == tag_out1);
		//index<=index1;
		if(write == 1'b0 && match == 1'b1 && valid)
	    	begin
			data_out =RMEM1[index][160:0];
			RMEM1[index][139:128] <=RMEM1[index][139:128]+ 1'b1;
			hit_counter = hit_counter + 1;
			end
		else if (write == 1'b0 && (match == 1'b0 | valid == 1'b0))
			/// read miss
			begin
			miss_counter = miss_counter +1 ;
			memrd_1 = 1'b1; // may need awhile loop to consider necessary delay
			end
		else if (write == 1'b1 && match == 1'b1 && valid)
	        begin
			RMEM1[index][160:0] <= data_in;
			//RMEM1[index][139:128] <=RMEM1[index][139:128]+ 1'b1;
			hit_counter = hit_counter + 1;
			end  
		else if (write == 1'b1 && (match == 1'b0 | valid == 1'b0))
			begin
			miss_counter = miss_counter +1 ;
			memrd_1 = 1'b1; // may need awhile loop to consider necessary delay
			end
    end
		
8'b11000000: begin
		valid <= (RMEM1[index][160] | RMEM2[index][160])? 1'b1: 1'b0;
		tag_out1 <= RMEM1[index][158:140];
		tag_out2 <= RMEM2[index][158:140];
		match <= (tag_out1== tag | tag_out2 == tag);
		if(write != 1'b1)
	    	begin
			if(match)
			begin
			data_out1 <= RMEM1[index][160:0];
		   	data_out2 <= RMEM2[index][160:0];
			data_out <= (tag_out1 == tag)? data_out1: data_out2;
				if(tag_out1 == tag)
				begin
				RMEM1[index][139:128] <=RMEM1[index][139:128]+ 1'b1;
				end
	
				else if(tag_out2 == tag)
				begin
				RMEM2[index][139:128] <=RMEM2[index][139:128]+ 1'b1;
				end
				
			end		
			else
			begin
				if(tag_out1 == tag)
				memrd_1 <= 1'b1; // may need awhile loop to consider necessary delay
				// read when hit

				else if(tag_out2 == tag)
				memrd_2 <= 1'b1; // may need awhile loop to consider necessary delay
				// read when hit		
		//		set = 8'b11000000;
			end
		end
			
		else
		begin
			if(match)
			begin
				if(tag_out1 == tag)
				begin
				RMEM1[index][160:0] <= data_in;
				RMEM1[index][139:128] <=RMEM1[index][139:128]+ 1'b1;
				end
			
				else if (tag_out2 == tag)
				begin
				RMEM2[index][160:0] <= data_in;
				RMEM2[index][139:128] <=RMEM2[index][139:128]+ 1'b1;
				end
			
			end
			else
			begin
				if(tag_out1 == tag)
				memrd_1 <= 1'b1; // may need awhile loop to consider necessary delay
				// read when hit
				else if(tag_out2 == tag)
				memrd_2 <= 1'b1; // may need awhile loop to consider necessary delay
				// read when hit	
				//set <= 8'b11000000;
				//counter <= counter + 1'b1;	
			end
		
		end
		
	    end

8'b11110000: begin
		valid <= RMEM1[index][160];
		tag_out1 <= RMEM1[index][158:140];
		tag_out2 <= RMEM2[index][158:140];
		tag_out3 <= RMEM3[index][158:140];
		tag_out4 <= RMEM4[index][158:140];
		match <= (tag_out1== tag | tag_out2 == tag | tag_out3 == tag | tag_out4 == tag); 

		if(write != 1'b1)
	    	begin
			if(match)
			begin
			data_out1 <= RMEM1[index][160:0];
			data_out2 <= RMEM2[index][160:0];
			data_out3 <= RMEM3[index][160:0];
			data_out4 <= RMEM4[index][160:0];
			data_out <= (tag_out1 == tag)? data_out1: (tag_out2 == tag)? data_out2: (tag_out3 == tag)? data_out3: data_out4;
			if(tag_out1 == tag)
			begin
			RMEM1[index][139:128] <=RMEM1[index][139:128]+ 1'b1;
			end

			else if(tag_out2 == tag)
			begin	
			RMEM2[index][139:128] <=RMEM2[index][139:128]+ 1'b1;
			end	
		
			else if(tag_out3 == tag)
			begin
			RMEM3[index][139:128] <=RMEM3[index][139:128]+ 1'b1;
			end

			else if(tag_out4 == tag)
			begin
			RMEM4[index][139:128] <=RMEM4[index][139:128]+ 1'b1;
			end
			end
			else
			begin
			// read miss
			if(tag_out1 == tag)
			memrd_1 <= 1'b1; // may need awhile loop to consider necessary delay
			else if(tag_out2 == tag)
			memrd_2 <= 1'b1; // may need awhile loop to consider necessary delay
			else if(tag_out3 == tag)
			memrd_3 <= 1'b1; // may need awhile loop to consider necessary delay
			else if(tag_out4 == tag)
			memrd_4 <= 1'b1; // may need awhile loop to consider necessary delay
			end
			
		end

		else
		begin
			if(match)
			begin
			if(tag_out1 == tag)
			begin
			RMEM1[index][160:0] <= data_in;
			RMEM1[index][139:128] <=RMEM1[index][139:128]+ 1'b1;
			end

			else if (tag_out2 == tag)
			begin
			RMEM2[index][160:0] <= data_in;
			RMEM2[index][139:128] <=RMEM2[index][139:128]+ 1'b1;
			end	
	
			else if (tag_out3 == tag)
			begin
			RMEM3[index][160:0] <= data_in;
			RMEM3[index][139:128] <=RMEM3[index][139:128]+ 1'b1;
			end
	
			else if (tag_out4 == tag)
			begin
			RMEM4[index][160:0] <= data_in;
			RMEM4[index][139:128] <=RMEM4[index][139:128]+ 1'b1;
			end
			end
			else
			begin
			if(tag_out1 == tag)
			memrd_1 <= 1'b1; // may need awhile loop to consider necessary delay
			else if(tag_out2 == tag)
			memrd_2 <= 1'b1; // may need awhile loop to consider necessary delay	
			else if(tag_out3 == tag)
			memrd_3 <= 1'b1; // may need awhile loop to consider necessary delay				
			else if(tag_out4 == tag)
			memrd_4 <= 1'b1; // may need awhile loop to consider necessary delay
			
			end
		
		end
		end
8'b11111111: begin
		valid <= RMEM1[index][160];
		tag_out1 <= RMEM1[index][158:140];
		tag_out2 <= RMEM2[index][158:140];
		tag_out3 <= RMEM3[index][158:140];
		tag_out4 <= RMEM4[index][158:140];
		tag_out5 <= RMEM5[index][158:140];
		tag_out6 <= RMEM6[index][158:140];
		tag_out7 <= RMEM7[index][158:140];
		tag_out8 <= RMEM8[index][158:140];
		
		match <= (tag_out1== tag | tag_out2 == tag | tag_out3 == tag | tag_out4 == tag | tag_out5== tag | tag_out6 == tag | tag_out7 == tag | tag_out8 == tag); 
		
		if(write != 1'b1)
	    	begin
			if(match)
			begin
			
			
			data_out1 <= RMEM1[index][160:0];
			
			data_out2 <= RMEM2[index][160:0];
		
			data_out3 <= RMEM3[index][160:0];
			
			data_out4 <= RMEM4[index][160:0];
			
			data_out5 <= RMEM5[index][160:0];
			
			data_out6 <= RMEM6[index][160:0];
			
			data_out7 <= RMEM7[index][160:0];
			
			data_out8 <= RMEM8[index][160:0];
			data_out <= (tag_out1 == tag)? data_out1: (tag_out2 == tag)? data_out2: (tag_out3 == tag)? data_out3:  (tag_out4== tag)? data_out4: (tag_out5 == tag)? data_out5: (tag_out6 == tag)? data_out6 : (tag_out7 == tag) ? data_out7: data_out8;
			
			
	
			if(tag_out1 == tag)
			begin
				RMEM1[index][139:128] <=RMEM1[index][139:128]+ 1'b1;
			end
			
			else if(tag_out2 == tag)
			begin
				RMEM2[index][139:128] <=RMEM2[index][139:128]+ 1'b1;
			end
			
			else if(tag_out3 == tag)
			begin
				RMEM3[index][139:128] <=RMEM3[index][139:128]+ 1'b1;
			end

			else if(tag_out4 == tag)
			begin
				RMEM4[index][139:128] <=RMEM4[index][139:128]+ 1'b1;
			end

			else if(tag_out5 == tag)
			begin
				RMEM5[index][139:128] <=RMEM5[index][139:128]+ 1'b1;
			end

			else if(tag_out6 == tag)
			begin
				RMEM6[index][139:128] <=RMEM6[index][139:128]+ 1'b1;
			end

			else if(tag_out7 == tag)
			begin
				RMEM7[index][139:128] <=RMEM7[index][139:128]+ 1'b1;
			end

			else if(tag_out8 == tag)
			begin
				RMEM8[index][139:128] <=RMEM8[index][139:128]+ 1'b1;
			end
			end
			


			else
			begin
			// read miss
			if(tag_out1 == tag)
			memrd_1 <= 1'b1; // may need awhile loop to consider necessary delay
			
			else if(tag_out2 == tag)
			memrd_2 <= 1'b1; // may need awhile loop to consider necessary delay
				
			else if(tag_out3 == tag)
			memrd_3 <= 1'b1; // may need awhile loop to consider necessary delay
				
			else if(tag_out4 == tag)
			memrd_4 <= 1'b1; // may need awhile loop to consider necessary delay
		
			if(tag_out5 == tag)
			memrd_5 <= 1'b1; // may need awhile loop to consider necessary delay
			
			else if(tag_out6 == tag)
			memrd_6 <= 1'b1; // may need awhile loop to consider necessary delay
				
			else if(tag_out7 == tag)
			memrd_7 <= 1'b1; // may need awhile loop to consider necessary delay
				
			else if(tag_out8 == tag)
			memrd_8 <= 1'b1; // may need awhile loop to consider necessary delay
		

			//set = 8'b11111111;
			
			end
		end
	
		else
		begin
			//if(dirty != 1'b1)
			//begin
			if(tag_out1 == tag)
			begin
			RMEM1[index][160:0] <= data_in;
			RMEM1[index][139:128] <=RMEM1[index][139:128]+ 1'b1;
			end
			else if (tag_out2 == tag)
			begin
			RMEM2[index][160:0] <= data_in;
			RMEM2[index][139:128] <=RMEM2[index][139:128]+ 1'b1;
			end
			else if (tag_out3 == tag)
			begin
			RMEM3[index][160:0] <= data_in;
			RMEM3[index][139:128] <=RMEM3[index][139:128]+ 1'b1;
			end
			else if (tag_out4 == tag)
			begin
			RMEM4[index][160:0] <= data_in;
			RMEM4[index][139:128] <=RMEM4[index][139:128]+ 1'b1;
			end
			else if (tag_out5 == tag)
			begin
			RMEM5[index][160:0] <= data_in;
			RMEM5[index][139:128] <=RMEM5[index][139:128]+ 1'b1;
			end
			else if (tag_out6 == tag)
			begin
			RMEM6[index][160:0] <= data_in;
			RMEM6[index][139:128] <=RMEM6[index][139:128]+ 1'b1;
			end
			else if (tag_out7 == tag)
			begin
			RMEM7[index][160:0] <= data_in;
			RMEM7[index][139:128] <=RMEM7[index][139:128]+ 1'b1;
			end
			else if (tag_out8 == tag)
			begin
			RMEM8[index][160:0] <= data_in;
			RMEM8[index][139:128] <=RMEM8[index][139:128]+ 1'b1;
			end
		else
		begin
		if(tag_out1 == tag)
		memrd_1 <= 1'b1; // may need awhile loop to consider necessary delay
			
			else if(tag_out2 == tag)
			memrd_2 <= 1'b1; // may need awhile loop to consider necessary delay
				
			else if(tag_out3 == tag)
			memrd_3 <= 1'b1; // may need awhile loop to consider necessary delay
				
			else if(tag_out4 == tag)
			memrd_4 <= 1'b1; // may need awhile loop to consider necessary delay
		
			else if(tag_out5 == tag)
			memrd_5 <= 1'b1; // may need awhile loop to consider necessary delay
			
			else if(tag_out6 == tag)
			memrd_6 <= 1'b1; // may need awhile loop to consider necessary delay
				
			else if(tag_out7 == tag)
			memrd_7 <= 1'b1; // may need awhile loop to consider necessary delay
				
			else if(tag_out8 == tag)
			memrd_8 <= 1'b1; // may need awhile loop to consider necessary delay
		
		//counter <= counter + 1'b1;
		//set = 8'b11111111;
		// write miss
		end
		end
end
endcase
hit_reg <= (match && valid);
miss_reg <= (match == 1'b0 || valid==1'b0) ;



//always @ *
//begin

// 1 valid and 19 bits tag
// 12 bits for lru
// 1 dirty bit
// 160 159 158-140    139-128     127-0
// 1 + 1 + 19 + 12 + 128


if(memrd_1)
begin
	/*mini_rmem1 = RMEM1[0][139:128];
	for(i=1; i<4096; i= i + 1 )
	begin
	if(RMEM1[i][139:128] < mini_rmem1)
	begin
	mini_rmem1 =  RMEM1[i][139:128];
	location = i;
	end
	end*/
	RMEM1[index][160] <= 1'b1;
	RMEM1[index][158:140] <= tag;
	$display("valid2 is %d", RMEM1[index][160]);
	$display("index2 is %d", index);
	 // 
	RMEM1[index][139:128] <= 12'd4095;
	
	RMEM1[index][159] <=1'b1;
	RMEM1[index][127:0] <= 128'd128; /// j out is the lru pointer
	memrd_1 = 0;

	if(write !=1)
	data_out <= RMEM1[index][160:0];
	else
	RMEM1[index][127:0] <=data_in;	

	
end

	
if(memrd_2)
begin
	mini_rmem1 = RMEM2[0][139:128];
	for(i=1; i<12'd4096; i= i + 1'b1 )
	begin
	if( RMEM2[i][139:128] < mini_rmem1)
	begin
	mini_rmem1 =  temp[i];
	location = i+1;
	end
	end
	RMEM2[location][158:140]= tag; // 
	RMEM2[location][139:128]= 12'd4095;
	RMEM2[location][160:159]=2'b11;
	RMEM2[location][127:0]= 128'b1; /// j out is the lru pointer
	if(write !=1)
	data_out = RMEM2[location][160:0];
	else
	RMEM2[location][160:0]={1'b1, 1'b1, tag, 12'd4095,data_in};	
end

else if(memrd_3)
begin
	mini_rmem1 = RMEM3[0][139:128];
	for(i=1; i<12'd4096; i= i + 1'b1 )
	begin
	if( RMEM3[i][139:128] < mini_rmem1)
	begin
	mini_rmem1 =  temp[i];
	location = i+1;
	end
	end
	RMEM3[location][158:140]= tag; // 
	RMEM3[location][139:128]= 12'd4095;
	RMEM3[location][160:159]=2'b11;
	RMEM3[location][127:0]= 128'b1; /// j out is the lru pointer
	if(write !=1)
	data_out = RMEM3[location][160:0];
	else
	RMEM3[location][160:0]={1'b1, 1'b1, tag, 12'd4095,data_in};	
end

else if(memrd_4)
begin	
	 mini_rmem1 = RMEM4[0][139:128];
	for(i=1; i<12'd4096; i= i + 1'b1 )
	begin
	if( RMEM4[i][139:128] < mini_rmem1)
	begin
	mini_rmem1 =  temp[i];
	location = i+1;
	end
	end
	RMEM4[location][158:140]= tag; // 
	RMEM4[location][139:128]= 12'd4095;
	RMEM4[location][160:159]=2'b11;
	RMEM4[location][127:0]= 128'b1; /// j out is the lru pointer
	if(write !=1)
	data_out = RMEM4[location][160:0];
	else
	RMEM4[location][160:0]={1'b1, 1'b1, tag, 12'd4095,data_in};	
end

else if(memrd_5)
 begin	
	 mini_rmem1 = RMEM5[0][139:128];
	for(i=1; i<12'd4096; i= i + 1'b1 )
	begin
	if( RMEM5[i][139:128] < mini_rmem1)
	begin
	mini_rmem1 =  temp[i];
	location = i+1;
	end
	end
	RMEM5[location][158:140]= tag; // 
	RMEM5[location][139:128]= 12'd4095;
	RMEM5[location][160:159]=2'b11;
	RMEM5[location][127:0]= 128'b1; /// j out is the lru pointer
	if(write !=1)
	data_out = RMEM5[location][160:0];
	else
	RMEM5[location][160:0]={1'b1, 1'b1, tag, 12'd4095,data_in};	
end

else if(memrd_6)
begin	
	mini_rmem1 = RMEM6[0][139:128];
	for(i=1; i<12'd4096; i= i + 1'b1 )
	begin
	if( RMEM6[i][139:128] < mini_rmem1)
	begin
	mini_rmem1 =  temp[i];
	location = i+1;
	end
	end
	RMEM6[location][158:140]= tag; // 
	RMEM6[location][139:128]= 12'd4095;
	RMEM6[location][160:159]=2'b11;
	RMEM6[location][127:0]= 128'b1; /// j out is the lru pointer
	if(write !=1)
	data_out = RMEM6[location][160:0];
	else
	RMEM6[location][160:0]={1'b1, 1'b1, tag, 12'd4095,data_in};	
end

else if(memrd_7)
begin	
	mini_rmem1 = temp[0];
	for(i=1; i<12'd4096; i= i + 1'b1 )
	begin
	if(temp[i] < mini_rmem1)
	begin
	mini_rmem1 =  temp[i];
	location = i+1;
	end
	end
	RMEM7[location][158:140]= tag; // 
	RMEM7[location][139:128]= 12'd4095;
	RMEM7[location][160:159]=2'b11;
	RMEM7[location][127:0]= 128'b1; /// j out is the lru pointer
	if(write !=1)
	data_out = RMEM7[location][160:0];
	else
	RMEM7[location][160:0]={1'b1, 1'b1, tag, 12'd4095,data_in};	
end

else if(memrd_8)
begin	
	 mini_rmem1 = temp[0];
	for(i=1; i<12'd4096; i= i + 1'b1 )
	begin
	if(temp[i] < mini_rmem1)
	begin
	mini_rmem1 =  temp[i];
	location = i+1;
	end
	end
	RMEM8[location][158:140]= tag; // 
	RMEM8[location][139:128]= 12'd4095;
	RMEM8[location][160:159]=2'b11;
	RMEM8[location][127:0]= 128'b1; /// j out is the lru pointer
	if(write !=1)
	data_out = RMEM8[location][160:0];
	else
	RMEM8[location][160:0]={1'b1, 1'b1, tag, 12'd4095,data_in};	
end
out_reg <= (offset==4'b0000)? data_out[31:0]:(offset==4'b0001)? data_out[63:32]:(offset==4'b0010)?data_out[95:64]:(offset==4'b0011)?data_out[127:96]: 32'b0;
end
end
// lru find the block check its dirty bit and do wrtieback if it is set else just replace in cache
initial
begin
$monitor("count is: %d", counter);

$monitor("RMEM is: %b", RMEM1[0][160:0]);
end
endmodule
