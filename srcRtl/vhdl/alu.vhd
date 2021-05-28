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
  signal decoded       : tDecoded                                 := cDecoded;
  signal decodedMem    : tDecodedMem                              := cDecodedMem;
  signal decodedReg    : tDecodedReg                              := cDecodedReg;
  signal decodedBranch : tDecodedBranch                           := cDecodedBranch;
  signal memOut        : tMemOp                                   := cMemOp;
  signal memOuti1      : tMemOp                                   := cMemOp;
  signal operand1      : std_logic_vector(cXLen-1 downto 0)       := (others => '0');
  signal operand2      : std_logic_vector(cXLen-1 downto 0)       := (others => '0');
  -- signal operation   : tArithEnum                               := eNOOP;
  signal operation     : std_logic_vector(3 downto 0)             := cNoArith;
  signal regAddr       : std_logic_vector(cRegSelBitW-1 downto 0) := (others => '0');
  signal regOpValid    : std_logic                                := '0';
  signal regOut        : tRegOp                                   := cRegOp;
  signal equal         : boolean                                  := false;
  signal lessThanUns   : boolean                                  := false;
  signal lessThan      : boolean                                  := false;
  signal curPC         : std_logic_vector(cXLen-1 downto 0)       := (others => '0');
  signal imm           : std_logic_vector(cXLen-1 downto 0)       := (others => '0');
  signal data1         : std_logic_vector(cXLen-1 downto 0)       := (others => '0');
  signal branchOpi1    : tDecodedBranch                           := cDecodedBranch;
  signal branchOut     : tBranchOp                                := cBranchOp;
begin  -- architecture rtl
  -- signal assignments
  decoded.rs1Data      <= iRs1Data;
  decoded.rs2Data      <= iRs2Data;
  decoded.rdAddr       <= iRdAddr;
  decoded.funct3       <= iFunct3;
  decoded.funct7       <= iFunct7;
  decoded.imm          <= iImm;
  decoded.opcode       <= iOpcode;
  decoded.curPc        <= iCurPc;
  -- iDecodedMem
  decodedMem.load      <= iLoad;
  decodedMem.store     <= iStore;
  decodedMem.dv        <= iMemDv;
  -- iDecodedReg
  decodedReg.arithType <= iArithType;
  decodedReg.opRs1     <= iOpRs1;
  decodedReg.opRs2     <= iOpRs2;
  decodedReg.opImm     <= iOpImm;
  decodedReg.opPc      <= iOpPc;
  decodedReg.opConst   <= iOpConst;
  decodedReg.dv        <= iRegdv;
  -- iDecodedBranch params
  decodedBranch.op     <= iBrOp;
  decodedBranch.dv     <= iBrDv;
  -- memWB
  oMemReadDv           <= memOuti1.readDv;
  oMemWriteDv          <= memOuti1.writeDv;
  oMemAddr             <= memOuti1.addr;
  oMemData             <= memOuti1.data;
  oMemOpType           <= memOuti1.opType;
  oMemRdAddr           <= memOuti1.rdAddr;
  -- oRegWB params
  oRegDv               <= regOut.dv;
  oRegAddr             <= regOut.addr;
  oRegData             <= regOut.data;
  -- oBranchWB params
  oBrFlushPipe         <= branchOut.flushPipe;
  oBrNewPc             <= branchOut.newPc;
  oBrPc                <= branchOut.pc;
  oBrDv                <= branchOut.dv;

  ---------------------------- load store op  ------------------------------
  loadStorePro : process (iClk) is
  begin  -- process loadStorePro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(decodedMem.dv = '1' and decodedMem.load = '1') then
        memOut.addr   <= std_logic_vector(signed(decoded.rs1Data) + signed(decoded.imm));
        memOut.rdAddr <= decoded.rdAddr;
        memOut.opType <= decoded.funct3;
        memOut.readDv <= '1';
      elsif(decodedMem.dv = '1' and decodedMem.store = '1') then
        memOut.addr    <= std_logic_vector(signed(decoded.rs1Data) + signed(decoded.imm));
        memOut.data    <= decoded.rs2Data;
        memOut.opType  <= decoded.funct3;
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
      if(decodedReg.opRs1 = '1') then
        operand1 <= decoded.rs1Data;
      elsif(decodedReg.opPc = '1') then
        operand1 <= decoded.curPc;
      elsif(decodedReg.opImm = '1') then
        operand1 <= decoded.imm;
      end if;

      if(decodedReg.opRs2 = '1') then
        operand2 <= decoded.rs2Data;
      elsif(decodedReg.opConst = '1') then
        operand2 <= std_logic_vector(to_unsigned(4, cXLen));
      elsif(decodedReg.opImm = '1') then
        operand2 <= decoded.imm;
      elsif(decodedReg.opPc = '1') then
        operand2 <= decoded.curPc;
      end if;

    end if;
  end process regOpSelPro;

  regOpRegPro : process (iClk) is
  begin  -- process regOpRegPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      operation  <= decodedReg.arithType;
      regAddr    <= decoded.rdAddr;
      regOpValid <= decodedReg.dv;
    end if;
  end process regOpRegPro;

  regOpDonePro : process (iClk) is

  begin  -- process regOpDonePro
    if iClk'event and iClk = '1' then   -- rising clock edge
      regOut.addr <= regAddr;
      regOut.dv   <= regOpValid;
      case operation is
        when cAdd =>
          regOut.data <= std_logic_vector(signed(operand1) + signed(operand2));

        when cSub =>
          regOut.data <= std_logic_vector(signed(operand1) - signed(operand2));

        when cShftLeft =>
          regOut.data <= std_logic_vector(shift_left(unsigned(operand1), to_integer(unsigned(operand2(cRegSelBitW-1 downto 0)))));

        when cCompareSigned =>
          if(signed(operand1) < signed(operand2)) then
            regOut.data(0)                <= '1';
            regOut.data(cXLen-1 downto 1) <= (others => '0');
          else
            regOut.data <= (others => '0');
          end if;

        when cCompareUnsigned =>
          if(unsigned(operand1) < unsigned(operand2)) then
            regOut.data(0)                <= '1';
            regOut.data(cXLen-1 downto 1) <= (others => '0');
          else
            regOut.data <= (others => '0');
          end if;

        when cXor =>
          regOut.data <= operand1 xor operand2;

        when cShftRight =>
          regOut.data <= std_logic_vector(shift_right(unsigned(operand1), to_integer(unsigned(operand2(cRegSelBitW-1 downto 0)))));

        when cShftRightArith =>
          regOut.data <= std_logic_vector(shift_right(signed(operand1), to_integer(unsigned(operand2(cRegSelBitW-1 downto 0)))));

        when cOr =>
          regOut.data <= operand1 or operand2;

        when cAnd =>
          regOut.data <= operand1 and operand2;

        when cNoArith =>
          regOut.data <= operand1;

        when others => null;
      end case;
    end if;
  end process regOpDonePro;

  ---------------------------- branch op  ------------------------------

  branchComparePro : process (iClk) is
  begin  -- process branchComparePro
    if iClk'event and iClk = '1' then   -- rising clock edge
      equal       <= decoded.rs1Data = decoded.rs2Data;  -- beq and bne comp
      lessThanUns <= unsigned(decoded.rs1Data) <
                     unsigned(decoded.rs2Data);  --bltu and bgeu comparison
      lessThan <= signed(decoded.rs1Data) <
                  signed(decoded.rs2Data);       -- blt and bge comp

      curPC <= decoded.curPc;
      imm   <= decoded.imm;
      data1 <= decoded.rs1Data;

      branchOpi1 <= decodedBranch;

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
        when cBrEqual =>
          branchOut.flushPipe <= bool2Logic(equal);
          branchOut.newPc     <= bool2Logic(equal);
        when cBrNEqual =>
          branchOut.flushPipe <= bool2Logic(not equal);
          branchOut.newPc     <= bool2Logic(not equal);
        when cBrLessTh =>
          branchOut.flushPipe <= bool2Logic(lessThan);
          branchOut.newPc     <= bool2Logic(lessThan);
        when cBrGreatEq =>
          branchOut.flushPipe <= bool2Logic(not lessThan);
          branchOut.newPc     <= bool2Logic(not lessThan);
        when cBrLessThUns =>
          branchOut.flushPipe <= bool2Logic(lessThanUns);
          branchOut.newPc     <= bool2Logic(lessThanUns);
        when cBrGreatEqUns =>
          branchOut.flushPipe <= bool2Logic(not lessThanUns);
          branchOut.newPc     <= bool2Logic(not lessThanUns);
        when cBrJal =>
          branchOut.flushPipe <= '1';
          branchOut.newPc     <= '1';
        when cBrJalR =>
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
        when cBrJalR =>
          branchOut.pc    <= std_logic_vector(signed(data1) + signed(imm));
          branchOut.pc(0) <= '0';
        when others =>
          branchOut.pc <= std_logic_vector(signed(curPc) + signed(imm));
      end case;
    end if;
  end process branchCompPRo;
end architecture rtl;
