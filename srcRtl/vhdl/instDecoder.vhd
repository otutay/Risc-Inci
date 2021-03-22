-------------------------------------------------------------------------------
-- Title      : instDecoder
-- Project    :
-------------------------------------------------------------------------------
-- File       : instDecoder.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-16
-- Last update: 2021-03-22
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

library work;
use work.corePckg.all;

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
--  signal opcode     : std_logic_vector(6 downto 0)             := cOpNoOp;
  signal opcode      : tOpcodeEnum                              := eNOOP;
  signal src1Addr    : std_logic_vector(cRegSelBitW-1 downto 0) := (others => '0');
  signal src2Addr    : std_logic_vector(cRegSelBitW-1 downto 0) := (others => '0');
  signal destAddr    : std_logic_vector(cRegSelBitW-1 downto 0) := (others => '0');
  signal funct3      : std_logic_vector(2 downto 0)             := (others => '0');
  signal funct7      : std_logic_vector(6 downto 0)             := (others => '0');
  signal insti1      : std_logic_vector(cXLEN-1 downto 0)       := (others => '0');
  signal curPci1     : std_logic_vector(cXLEN-1 downto 0)       := (others => '0');
  signal rSelection  : std_logic_vector(3 downto 0)             := (others => '0');
  signal regOp       : tDecodedReg                              := cDecodedReg;
  signal memOp       : tDecodedMem                              := cDecodedMem;
  signal branchOp    : tDecodedBranch                           := cDecodedBranch;
  signal decodedInst : tDecodedInst                             := cDecodedInst;
begin  -- architecture rtl
  -- assert statements
  assert cycleNum = 1 or cycleNum = 2 report "cycleNum is not supported" severity failure;

  -- entity started
  OneCycleGen : if cycleNum = 1 generate

    flop : process (all) is
    begin  -- process flop
      if(iFlushPipe = '1') then
        opcode     <= eNOOP;
        src1Addr   <= (others => '0');
        src2Addr   <= (others => '0');
        dest2Addr  <= (others => '0');
        funct3     <= (others => '0');
        funct7     <= (others => '0');
        insti1     <= (others => '0');
        curPci1    <= (others => '0');
        rSelection <= (others => '0');
      else
        opcode     <= to_opcodeEnum(iInst(6 downto 0));
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
          opcode     <= eNOOP;
          src1Addr   <= (others => '0');
          src2Addr   <= (others => '0');
          dest2Addr  <= (others => '0');
          funct3     <= (others => '0');
          funct7     <= (others => '0');
          insti1     <= (others => '0');
          curPci1    <= (others => '0');
          rSelection <= (others => '0');
        else
          opcode     <= to_opcodeEnum(iInst(6 downto 0));
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

  regOpPro : process (iClk) is
  begin  -- process operationPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iFlushPipe = '1') then
        regOp <= cDecodedReg;
      else
        case opcode is
          when eOpRtype =>
            regOp.arithType <= to_arithEnum(rSelection);
            regOp.opRs1     <= '1';
            regOp.opRs2     <= '1';
            regOp.opImm     <= '0';
            regOp.opPc      <= '0';
            regOp.opConst   <= '0';
            regOp.dv        <= '1';
          when eOpImmedi =>
            case funct3 is
              when "000" =>
                regOp.arithType <= eAdd;
              when "010" =>
                regOp.arithType <= eCompareSigned;
              when "011" =>
                regOp.aritType <= eCompareUnsigned;
              when "100" =>
                regOp.aritType <= eXor;
              when "110" =>
                regOp.aritType <= eOr;
              when "111" =>
                regOp.aritType <= eAnd;
              when "001" =>
                regOp.aritType <= eShftLeft;
              when "101" =>
                if(funct7(5) = '1') then
                  regOp.aritType <= eShftRight;
                else
                  regOp.aritType <= eShftRightArit;
                end if;
            end case;
            regOp.opRs1   <= '1';
            regOp.opRs2   <= '0';
            regOp.opImm   <= '1';
            regOp.opPc    <= '0';
            regOp.opConst <= '0';
            regOp.dv      <= '1';
          when eOpJal =>
            regOp.aritType <= eAdd;
            regOp.opRs1    <= '0';
            regOp.opRs2    <= '0';
            regOp.opImm    <= '0';
            regOp.opPc     <= '1';
            regOp.opConst  <= '1';
            regOp.dv       <= '1';

          when eOpJalr =>
            regOp.aritType <= eAdd;
            regOp.opRs1    <= '0';
            regOp.opRs2    <= '0';
            regOp.opImm    <= '0';
            regOp.opPc     <= '1';
            regOp.opConst  <= '1';
            regOp.dv       <= '1';
          when opLui =>
            regOp.aritType <= eNoArithOp;
            regOp.opRs1    <= '0';
            regOp.opRs2    <= '0';
            regOp.opImm    <= '1';
            regOp.opPc     <= '0';
            regOp.opConst  <= '0';
            regOp.dv       <= '1';

          when eOpAuIpc =>
            regOp.aritType <= eAdd;
            regOp.opRs1    <= '0';
            regOp.opRs2    <= '0';
            regOp.opImm    <= '1';
            regOp.opPc     <= '1';
            regOp.opConst  <= '0';
            regOp.dv       <= '1';

          when others =>
            regOp <= cDecodedReg;
          when others => null;
        end case;
      end if;
    end if;
  end process regOpPro;


  memOpPro : process (iClk) is
  begin  -- process memOpPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iFlushPipe = '1') then
        memOp <= cDecodedMem;
      else
        case opcode is
          when eOpLoad =>
            memOp.load  <= '1';
            memOp.store <= '0';
            memOp.dv    <= '1';
          when eOpStore =>
            memOp.load  <= '0';
            memOp.store <= '1';
            memOp.dv    <= '1';

          when others =>
            memOp <= cDecodedMem;
        end case;
      end if;
    end if;
  end process memOpPro;


  branchOpPRo : process (iClk) is
  begin  -- process branchOpPRo
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iFlushPipe = '1') then
        branchOp <= cDecodedBranch;
      else
        case opcode is
          when eOpJal =>
            branchOp.op <= eJal;
            branchOp.dv <= '1';
          when eOpJalr =>
            branchOp.op <= eJalr;
            branchOp.dv <= '1';
          when eOpBranch =>
            branchOp.op <= to_branchEnum(funct3);
            branchOp.dv <= '1';
          when others =>
            branchOp <= cDecodedBranch;
        end case;
      end if;
    end if;
  end process branchOpPRo;

  decodedInstPro : process (iClk) is
  begin  -- process decodedInstPro
    if iClk'event and iClk = '1' then   -- rising clock edge
      if(iFlushPipe = '1') then
        decodedInst <= cDecodedInst;
      else
        decodedInst.rs1    <= ('1', src1Addr, (others => '0'));
        decodedInst.rs2    <= ('1', src1Addr, (others => '0'));
        decodedInst.rdAddr <= destAddr;
        decodedInst.funct3 <= funct3;
        decodedInst.funct7 <= funct7;
        decodedInst.opcode <= opcode;
        decodedInst.curPc  <= curPc;

        case opcode is
          when eOpLoad =>
            decodedInst.imm <= std_logic_vector(resize(signed(insti1(31 downto 20)), cXLEN));
          when eOpStore =>
            decodedInst.imm <= std_logic_vector(resize(signed(insti1(31 downto 25) & insti1(11 downto 7)), cXLEN));
          when eOpRtype =>
            decodedInst.imm <= (others => '0');
          when eOpFence =>
            decodedInst.imm <= (others => '0'); -- not implemented
          when eOpImmedi =>
            decodedInst.imm <= std_logic_vector(resize(signed(insti1(31 downto 20)), cXLEN));
          when eOpAuIpc =>
            decodedInst.imm(31 downto 12) <= insti1(31 downto 12);
            decodedInst.imm(11 downto 0)  <= (others => '0');
          when eOpLui =>
            decodedInst.imm(31 downto 12) <= insti1(31 downto 12);
            decodedInst.imm(11 downto 0)  <= (others => '0');
          when eOpBranch =>
            decodedInst.imm <= std_logic_vector(resize(signed(insti1(31) & insti1(7) & insti1(30 downto 25)
                                                              & insti1(11 downto 8) & '0'), cXLEN));
          when eOpJalr =>
            decodedInst.imm <= std_logic_vector(resize(signed(insti1(31 downto 20)), cXLEN));
          when eOpJal =>
            decodedInst.imm <= std_logic_vector(resize(signed(insti1(31) & insti1(19 downto 12) & insti1(20)
                                                              & insti1(30 downto 21) & '0'), cXLEN));
          when eOpCntrlSt =>
            decodedInst.imm <= (others => '0'); -- not implemented
          when others =>
            decodedInst.imm <= (others => '0');
        end case;

      end if;
    end if;
  end process decodedInstPro;

end architecture rtl;
