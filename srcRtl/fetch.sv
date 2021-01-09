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
module fetch(
    input iClk,
    input iRst,
    input tMemOp iMemOp,
    input tFetchCtrl iFetchCtrl,
    output logic [cXLEN-1 : 0] oCurPc,
    output logic [cXLEN-1 : 0] oInstr
);
    
    
    
    
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
        .iAddrA(iAddrA),
        .iDataA({cXLEN{1'b0}}),
        .oDataA(instruction),
        // load store port
        .iRstB(1'b0),
        .iEnB(1'b1),
        .iWEnB(iWEnB),
        .iAddrB(iAddrB),
        .iDataB(iDataB),
        .oDataB(oDataB)
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
        readAddr = curPc;
    end
    
    assign oInstr = instruction;
    assign oCurPc = curPc;

endmodule
