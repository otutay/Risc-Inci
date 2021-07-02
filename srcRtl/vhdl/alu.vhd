-------------------------------------------------------------------------------
-- Title      : alu.vhd
-- Project    :
-------------------------------------------------------------------------------
-- File       : alu.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-22
-- Last update: 2021-07-02
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
    iClk           : in  std_logic;
    iRst           : in  std_logic;
    -- iDecoded params
    iDecoded       : in  tDecoded;
    -- iDecodedMem params
    iDecodedMem    : in  tDecodedMem;
    -- iDecodedReg params
    iDecodedReg    : in  tDecodedReg;
    -- iDecodedBranch params
    iDecodedBranch : in  tDecodedBranch;
    -- oMemWB params
    oMemWB         : out tMemOp;
    -- oRegWB params
    oRegWB         : out tRegOp;
    -- oBranchWB params
    oBranchWB     : out tBranchOp
    );
end entity alu;

architecture rtl of alu is
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
  -- memWB
  oMemWB <= memOuti1;
  -- oRegWB params
  oRegWB <= regOut;
  -- oBranchWB params
  oBranchWB <= branchOut;

  ---------------------------- load store op  ------------------------------
  loadStorePro : process (iClk) is
  begin  -- process loadStorePro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iDecodedMem.dv = '1' and iDecodedMem.load = '1') then
        memOut.addr   <= std_logic_vector(signed(iDecoded.rs1Data) + signed(iDecoded.imm));
        memOut.rdAddr <= iDecoded.rdAddr;
        memOut.opType <= iDecoded.funct3;
        memOut.readDv <= '1';
      elsif(iDecodedMem.dv = '1' and iDecodedMem.store = '1') then
        memOut.addr    <= std_logic_vector(signed(iDecoded.rs1Data) + signed(iDecoded.imm));
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
