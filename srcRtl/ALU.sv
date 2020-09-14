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
		input tDecodedInst iDecoded 
		);

	
	
	always_ff @(posedge iClk)
	begin : loadOperation
		if(iDecoded.opcode == eOpLoad)
		begin
			
		end
	end
endmodule


