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

	
	logic [2:0] funct3;
	logic [6:0] funct7;
	logic [cRegSelBitW-1:0] destAddr;
	logic [cRegSelBitW-1:0] src1Addr;
	logic [cRegSelBitW-1:0] src2Addr;
	logic [31:0] insti1;
	tDecodedInst dInst;
//	tOpLoad opLoad;
//	tOpImmedi opImmedi;
//	tOpAuIPC opAuIPC;
//	tOpStore opStore;
	
	always_ff @(posedge iCLk) // opcode and input flops
	begin
		opcode 	  	<= iInst[6:0];
		src1Addr	<= iInst[19:15];
		src2Addr 	<= iInst[24:20];
		destAddr 	<= iInst[11:7];
		funct3 	  	<= iInst[14:12];
		funct7	  	<= iInst[31:25];
		instruction <= insti1;
	end
	
	always_ff @(posedge iClk) // instructionDecode
	begin
		dInst <= {default:0};
		case (opcode)
			eOpLoad: 
			begin
				dInst.funct3 <= {funct3,1'b1};
				dInst.rd <= {destAddr,1'b1};
				dInst.rs1 <= {src1Addr,1'b1};
				dInst.imm.value <= {{20{1'b0}},insti1[31:20]};// TODO sign extension
				dInst.imm.dv <= 1'b1;
			end
			eOpFence:
			begin
				// nothing done right now.
			end
			eOpImmedi:
			begin
				dInst.funct3 <= {funct3,1'b1};
				dInst.rd <= {destAddr,1'b1};
				dInst.rs1 <= {src1Addr,1'b1};
				dInst.imm.value <= {{20{1'b0}},insti1[31:20]}; // TODO sign extension
				dInst.imm.dv <= 1'b1;
			end
			eOpAuIpc:
			begin
				dInst.rd <= {destAddr,1'b1};
				dInst.imm.value <= {insti1[31:12],{12{1'b0}}};
				dInst.imm.dv <= 1'b1;
				
			end
			
			eOpStore:
			begin
				
			end
			
			default: 
			begin
				
			end
		endcase
	end
	
	
	
	
endmodule


