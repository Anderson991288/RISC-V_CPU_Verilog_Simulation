# RISC-V_CPU

Implementing a simple RISC-V processor in Verilog.

## Outline:
* Design a single-cycle 32-bit RISC-V processor 
* Use vivado to view waveform 
* Run the test codes

## RV32I Base Instruction Set: 

| Instruction  | Funct3 | Funct6/7 | Opcode | 
| :--------:| :----:  | :------: | :------:|
|    add    |   000   | 0000000  | 0110011 |
|    addi   |  000    |   N/A    | 0010011 |
|    and    |   111   | 0000000  | 0110011 |
|    or     |   110   | 0000000  | 0110011 |
|    xor    |   100   | 0000000  | 0110011 |
|    lw     |   010   |   N/A    | 0000011 |
|    sw     |  010    |   N/A    | 0100011 | 
|    blt    |  100    |   N/A    | 1100111 |
|    beq    |   000   |   N/A    | 1100111 |
|    jal    |  N/A    |   N/A    | 1101111 |
|    sll    |  001    | 0000000  | 0110011 |
|    srl    | 101     | 0000000  | 0110011 | 

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

* Program Counter : 用於控制計數器。

* 第一個always block根據重置訊號rst來控制ce訊號，重置訊號為1時，ce訊號為0，否則為1。

* 第二個always block根據ce訊號和Branch訊號來控制PC訊號。如果ce訊號為0，表示需要重置程序計數器，PC訊號為0。如果Branch訊號為1，表示需要跳轉到指定地址，PC訊號為目標地址Addr。否則，PC訊號等於上一個周期的PC訊號加4。

* 因為每個指令的大小都是4 bit，所以程式計數器需要加4才能指向下一個指令的地址。

### id.v (single cycle) :

* 將前面所得的指令進行decode，根據opcode, funct3, funct7決定ALUop

| Instruction | opcode  | funct3 | funct7  | ALUop  |
| :---------: | :-----: | :----: | :-----: | :----: |
|     add     | 0110011 |  000   | 0000000 | 01101  |
|     sub     | 0110011 |  000   | 0100000 | 01110  |
|     sw      | 0100011 |  001   | N/A     | 10101  |
|     lw      | 0000011 |  010   |   N/A   | 10100  |
|     addi    | 0010011 |  000   | N/A     | 01100  |

```
always @ (*) begin
    if (rst)
        ALUop <= 5'b0;
    else begin
        casex (inst_i)
            32'bxxxxxxxxxxxxxxxxxxxxxxxxx1101111: ALUop <= 5'b10000;  // jal
            32'bxxxxxxxxxxxxxxxxx000xxxxx1100011: ALUop <= 5'b10001;  // beq
            32'bxxxxxxxxxxxxxxxxx100xxxxx1100011: ALUop <= 5'b10010;  // blt
            32'bxxxxxxxxxxxxxxxxx010xxxxx0000011: ALUop <= 5'b10100;  // lw
            32'bxxxxxxxxxxxxxxxxx010xxxxx0100011: ALUop <= 5'b10101;  // sw
            32'bxxxxxxxxxxxxxxxxx000xxxxx0010011: ALUop <= 5'b01100;  // addi
            32'b0000000xxxxxxxxxx000xxxxx0110011: ALUop <= 5'b01101;  // add
            32'b0100000xxxxxxxxxx000xxxxx0110011: ALUop <= 5'b01110;  // sub
            32'b0000000xxxxxxxxxx001xxxxx0110011: ALUop <= 5'b01000;  // sll
            32'b0000000xxxxxxxxxx100xxxxx0110011: ALUop <= 5'b00110;  // xor
            32'b0000000xxxxxxxxxx101xxxxx0110011: ALUop <= 5'b01001;  // srl
            32'b0000000xxxxxxxxxx110xxxxx0110011: ALUop <= 5'b00101;  // or
            32'b0000000xxxxxxxxxx111xxxxx0110011: ALUop <= 5'b00100;  // and
            default: ALUop <= 5'b0;
        endcase
    end
end
```


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

