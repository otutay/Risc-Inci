// ****************************************************************************
// * InstDecoder.sv
// * osmant 
// * 
// ****************************************************************************/

/**
 * Module: InstDecoder
 * 
 * TODO: Add module documentation
 */
import corePckg::*;
module InstDecoder
		(
		input logic iClk,
		input logic iRst,
		input logic [31:0] iInst
		);

	//	
	//	tOpcodeEnum opcode;
	logic [2:0] funct3;
	logic [6:0] funct7;
	logic [cRegSelBitW-1:0] destAddr;
	logic [cRegSelBitW-1:0] src1Addr;
	logic [cRegSelBitW-1:0] src2Addr;
	logic [31:0] instruction;
	tOpLoad opLoad;
	
	
	
	always_ff @(posedge iCLk) // opcode and input flops
	begin
		opcode 	  	<= iInst[6:0];
		src1Addr	<= iInst[19:15];
		src2Addr 	<= iInst[24:20];
		destAddr 	<= iInst[11:7];
		funct3 	  	<= iInst[14:12];
		funct7	  	<= iInst[31:25];
		instruction <= iInst;
	end
	
	always_ff @(posedge iClk) // instructionDecode
	begin
		opLoad <= {{3'b000},{cRegSelBitW,{1'b0}},{cRegSelBitW,{1'b0}},{12{1'b0}},1'b0};
		case (opcode)
			opLoad: 
			begin
				opLoad.size <= funct3;
				opLoad.destAddr <= destAddr;
				opLoad.srcAddr <= src1Addr;
				opLoad.dv <= 1'b1;
			end
			opFence:
			begin
				
			end
			default: 
			begin
				
			end
		endcase
	end
	
	
	
	
endmodule


