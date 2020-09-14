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

	
	
	always_ff @(posedge iClk)
		case (iDecoded.opcode)
			eOpLoad: 
			begin
				case (iDecoded.funct3)
					3'b000 : 
					begin
						
					end
					3'b001 :
					begin
						
					end
					
					default: 
					begin
					end
				endcase
				
			end
			default: begin
			end
		endcase
		//	begin : loadOperation
		//		if(iDecoded.opcode == eOpLoad)
		//		begin
		//			
		//		end
	end
endmodule


