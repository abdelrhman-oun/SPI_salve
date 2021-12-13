
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Abdelrahman Oun
// 
// Create Date:    15:19:12 14/10/2021 
// Design Name: 
// Module Name:    SPIslave_FSMController 
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

module SPIsalve_FSMController (
	//input internal signal indicates that the counter overflow
	input wire coutner_tick,
	
	//input internal signal indicates that the mode of operation is write
	input wire OP_Wr,
	
	//input internal signal indicates that the mode of operation is read
	input wire OP_Rd,
	
	//input clock to the system 
	input wire SCLK,
	
	//input to the system used as active high reset
	input wire SS,
	
	//output internal control signal is used to select the source of the data will be written into the shift register 
	output reg DataSel,
	
	//output internal control signal indicates address is valid to be captured
	output reg Address_en,
	
	//output internal control signal indicates write data is valid to be captured
	output reg Wr_Data_en,
	
	//output internal control signal is used to activate the incrementer to increment the current address to the next one
	output reg incr_sel,
	
	//output form the system to REG file as read enable signal
	output reg Rd_EN
	);
	
	//local parameter to define the FSM states
	localparam [2:0] IDLE = 3'b000,
							address = 3'b001,
							general = 3'b010,
							mul_write = 3'b011,
							mul_read = 3'b100;
	
	//at each state we define three types of states
	// current state : defines the state of this time
	// next state : defines the state which going next
	// operation state : defines the mode of this operation
	//							holds values mul_write (3'b011) to indicates the operation mode is write
	//							and mul_read (3'b100) to indicates the operation mode is read
	reg [2:0] current_state,next_state,operation_state;
	
	
	///////////////////////////////////////////////////////////////////////////////////
	// sequential always to reset the system and assign the current state to next state
	///////////////////////////////////////////////////////////////////////////////////
	always @ (posedge SCLK or posedge SS)	begin
		if(SS)	begin
			current_state <= IDLE ;
			operation_state <= 3'b000;
		end
		else	begin
			current_state <= next_state ;
		end
	end

	///////////////////////////////////////////////////////////////////////////////////////////
	//	 combinational always to assign the next state and the operation state due ot the inputs
	///////////////////////////////////////////////////////////////////////////////////////////
	always @ (*)	begin
		case(current_state)
		IDLE : begin
      
			if(coutner_tick)	begin
				//next state will be address state 
				next_state = address;
				if(OP_Wr)
					// multi operation is write operation
					operation_state = mul_write;
				else if (OP_Rd)
					// multi operation is read operation
					operation_state = mul_read;
				else
					// if something wrong go to idel state
					operation_state = IDLE;
			
			end
			else
				//stay in idle state untill the counter tick
				next_state = IDLE;
			end
		
		address : begin
			if(coutner_tick)
				// next steate will be general steate (write mode or read mode)
				next_state = general;
			else
				// stay in address state untill the counter tick
				next_state = address;
		end
		
		general : begin
			if(coutner_tick)
				// next stete will be operation state which means it depends on the mode of operation
				next_state = operation_state;
			else
				// stay in general untill the counter tick
				next_state = general;
		end
		
		mul_write : begin
			// stay in the multi write mode untill the system is reset
			next_state = mul_write;
		end
		
		mul_read : begin
			// stay in the multi read mode untill the system is reset
			next_state = mul_read;
		end
		endcase
	end
	
	
	////////////////////////////////////////////////////////////////////////////////////////////
	//	 combinational always to assign the output control signals depending on the input signals
	//  the flow of  the signal is  illustrated in  the attached documentation of the  SPI slave
	////////////////////////////////////////////////////////////////////////////////////////////
	always @ (*)
	begin
		case(current_state)
		IDLE : begin
			DataSel = 1'b1;
			Address_en = 1'b0;
			Wr_Data_en = 1'b0;
			incr_sel = 1'b0;
			Rd_EN = 1'b0;
		end
    
		address : begin
			Wr_Data_en = 1'b0;
			incr_sel = 1'b0;

			if(coutner_tick)	begin
				Address_en = 1'b1;
				if(operation_state == mul_write)	begin
					Rd_EN = 1'b0;
					DataSel = 1'b1;
				end
				else if(operation_state == mul_read)	begin
					Rd_EN = 1'b1;
					DataSel = 1'b0;
				end
				else	begin
					Rd_EN = 1'b0;
					DataSel = 1'b1;
				end
			end
			else	begin
				Address_en = 1'b0;
				Rd_EN = 1'b0;
				DataSel = 1'b1;
			end
		end
    
		general : begin
			Address_en = 1'b0;
			
			if(coutner_tick)	begin
				if(operation_state == mul_write)	begin
					DataSel = 1'b1;
					Wr_Data_en = 1'b1;
					Rd_EN = 1'b0;
					incr_sel = 1'b0;
				end
				else if(operation_state == mul_read)	begin
					DataSel = 1'b0;
					Wr_Data_en = 1'b0;
					Rd_EN = 1'b1;
					incr_sel = 1'b1;
				end
				else	begin
					DataSel = 1'b1;
					Wr_Data_en = 1'b0;
					Rd_EN = 1'b0;
					incr_sel = 1'b0;
				end
			end
			else	begin
				DataSel = 1'b1;
				Wr_Data_en = 1'b0;
				Rd_EN = 1'b0;
				incr_sel = 1'b0;
			end
		end
		
		mul_write : begin
			DataSel = 1'b1;
			Address_en = 1'b0;
			Rd_EN = 1'b0;
			if(coutner_tick)	begin
				incr_sel = 1'b1;
				Wr_Data_en = 1'b1;
			end
			else	begin
				incr_sel = 1'b0;
				Wr_Data_en = 1'b0;
			end
		end
    
		mul_read : begin
			Address_en = 1'b0;
			Wr_Data_en = 1'b0;
      
			if(coutner_tick)	begin
				DataSel = 1'b0;
				incr_sel = 1'b1;
				Rd_EN = 1'b1;
			end
			else	begin
				DataSel = 1'b1;
				incr_sel = 1'b0;
				Rd_EN = 1'b0;
			end
		end
		endcase
	end
	
endmodule
