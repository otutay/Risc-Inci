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
		#(parameter cycleNum = 2)
		(
		input logic iClk,
		input logic iRst,
		input logic [31:0] iInst,
		output tDecodedInst oDecoded 
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
	
	generate 
		if(cycleNum == 1)
		begin : cycle1
			assign opcode 	   = iInst[6:0];
			assign src1Addr	   = iInst[19:15];
			assign src2Addr    = iInst[24:20];
			assign destAddr    = iInst[11:7];
			assign funct3 	   = iInst[14:12];
			assign funct7	   = iInst[31:25];
			assign instruction = insti1;
		end
				
		if (cycleNum == 2)
		begin : cycle2
			always_ff @(posedge iCLk) // opcode and input flops
			begin :flop
				opcode 	  	<= iInst[6:0];
				src1Addr	<= iInst[19:15];
				src2Addr 	<= iInst[24:20];
				destAddr 	<= iInst[11:7];
				funct3 	  	<= iInst[14:12];
				funct7	  	<= iInst[31:25];
				instruction <= insti1;
		
			end		
		end
	endgenerate
	
	always_ff @(posedge iClk) // instructionDecode
	begin : decode
		dInst <= {default:0};
		case (opcode)
			eOpLoad: 
			begin
				dInst.rs1 <= {src1Addr,1'b1};
				dInst.rd <= {destAddr,1'b1};
				dInst.funct3 <= {funct3,1'b1};
				dInst.imm.value <= {{20{1'b0}},insti1[31:20]};// TODO sign extension
				dInst.imm.dv <= 1'b1;
			end
			eOpFence:
			begin
				// nothing done right now.
			end
			eOpImmedi:
			begin
				dInst.rs1 <= {src1Addr,1'b1};
				dInst.rd <= {destAddr,1'b1};
				dInst.funct3 <= {funct3,1'b1};
				dInst.imm.value <= {{20{1'b0}},insti1[31:20]}; // TODO sign extension
				dInst.imm.dv <= 1'b1; // TODO shift operations are decoded in alu
			end
			eOpAuIpc:
			begin
				dInst.rd <= {destAddr,1'b1};
				dInst.imm.value <= {insti1[31:12],{12{1'b0}}};
				dInst.imm.dv <= 1'b1;
				
			end
			
			eOpStore:
			begin
				dInst.rs1 <= {src1Addr,1'b1};
				dInst.rs2 <= {src2Addr,1'b1};
				dInst.funct3 <=  {funct3,1'b1};
				dInst.imm.value <= {{20{1'b0}},insti1[31:25],insti1[11:7]}; // TODO sign extension 
				dInst.imm.dv <= 1'b1;
			end
			eOpRType:
			begin
				dInst.rs1 <= {src1Addr,1'b1};
				dInst.rs2 <= {src2Addr,1'b1};
				dInst.rd <= {destAddr,1'b1};
				dInst.funct3 <=  {funct3,1'b1};
				dInst.funct7 <=  {funct7,1'b1};
			end
			eOpLui:
			begin
				dInst.rd <= {destAddr,1'b1};
				dInst.imm.value <= {insti1[31:12],{12{1'b0}}};
				dInst.imm.dv <= 1'b1;
			end
			eOpBranch:
			begin
				dInst.rs1 <= {src1Addr,1'b1};
				dInst.rs2 <= {src2Addr,1'b1};
				dInst.funct3 <=  {funct3,1'b1};
				dInst.imm.value[12] <= insti1[31];
				dInst.imm.value[10:5] <= insti1[30:25];
				dInst.imm.value[4:1] <=  insti1[11:8];
				dInst.imm.value[11] <=  insti1[7];
				dInst.imm.dv <= 1'b1;
			end
			eOpJalr:
			begin
				dInst.rs1 <= {src1Addr,1'b1};
				dInst.rd <= {destAddr,1'b1};
				dInst.funct3 <=  {funct3,1'b1};
				dInst.imm.value <= {{20{1'b0}},insti1[31:20]};// TODO sign extension
				
			end
			eOpJal:
			begin
				dInst.rd <= {destAddr,1'b1};
				dInst.imm.value[20] <= insti1[31];
				dInst.imm.value[10:1] <= insti1[30:21];
				dInst.imm.value[11] <= insti1[20];
				dInst.imm.value[19:12] <= insti1[19:12];
				dInst.imm.dv <= 1'b1;
			end
			eOpCntrlSt:
			begin
				// nothing done right now.	
			end
			default: 
			begin
				
			end
		endcase
	end
	
	assign oDecoded = dInst;
	
	
	
	
endmodule


