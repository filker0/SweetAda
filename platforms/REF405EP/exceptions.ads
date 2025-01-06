-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ exceptions.ads                                                                                            --
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

package Exceptions
   is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                               Public part                              --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   use Interfaces;

   UART0_IRQ_ID : constant := 16#0500#;
   GPT0_IRQ_ID  : constant := 16#0501#;
   PIT_IRQ_ID   : constant := 16#1000#;
   FIT_IRQ_ID   : constant := 16#1010#;

   procedure Exception_Fatal (Identifier : in Unsigned_32)
      with Export        => True,
           Convention    => Asm,
           External_Name => "exception_fatal";

   procedure Exception_Process (Identifier : in Unsigned_32)
      with Export        => True,
           Convention    => Asm,
           External_Name => "exception_process";

   procedure Init;

end Exceptions;
