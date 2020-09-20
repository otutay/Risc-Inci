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
						aluOut.regOp.data[31:1] <=  '{default:'0};
						aluOut.regOp.data[0] <=  signed'(iDecoded.rs1Data) < signed'(iDecoded.rs2Data);
					end
					4'b0011 : // sltu
					begin
						aluOut.regOp.data[31:1] <=  '{default:'0};
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


