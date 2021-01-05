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
    input logic [cXLEN-1 : 0] newPc,
    output logic [cXLEN-1 : 0] curPc,
    tMemOp memOp,
);

    logic [cXLEN-1:0] instruction;

    ram #(
    .cRamPerformance("LOW_LATENCY"),
    .cRamWidth(cXLEN),
    .cRamDepth(1024)
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
    
    
    
endmodule
