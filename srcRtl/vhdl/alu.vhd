-------------------------------------------------------------------------------
-- Title      : alu.vhd
-- Project    :
-------------------------------------------------------------------------------
-- File       : alu.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-22
-- Last update: 2021-03-24
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
use work.corePckg.all;
entity alu is

  port (
    iClk           : in  std_logic;
    iRst           : in  std_logic;
    iDecoded       : in  tDecoded;
    iDecodedMem    : in  tDecodedMem;
    iDecodedReg    : in  tDecodedReg;
    iDecodedBranch : in  tDecodedBranch;
    oMemWB         : out tMemOp;
    oRegWB         : out tRegOp;
    oBranchWB      : out tBranchOp
    );


end entity alu;

architecture rtl of alu is
  signal memOut     : tMemOp                                   := cMemOp;
  signal memOuti1   : tMemOp                                   := cMemOp;
  signal operand1   : std_logic_vector(cXLen-1 downto 0)       := (others => '0');
  signal operand2   : std_logic_vector(cXLen-1 downto 0)       := (others => '0');
  signal operation  : tArithEnum                               := eNOOP;
  signal regAddr    : std_logic_vector(cRegSelBitW-1 downto 0) := (others => '0');
  signal regOpValid : std_logic                                := '0';
  signal regOut     : tRegOp                                   := cRegOp;
begin  -- architecture rtl

  -- load store op
  oMemWB <= memOuti1;
  loadStorePro : process (iClk) is
  begin  -- process loadStorePro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iDecodedMem.dv and iDecodedMem.load) then
        memOut.addr   <= signed(iDecoded.rs1) + signed(iDecoded.imm);
        memOut.rdAddr <= iDecoded.rdAddr;
        memOut.opType <= iDecoded.funct3;
        memOut.readDv <= '1';
      elsif(iDecodedMem.dv and iDecodedMem.store) then
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

  ----   register opeartion

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
          regOut.data <= operand1 sll to_integer(unsigned(operand2(cRegSelBitW-1 downto 0)));
        when eCompareSigned =>
          regOut.data <=
        when others => null;
      end case;
    end if;
  end process regOpDonePro;


end architecture rtl;
