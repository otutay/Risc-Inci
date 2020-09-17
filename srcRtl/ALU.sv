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
				aluOut.memOp.rdAddr<= iDecoded.rdAddr;
				aluOut.memOp.opType <= iDecoded.funct3;
				aluOut.memOp.read <= 1'b1;
			end
			eOpStore:
			begin
				aluOut.addr <= iDecoded.rs1Data + iDecoded.imm;
				aluOut.data <= iDecoded.rs2Data;
				aluOut.memOp.opType <= iDecoded.funct3;
				aluOut.memOp.write <= 1'b1;
				//				aluOut.addr <= iDecoded.rs1 + 	32'(signed'(iDecoded.imm));
				//				aluOut.memWrite <= 1'b1;
				//				aluOut.destReg <= iDecoded.rd;
				//				aluOut.opcode <= iDecoded.opcode;
			end
			eOpRtype : 
			begin
								
				
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


