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
    output logic[cXLEN-1:0] oRs1Data,
    output logic[cXLEN-1:0] oRs2Data
    //		input  logic[cXLEN-1:0] rdData,
    //		input logic [cRegSelBitW-1:0] rs1Addr,
    //		input logic [cRegSelBitW-1:0] rs2Addr,
    //		input logic [cRegSelBitW-1:0] rdAddr,
    //		input tRegControl  rs1Cntrl,
    //		input tRegControl  rs2Cntrl,
    //		input tRegControl  rdCntrl,
);

    logic [cRegNum-1:0][cXLEN-1:0] rf;

    always_ff @(posedge iClk)
    begin
        if (iRd.dv)
        begin
            if(iRd.addr == {cRegSelBitW{ 1'b0}})
                begin
                    rf[0] <= '0;
                end
            else
                begin
                    rf[iRd.addr] <= rdData;
                end

        end
    end

    always_comb
    begin
        oRs1Data <= iRs1.dv ? rf[iRs1.addr] : cXLEN'(0);
        oRs2Data <= iRs2.dv ? rf[iRs2.addr] : cXLEN'(0);
    end


endmodule : regFile




