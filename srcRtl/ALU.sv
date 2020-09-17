// ****************************************************************************
// * ALU.sv
// * osmant 
// * 
// ****************************************************************************/

/**
 * Module: ALU
 * 
 * TODO: Add module documentation
 */
import corePckg::*;
module ALU
		(
	input logic iClk,
	input logic iRst,
	input tDecoded iDecoded

);



	tAluOut aluOut;

	always_ff @(posedge iClk)
	begin : operation
		aluOut <= '{default:'0};
		case (iDecoded.opcode)
			eOpLoad:
			begin
				aluOut.memOp.addr <= iDecoded.rs1Data + iDecoded.imm;
				aluOut.memOp.memRead <= 1'b1;
				aluOut.memOp.rdAddr<= iDecoded.rdAddr;
			end
			eOpStore:
			begin
				//				aluOut.addr <= iDecoded.rs1 + 	32'(signed'(iDecoded.imm));
				//				aluOut.memWrite <= 1'b1;
				//				aluOut.destReg <= iDecoded.rd;
				//				aluOut.opcode <= iDecoded.opcode;
			end


			default: begin
			end
		endcase
		//	begin : loadOperation
		//		if(iDecoded.opcode == eOpLoad)
		//		begin
		//			
		//		














	end
endmodule


