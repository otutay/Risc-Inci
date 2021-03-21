// ****************************************************************************
// * regFile.sv
// * osmant 
// * 
// ****************************************************************************/

/**
 * Module: regFile
 * 
 * TODO: Add module documentation
 */

import corePckg::*;

module regFile 
		(
    input logic iClk,
    input logic iRst,
    input tRegOp iRs1,
    input tRegOp iRs2,
    input tRegOp iRd,
    input tRegOp iRdMem,
    output logic[cXLEN-1:0] oRs1Data,
    output logic[cXLEN-1:0] oRs2Data
);

    logic [cRegNum-1:0][cXLEN-1:0] rf;

    always_ff @(posedge iClk)
    begin
        if(iRd.dv)
            rf[iRd.addr] <= iRd.data;

        if(iRdMem.dv)
            rf[iRdMem.addr] <= iRdMem.data;

        rf[0] <= cXLEN'(0);

    end

    always_comb
    begin
        oRs1Data <= iRs1.dv ? rf[iRs1.addr] : cXLEN'(0);
        oRs2Data <= iRs2.dv ? rf[iRs2.addr] : cXLEN'(0);
    end


endmodule : regFile




