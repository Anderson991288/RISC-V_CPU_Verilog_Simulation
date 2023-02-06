# RISC-V_CPU_Verilog_Simulation

### Convert to machine code by assembler
![Screenshot 2023-02-06 214127](https://user-images.githubusercontent.com/68816726/216986967-2e03f3f7-9afd-4786-8c0e-f4503aa314f8.png)

### put the converted machine code under the same path as the vivado project
### and read the machine code by inst_mem 

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

### waveform

### Read the first instruction when the first clock posedge after reset is zero.
### Read the second instruction when the second clock posedge after reset is zero...

![Screenshot 2023-02-06 220638](https://user-images.githubusercontent.com/68816726/216992546-15e8bf68-a821-45ef-8255-f931ba008b13.png)

