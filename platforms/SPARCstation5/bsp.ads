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
with Bits;
with Z8530;
with Am7990;

package BSP
   is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                               Public part                              --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   Nwindows : aliased Bits.CPU_Integer
      with Import        => True,
           Convention    => Asm,
           External_Name => "nwindows";

   Tick_Count : aliased Interfaces.Unsigned_32 := 0
      with Atomic        => True,
           Export        => True,
           Convention    => Asm,
           External_Name => "tick_count";

   QEMU : Boolean := False;

   SCC_Descriptor : aliased Z8530.Descriptor_Type := Z8530.DESCRIPTOR_INVALID;

   Am7990_Descriptor : aliased Am7990.Descriptor_Type := Am7990.DESCRIPTOR_INVALID;

   procedure Console_Putchar
      (C : in Character);
   procedure Console_Getchar
      (C : out Character);
   procedure Setup;

end BSP;
