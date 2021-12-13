
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Abdelrahman Oun
// 
// Create Date:    14/10/2021 
// Design Name: 
// Module Name:    SPIslave_Top 
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
module SPIslave_Top#(
	// parametr to define the width of the address bus and the data bus
	parameter WIDTH = 8
	)(
	// input bus to the system from REG file as read data 
	input wire [WIDTH-1:0] Rd_Data,
	
	// input signal to the system from the master (master output salve input)
	input wire MOSI,
	
	//input clock to the system
	input wire SCLK,
	
	// input slave select from SPI slave master
	input wire SS,
	
	// input active low reset
	input wire RST,
	
	// output signal from the system to the master (master input slave output)
	output wire MISO,
	
	// output signal from the system to REG file to write enable
	output wire Wr_EN,
	
	//output form the system to REG file as read enable signal
	output wire Rd_EN,
	
	// output bus from the system to REG file as address bus to write in or read from
	output wire [WIDTH-1:0] Address,
	
	// output bus from the system to REG file as data to write into
	output wire [WIDTH-1:0] Wr_Data
	
	);
  
	// internal signals to connect between different blocks
	wire counter_tick,OP_Wr,OP_Rd,DataSel,Address_en,Wr_Data_en,incr_sel;
	// internal bus holds the value of shift register
	wire [WIDTH-1:0] Data_sh;
  
	SPIsalve_FSMController FSM_1 (
		.coutner_tick(counter_tick),
		.OP_Wr(OP_Wr),
		.OP_Rd(OP_Rd),
		.SCLK(SCLK),
		.SS(SS),
		.DataSel(DataSel),
		.Address_en(Address_en),
		.Wr_Data_en(Wr_Data_en),
		.incr_sel(incr_sel),
		.Rd_EN(Rd_EN)
		);
		
	SPIslave_SHregister #(
		.WIDTH(WIDTH)
		) SH_Register_1 (
		.Rd_Data(Rd_Data),
		.MOSI(MOSI),
		.DataSel(DataSel),
		.CLK(SCLK),
		.RST(SS),
		.MISO(MISO),
		.OP_Wr(OP_Wr),
		.OP_Rd(OP_Rd),
		.Data_sh(Data_sh)
		);
		
		
	SPIslave_InternalComponent #(
		.WIDTH(WIDTH)
		) SPI_1 (
		.Data_sh(Data_sh),
		.Address_en(Address_en),
		.Wr_Data_en(Wr_Data_en),
		.incr_sel(incr_sel),
		.SCLK(SCLK),
		.SS(SS),
		.RST(RST),
		.coutner_tick(counter_tick),
		.Wr_EN(Wr_EN),
		.Address(Address),
		.Wr_Data(Wr_Data)  
	);

endmodule


