-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ sparc.adb                                                                                                 --
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
with Ada.Unchecked_Conversion;
with Interfaces;
with Definitions;

package body SPARC
   is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Local declarations                           --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   use System.Machine_Code;
   use Interfaces;

   CRLF : String renames Definitions.CRLF;

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Package subprograms                          --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   ----------------------------------------------------------------------------
   -- NOP
   ----------------------------------------------------------------------------
   procedure NOP
      is
   begin
      Asm (
           Template => ""            & CRLF &
                       "        nop" & CRLF &
                       "",
           Outputs  => No_Output_Operands,
           Inputs   => No_Input_Operands,
           Clobber  => "",
           Volatile => True
          );
   end NOP;

   ----------------------------------------------------------------------------
   -- Asm_Call
   ----------------------------------------------------------------------------
   procedure Asm_Call
      (Target_Address : in Address)
      is
   begin
      Asm (
           Template => ""                   & CRLF &
                       "        call    %0" & CRLF &
                       "        nop       " & CRLF &
                       "",
           Outputs  => No_Output_Operands,
           Inputs   => Address'Asm_Input ("r", Target_Address),
           Clobber  => "",
           Volatile => True
          );
   end Asm_Call;

   ----------------------------------------------------------------------------
   -- PSR_Read/Write
   ----------------------------------------------------------------------------

   function PSR_Read
      return PSR_Type
      is
      PSR : PSR_Type;
   begin
      Asm (
           Template => ""                         & CRLF &
                       "        mov     %%psr,%0" & CRLF &
                       "",
           Outputs  => PSR_Type'Asm_Output ("=r", PSR),
           Inputs   => No_Input_Operands,
           Clobber  => "",
           Volatile => True
          );
      return PSR;
   end PSR_Read;

   procedure PSR_Write
      (PSR : in PSR_Type)
      is
   begin
      Asm (
           Template => ""                         & CRLF &
                       "        mov     %0,%%psr" & CRLF &
                       "        nop ; nop ; nop " & CRLF &
                       "",
           Outputs  => No_Output_Operands,
           Inputs   => PSR_Type'Asm_Input ("r", PSR),
           Clobber  => "",
           Volatile => True
          );
   end PSR_Write;

   ----------------------------------------------------------------------------
   -- Traps
   ----------------------------------------------------------------------------

   procedure TBR_Set
      (TBR_Address : in Address)
      is
      function To_U32 is new Ada.Unchecked_Conversion (Address, Unsigned_32);
   begin
      Asm (
           Template => ""                           & CRLF &
                       "        wr      %0,0,%%tbr" & CRLF &
                       "",
           Outputs  => No_Output_Operands,
           Inputs   => Unsigned_32'Asm_Input ("r", To_U32 (TBR_Address) and 16#FFFF_FFF0#),
           Clobber  => "",
           Volatile => True
          );
   end TBR_Set;

   procedure Traps_Enable
      (Enable : in Boolean)
      is
      PSR : PSR_Type;
   begin
      PSR := PSR_Read;
      PSR.ET := Enable;
      PSR_Write (PSR);
   end Traps_Enable;

   ----------------------------------------------------------------------------
   -- Intcontext_Get
   ----------------------------------------------------------------------------
   procedure Intcontext_Get
      (Intcontext : out Intcontext_Type)
      is
   begin
      Intcontext := 0; -- __TBD__
   end Intcontext_Get;

   ----------------------------------------------------------------------------
   -- Intcontext_Set
   ----------------------------------------------------------------------------
   procedure Intcontext_Set
      (Intcontext : in Intcontext_Type)
      is
   begin
      null; -- __TBD__
   end Intcontext_Set;

   ----------------------------------------------------------------------------
   -- Irq_Enable
   ----------------------------------------------------------------------------
   procedure Irq_Enable
      is
      PSR_R : Unsigned_32;
   begin
      Asm (
           Template => ""                           & CRLF &
                       "        rd      %%psr,%0  " & CRLF &
                       "        nop ; nop ; nop   " & CRLF &
                       "        andn    %0,%1,%0  " & CRLF &
                       "        wr      %0,0,%%psr" & CRLF &
                       "        nop ; nop ; nop   " & CRLF &
                       "",
           Outputs  => Unsigned_32'Asm_Output ("=r", PSR_R),
           Inputs   => Unsigned_32'Asm_Input ("i", PSR_PIL),
           Clobber  => "memory",
           Volatile => True
          );
   end Irq_Enable;

   ----------------------------------------------------------------------------
   -- Irq_Disable
   ----------------------------------------------------------------------------
   procedure Irq_Disable
      is
      PSR_R : Unsigned_32;
   begin
      Asm (
           Template => ""                           & CRLF &
                       "        rd      %%psr,%0  " & CRLF &
                       "        nop ; nop ; nop   " & CRLF &
                       "        or      %0,%1,%0  " & CRLF &
                       "        wr      %0,0,%%psr" & CRLF &
                       "        nop ; nop ; nop   " & CRLF &
                       "",
           Outputs  => Unsigned_32'Asm_Output ("=r", PSR_R),
           Inputs   => Unsigned_32'Asm_Input ("i", PSR_PIL),
           Clobber  => "memory",
           Volatile => True
          );
   end Irq_Disable;

end SPARC;
