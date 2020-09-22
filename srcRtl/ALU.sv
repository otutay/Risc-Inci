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

	logic[3:0] rSelection;
	logic equal;
	logic lessThan;
	logic lessThanUns;

	always_comb
	begin
		rSelection = {iDecoded.funct7[5],iDecoded.funct3};
	end

	always_ff @(posedge iClk)
	begin : operation
		aluOut <= '{default:'0};
		case (iDecoded.opcode)
			eOpLoad:
			begin
				aluOut.memOp.addr <= signed'(iDecoded.rs1Data) + signed'(siDecoded.imm);
				aluOut.memOp.rdAddr<= iDecoded.rdAddr;
				aluOut.memOp.opType <= iDecoded.funct3;
				aluOut.memOp.read <= 1'b1;
			end
			eOpStore:
			begin
				aluOut.addr <= signed'(iDecoded.rs1Data) + signed'(iDecoded.imm);
				aluOut.data <= iDecoded.rs2Data;
				aluOut.memOp.opType <= iDecoded.funct3;
				aluOut.memOp.write <= 1'b1;
			end
			eOpRtype :
			begin
				aluOut.regOp.addr <= iDecoded.rdAddr;
				aluOut.regOp.dv <= 1'b1;
				case (rSelection)
					4'b0000 : // add 
					begin
						aluOut.regOp.data <= signed'(iDecoded.rs1Data) + signed'(iDecoded.rs2Data);
					end
					4'b1000: // sub
					begin
						aluOut.regOp.data <= signed'(iDecoded.rs1Data) - signed'(iDecoded.rs2Data);
					end
					4'b0001 : // sll
					begin
						aluOut.regOp.data <= iDecoded.rs1Data << iDecoded.rs2Data[$clog2(cDataWidth)-1:0];
					end
					4'b0010 : // slt
					begin
						aluOut.regOp.data[cXLEN-1:1] <=  '{default:'0};
						aluOut.regOp.data[0] <=  signed'(iDecoded.rs1Data) < signed'(iDecoded.rs2Data);
					end
					4'b0011 : // sltu
					begin
						aluOut.regOp.data[cXLEN-1:1] <=  '{default:'0};
						aluOut.regOp.data[0] <=  iDecoded.rs1Data < iDecoded.rs2Data;
					end
					4'b0100 : // xor
					begin
						aluOut.regOp.data <=  iDecoded.rs1Data ^ iDecoded.rs2Data;
					end
					4'b0101 : // srl
					begin
						aluOut.regOp.data <= iDecoded.rs1Data >> iDecoded.rs2Data[$clog2(cDataWidth)-1:0];
					end
					4'b1101 : // srA
					begin
						aluOut.regOp.data <= signed'(iDecoded.rs1Data) >> iDecoded.rs2Data[$clog2(cDataWidth)-1:0];
					end
					4'b0110 : // or
					begin
						aluOut.regOp.data <= iDecoded.rs1Data | iDecoded.rs2Data;
					end
					4'b0111 : // and
					begin
						aluOut.regOp.data <= iDecoded.rs1Data & iDecoded.rs2Data;
					end
					
					default : statement_or_null_2;
				endcase

			end
			eOpBranch:
			begin
				case (iDecoded.funct3)
					3'b000 : // beq 
					begin
						if(equal == 1'b1)
						begin
							
						end
					end
					3'b001: // bne
					begin
					
					end
					3'b100: //blt
					begin
					
					end
					3'b101: //bge
					begin
					
					end
					3'b110: //bltu
					begin
					
					end
					3'b111: // bgeu
					begin
					
					end
					default : NULL;
				endcase
			end 
			default: begin
			end
		endcase
	end
	
	always_comb
	begin
		equal = iDecoded.rs1Data == iDecoded.rs2Data;// beq and bne comparison
		lessThanUns = iDecoded.rs1Data < iDecoded.rs2Data; // bltu and bgeu comparison
		lessThan    = signed'(iDecoded.rs1Data) < signed'(iDecoded.rs2Data); // blt and bge comparison
	end
	
endmodule


