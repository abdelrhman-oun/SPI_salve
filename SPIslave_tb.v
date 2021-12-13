`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Abdelrahman
//
// Create Date:   14/10/2021 
// Design Name:   SPIslave_Top
// Module Name:   E:/Si-Vision internship/internship Assignment/project/SPI_slave/SPIslave_tb.v
// Project Name:  SPI_slave
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: SPIslave_Top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module SPIslave_tb;
  
  parameter  WIDTH = 8;
  
  parameter CLK_PERIOD = 50 ;           //  Frequency 20 MHz
  
  // inputs
  reg [WIDTH-1:0] Rd_Data_tb;
  reg MOSI_tb,SCLK_tb,SS_tb,RST_tb;
  
  // outputs
  wire MISO_tb,Wr_EN_tb,Rd_EN_tb;
  wire [WIDTH-1:0] Address_tb,Wr_Data_tb;
  
  // internal variables to be used in testbench
  reg result;
  reg [WIDTH-1:0] T_Data,T_Data2,T_Data3,T_Data4,T_Data5;
  integer i;
  
  /////////////////// DUT Instantation ///////////////////
  SPIslave_Top #(
    .WIDTH(WIDTH)
  ) DUT (
      .Rd_Data(Rd_Data_tb),
      .MOSI(MOSI_tb),
      .SCLK(SCLK_tb),
      .SS(SS_tb),
      .RST(RST_tb),
      .MISO(MISO_tb),
      .Wr_EN(Wr_EN_tb),
      .Rd_EN(Rd_EN_tb),
      .Address(Address_tb),
      .Wr_Data(Wr_Data_tb)
  );

////////////////// Clock Generator  ////////////////////
  always #(CLK_PERIOD/2) SCLK_tb = ~SCLK_tb ; 
  
  
  //Initial 
  initial
  begin
  
    //initialization
    initialize() ;
  
    //Reset the design
    reset();
    
    //test single write operation
    single_write_op(8'b00110101, 8'b00011011, result);
    if(result == 1)
      $display("test case of single write is ok");
    else
      $display("test case of single write is NOT ok");
      
    //Reset the design
    reset();
      
    //test Multi write operation
    five_write_op(8'b00110101, 8'b00011011, 8'b11001010, 8'b01010010, 8'b11001010, 8'b00011110, result);
    if(result == 1)
      $display("test case of Multi write is ok");
    else
      $display("test case of Multi write is NOT ok");
    
    //Reset the design
    reset();
  
    
    //test Single read operation
    single_read_op(8'b00110101, 8'b00011011, result);
    if(result == 1)
      $display("test case of Single read is ok");
    else
      $display("test case of Single read is NOT ok");
      
    //Reset the design
    reset();
      
    //test Multi read operation
    five_read_op(8'b00110101, 8'b11011011, 8'b11001010, 8'b01010010, 8'b11001010, 8'b00011110, result);
    if(result == 1)
      $display("test case of Multi read is ok");
    else
      $display("test case of Multi read is NOT ok");
    
    //Reset the design
    SS_tb = 1'b1;
  
    
    #500;
    $stop ;
    
  end
  
  
  /***************************************************************************************/
  ///////////////////////////////////// TASKS ////////////////////////////////////////////
  /*************************************************************************************/
  
  /////////////////////////////////////// Signals Initialization ////////////////////////
  task initialize ;
  begin
    Rd_Data_tb = 'h00;
    MOSI_tb = 1'b0;
    SCLK_tb = 1'b0;
    SS_tb = 1'b1;
    RST_tb = 1'b0;
    result = 1'b0;
    T_Data = 'h00;
    i = 0;
  end
  endtask
  
  //////////////////////////////////////// RESET /////////////////////////////////////////////  
  task reset ;
  begin 
    #5
    SS_tb = 1'b1;
    RST_tb = 1'b0;  
    #7.5
    SS_tb = 1'b0;
    RST_tb = 1'b1;  
  end
  endtask
  
  ////////////////////////////////////test Single write operation//////////////////////////////
  task single_write_op ;
    input  [WIDTH-1:0]     address;
    input  [WIDTH-1:0]     data;
    output result;
   
  begin
    #((3*CLK_PERIOD)/4)
    
    result = 0;
    
    #(5*CLK_PERIOD)
    MOSI_tb = 1'b1;
    #CLK_PERIOD
    MOSI_tb = 1'b0;
    
    for ( i = 7 ; i >= 0 ; i = i -1 )
    begin
      #CLK_PERIOD
      MOSI_tb = address[i];
    end
    
    #CLK_PERIOD
    MOSI_tb = data[7];
    
    #((3*CLK_PERIOD)/4)
    if(Address_tb == address)
    begin
      $display("writing address is ok");
      result = 1;
    end
    else
    begin
      $display("writing address is NOT ok");
      result = 0;
    end
    
    #(CLK_PERIOD/4)
    MOSI_tb = data[6];
    
    for ( i = 5 ; i >= 0 ; i = i -1 )
    begin
      #CLK_PERIOD
      MOSI_tb = data[i];
    end
    #CLK_PERIOD
    MOSI_tb = 1'b0;
    #CLK_PERIOD
    if(Wr_Data_tb == data)
    begin
      $display("writing data is ok");
      result = 1;
    end
    else
    begin
      $display("writing data is NOT ok");
      result = 0;
    end
    
    
    
  end
  endtask
  
  //////////////////////////////////test Multi write operation///////////////////////////////
  task five_write_op ;
    input  [WIDTH-1:0]     address;
    input  [WIDTH-1:0]     data1;
    input  [WIDTH-1:0]     data2;
    input  [WIDTH-1:0]     data3;
    input  [WIDTH-1:0]     data4;
    input  [WIDTH-1:0]     data5;
    output result;
   
  begin
    result = 0;
    #((3*CLK_PERIOD)/4)
    
    #(5*CLK_PERIOD)
    MOSI_tb = 1'b1;
    #CLK_PERIOD
    MOSI_tb = 1'b0;
    
    for ( i = 7 ; i >= 0 ; i = i -1 )
    begin
      #CLK_PERIOD
      MOSI_tb = address[i];
    end
    
    #CLK_PERIOD
    MOSI_tb = data1[7];
    
    #((3*CLK_PERIOD)/4)
    if(Address_tb == address)
    begin
      $display("writing address is ok");
      result = 1;
    end
    else
    begin
      $display("writing address is NOT ok");
      result = 0;
    end
    
    #(CLK_PERIOD/4)
    MOSI_tb = data1[6];
    
    for ( i = 5 ; i >= 0 ; i = i -1 )
    begin
      #CLK_PERIOD
      MOSI_tb = data1[i];
    end
    
    #CLK_PERIOD
    MOSI_tb = data2[7];
    
    #((3*CLK_PERIOD)/4)
    if(Wr_Data_tb == data1)
    begin
      $display("writing data1 is ok");
      result = 1;
    end
    else
    begin
      $display("writing data1 is NOT ok");
      result = 0;
    end
    
    #(CLK_PERIOD/4)
    MOSI_tb = data2[6];
    
    for ( i = 5 ; i >= 0 ; i = i -1 )
    begin
      #CLK_PERIOD
      MOSI_tb = data2[i];
    end
    
    #CLK_PERIOD
    MOSI_tb = data3[7];
    
    #((3*CLK_PERIOD)/4)
    if(Wr_Data_tb == data2)
    begin
      $display("writing data2 is ok");
      result = 1;
    end
    else
    begin
      $display("writing data2 is NOT ok");
      result = 0;
    end
    
    #(CLK_PERIOD/4)
    MOSI_tb = data3[6];
    
    for ( i = 5 ; i >= 0 ; i = i -1 )
    begin
      #CLK_PERIOD
      MOSI_tb = data3[i];
    end
    
    #CLK_PERIOD
    MOSI_tb = data4[7];
    
    #((3*CLK_PERIOD)/4)
    if(Wr_Data_tb == data3)
    begin
      $display("writing data3 is ok");
      result = 1;
    end
    else
    begin
      $display("writing data3 is NOT ok");
      result = 0;
    end
    
    #(CLK_PERIOD/4)
    MOSI_tb = data4[6];
    
    for ( i = 5 ; i >= 0 ; i = i -1 )
    begin
      #CLK_PERIOD
      MOSI_tb = data4[i];
    end
    
    #CLK_PERIOD
    MOSI_tb = data5[7];
    
    #((3*CLK_PERIOD)/4)
    if(Wr_Data_tb == data4)
    begin
      $display("writing data4 is ok");
      result = 1;
    end
    else
    begin
      $display("writing data4 is NOT ok");
      result = 0;
    end
    
    #(CLK_PERIOD/4)
    MOSI_tb = data5[6];
    
    for ( i = 5 ; i >= 0 ; i = i -1 )
    begin
      #CLK_PERIOD
      MOSI_tb = data5[i];
    end
    
    #CLK_PERIOD
    MOSI_tb = 1'b0;
    #CLK_PERIOD
    if(Wr_Data_tb == data5)
    begin
      $display("writing data5 is ok");
      result = 1;
    end
    else
    begin
      $display("writing data5 is NOT ok");
      result = 0;
    end
    
    
  end
  endtask
  ////////////////////////////////test Single read operation///////////////////////////
  task single_read_op ;
    input  [WIDTH-1:0]     address;
    input  [WIDTH-1:0]     data;
    output result;
   
  begin
    #((3*CLK_PERIOD)/4)
    result = 0;
    #(5*CLK_PERIOD)
    MOSI_tb = 1'b1;
    #CLK_PERIOD
    MOSI_tb = 1'b1;
    
    for ( i = 7 ; i >= 0 ; i = i -1 )
    begin
      #CLK_PERIOD
      MOSI_tb = address[i];
    end
    
    #(CLK_PERIOD/4)
    Rd_Data_tb = data;
    #((3*CLK_PERIOD)/2)
    T_Data[7] = MISO_tb;
    
    #(CLK_PERIOD/4)
    if(Address_tb == address)
    begin
      $display("writing address is ok");
      result = 1;
    end
    else
    begin
      $display("writing address is NOT ok");
      result = 0;
    end
    #((3*CLK_PERIOD)/4)
    T_Data[6] = MISO_tb;
    
    for ( i = 5 ; i >= 0 ; i = i -1 )
    begin
      #CLK_PERIOD
      T_Data[i] = MISO_tb;
    end
    
    #CLK_PERIOD
    if(T_Data == data)
    begin
      $display("reading data is ok");
      result = 1;
    end
    else
    begin
      $display("reading data is NOT ok");
      result = 0;
    end
    
    MOSI_tb = 1'b0;
    
  end
  endtask
  
  ///////////////////////////////test Multi read operation//////////////////////////////
  task five_read_op ;
    input  [WIDTH-1:0]     address;
    input  [WIDTH-1:0]     data1;
    input  [WIDTH-1:0]     data2;
    input  [WIDTH-1:0]     data3;
    input  [WIDTH-1:0]     data4;
    input  [WIDTH-1:0]     data5;
    output result;
   
  begin
    #(CLK_PERIOD/4)
    result = 0;
    #(6*CLK_PERIOD)
    MOSI_tb = 1'b1;
    #CLK_PERIOD
    MOSI_tb = 1'b1;
    
    for ( i = 7 ; i >= 0 ; i = i -1 )
    begin
      #CLK_PERIOD
      MOSI_tb = address[i];
    end
    
    #(CLK_PERIOD/4)
    Rd_Data_tb = data1;
    #((3*CLK_PERIOD)/2)
    T_Data[7] = MISO_tb;
    
    #(CLK_PERIOD/4)
    if(Address_tb == address)
    begin
      $display("writing address is ok");
      result = 1;
    end
    else
    begin
      $display("writing address is NOT ok");
      result = 0;
    end
    #((3*CLK_PERIOD)/4)
    T_Data[6] = MISO_tb;
    
    for ( i = 5 ; i >= 0 ; i = i -1 )
    begin
      #CLK_PERIOD
      T_Data[i] = MISO_tb;
    end
    Rd_Data_tb = data2;
    
    #CLK_PERIOD
    T_Data2[7] = MISO_tb;
    if(T_Data == data1)
    begin
      $display("reading data1 is ok");
      result = 1;
    end
    else
    begin
      $display("reading data1 is NOT ok");
      result = 0;
    end
    
    #CLK_PERIOD
    T_Data2[6] = MISO_tb;
    for ( i = 5 ; i >= 0 ; i = i -1 )
    begin
      #CLK_PERIOD
      T_Data2[i] = MISO_tb;
    end
    
    Rd_Data_tb = data3;
    
    #CLK_PERIOD
    T_Data3[7] = MISO_tb;
    if(T_Data2 == data2)
    begin
      $display("reading data2 is ok");
      result = 1;
    end
    else
    begin
      $display("reading data2 is NOT ok");
      result = 0;
    end
    
    #CLK_PERIOD
    T_Data3[6] = MISO_tb;
    for ( i = 5 ; i >= 0 ; i = i -1 )
    begin
      #CLK_PERIOD
      T_Data3[i] = MISO_tb;
    end
    
    Rd_Data_tb = data4;
    
    #CLK_PERIOD
    T_Data4[7] = MISO_tb;
    if(T_Data3 == data3)
    begin
      $display("reading data3 is ok");
      result = 1;
    end
    else
    begin
      $display("reading data3 is NOT ok");
      result = 0;
    end
    
    #CLK_PERIOD
    T_Data4[6] = MISO_tb;
    for ( i = 5 ; i >= 0 ; i = i -1 )
    begin
      #CLK_PERIOD
      T_Data4[i] = MISO_tb;
    end
    
    Rd_Data_tb = data5;
    
    #CLK_PERIOD
    T_Data5[7] = MISO_tb;
    if(T_Data4 == data4)
    begin
      $display("reading data4 is ok");
      result = 1;
    end
    else
    begin
      $display("reading data4 is NOT ok");
      result = 0;
    end
    
    #CLK_PERIOD
    T_Data5[6] = MISO_tb;
    for ( i = 5 ; i >= 0 ; i = i -1 )
    begin
      #CLK_PERIOD
      T_Data5[i] = MISO_tb;
    end
    
    #CLK_PERIOD
    if(T_Data5 == data5)
    begin
      $display("reading data5 is ok");
      result = 1;
    end
    else
    begin
      $display("reading data5 is NOT ok");
      result = 0;
    end
    
    MOSI_tb = 1'b0;
    
  end
  endtask


endmodule



