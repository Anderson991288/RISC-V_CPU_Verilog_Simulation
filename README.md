# RISC-V_CPU

Implementing a simple RISC-V processor in Verilog.

## Outline:
* Design a single-cycle 32-bit RISC-V processor 
* Use vivado to view waveform 
* Run the test codes

## RV32I Base Instruction Set: 

![RV32I Base Instruction Set](https://user-images.githubusercontent.com/68816726/221367757-ee89f98c-b9be-4689-9452-a6259137e76d.png)

*The last 7 bit are opcode.

### if.v (single cycle) :

![未命名绘图](https://user-images.githubusercontent.com/68816726/221366863-2b04d18a-567b-40a4-88bc-509f29fb84f8.jpg)
```
module PC(

	input	wire 		clk,
	input	wire		rst,
	input 	wire		Branch,  // if branch or not
	input 	wire[31:0] 	Addr,	 // target address
	output 	reg 	 	ce,
	output	reg [31:0] 	PC

);

always @ (posedge clk) begin
	if (rst)
		ce <= 1'b0;
	else
		ce <= 1'b1;
end

always @ (posedge clk) begin
	if (!ce)
		PC <= 32'b0;
	else if (Branch)
		PC <= Addr;
	else
		PC <= PC + 4'h4;  // New PC equals ((old PC) + 4) per cycle.
end

endmodule
```

Program Counter : 用於控制計數器。

在這個模塊中，總共有兩個always block。

第一個always block根據重置訊號rst來控制ce訊號，重置訊號為1時，ce訊號為0，否則為1。

第二個always block根據ce訊號和Branch訊號來控制PC訊號。如果ce訊號為0，表示需要重置程序計數器，PC訊號為0。如果Branch訊號為1，表示需要跳轉到指定地址，PC訊號為目標地址Addr。否則，PC訊號等於上一個周期的PC訊號加4。

因為每個指令的大小都是4 bit，所以程式計數器需要加4才能指向下一個指令的地址。

### id.v (single cycle) :

* Decode the instruction, get ALUop by opcode, funct3 and funct7
* Determine whether the registers need to be read, and send the register numbers rs1, rs2 to the register file, and read the corresponding data as the source operands.
* Sign extension (or unsigned extension) for instructions containing immediate values as one of the source operands










# RISC-V_CPU_Verilog_Simulation

### 1.Convert to machine code by assembler

(assembly.asm to machinecode)

![Screenshot 2023-02-06 214127](https://user-images.githubusercontent.com/68816726/216986967-2e03f3f7-9afd-4786-8c0e-f4503aa314f8.png)

### 2.Put the converted machine code under the same path as the vivado project.Read the machine code by inst_mem 

![Screenshot 2023-02-06 215445](https://user-images.githubusercontent.com/68816726/216989718-2b792495-fcc6-43a2-8de6-9b42676c33a4.png)

### inst_mem.v

```
module inst_mem(

	input	wire		ce,    // chip select signal
	input	wire[31:0]	addr,  // instruction address
	output 	reg [31:0]	inst   // instruction
	
);

	reg[31:0]  inst_memory[0:1000];

	initial $readmemb ("./TestCode/machinecode.txt", inst_memory);	// read test assembly code file

always @ (*) begin
	if (!ce)
		inst <= 32'b0;
	else
		inst <= inst_memory[addr[31:2]];
end

endmodule
```

### 3.waveform : 

### Read the first instruction when the first clock posedge after reset is zero.
### Read the second instruction when the second clock posedge after reset is zero...

![Screenshot 2023-02-06 221529](https://user-images.githubusercontent.com/68816726/216994797-1e047b78-affb-4f0f-85a8-a6318cf0b0a9.png)

