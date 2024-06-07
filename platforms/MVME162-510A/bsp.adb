-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ bsp.adb                                                                                                   --
-- __DSC__                                                                                                           --
-- __HSH__ e69de29bb2d1d6434b8b29ae775ad8c2e48c5391                                                                  --
-- __HDE__                                                                                                           --
-----------------------------------------------------------------------------------------------------------------------
-- Copyright (C) 2020-2024 Gabriele Galeotti                                                                         --
--                                                                                                                   --
-- SweetAda web page: http://sweetada.org                                                                            --
-- contact address: gabriele.galeotti@sweetada.org                                                                   --
-- This work is licensed under the terms of the MIT License.                                                         --
-- Please consult the LICENSE.txt file located in the top-level directory.                                           --
-----------------------------------------------------------------------------------------------------------------------

with System;
with System.Storage_Elements;
with Definitions;
with Bits;
with MMIO;
with MVME162FX;
with Console;

package body BSP
   is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Local declarations                           --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   use System;
   use System.Storage_Elements;
   use Interfaces;
   use Definitions;
   use Bits;
   use MVME162FX;

   procedure SCC_Write_8
      (Port  : in Address;
       Value : in Unsigned_8);

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Package subprograms                          --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   ----------------------------------------------------------------------------
   -- SCC_Write_8
   ----------------------------------------------------------------------------
   -- MVME162FX MC2 revision 1 bug
   ----------------------------------------------------------------------------
   procedure SCC_Write_8
      (Port  : in Address;
       Value : in Unsigned_8)
      is
   begin
      MMIO.Write_U8 (Port, 16#08#);
      MMIO.Write_U8 (Port, Value);
   end SCC_Write_8;

   ----------------------------------------------------------------------------
   -- Console wrappers
   ----------------------------------------------------------------------------

   procedure Console_Putchar
      (C : in Character)
      is
   begin
      Z8530.TX (SCC_Descriptor, Z8530.CHANNELA, To_U8 (C));
   end Console_Putchar;

   procedure Console_Getchar
      (C : out Character)
      is
   begin
      C := Character'Val (0);
   end Console_Getchar;

   ----------------------------------------------------------------------------
   -- Setup
   ----------------------------------------------------------------------------
   procedure Setup
      is
   begin
      -- SCC ------------------------------------------------------------------
      SCC_Descriptor.Base_Address   := To_Address (SCC_BASEADDRESS);
      SCC_Descriptor.AB_Address_Bit := 2;                            -- address bit2 --> A//B channel selector
      SCC_Descriptor.CD_Address_Bit := 1;                            -- address bit1 --> D//C data/command selector
      SCC_Descriptor.Baud_Clock     := 10_000_000; -- __FIX__
      SCC_Descriptor.Read_8         := MMIO.Read'Access;
      SCC_Descriptor.Write_8        := SCC_Write_8'Access;
      Z8530.Init (SCC_Descriptor, Z8530.CHANNELA);
      Z8530.Init (SCC_Descriptor, Z8530.CHANNELB);
      -- Console --------------------------------------------------------------
      Console.Console_Descriptor := (
         Write => Console_Putchar'Access,
         Read  => Console_Getchar'Access)
         ;
      Console.Print (ANSI_CLS & ANSI_CUPHOME & VT100_LINEWRAP);
      -------------------------------------------------------------------------
      Console.Print ("MVME162-510A", NL => True);
      Console.Print (Prefix => "MC2 ID      : ", Value => MMIO.Read_U8 (MC2.ID'Address), NL => True);
      Console.Print (Prefix => "MC2 Revision: ", Value => MMIO.Read_U8 (MC2.Revision'Address), NL => True);
      -------------------------------------------------------------------------
   end Setup;

end BSP;
