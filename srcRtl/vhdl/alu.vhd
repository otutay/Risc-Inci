-------------------------------------------------------------------------------
-- Title      : alu.vhd
-- Project    :
-------------------------------------------------------------------------------
-- File       : alu.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-22
-- Last update: 2021-05-28
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: alu code for risc inci
-------------------------------------------------------------------------------
-- Copyright (c) 2021
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-03-22  1.0      otutay  Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.corePackage.all;
entity alu is

  port (
    iClk         : in  std_logic;
    iRst         : in  std_logic;
    -- iDecoded params
    iRs1Data     : in  std_logic_vector(cXLen-1 downto 0);
    iRs2Data     : in  std_logic_vector(cXLen-1 downto 0);
    iRdAddr      : in  std_logic_vector(cRegSelBitW-1 downto 0);
    iFunct3      : in  std_logic_vector(2 downto 0);
    iFunct7      : in  std_logic_vector(6 downto 0);
    iImm         : in  std_logic_vector(cXLen-1 downto 0);
    iOpcode      : in  std_logic_vector(6 downto 0);
    iCurPc       : in  std_logic_vector(cXLen-1 downto 0);
    -- iDecodedMem params
    iLoad        : in  std_logic;
    iStore       : in  std_logic;
    iMemdv       : in  std_logic;
    -- iDecodedReg params
    iArithType   : in  std_logic_vector(3 downto 0);
    iOpRs1       : in  std_logic;
    iOpRs2       : in  std_logic;
    iOpImm       : in  std_logic;
    iOpPc        : in  std_logic;
    iOpConst     : in  std_logic;
    iRegdv       : in  std_logic;
    -- iDecodedBranch params
    iBrOp        : in  std_logic_vector(2 downto 0);
    iBrDv        : in  std_logic;
    -- oMemWB params
    oMemReadDv   : out std_logic;
    oMemWriteDv  : out std_logic;
    oMemAddr     : out std_logic_vector(cXLen-1 downto 0);
    oMemData     : out std_logic_vector(cXLen-1 downto 0);
    oMemOpType   : out std_logic_vector(2 downto 0);
    oMemRdAddr   : out std_logic_vector(cRegSelBitW-1 downto 0);
    -- oRegWB params
    oRegDv       : out std_logic;
    oRegAddr     : out std_logic_vector(cRegSelBitW-1 downto 0);
    oRegData     : out std_logic_vector(cXLen-1 downto 0);
    -- oBranchWB params
    oBrFlushPipe : out std_logic;
    oBrNewPc     : out std_logic;
    oBrPc        : out std_logic_vector(cXLen-1 downto 0);
    oBrDv        : out std_logic
    );
end entity alu;

architecture rtl of alu is
 -- sverilog 2 vhdl bottleneck

  signal memOut      : tMemOp                                   := cMemOp;
  signal memOuti1    : tMemOp                                   := cMemOp;
  signal operand1    : std_logic_vector(cXLen-1 downto 0)       := (others => '0');
  signal operand2    : std_logic_vector(cXLen-1 downto 0)       := (others => '0');
  -- signal operation   : tArithEnum                               := eNOOP;
  signal operation   : std_logic_vector(3 downto 0)             := cNoArith;
  signal regAddr     : std_logic_vector(cRegSelBitW-1 downto 0) := (others => '0');
  signal regOpValid  : std_logic                                := '0';
  signal regOut      : tRegOp                                   := cRegOp;
  signal equal       : boolean                                  := false;
  signal lessThanUns : boolean                                  := false;
  signal lessThan    : boolean                                  := false;
  signal curPC       : std_logic_vector(cXLen-1 downto 0)       := (others => '0');
  signal imm         : std_logic_vector(cXLen-1 downto 0)       := (others => '0');
  signal data1       : std_logic_vector(cXLen-1 downto 0)       := (others => '0');
  signal branchOpi1  : tDecodedBranch                           := cDecodedBranch;
  signal branchOut   : tBranchOp                                := cBranchOp;
begin  -- architecture rtl
  -- signal assignments
  iDecoded.rs1Data      <= iRs1Data;
  iDecoded.rs2Data      <= iRs2Data;
  iDecoded.rdAddr       <= iRdAddr;
  iDecoded.funct3       <= iFunct3;
  iDecoded.funct7       <= iFunct7;
  iDecoded.imm          <= iImm;
  iDecoded.opcode       <= iOpcode;
  iDecoded.curPc        <= iCurPc;
  -- iDecodedMem
  iDecodedMem.load      <= iLoad;
  iDecodedMem.store     <= iStore;
  iDecodedMem.dv        <= iMemDv;
  -- iDecodedReg
  iDecodedReg.arithType <= iArithType;
  iDecodedReg.opRs1     <= iOpRs1;
  iDecodedReg.opRs2     <= iOpRs2;
  iDecodedReg.opImm     <= iOpImm;
  iDecodedReg.opPc      <= iOpPc;
  iDecodedReg.opConst   <= iOpConst;
  iDecodedReg.dv        <= iRegdv;
  -- iDecodedBranch params
  iDecodedBranch.op     <= iBrOp;
  iDecodedBranch.dv     <= iBrDv;
  -- memWB
  oMemReadDv            <= memOuti1.readDv;
  oMemWriteDv           <= memOuti1.writeDv;
  oMemAddr              <= memOuti1.addr;
  oMemData              <= memOuti1.data;
  oMemOpType            <= memOuti1.opType;
  oMemRdAddr            <= memOuti1.rdAddr;
  -- oRegWB params
  oRegDv                <= regOut.dv;
  oRegAddr              <= regOut.addr;
  oRegData              <= regOut.data;
  -- oBranchWB params
  oBrFlushPipe          <= branchOut.flushPipe;
  oBrNewPc              <= branchOut.newPc;
  oBrPc                 <= branchOut.pc;
  oBrDv                 <= branchOut.dv;

  ---------------------------- load store op  ------------------------------
  loadStorePro : process (iClk) is
  begin  -- process loadStorePro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iDecodedMem.dv = '1' and iDecodedMem.load = '1') then
        memOut.addr   <= signed(iDecoded.rs1) + signed(iDecoded.imm);
        memOut.rdAddr <= iDecoded.rdAddr;
        memOut.opType <= iDecoded.funct3;
        memOut.readDv <= '1';
      elsif(iDecodedMem.dv = '1' and iDecodedMem.store = '1') then
        memOut.addr    <= signed(iDecoded.rs1) + signed(iDecoded.imm);
        memOut.data    <= iDecoded.rs2Data;
        memOut.opType  <= iDecoded.funct3;
        memOut.writeDv <= '1';
      else
        memOut <= cMemOp;
      end if;
    end if;
  end process loadStorePro;

  loadStoreRegPRo : process (iClk) is
  begin  -- process loadStoreRegPRo
    if iClk'event and iClk = '1' then   -- rising clock edge
      memOuti1 <= memOut;
    end if;
  end process loadStoreRegPRo;


  ---------------------------- register opeartion ------------------------------

  regOpSelPro : process (iClk) is
  begin  -- process regOpSelPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iDecodedReg.opRs1 = '1') then
        operand1 <= iDecoded.rs1Data;
      elsif(iDecodedReg.opPc = '1') then
        operand1 <= iDecoded.curPc;
      elsif(iDecodedReg.opImm = '1') then
        operand1 <= iDecoded.imm;
      end if;

      if(iDecodedReg.opRs2 = '1') then
        operand2 <= iDecoded.rs2Data;
      elsif(iDecodedReg.opConst = '1') then
        operand2 <= std_logic_vector(to_unsigned(4, cXLen));
      elsif(iDecodedReg.opImm = '1') then
        operand2 <= iDecoded.imm;
      elsif(iDecodedReg.opPc = '1') then
        operand2 <= iDecoded.curPc;
      end if;

    end if;
  end process regOpSelPro;

  regOpRegPro : process (iClk) is
  begin  -- process regOpRegPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      operation  <= iDecodedReg.arithType;
      regAddr    <= iDecoded.rdAddr;
      regOpValid <= iDecodedReg.dv;
    end if;
  end process regOpRegPro;

  regOpDonePro : process (iClk) is

  begin  -- process regOpDonePro
    if iClk'event and iClk = '1' then   -- rising clock edge
      regOut.addr <= regAddr;
      regOut.dv   <= regOpValid;
      case operation is
        when eAdd =>
          regOut.data <= signed(operand1) + signed(operand2);

        when eSub =>
          regOut.data <= signed(operand1) - signed(operand2);

        when eShftLeft =>
          regOut.data <= shift_left(unsigned(operand1), to_integer(unsigned(operand2(cRegSelBitW-1 downto 0))));

        when eCompareSigned =>
          if(signed(operand1) < signed(operand2)) then
            regOut.data(0)                <= '1';
            regOut.data(cXLen-1 downto 1) <= (others => '0');
          else
            regOut.data <= (others => '0');
          end if;

        when eCompareUnsigned =>
          if(unsigned(operand1) < unsigned(operand2)) then
            regOut.data(0)                <= '1';
            regOut.data(cXLen-1 downto 1) <= (others => '0');
          else
            regOut.data <= (others => '0');
          end if;

        when eXor =>
          regOut.data <= operand1 xor operand2;

        when eShftRight =>
          regOut.data <= shift_right(unsigned(operand1), to_integer(unsigned(operand2(cRegSelBitW-1 downto 0))));

        when eShftRightArit =>
          regOut.data <= shift_right(signed(operand1), to_integer(unsigned(operand2(cRegSelBitW-1 downto 0))));

        when eOr =>
          regOut.data <= operand1 or operand2;

        when eAnd =>
          regOut.data <= operand1 and operand2;

        when eNOOP =>
          regOut.data <= operand1;

        when others => null;
      end case;
    end if;
  end process regOpDonePro;

  ---------------------------- branch op  ------------------------------

  branchComparePro : process (iClk) is
  begin  -- process branchComparePro
    if iClk'event and iClk = '1' then   -- rising clock edge
      equal       <= iDecoded.rs1Data = iDecoded.rs2Data;  -- beq and bne comp
      lessThanUns <= unsigned(iDecoded.rs1Data) <
                     unsigned(iDecoded.rs2Data);  --bltu and bgeu comparison
      lessThan <= signed(iDecoded.rs1Data) <
                  signed(iDecoded.rs2Data);       -- blt and bge comp

      curPC <= iDecoded.curPc;
      imm   <= iDecoded.imm;
      data1 <= iDecoded.rs1Data;

      branchOpi1 <= iDecodedBranch;

    end if;
  end process branchComparePro;

  branchValPro : process (iClk) is
  begin  -- process branchValPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      branchOut.dv <= branchOpi1.dv;
    end if;
  end process branchValPro;


  branchSelPro : process (iClk) is
  begin  -- process branchSelPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      case branchOpi1.op is
        when eEqual =>
          branchOut.flushPipe <= equal;
          branchOut.newPc     <= equal;
        when eNEqual =>
          branchOut.flushPipe <= not equal;
          branchOut.newPc     <= not equal;
        when eLessThan =>
          branchOut.flushPipe <= lessThan;
          branchOut.newPc     <= lessThan;
        when eGreatEqual =>
          branchOut.flushPipe <= not lessThan;
          branchOut.newPc     <= not lessThan;
        when eLessThanUns =>
          branchOut.flushPipe <= lessThanUns;
          branchOut.newPc     <= lessThanUns;
        when eGreatEqualUns =>
          branchOut.flushPipe <= not lessThanUns;
          branchOut.newPc     <= not lessThanUns;
        when eJal =>
          branchOut.flushPipe <= '1';
          branchOut.newPc     <= '1';
        when eJalr =>
          branchOut.flushPipe <= '1';
          branchOut.newPc     <= '1';
        when others =>
          branchOut.flushPipe <= '0';
          branchOut.newPc     <= '0';
      end case;
    end if;
  end process branchSelPro;

  branchCompPRo : process (iClk) is
  begin  -- process branchCompPRo
    if iClk'event and iClk = '1' then   -- rising clock edge
      case branchOpi1.op is
        when eJalr =>
          branchOut.pc    <= signed(data1) + signed(imm);
          branchOut.pc(0) <= '0';
        when others =>
          branchOut.pc <= signed(curPc) + signed(imm);
      end if;
end process branchCompPRo;
end architecture rtl;
