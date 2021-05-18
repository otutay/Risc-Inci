-------------------------------------------------------------------------------
-- Title      : instDecoder
-- Project    :
-------------------------------------------------------------------------------
-- File       : instDecoder.vhd
-- Author     : osmant  <otutaysalgir@gmail.com>
-- Company    :
-- Created    : 2021-03-16
-- Last update: 2021-05-19
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
use work.corePackage.all;

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
    -- decoded params
    oRs1Addr   : out std_logic_vector(cRegSelBitW-1 downto 0);
    oRs2Addr   : out std_logic_vector(cRegSelBitW-1 downto 0);
    oRdAddr    : out std_logic_vector(cRegSelBitW-1 downto 0);
    oF3        : out std_logic_vector(2 downto 0);
    oF7        : out std_logic_vector(6 downto 0);
    oImm       : out std_logic_vector(cXLen-1 downto 0);
    oOpcode    : out std_logic_vector(6 downto 0);
    oCurPc     : out std_logic_vector(cXLen-1 downto 0);
    -- oDecodedMem
    oLoad      : out std_logic;
    oStore     : out std_logic;
    oMemDv     : out std_logic;
    -- oDecodedReg
    oAritType  : out std_logic_vector(3 downto 0);
    oOpRs1     : out std_logic;
    oOpRs2     : out std_logic;
    oOpImm     : out std_logic;
    oOpPc      : out std_logic;
    oOpConst   : out std_logic;
    oOpDv      : out std_logic;
    -- oDecodedBranch
    oBrOp      : out std_logic_vector(2 downto 0);
    oBrDv      : out std_logic
   -- oDecoded   : out tDecodedInst;
   -- oMemOp     : out tDecodedMem;
   -- oRegOp     : out tDecodedReg;
   -- oBranchOp  : out tDecodedBranch
    );

end entity instDecoder;
architecture rtl of instDecoder is
--  signal opcode     : std_logic_vector(6 downto 0)             := cOpNoOp;
  signal opcode      : std_logic_vector(6 downto 0)             := cOpNoop;
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


  -- output setting
-- decoded params
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


  OneCycleGen : if cycleNum = 1 generate

    flop : process (iFlushPipe, iInst, iCurPc) is
    begin  -- process flop
      if(iFlushPipe = '1') then
        opcode     <= cOpNoop;
        src1Addr   <= (others => '0');
        src2Addr   <= (others => '0');
        destAddr   <= (others => '0');
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
        rSelection <= iInst(30) & iInst(14 downto 12);
      end if;
    end process flop;

  end generate OneCycleGen;

  twoCycleGen : if cycleNum = 2 generate

    flop : process (iClk) is
    begin  -- process flop
      if iClk'event and iClk = '1' then  -- rising clock edge
        if(iFlushPipe = '1') then
          opcode     <= cOpNoop;
          src1Addr   <= (others => '0');
          src2Addr   <= (others => '0');
          destAddr   <= (others => '0');
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
          rSelection <= iInst(30) & iInst(14 downto 12);
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
          when cOpRType =>
            regOp.opRs1   <= '1';
            regOp.opRs2   <= '1';
            regOp.opImm   <= '0';
            regOp.opPc    <= '0';
            regOp.opConst <= '0';
            regOp.dv      <= '1';

            case funct3 is
              when "000" =>
                if (funct7(5) = '0') then
                  regOp.arithType <= cAdd;
                else
                  regOp.arithType <= cSub;
                end if;
              when "001" =>
                regOp.arithType <= cShftLeft;
              when "010" =>
                regOp.arithType <= cCompareSigned;
              when "011" =>
                regOp.arithType <= cCompareUnSigned;
              when "100" =>
                regOp.arithType <= cXor;
              when "101" =>
                if(funct7(5) = '0') then
                  regOp.arithType <= cShftRight;
                else
                  regOp.arithType <= cShftRightArith;
                end if;
              when "110" =>
                regOp.arithType <= cOr;

              when "111" =>
                regOp.arithType <= cAnd;
              when others =>
                regOp.arithType <= cNoArith;
            end case;
          when cOpImmedi =>               --eOpImmedi =>
            regOp.opRs1   <= '1';
            regOp.opRs2   <= '0';
            regOp.opImm   <= '1';
            regOp.opPc    <= '0';
            regOp.opConst <= '0';
            regOp.dv      <= '1';
            case funct3 is
              when "000" =>
                -- if (funct7(5) = '0') then
                --   regOp.arithType <= cSub;  --eSub;
                -- else
                regOp.arithType <= cAdd;  -- eAdd;
                -- end if;

              when "010" =>
                regOp.arithType <= cCompareSigned;     --eCompareSigned; slt
              when "011" =>
                regOp.arithType <= cCompareUnSigned;   --eCompareUnsigned; sltu
              when "100" =>
                regOp.arithType <= cXor;               --eXor;
              when "110" =>
                regOp.arithType <= cOr;                --eOr;
              when "111" =>
                regOp.arithType <= cAnd;               --eAnd;
              when "001" =>
                regOp.arithType <= cShftLeft;          --eShftLeft;
              when "101" =>
                if(funct7(5) = '1') then
                  regOp.arithType <= cShftRightArith;  --eShftRight;
                else
                  regOp.arithType <= cShftRight;       --eShftRightArit;
                end if;
              when others => regOp <= cDecodedReg;
            end case;

          when cOpJal =>                -- eOpJal =>
            regOp.arithType <= cAdd;    --eAdd;
            regOp.opRs1     <= '0';
            regOp.opRs2     <= '0';
            regOp.opImm     <= '0';
            regOp.opPc      <= '1';
            regOp.opConst   <= '1';
            regOp.dv        <= '1';

          when cOpJalR =>                 --eOpJalr =>
            regOp.arithType <= cAdd;      --eAdd;
            regOp.opRs1     <= '0';
            regOp.opRs2     <= '0';
            regOp.opImm     <= '0';
            regOp.opPc      <= '1';
            regOp.opConst   <= '1';
            regOp.dv        <= '1';
          when cOpLui =>                  --opLui =>
            regOp.arithType <= cNoArith;  --eNoArithOp;
            regOp.opRs1     <= '0';
            regOp.opRs2     <= '0';
            regOp.opImm     <= '1';
            regOp.opPc      <= '0';
            regOp.opConst   <= '0';
            regOp.dv        <= '1';

          when cOpAuIpc =>              --eOpAuIpc =>
            regOp.arithType <= cAdd;    --eAdd;
            regOp.opRs1     <= '0';
            regOp.opRs2     <= '0';
            regOp.opImm     <= '1';
            regOp.opPc      <= '1';
            regOp.opConst   <= '0';
            regOp.dv        <= '1';

          when others =>
            regOp <= cDecodedReg;
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
          when cOpLoad =>               --eOpLoad =>
            memOp.load  <= '1';
            memOp.store <= '0';
            memOp.dv    <= '1';
          when cOpStore =>              --eOpStore =>
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
          when cOpJal =>                --eOpJal =>
            branchOp.op <= cBrJal;      --eJal;
            branchOp.dv <= '1';
          when cOpJalR =>               --eOpJalr =>
            branchOp.op <= cBrJalR;     -- eJalr;
            branchOp.dv <= '1';
          when cOpBranch =>             --eOpBranch =>
            branchOp.op <= funct3;      --to_branchEnum(funct3);
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
        decodedInst.rs2    <= ('1', src2Addr, (others => '0'));
        decodedInst.rdAddr <= destAddr;
        decodedInst.funct3 <= funct3;
        decodedInst.funct7 <= funct7;
        decodedInst.opcode <= opcode;
        decodedInst.curPc  <= curPci1;

        case opcode is
          when cOpLoad =>                        --eOpLoad =>
            decodedInst.imm <= std_logic_vector(resize(signed(insti1(31 downto 20)), cXLEN));
          when cOpStore =>                       --eOpStore =>
            decodedInst.imm <= std_logic_vector(resize(signed(insti1(31 downto 25) & insti1(11 downto 7)), cXLEN));
          when cOpRType =>                       --eOpRtype =>
            decodedInst.imm <= (others => '0');
          when cOpFence =>                       --eOpFence =>
            decodedInst.imm <= (others => '0');  -- not implemented
          when cOpImmedi =>                      --eOpImmedi =>
            decodedInst.imm <= std_logic_vector(resize(signed(insti1(31 downto 20)), cXLEN));
          when cOpAuIpc =>                       --eOpAuIpc =>
            decodedInst.imm(31 downto 12) <= insti1(31 downto 12);
            decodedInst.imm(11 downto 0)  <= (others => '0');
          when cOpLui =>                         --eOpLui =>
            decodedInst.imm(31 downto 12) <= insti1(31 downto 12);
            decodedInst.imm(11 downto 0)  <= (others => '0');
          when cOpBranch =>                      --eOpBranch =>
            decodedInst.imm <= std_logic_vector(resize(signed(insti1(31) & insti1(7) & insti1(30 downto 25)
                                                              & insti1(11 downto 8) & '0'), cXLEN));
          when cOpJalR =>                        --eOpJalr =>
            decodedInst.imm <= std_logic_vector(resize(signed(insti1(31 downto 20)), cXLEN));
          when cOpJal =>                         -- eOpJal =>
            decodedInst.imm <= std_logic_vector(resize(signed(insti1(31) & insti1(19 downto 12) & insti1(20)
                                                              & insti1(30 downto 21) & '0'), cXLEN));
          when cOpCtrlSt =>                      --eOpCntrlSt =>
            decodedInst.imm <= (others => '0');  -- not implemented
          when others =>
            decodedInst.imm <= (others => '0');
        end case;

      end if;
    end if;
  end process decodedInstPro;

end architecture rtl;
