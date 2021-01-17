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
module fetch_WB(
    input iClk,
    input iRst,
    input tMemOp iMemOp,
    input tFetchCtrl iFetchCtrl,
    output logic [cXLEN-1 : 0] oCurPc,
    output logic [cXLEN-1 : 0] oInstr
);

    logic LSWEN;
    logic LSEn;
    logic [$clog2(cRamDepth-1)-1:0] LSAddr;
    logic [cXLEN-1:0] LSStoreData;
    logic [cXLEN-1:0] LSLoadData;




    always_ff @(posedge iCLk)
    begin : load_StoreOp
        LSAddr      <= iMemOp.addr;
        LSStoreData <= data;
        LSEn <= iMemOp.read | iMemOp.write;
        LSWEN <= iMemOp.write;
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
        .iEnB(1'b1),
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
    assign oCurPc = curPc;

endmodule
