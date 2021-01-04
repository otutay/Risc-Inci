//import ramPckg::*;

module ram
#(
    parameter cRamPerformance= "HIGH_PERFORMANCE",
    parameter int unsigned cRamWidth = 32,
    parameter int unsigned cRamDepth = 1024
)
(
    input iClk,

    // port A
    input logic iRstA,
    input logic iEnA,
    input logic iWEnA,
    input logic [$clog2(cRamDepth-1)-1:0] iAddrA,
    input logic [cRamWidth-1:0] iDataA,
    output logic [cRamWidth-1:0] oDataA,

    //portB
    input logic iRstB,
    input logic iEnB,
    input logic iWEnB,
    input logic [$clog2(cRamDepth-1)-1:0] iAddrB,
    input logic [cRamWidth-1:0] iDataB,
    output logic [cRamWidth-1:0] oDataB,

);

    //  <wire_or_reg> <regcea>;                         // Port A output register enable
    //  <wire_or_reg> <regceb>;                         // Port B output register enable

    logic [cRamWidth-1:0] ram [cRamDepth-1:0];
    logic [cRamWidth-1:0] ramDataA;
    logic [cRamWidth-1:0] ramDataB;

    always @(posedge iClk)
    begin : portA
        if (iEnA)
        begin
            if (iWEnA)
                ram[iAddrA] <= iDataA;
            else
                ramDataA <= ram[iAddrA];
        end
    end

    always @(posedge iClk)
    begin : portB
        if (iEnB)
        begin
            if (iWEnB)
                ram[iAddrB] <= iDataB;
            else
                ramDataB <= ram[iAddrB];
        end
    end

    generate
        if(cRamPerformance == "LOW_LATENCY") begin: noLatencyRam
            assign oDataA = ramDataA;
            assign oDataB = ramDataB;
        end
        else
        begin
            always_ff @(posedge clk)
            begin : outDataRegistered
                oDataA <= ramDataA;
                oDataB <= ramDataB;
            end
        end
    endgenerate






endmodule
