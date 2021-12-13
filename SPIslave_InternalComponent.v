
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Abdelrahman Oun
// 
// Create Date:     14/10/2021 
// Design Name: 
// Module Name:    SPIslave_InternalComponent 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module SPIslave_InternalComponent #(
	// parametr to define the width of the address bus and the data bus
	parameter WIDTH = 8
	)(
	// input internal bus from shift register
	input wire [WIDTH-1:0] Data_sh,
	
	// input internal control signal from FSM indicates address is valid to be captured 
	input wire Address_en,
	
	// input internal control signal from FSM indicates write data is valid to be captured
	input wire Wr_Data_en,
	
	// input internal control signal from FSM is used to activate the incrementer to increment the current address to the next one
	input wire incr_sel,
	
	// input clock to the system 
	input wire SCLK,
	
	// input slave select from SPI slave master
	input wire SS,
	
	// input the system as active low reset
	input wire RST,
	
	// output internal control singal indicates that the counter overflow
	output reg coutner_tick,
	
	// output signal from the system to REG file to write enable
	output reg Wr_EN,
	
	// output bus from the system to REG file as address bus to write in or read from
	output reg [WIDTH-1:0] Address, 
	
	// output bus from the system to REG file as data to write into
	output reg [WIDTH-1:0] Wr_Data
	);
  
	// local parameter to define the width of the counter
	parameter COUNTER_WIDTH = $clog2(WIDTH);
	
	// defining the counter to count number of bits entered to the system
	reg [COUNTER_WIDTH:0] counter;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// sequential always to reset the system and assign the outputs form SPI slave to REG file
	//////////////////////////////////////////////////////////////////////////////////////////
	always @ (posedge SCLK or negedge RST)	begin 
		if (!RST)	begin
			// reset all registers
			Address <= {WIDTH {1'b0}};
			Wr_Data <= {WIDTH {1'b0}};
			Wr_EN <= 1'b0;
		end
    
		else	begin
			if(!SS)	begin
        
				if(Wr_Data_en)	begin
					// assign the data of write data bus to shift register
					Wr_Data <= Data_sh;
					// assign the write enable signal to one to enable REG file to write the data
					Wr_EN <= 1'b1;
				end
				else	begin
					// write data bus still the same and deactivate the enable signal
					Wr_EN <= 1'b0;
				end
        
				if(incr_sel)
					// increment the address bus to the next address to enable multi mode
					Address <= Address + 1;
				else if (Address_en)
					// assign the address bus to data from the shift register
					Address <= Data_sh;
				else begin
					// address bus still the same
				end
			end
		end
	end
	
	///////////////////////////////////////////////////////////////////////////
	// sequential always to reset the counter and handle the counter operations
	///////////////////////////////////////////////////////////////////////////
	
	always @ (posedge SCLK or posedge SS)	begin 
	
		if(SS)	begin
			// reset the conter and the conter tick register
			counter <= {COUNTER_WIDTH {1'b0}};
			coutner_tick <= 1'b0;
		end
		else	begin
			if (counter == WIDTH-1)	begin
				// reset the counter when overflow happen
				counter <= {COUNTER_WIDTH {1'b0}};
				// conter tick with overflow of the counter
				coutner_tick <= 1'b1;
			end
			else	begin
				// increment the counter withe each clock cycle
				counter <= counter +1;
				coutner_tick <= 1'b0;
			end
		end
	end
  
endmodule

