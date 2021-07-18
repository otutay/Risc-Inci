-------------------------------------------------------------------------------
-- Title      : top vhd
-- Project    :
-------------------------------------------------------------------------------
-- File       : Top.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-07-02
-- Last update: 2021-07-19
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: top modul for risc inci
-------------------------------------------------------------------------------
-- Copyright (c) 2021
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-07-02  1.0      otutay  Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.corePackage.all;


entity Top is

  port (
    iClk        : in  std_logic;
    iRst        : in  std_logic;
    iStart      : in  std_logic;
    -- inst load interface
    iInst2Write : in  std_logic_vector(cXLen-1 downto 0);
    iInstWen    : in  std_logic;
    -- data load interface
    iData2Write : in  std_logic_vector(cXLen-1 downto 0);
    iDataWen    : in  std_logic;
    -- instDecode signals for tb
    oRs1Addr    : out std_logic_vector(cRegSelBitW-1 downto 0);
    oRs2Addr    : out std_logic_vector(cRegSelBitW-1 downto 0);
    oRdAddr     : out std_logic_vector(cRegSelBitW-1 downto 0);
    oF3         : out std_logic_vector(2 downto 0);
    oF7         : out std_logic_vector(6 downto 0);
    oImm        : out std_logic_vector(cXLen-1 downto 0);
    oOpcode     : out std_logic_vector(6 downto 0);
    oCurPc      : out std_logic_vector(cXLen-1 downto 0);
    -- oDecodedMem
    oLoad       : out std_logic;
    oStore      : out std_logic;
    oMemDv      : out std_logic;
    -- oDecodedReg
    oAritType   : out std_logic_vector(3 downto 0);
    oOpRs1      : out std_logic;
    oOpRs2      : out std_logic;
    oOpImm      : out std_logic;
    oOpPc       : out std_logic;
    oOpConst    : out std_logic;
    oOpDv       : out std_logic;
    -- oDecodedBranch
    oBrOp       : out std_logic_vector(2 downto 0);
    oBrDv       : out std_logic
    -- alu signals for tb

    );
end entity Top;
architecture rtl of Top is
  signal inst          : std_logic_vector(cXLen-1 downto 0);
  signal curPc         : std_logic_vector(cXLen-1 downto 0);
  signal flushPipe     : std_logic;
  signal decodedInst   : tDecodedInst;
  signal memOp         : tDecodedMem;
  signal regOp         : tDecodedReg;
  signal branchOp      : tDecodedBranch;
  signal decoded       : tDecoded;
  signal decodedMem    : tDecodedMem;
  signal decodedReg    : tDecodedReg;
  signal decodedBranch : tDecodedBranch;
  signal memWB         : tMemOp;
  signal regWB         : tRegOp;
  signal branchWB      : tBranchOp;
  signal en            : std_logic;
  signal rs1           : tRegOp;
  signal rs2           : tRegOp;
  signal rd            : tRegOp;
  signal rdMem         : tRegOp;
  signal rs1Data       : std_logic_vector(cXLen-1 downto 0);
  signal rs2Data       : std_logic_vector(cXLen-1 downto 0);
  signal fetchCtrl     : tFetchCtrl;
begin  -- architecture rtl

  fetchComp : entity work.fetch
    port map (
      iClk        => iClk,
      iRst        => iRst,
      iStart      => iStart,
      iFetchCtrl  => fetchCtrl,
      oCurPc      => curPc,
      oInstr      => inst,
      iInst2Write => iInst2Write,
      iInstWen    => iInstWen
      );


  instDecoderComp : entity work.instDecoder
    generic map (
      cycleNum => 2)
    port map (
      iClk       => iClk,
      iRst       => iRst,
      iInst      => inst,
      iCurPc     => curPc,
      iFlushPipe => flushPipe,
      oDecoded   => decodedInst,
      oMemOp     => memOp,
      oRegOp     => regOp,
      oBranchOp  => branchOp
      );


  regFileComp : entity work.regFile
    port map (
      iClk     => iClk,
      iEn      => en,
      iRs1     => decodedInst.rs1,
      iRs2     => decodedInst.rs2,
      iRd      => rd,
      iRdMem   => rdMem,
      oRs1Data => rs1Data,
      oRs2Data => rs2Data
      );

  dataSelect2Alu : process (all) is
  begin  -- process dataSelect2Alu
    decoded.rs1Data <= rs1Data;
    decoded.rs2Data <= rs2Data;
    decoded.rdAddr  <= decodedInst.rdAddr;
    decoded.funct3  <= decodedInst.funct3;
    decoded.funct7  <= decodedInst.funct7;
    decoded.imm     <= decodedInst.imm;
    decoded.opcode  <= decodedInst.opcode;
    decoded.curPc   <= decodedInst.curPc;
  end process dataSelect2Alu;

  aluComp : entity work.alu
    port map (
      iClk           => iClk,
      iRst           => iRst,
      iDecoded       => decoded,
      iDecodedMem    => memOp,
      iDecodedReg    => regOp,
      iDecodedBranch => branchOp,
      oMemWB         => memWB,
      oRegWB         => regWB,
      oBranchWB      => branchWB
      );


  dataRamComp : entity work.dataRam
    port map (
      iClk        => iClk,
      iRst        => iRst,
      iMemOp      => memWB,
      oRegOp      => rdMem,
      -- data 2 load
      iData2Write => iData2Write,
      iWEn        => iDataWen
      );

  fetchCtrlPro : process (all) is
  begin  -- process fetchCtrl

    fetchCtrl.pc    <= x"00000"& "00" & branchWB.pc(9 downto 0); -- to be corrected
    fetchCtrl.newPc <= branchWB.newPc and branchWB.dv;
    fetchCtrl.noOp  <= '0'; -- to be corrected
  end process fetchCtrlPro;

  -- signals2tb

  -- synthesis translate_off
  -- InstDecodeSignals
  oRs1Addr  <= decodedInst.rs1.addr;
  oRs2Addr  <= decodedInst.rs2.addr;
  oRdAddr   <= decodedInst.rdAddr;
  oF3       <= decodedInst.funct3;
  oF7       <= decodedInst.funct7;
  oImm      <= decodedInst.imm;
  oOpcode   <= decodedInst.opcode;
  oCurPc    <= decodedInst.curPC;
  -- oDecodedMem
  oLoad     <= memOp.load;
  oStore    <= memOp.store;
  oMemDv    <= memOp.dv;
  -- oDecodedReg
  oAritType <= regOp.arithType;
  oOpRs1    <= regOp.opRs1;
  oOpRs2    <= regOp.opRs2;
  oOpImm    <= regOp.opImm;
  oOpPc     <= regOp.opPc;
  oOpConst  <= regOp.opConst;
  oOpDv     <= regOp.dv;
  -- oDecodedBranch
  oBrOp     <= branchOp.op;
  oBrDv     <= branchOp.dv;
-- synthesis translate_on

end architecture rtl;
