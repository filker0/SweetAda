-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ exceptions.adb                                                                                            --
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

with System.Storage_Elements;
with Ada.Unchecked_Conversion;
with Interfaces;
with Definitions;
with Bits;
with LLutils;
with RISCV;
with MTIME;
with Console;
with BSP;

package body Exceptions
   is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Local declarations                           --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   use System.Storage_Elements;
   use Interfaces;
   use Bits;
   use RISCV;
   use MTIME;

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Package subprograms                          --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   ----------------------------------------------------------------------------
   -- Exception_Process
   ----------------------------------------------------------------------------
   procedure Exception_Process
      is
      mcause : mcause_Type;
   begin
      mcause := mcause_Read;
      if mcause.Interrupt then
         BSP.Tick_Count := @ + 1;
         -- if BSP.Tick_Count mod 1_000 = 0 then
         --    Console.Print ("T", NL => False);
         -- end if;
         BSP.Timer_Value := @ + BSP.Timer_Constant;
         mtimecmp_Write (BSP.Timer_Value);
      else
         declare
            function To_U32 is new Ada.Unchecked_Conversion (mcause_Type, Unsigned_32);
         begin
            Console.Print (To_U32 (mcause), Prefix => "*** EXCEPTION: ", NL => True);
         end;
         loop null; end loop;
      end if;
   end Exception_Process;

   ----------------------------------------------------------------------------
   -- Init
   ----------------------------------------------------------------------------
   procedure Init
      is
      Vectors : aliased Asm_Entry_Point
         with Import        => True,
              External_Name => "vectors";
   begin
      mtvec_Write ((
         MODE => MODE_Direct,
         BASE => mtvec_BASE_Type (LLutils.Select_Address_Bits (
                    Vectors'Address,
                    mtvec_BASE_ADDRESS_LSB,
                    mtvec_BASE_ADDRESS_MSB
                    ))
         ));
   end Init;

end Exceptions;
