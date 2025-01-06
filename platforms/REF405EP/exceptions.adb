-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ exceptions.adb                                                                                            --
-- __DSC__                                                                                                           --
-- __HSH__ e69de29bb2d1d6434b8b29ae775ad8c2e48c5391                                                                  --
-- __HDE__                                                                                                           --
-----------------------------------------------------------------------------------------------------------------------
-- Copyright (C) 2020-2025 Gabriele Galeotti                                                                         --
--                                                                                                                   --
-- SweetAda web page: http://sweetada.org                                                                            --
-- contact address: gabriele.galeotti@sweetada.org                                                                   --
-- This work is licensed under the terms of the MIT License.                                                         --
-- Please consult the LICENSE.txt file located in the top-level directory.                                           --
-----------------------------------------------------------------------------------------------------------------------

with System.Machine_Code;
with Definitions;
with Abort_Library;
with BSP;
with Console;

package body Exceptions
   is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Local declarations                           --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   use System.Machine_Code;
   use Definitions;

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Package subprograms                          --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   ----------------------------------------------------------------------------
   -- Exception_Fatal
   ----------------------------------------------------------------------------
   procedure Exception_Fatal (Identifier : in Unsigned_32)
      is
   begin
      Abort_Library.System_Abort;
   end Exception_Fatal;

   ----------------------------------------------------------------------------
   -- Exception_Process
   ----------------------------------------------------------------------------
   procedure Exception_Process (Identifier : in Unsigned_32)
      is
   begin
      if Identifier = PIT_IRQ_ID then
         BSP.Tick_Count := @ + 1;
      end if;
      -- if Identifier = FIT_IRQ_ID then
      --    Console.Print ("FIT interrupt", NL => True);
      -- end if;
      -- if Identifier = UART0_IRQ_ID then
      --    Console.Print ("UART0 external interrupt", NL => True);
      -- end if;
      -- if Identifier = GPT0_IRQ_ID then
      --    Console.Print ("GPT0 external interrupt", NL => True);
      -- end if;
      if Identifier = 16#0000_0700# then
         Console.Print ("BREAKPOINT", NL => True);
      end if;
      -- if Identifier >= 10 and then Identifier <= 19 then
      --    Console.Print (Identifier, Prefix => "Exception : ", NL => True);
      -- end if;
   end Exception_Process;

   ----------------------------------------------------------------------------
   -- Init
   ----------------------------------------------------------------------------
   procedure Init
      is
   begin
      Asm (
           Template => ""                                        & CRLF &
                       "        lis     r0,exception_stack@ha  " & CRLF &
                       "        ori     r0,r0,exception_stack@l" & CRLF &
                       "        mtsprg0 r0                     " & CRLF &
                       "",
           Outputs  => No_Output_Operands,
           Inputs   => No_Input_Operands,
           Clobber  => "r0",
           Volatile => True
          );
   end Init;

end Exceptions;
