/*`timescale 1 ps / 1 ps

module cache_tb();

localparam CLK_PERIOD = 20; //ns
localparam QSTEP = CLK_PERIOD/4;			//a timestep of quarter clock cycle
localparam TIMESTEP = CLK_PERIOD/10;	//a small timestep

localparam N_INPUTS = 10;
// Initialize the random number to 2
//localparam SEED = 32'd2; 

reg clk;
reg reset;
reg [31:0] i_addr;
reg write;
reg [31:0] data_in;
wire [7:0] set;
wire [18:0] tag;
wire [3:0] offset;
wire [11:0] index;
wire [31:0] out;
wire  hit;
reg [1:0] select;
wire miss;
// Generate a 50MHz clock
initial clk = 1'b1;

always #(CLK_PERIOD) clk = ~clk;


/*/////////////////////////////////////////////////////////////////////////////////////TEST ALL MODES FOR A FIXED INSTURCTION SET, START WITH 00 MODE AND TEST ALL HITS AND MISS FOR SAME SET OF INSTRUCTION
////////////////////////////////////////////////////////////////////////////////////////1. First only write and 2. then read and 3. then both 4. test for all then do previous one*/
/*initial
begin
select = 2'b00;
end
/*#CLK_PERIOD
#CLK_PERIOD  // same adddress read next time is hit (later add some other address adn call 1st address again)
select = 2'b01;
#CLK_PERIOD
#CLK_PERIOD 
select = 2'b10;
#CLK_PERIOD
#CLK_PERIOD 
select = 2'b11;
#CLK_PERIOD
#CLK_PERIOD */


/*cache_set_cu dut2 (
 	.address(i_addr),
	.reset(reset),
	.clk(clk),
	.selection_signal(select),
	.set(set),
 	.tag(tag),
 	.offset(offset),
	.index(index)
);
*//*
test dut1 ( 
  	//.set(set),
	//.tag(tag),
	//.offset(offset),
	// .index(index),
	 .clk(clk),
.address(i_addr),
.selection_signal(select),
	 .reset(reset),       // use
	.data_in(data_in),
	.write(write),
	.out(out),
	.hit(hit),
	.miss(miss)
);

integer i;

initial
begin
	for(i=0; i <= 12'd4095; i=i+1'b1) begin
		dut1.RMEM1 [i] = (5);
	end
end
		/*dut1.RMEM2 [i] = (5);
		dut1.RMEM3 [i] = (5);
		dut1.RMEM4 [i] = (5);
		dut1.RMEM5 [i] = (5);
		dut1.RMEM6 [i] = (5);
		dut1.RMEM7 [i] = (5);
		dut1.RMEM8 [i] = (5);*/



/*
initial
begin
	reset = 1'b0;
	#(CLK_PERIOD);
	reset = 1'b1;
	#(CLK_PERIOD);

	
	write = 1'b1;
	data_in = 32'b0;
	i_addr = 32'b0111_0000_0000_0000_0000_0000_1100_0000;
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	
	write = 1'b1;
	data_in = 32'b10;
	i_addr = 32'b0111_0000_0000_0000_0000_0000_1100_0000;
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	
	write <= 1'b1;
	data_in <= 32'b1;
	i_addr <= 32'd164;
	#(CLK_PERIOD);
	#(CLK_PERIOD);

	write <= 1'b1;
	data_in <= 32'b10;
	i_addr <= 32'd164;
end
endmodule 
/*
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	write <= 1'b0;
	//data_in <= 32'b1;
	i_addr <= 32'b0;
	write <= 1'b0;
	//data_in <= 32'b1;
	i_addr <= 32'd1;*/



	
	// Generate N_INPUTS inputs and deliver to circuit
/*	for (prod_i = 0; prod_i < N_INPUTS; prod_i = prod_i + 1) begin
		
		/*while(!o_ready) begin
			//wait for a clock period before checking o_ready again
			#(CLK_PERIOD);
		end*/

		//start on posedge
		
		//advance quarter cycle
/*		#(QSTEP);
		//generate an input value
		i_addr = prod_rand;
		//only change addr after 2 consecutive accesses
		if(prod_i % 2 == 1) begin
			prod_rand = $random(prod_rand);
		end
	
		//advance quarter cycle (now on negedge)
		#(QSTEP);
		//nothing to do here
		
		//advance another quarter cycle
		#(QSTEP);
		//set i_read or i_write
		//i_read = 1'b1;
		write = 1'b0;
		// i_writedata = 1;
		
		//advance another quarter cycle to next posedge
		#(QSTEP);

		write = 1'b1;

		while(!hit) begin
			#(CLK_PERIOD);
		end

		$display("read value: %d", out);
		#(CLK_PERIOD);

	end
	
	$stop(0);
end
*/

`timescale 1 ns / 1 ps

module cache_tb();

localparam CLK_PERIOD = 20; //ns
localparam QSTEP = CLK_PERIOD/4;			//a timestep of quarter clock cycle
localparam TIMESTEP = CLK_PERIOD/10;	//a small timestep

localparam TAG_WIDTH = 19;
localparam INDEX_WIDTH = 9;

localparam N_INPUTS = 32;
// Initialize the random number to 2
localparam SEED = 32'd2; 

reg clk;
reg reset;
reg [31:0] i_addr;
reg i_read;
reg i_write;
reg [31:0] i_writedata;

wire [31:0] o_readdata;
wire o_readdata_valid;
wire o_ready;
wire hit;
wire miss;


// Generate a 50MHz clock
initial clk = 1'b1;
always #(CLK_PERIOD/2) clk = ~clk;

// Instantiate the circuit
test dut1 ( 
  	//.set(set),
	//.tag(tag),
	//.offset(offset),
	// .index(index),
	 .clk(clk),
.address(i_addr),
.selection_signal(select),
	 .reset(reset),       // use
	.data_in(i_writedata),
	.write(i_write),
	.out(o_readdata),
	.hit(hit),
	.miss(miss)
);


reg [31:0] prod_rand = SEED;
integer prod_i;
initial begin
	i_read = 1'b0;
	i_write = 1'b0;
	i_writedata = 0;

	// Toggle the reset
	reset = 1'b1;
	#(CLK_PERIOD);
	#(CLK_PERIOD);
	reset = 1'b0;
	#(CLK_PERIOD);
	
	// Generate N_INPUTS inputs and deliver to circuit
	for (prod_i = 0; prod_i < N_INPUTS; prod_i = prod_i + 1) begin
		
		while(!o_ready) begin
			//wait for a clock period before checking o_ready again
			#(CLK_PERIOD);
		end

		//start on posedge
		
		//generate an input value
		i_addr = prod_rand;

		//set i_read or i_write
		i_write = 1'b1;
		// i_write = 1'b1;
		// i_writedata = 1;

		//only change addr after 2 consecutive accesses
		if(prod_i % 2 == 1) begin
			//prod_rand = $random(prod_rand);
			prod_rand = prod_rand + 1048576;
		end

		//advance to next posedge
		#(CLK_PERIOD);

		
		i_write = 1'b0;

		while(!o_readdata_valid) begin
			#(CLK_PERIOD);
		end
		
		$display("read value: %d", o_readdata);
		#(CLK_PERIOD);
	end
	
	$stop(0);
end

endmodule



