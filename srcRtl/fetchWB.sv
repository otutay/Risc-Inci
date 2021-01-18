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
    input iClk,
    input iRst,
    input tMemOp iMemOp,
    input tFetchCtrl iFetchCtrl,
    output logic [cXLEN-1 : 0] oCurPc,
    output logic [cXLEN-1 : 0] oInstr,
    output tRegOp oRegOp
);

    logic LSWEN;
    logic LSEn;
    logic [$clog2(cRamDepth-1)-1:0] LSAddr;
    logic [cXLEN-1:0] LSStoreData;
    logic [cXLEN-1:0] LSLoadData;



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
    always_ff @(posedge iClk) 
    begin : ramDataCollect
        regOp.dv <= iMemOp.read;
        regOp.addr <= iMemOp.rdAddr;
        regOp.data <= LSLoadData;
    end

    

    logic [cXLEN-1:0] instruction;
    logic [$clog2(cRamDepth-1)-1:0] readAddr;
    logic [cXLEN-1:0] curPc;
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
        else if(iFetchCtrl.newPcValid)
            curPc <= iFetchCtrl.newPc;
        else
            curPc <= curPc + 4;
    end

    always_comb
    begin: addrPro
        readAddr = curPc[$clog2(cRamDepth-1)-1:0];
    end

    assign oInstr = instruction;
    assign oCurPc = curPc-4;
    assign oRegOp = regOp;

endmodule
