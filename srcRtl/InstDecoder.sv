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
	input logic [cXLEN-1:0] iInst,
	input logic [cXLEN-1:0] iCurPc,
	output tDecodedInst oDecoded,
	output tDecodedMem oMemOp,
	output tDecodedReg oRegOp
);

	logic [2:0] funct3;
	logic [6:0] funct7;
	logic [cRegSelBitW-1:0] destAddr;
	logic [cRegSelBitW-1:0] src1Addr;
	logic [cRegSelBitW-1:0] src2Addr;
	logic [cXLEN-1:0] insti1;
	logic [cXLEN-1:0] curPci1;
	tOpcodeEnum opcode;
	logic[3:0] rSelection;
	tDecodedInst dInst;
	tDecodedMem memOp;
	tDecodedReg regOp;

	generate
		if(cycleNum == 1)
		begin : cycle1
			assign opcode 	   = tOpcodeEnum'(iInst[6:0]);
			assign src1Addr	   = iInst[19:15];
			assign src2Addr    = iInst[24:20];
			assign destAddr    = iInst[11:7];
			assign funct3 	   = iInst[14:12];
			assign funct7	   = iInst[31:25];
			assign insti1 	   = iInst;
			assign curPci1     = iCurPc;
			assign rSelection  = {iInst[30],iInst[14:12]};
		end

		if (cycleNum == 2)
		begin : cycle2
			always_ff @(posedge iClk) // opcode and input flops
			begin :flop
				opcode 	  	<= tOpcodeEnum'(iInst[6:0]);
				src1Addr	<= iInst[19:15];
				src2Addr 	<= iInst[24:20];
				destAddr 	<= iInst[11:7];
				funct3 	  	<= iInst[14:12];
				funct7	  	<= iInst[31:25];
				insti1 		<= iInst;
				curPci1     <= iCurPc;
				rSelection  <= {iInst[30],iInst[14:12]};
			end
		end
	endgenerate


	assign oDecoded = dInst;
	assign oMemOp   = memOp;
	assign oRegOp = regOp;

	always_ff @(posedge iClk)
	begin : operationDecide
		case (opcode)
			eOpLoad:
			begin
				// memOpDecode
				memOp.load <= 1'b1;
				memOp.store <= 1'b0;
				memOp.dv <= 1'b1;

				// regOpDecode
				regOp <= {eNoOp,1'b0,1'b0,1'b0,1'b0,1'b0};
			end
			eOpStore:
			begin
				// memOpDecode			
				memOp.load <= 1'b0;
				memOp.store <= 1'b1;
				memOp.dv <= 1'b1;

				// regOpDecode
				regOp <= {eNoOp,1'b0,1'b0,1'b0,1'b0,1'b0};
			end
			eOpRtype:
			begin
				// regOpDecode
				regOp.arithType <= tArithEnum'{rSelection};
				regOp.opRs1 <= 1'b1;
				regOp.opRs2 <= 1'b1;
				regOp.opImm <= 1'b0;
				regOp.opPc <= 1'b0;
				regOp.dv <= 1'b1;

				// memOpDecode
				memOp <= '{default:'0};
			end
			eOpImmedi:
			begin
				// regOpDecode
				case (funct3)
					3'b000 : regOp.arithType <= eAdd;
					3'b010 : regOp.arithType <= eCompareSigned;
					3'b011 : regOp.arithType <= eCompareUnsigned;
					3'b100 : regOp.arithType <= eXor;
					3'b110 : regOp.arithType <= eOr;
					3'b111 : regOp.arithType <= eAnd;
					3'b001 : regOp.arithType <= eShftLeft;
					3'b101 : regOp.arithType <= funct7[5] ? eShftRight : eShftRightArit;
					default : regOp.arithType <= eNoOp;
				endcase
				regOp.opRs1 <= 1'b1;
				regOp.opRs2 <= 1'b0;
				regOp.opImm <= 1'b1;
				regOp.opPc <= 1'b0;
				regOp.dv <= 1'b1;

				// memOp
				memOp <= '{default:'0};
			end
		endcase
	end


	always_ff @(posedge iClk) // instructionDecode
	begin : decode
		dInst <= '{default:'0};
		dInst.opcode <= opcode;
		dInst.curPc <= curPci1;

		case (opcode)
			eOpLoad:
			begin
				// decoded inst
				dInst.rs1Addr <= src1Addr;
				dInst.rdAddr <= destAddr;
				dInst.funct3 <= funct3;
				dInst.imm <= cXLEN'(signed'(insti1[31:20]));

			end
			eOpStore:
			begin
				dInst.rs1Addr <=src1Addr;
				dInst.rs2Addr <= src2Addr;
				dInst.funct3 <= funct3;
				dInst.imm <=  cXLEN'(signed'({insti1[31:25],insti1[11:7]}));
			end


			eOpRtype:
			begin
				dInst.rs1Addr <= src1Addr;
				dInst.rs2Addr <= src2Addr;
				dInst.rdAddr <= destAddr;
				dInst.funct3 <=  funct3;
				dInst.funct7 <=  funct7;

			end


			eOpFence:
			begin
				// nothing done right now.
			end
			eOpImmedi:
			begin
				dInst.rs1Addr <=src1Addr; //{src1Addr,1'b1};
				dInst.rdAddr <= destAddr; //{destAddr,1'b1};
				dInst.funct3 <= funct3; //{funct3,1'b1};
				dInst.imm <=  cXLEN'(signed'(insti1[31:20])); //{{20{1'b0}},insti1[31:20]}; 
				//				dInst.imm.value <= {{20{1'b0}},insti1[31:20]}; 
				//				dInst.imm.dv <= 1'b1; // TODO shift operations are decoded in alu
			end
			eOpAuIpc:
			begin
				dInst.rdAddr <= destAddr; // {destAddr,1'b1};
				dInst.imm <= {insti1[31:12],{12{1'b0}}};
				//				dInst.imm.value <= {insti1[31:12],{12{1'b0}}};
				//				dInst.imm.dv <= 1'b1;

			end



			eOpLui:
			begin
				dInst.rdAddr <= destAddr; //{destAddr,1'b1};
				dInst.imm <= {insti1[31:12],{12{1'b0}}};
				//				dInst.imm.value <= {insti1[31:12],{12{1'b0}}};
				//				dInst.imm.dv <= 1'b1;
			end
			eOpBranch:
			begin
				dInst.rs1Addr <= src1Addr; //{src1Addr,1'b1};
				dInst.rs2Addr <= src2Addr; //{src2Addr,1'b1};
				dInst.funct3 <=  funct3;{funct3,1'b1};
				// 
				dInst.imm <= {{cXLEN-12{insti1[31]}},insti1[7],insti1[30:25],insti1[11:8],1'b0};
				//				dInst.imm[12] <= insti1[31];
				//				dInst.imm[10:5] <= insti1[30:25];
				//				dInst.imm[4:1] <=  insti1[11:8];
				//				dInst.imm[11] <=  insti1[7];

				//				dInst.imm.value[12] <= insti1[31];
				//				dInst.imm.value[10:5] <= insti1[30:25];
				//				dInst.imm.value[4:1] <=  insti1[11:8];
				//				dInst.imm.value[11] <=  insti1[7];
				//				dInst.imm.dv <= 1'b1;
			end
			eOpJalr:
			begin
				dInst.rs1Addr <= src1Addr; //{src1Addr,1'b1};
				dInst.rdAddr <= destAddr; //{destAddr,1'b1};
				dInst.funct3 <=  funct3; //{funct3,1'b1};
				dInst.imm <= cXLEN'(signed'(insti1[31:20])); //{{20{1'b0}},insti1[31:20]};
				//				dInst.imm.value <= {{20{1'b0}},insti1[31:20]};

			end
			eOpJal:
			begin
				dInst.rdAddr <=destAddr; // {destAddr,1'b1};
				dInst.imm <= cXLEN'(signed'({insti1[31],insti1[19:12],insti1[20],insti1[30:21],1'b0}));
				//				dInst.imm.value[20] <= insti1[31];
				//				dInst.imm.value[10:1] <= insti1[30:21];
				//				dInst.imm.value[11] <= insti1[20];
				//				dInst.imm.value[19:12] <= insti1[19:12];
				//				dInst.imm.dv <= 1'b1;
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





endmodule


