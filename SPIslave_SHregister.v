
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Abdelrahman Oun
// 
// Create Date:    14/10/2021 
// Design Name: 
// Module Name:    SPIslave_SHregister 
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
module SPIslave_SHregister #(
	// parametr to define the width of the address bus and the data bus
	parameter WIDTH = 8
	)(
	// input bus to the system from REG file as read data 
	input wire [WIDTH-1:0] Rd_Data,
	
	// input signal to the system from the master (master output salve input)
	input wire MOSI,
	
	// input internal control signal from FSM is used to select the source of the data will be written into the shift register  
	input wire DataSel,
	
	// input clock to the shift register
	input wire CLK,
	
	// input active low reset
	input wire RST,
	
	// output signal from the system to the master (master input slave output)
	output wire MISO,
	
	// output internal control signal indicates that the operation mode is write
	output wire OP_Wr,
	
	// output internal control signal indicates that the operation mode is read
	output wire OP_Rd,
	
	// ouput internal bus holds the value of the shift register
	output wire [WIDTH-1:0] Data_sh
	);
	
	// shift register is working with postive edge of clk signal
	reg [WIDTH-1:0] Data_in;
	
	// shift register is working wigh negative edge of clk signal 
	reg [WIDTH-1:0] Data_out;
	
	// integer to be used in the for loop
	integer i;
	
	// internal signal holds the inverted version of clock
	wire CLK_inv;
	
	// assign the clk_inv to the clock invert
	assign CLK_inv = ~CLK;
	
	// assign the MISO signal to the MSB of Data_out
	assign MISO = Data_out[WIDTH-1];
	
	// assign the Data_sh bus to the Data_in register
	assign Data_sh = Data_in;
	
	// assign the op_wr signal to 1 if the operation code is 0x2 and 0 otherwise 
	assign OP_Wr = (Data_in == 8'h02)? 1'b1 : 1'b0;
	
	// assign the op_wr signal to 1 if the operation code is 0x3 and 0 otherwise 
	assign OP_Rd = (Data_in == 8'h03)? 1'b1 : 1'b0;
	
	
	//////////////////////////////////////////////////////////////////////////
	// sequential always to reset the system and assign Data_in shift register
	//////////////////////////////////////////////////////////////////////////
	always @ (posedge CLK or posedge RST)	begin
		if(RST)	begin
			// reset the shift register
			Data_in <= {WIDTH {1'b0}};
		end
		else	begin
			// perform shift operation
			Data_in[0] <= MOSI;
			for(i=1; i<WIDTH;i = i+1)	begin
				Data_in[i] <= Data_in[i-1];
			end
		end
	end
  
	//////////////////////////////////////////////////////////////////////////
	// sequential always to reset the system and assign Data_out shift register
	//////////////////////////////////////////////////////////////////////////
	always @ (posedge CLK_inv or posedge RST)	begin
		if(RST)	begin
			// reset the shift registerData_out <= WIDTH {1'b0};
			Data_out <= {WIDTH {1'b0}};
		end
		else	begin
			if(DataSel)	begin
				// perform shift operation
				Data_out[0] <= MOSI;
				for(i=1; i<WIDTH;i = i+1)	begin
					Data_out[i] <= Data_out[i-1];
				end
			end
			else	begin
				// insert the value of read data from REG file to Data_out shift register
				Data_out <= Rd_Data;
			end
		end  
	end
  
  
endmodule


















