-------------------------------------------------------------------------------
-- Title      : reg file
-- Project    :
-------------------------------------------------------------------------------
-- File       : regFile.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-14
-- Last update: 2021-07-02
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
    iClk   : in std_logic;
    iEn    : in std_logic;
    -- src1
    iRs1   : in tRegOp;
    -- src2
    iRs2   : in tRegOp;
    -- dest
    iRd    : in tRegOp;
    -- mem data
    iRdMem : in tRegOp;
    -- out data
    oRs1Data : out std_logic_vector(cXLen-1 downto 0);
    oRs2Data : out std_logic_vector(cXLen-1 downto 0)
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

  writeDataPro : process (iClk) is
  begin  -- process writeDataPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iRd.dv = '1') then
        rf(to_integer(unsigned(iRd.addr))) <= iRd.data;
      end if;

      if(iRdMem.dv = '1') then
        rf(to_integer(unsigned(iRdMem.addr))) <= iRdMem.data;
      end if;

      rf(0) <= (others => '0');
    end if;
  end process writeDataPro;


  outData : process (all) is
  begin  -- process outData
    if(iRs1.dv = '1') then
      oRs1Data <= rf(to_integer(unsigned(iRs1.addr)));
    else
      oRs1Data <= (others => '0');
    end if;

    if(iRs2.dv = '1') then
      oRs2Data <= rf(to_integer(unsigned(iRs2.addr)));
    else
      oRs2Data <= (others => '0');
    end if;
  end process outData;

end architecture rtl;
