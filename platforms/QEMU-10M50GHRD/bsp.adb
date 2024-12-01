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
with Definitions;
with Bits;
with Core;
with MMIO;
with CPU;
with NiosII;
with GHRD;
with Exceptions;
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

   use Interfaces;
   use Bits;

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Package subprograms                          --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   ----------------------------------------------------------------------------
   -- Console wrappers
   ----------------------------------------------------------------------------

   procedure Console_Putchar
      (C : in Character)
      is
   begin
      UART16x50.TX (UART_Descriptor, To_U8 (C));
   end Console_Putchar;

   procedure Console_Getchar
      (C : out Character)
      is
      Data : Unsigned_8;
   begin
      UART16x50.RX (UART_Descriptor, Data);
      C := To_Ch (Data);
   end Console_Getchar;

   ----------------------------------------------------------------------------
   -- Setup
   ----------------------------------------------------------------------------
   procedure Setup
      is
      use Definitions;
      use GHRD;
   begin
      -- UART -----------------------------------------------------------------
      UART_Descriptor := (
         Uart_Model    => UART16x50.UART16450,
         Base_Address  => System'To_Address (UART_BASEADDRESS),
         Scale_Address => 2,
         Baud_Clock    => CLK_UART1M8,
         Read_8        => MMIO.Read'Access,
         Write_8       => MMIO.Write'Access,
         Data_Queue    => ([others => 0], 0, 0, 0),
         others        => <>
         );
      UART16x50.Init (UART_Descriptor);
      -- Console --------------------------------------------------------------
      Console.Console_Descriptor := (
         Write => Console_Putchar'Access,
         Read  => Console_Getchar'Access
         );
      Console.Print (ANSI_CLS & ANSI_CUPHOME & VT100_LINEWRAP);
      -------------------------------------------------------------------------
      Console.Print ("Altera 10M50GHRD (QEMU emulator)", NL => True);
      Console.Print (NiosII.cpuid_Read, Prefix => "CPUID: ", NL => True);
      -------------------------------------------------------------------------
      if Core.Debug_Flag then
         Console.Print ("Debug_Flag: ENABLED", NL => True);
      end if;
      -------------------------------------------------------------------------
      Exceptions.Init;
      -------------------------------------------------------------------------
      Tclk_Init;
      NiosII.ienable_Write (Bitmap_32'(
         NiosII.IRQ0 => True, -- enable timer irq
         others      => False
         ));
      CPU.Irq_Enable;
      -------------------------------------------------------------------------
   end Setup;

end BSP;
