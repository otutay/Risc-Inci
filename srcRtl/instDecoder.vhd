-------------------------------------------------------------------------------
-- Title      : instDecoder
-- Project    :
-------------------------------------------------------------------------------
-- File       : instDecoder.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-16
-- Last update: 2021-03-18
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: instruction decode code for risc inci
-------------------------------------------------------------------------------
-- Copyright (c) 2021
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-03-16  1.0      otutay  Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instDecoder is
  generic (
    cycleNum : integer := 2             -- cycleNum for instruction decode.
    );
  port (
    iClk       : in  std_logic;
    iRst       : in  std_logic;
    iInst      : in  std_logic_vector(cXLen-1 downto 0);
    iCurPc     : in  std_logic_vector(cXLen-1 downto 0);
    iFlushPipe : in  std_logic;
    oDecoded   : out tDecodedInst;
    oMemOp     : out tDecodedMem;
    oRegOp     : out tDecodedReg;
    oBranchOp  : out tDecodedBranch
    );

end entity instDecoder;
architecture rtl of instDecoder is
  signal opcode     : std_logic_vector(6 downto 0)             := cOpNoOp;
  signal src1Addr   : std_logic_vector(cRegSelBitW-1 downto 0) := (others => '0');
  signal src2Addr   : std_logic_vector(cRegSelBitW-1 downto 0) := (others => '0');
  signal dest2Addr  : std_logic_vector(cRegSelBitW-1 downto 0) := (others => '0');
  signal funct3     : std_logic_vector(2 downto 0)             := (others => '0');
  signal funct7     : std_logic_vector(6 downto 0)             := (others => '0');
  signal insti1     : std_logic_vector(cXLEN-1 downto 0)       := (others => '0');
  signal curPci1    : std_logic_vector(cXLEN-1 downto 0)       := (others => '0');
  signal rSelection : std_logic_vector(3 downto 0)             := (others => '0');
begin  -- architecture rtl
  -- assert statements
  assert cycleNum = 1 or cycleNum = 2 report "cycleNum is not supported" severity failure;

  -- entity started
  OneCycleGen : if cycleNum = 1 generate

    flop : process (all) is
    begin  -- process flop
      if(iFlushPipe = '1') then
        opcode     <= cOpNoOp;
        src1Addr   <= (others => '0');
        src2Addr   <= (others => '0');
        dest2Addr  <= (others => '0');
        funct3     <= (others => '0');
        funct7     <= (others => '0');
        insti1     <= (others => '0');
        curPci1    <= (others => '0');
        rSelection <= (others => '0');
      else
        opcode     <= iInst(6 downto 0);
        src1Addr   <= iInst(19 downto 15);
        src2Addr   <= iInst(24 downto 20);
        destAddr   <= iInst(11 downto 7);
        funct3     <= iInst(14 downto 12);
        funct7     <= iInst(31 downto 25);
        insti1     <= iInst;
        curPci1    <= iCurPc;
        rSelection <= iInst(30) & iInst(14 : 12);
      end if;
    end process flop;

  end generate OneCycleGen;

  twoCycleGen : if cycleNum = 2 generate

    flop : process (iClk) is
    begin  -- process flop
      if iClk'event and iClk = '1' then  -- rising clock edge
        if(iFlushPipe = '1') then
          opcode     <= cOpNoOp;
          src1Addr   <= (others => '0');
          src2Addr   <= (others => '0');
          dest2Addr  <= (others => '0');
          funct3     <= (others => '0');
          funct7     <= (others => '0');
          insti1     <= (others => '0');
          curPci1    <= (others => '0');
          rSelection <= (others => '0');
        else
          opcode     <= iInst(6 downto 0);
          src1Addr   <= iInst(19 downto 15);
          src2Addr   <= iInst(24 downto 20);
          destAddr   <= iInst(11 downto 7);
          funct3     <= iInst(14 downto 12);
          funct7     <= iInst(31 downto 25);
          insti1     <= iInst;
          curPci1    <= iCurPc;
          rSelection <= iInst(30) & iInst(14 : 12);
        end if;

      end if;
    end process flop;

  end generate twoCycleGen;

  operationPro : process (iClk) is
  begin  -- process operationPro
    if iClk'event and iClk = '1' then   -- rising clock edge

    end if;
  end process operationPro;


end architecture rtl;
