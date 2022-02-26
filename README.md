# SPI_salve

Specifications:
  - The BLE50 SPI Slave is interfacing with Register File through pins (Address, Wr_EN, Wr_Data, Rd_EN, Rd_Data).
  - SPI Slave receives new packet on SS activated (SS is active low).
  - The master sends clock on SCLK and the first byte is command byte:
    o 0x02: the master will send data.
    o 0x03: the master needs data form the slave.
  - After receiving the command master will send the address that will be write on it or read from it.
  - SS is active along the whole operation.
  - Two modes of operation:
    o Single byte it detected if the byte received/sent and the SS is deactivated.
    o More than one byte if after sending/receiving SS is still activated the address incremented to write on/read from next location.


I/O ports description:
  -- Input ports:
  - **SS**: Slave select active low pin, it acts as asynchronous active high reset and enables the slave to communicate with the master.
  - **SCLK**: Serial Clock, master generates this clock for the communication.
  - **MOSI**: Master output Slave input, Master transmit data through this pin.
  - **Rd_Data**: Read data bus, this bus holds the data form register file which located in the address on the Address bus.
  -- Output ports:
  - **MISO**: Master input Slave output, Slave transmit data through this pin.
  - **Address**: contains the Address that the slave will read from or write on.
  - **Wr_Data**: Write Data bus, this bus holds the data received from the master that will be written on the register file.
  - **Wr_EN**: Write enable flag to allow slave to write on the register file.
  - **Rd_EN**: Read enable flag to allow slave to read from the register file.
