// ****************************************************************************
// * fetch.sv
// * osmant
// *
// ****************************************************************************/

/**
 * Module: fetch
 *
 * TODO: Add module documentation
 */

import corePckg::*;
module fetchWB(
	       input			  iClk,
	       input			  iRst,
	       input			  tMemOp iMemOp,
	       input			  tFetchCtrl iFetchCtrl,
	       output logic [cXLEN-1 : 0] oCurPc,
	       output logic [cXLEN-1 : 0] oInstr,
	       output			  tRegOp oRegOp
	       );

   logic				  LSWEN;
   logic				  LSEn;
   logic [$clog2(cRamDepth-1)-1:0]	  LSAddr;
   logic [cXLEN-1:0]			  LSStoreData;
   logic [cXLEN-1:0]			  LSLoadData;



   assign oRegOp = regOp;

   // this directly goes to ram port
   always_ff @(posedge iClk)
     begin : load_StoreOp
	// same for every store
	LSAddr      <= iMemOp.addr;
	LSEn        <= iMemOp.read | iMemOp.write;
	LSWEN       <= iMemOp.write;
	case (iMemOp.opType)
	  3'b000 : LSStoreData <= (cXLEN)'(signed'( iMemOp.data[7:0]));
	  3'b001 : LSStoreData <= (cXLEN)'(signed'( iMemOp.data[15:0]));
	  3'b010 : LSStoreData <=  iMemOp.data[15:0];
	  default : LSStoreData <= cXLEN'(1'b0);
	endcase

     end

   // collect ram data and form reg op
   tRegOp regOp;
   logic readi1;
   logic [cRegSelBitW : 0] rdAddri1;
   always_ff @(posedge iClk)
     begin : ramDataCollect
	readi1 <= iMemOp.read;
	rdAddri1<= iMemOp.rdAddr;

	regOp.dv <= readi1;
	regOp.addr <= rdAddri1;
	regOp.data <= LSLoadData;
     end



   logic [cXLEN-1:0] instruction;
   logic [$clog2(cRamDepth-1)-1:0] readAddr;
   logic [cXLEN-1:0]		   curPc;
   ram #(
	 .cRamPerformance("LOW_LATENCY"),
	 .cRamWidth(cXLEN),
	 .cRamDepth(cRamDepth)
	 ) ram_instance (
			 .iClk(iClk),
			 // current pc port
			 .iRstA(1'b0),
			 .iEnA(1'b1),
			 .iWEnA(1'b0),
			 .iAddrA(readAddr),
			 .iDataA({cXLEN{1'b0}}),
			 .oDataA(instruction),
			 // load store port
			 .iRstB(1'b0),
			 .iEnB(LSEn),
			 .iWEnB(LSWEN),
			 .iAddrB(LSAddr),
			 .iDataB(LSStoreData),
			 .oDataB(LSLoadData)
			 );

   always_ff @(posedge iClk)
     begin : pcCounter
	if(iFetchCtrl.noOp)
	  curPc <= curPc;
	else if(iFetchCtrl.newPc)
	  curPc <= iFetchCtrl.newPc;
	else
	  curPc <= curPc + 4;
     end

   always_comb
     begin: addrPro
	readAddr = curPc[$clog2(cRamDepth-1)-1:0];
     end

   always_comb
     begin: outputRename
	oInstr = iFetchCtrl.newPc ? cXLEN'(0) : instruction;
	// TODO check below instruction not sure
	oCurPc = iFetchCtrl.newPc ? iFetchCtrl.newPc : curPc-4;
     end

endmodule
