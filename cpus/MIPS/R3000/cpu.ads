-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ cpu.ads                                                                                                   --
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

with System;
with MIPS;
with R3000;

package CPU
   with Preelaborate => True
   is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                               Public part                              --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   use System;

   ----------------------------------------------------------------------------
   -- CPU helper subprograms
   ----------------------------------------------------------------------------

   procedure NOP
      renames MIPS.NOP;

   procedure Asm_Call
      (Target_Address : in Address)
      renames MIPS.Asm_Call;

   ----------------------------------------------------------------------------
   -- Exceptions and interrupts
   ----------------------------------------------------------------------------

   subtype Intcontext_Type is R3000.Intcontext_Type;
   subtype Irq_Id_Type     is R3000.Irq_Id_Type;

   procedure Intcontext_Get
      (Intcontext : out Intcontext_Type)
      renames R3000.Intcontext_Get;
   procedure Intcontext_Set
      (Intcontext : in Intcontext_Type)
      renames R3000.Intcontext_Set;

   procedure Irq_Enable
      renames R3000.Irq_Enable;
   procedure Irq_Disable
      renames R3000.Irq_Disable;

end CPU;
