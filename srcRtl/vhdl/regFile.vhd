-------------------------------------------------------------------------------
-- Title      : reg file
-- Project    :
-------------------------------------------------------------------------------
-- File       : regFile.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-14
-- Last update: 2021-06-30
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: register file changed from sv
-------------------------------------------------------------------------------
-- Copyright (c) 2021
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2021-03-14  1.0      otutay  Created
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.corePackage.all;

entity regFile is

  port (
    iClk       : in  std_logic;
    iEn        : in  std_logic;
    -- src1
    iRs1Addr   : in  std_logic_vector(cRegSelBitW-1 downto 0);
    iRs1Dv     : in  std_logic;
    -- src2
    iRs2Addr   : in  std_logic_vector(cRegSelBitW-1 downto 0);
    iRs2Dv     : in  std_logic;
    -- dest
    iRdAddr    : in  std_logic_vector(cRegSelBitW-1 downto 0);
    iRdData    : in  std_logic_vector(cXLen-1 downto 0);
    iRdDv      : in  std_logic;
    -- mem data
    iRdMemAddr : in  std_logic_vector(cRegSelBitW-1 downto 0);
    iRdMemData : in  std_logic_vector(cXLen-1 downto 0);
    iRdMemDv   : in  std_logic;
    -- rs1     : in  tRegOp;
    -- rs2     : in  tRegOp;
    -- rd      : in  tRegOp;
    -- rdMem   : in  tRegOp;
    oRs1Data   : out std_logic_vector(cXLen-1 downto 0);
    oRs2Data   : out std_logic_vector(cXLen-1 downto 0)
    );

end entity regFile;

architecture rtl of regFile is
  type tRegFile is array (0 to cRegNum-1) of std_logic_vector(cXLen-1 downto 0);
  signal rf    : tRegFile := (others => (others => '0'));
  signal rs1   : tRegOp   := cRegOp;
  signal rs2   : tRegOp   := cRegOp;
  signal rd    : tRegOp   := cRegOp;
  signal rdMem : tRegOp   := cRegOp;
begin  -- architecture rtl

  rs1.addr <= iRs1Addr;
  rs1.dv   <= iRs1Dv;

  rs2.addr <= iRs2Addr;
  rs2.dv   <= iRs2Dv;

  rd.addr <= iRdAddr;
  rd.data <= iRdData;
  rd.dv   <= iRdDv;

  rdMem.addr <= iRdMemAddr;
  rdMem.data <= iRdMemData;
  rdMem.dv   <= iRdMemDv;


  writeDataPro : process (iClk) is
  begin  -- process writeDataPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(rd.dv = '1') then
        rf(to_integer(unsigned(rd.addr))) <= rd.data;
      end if;

      if(rdMem.dv = '1') then
        rf(to_integer(unsigned(rd.addr))) <= rdMem.data;
      end if;

      rf(0) <= (others => '0');
    end if;
  end process writeDataPro;


  outData : process (all) is
  begin  -- process outData
    if(rs1.dv = '1') then
      oRs1Data <= rf(to_integer(unsigned(rs1.addr)));
    else
      oRs1Data <= (others => '0');
    end if;

    if(rs2.dv = '1') then
      oRs2Data <= rf(to_integer(unsigned(rs2.addr)));
    else
      oRs2Data <= (others => '0');
    end if;
  end process outData;

end architecture rtl;
