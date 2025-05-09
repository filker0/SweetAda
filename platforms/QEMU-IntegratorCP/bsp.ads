-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ bsp.ads                                                                                                   --
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

with Interfaces;
with PL031;
with PL011;
with PL110;

package BSP
   is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                               Public part                              --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   Tick_Count : aliased Interfaces.Unsigned_32 := 0
      with Atomic        => True,
           Export        => True,
           Convention    => Asm,
           External_Name => "tick_count";

   PL031_Descriptor : aliased PL031.Descriptor_Type := PL031.DESCRIPTOR_INVALID;
   PL011_Descriptor : aliased PL011.Descriptor_Type := PL011.DESCRIPTOR_INVALID;
   PL110_Descriptor : aliased PL110.Descriptor_Type := PL110.DESCRIPTOR_INVALID;

   procedure Console_Putchar
      (C : in Character);
   procedure Console_Getchar
      (C : out Character);
   procedure Setup;

end BSP;
