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
		case (iDecoded.opcode)
			eOpLoad: 
			begin
				addr <= iDecoded.rs1 + 	32'(signed'(iDecoded.imm));
				
			end
				
//				case (iDecoded.funct3) 
//					3'b000 : 
//					begin 
//						
//					end
//					3'b001 :
//					begin
//						
//					end
//					3'b010 :
//					begin
//						
//					end
//					3'b100 :
//					begin
//						
//					end
//					3'b101 :
//					begin
//						
//					end
//					default : 
//					begin
//						
//					end
//				endcase
//				
			
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


