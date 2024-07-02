-----------------------------------------------------------------------------------------------------------------------
--                                                     SweetAda                                                      --
-----------------------------------------------------------------------------------------------------------------------
-- __HDS__                                                                                                           --
-- __FLN__ uart16x50.adb                                                                                             --
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
with Definitions;
with LLutils;

package body UART16x50
   is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Local declarations                           --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   use System.Storage_Elements;
   use LLutils;

   ----------------------------------------------------------------------------
   -- Register types
   ----------------------------------------------------------------------------

   type Register_Type is (RBR, IER, IIR, LCR, MCR, LSR, MSR, SCR, THR, DLL, DLM);
   for Register_Type use
      (
       16#00#, -- RBR
       16#01#, -- IER
       16#02#, -- IIR
       16#03#, -- LCR
       16#04#, -- MCR
       16#05#, -- LSR
       16#06#, -- MSR
       16#07#, -- SCR
       16#10#, -- THR
       16#20#, -- DLL
       16#21#  -- DLM
      );

   -- 8.1 Line Control Register

   type Word_Length_Select_Type is new Bits_2;
   WORD_LENGTH_5 : constant Word_Length_Select_Type := 2#00#;
   WORD_LENGTH_6 : constant Word_Length_Select_Type := 2#01#;
   WORD_LENGTH_7 : constant Word_Length_Select_Type := 2#10#;
   WORD_LENGTH_8 : constant Word_Length_Select_Type := 2#11#;

   type Number_Of_Stop_Bits_Type is new Bits_1;
   STOP_BITS_1 : constant Number_Of_Stop_Bits_Type := 0;
   STOP_BITS_2 : constant Number_Of_Stop_Bits_Type := 1;

   type LCR_Type is record
      WLS  : Word_Length_Select_Type;
      STB  : Number_Of_Stop_Bits_Type;
      PEN  : Boolean;                  -- Parity Enable
      EPS  : Boolean;                  -- Even Parity Select
      SP   : Boolean;                  -- Stick Parity
      SB   : Boolean;                  -- Set Break
      DLAB : Boolean;                  -- Divisor Latch Access Bit
   end record
      with Bit_Order => Low_Order_First,
           Size      => 8;
   for LCR_Type use record
      WLS  at 0 range 0 .. 1;
      STB  at 0 range 2 .. 2;
      PEN  at 0 range 3 .. 3;
      EPS  at 0 range 4 .. 4;
      SP   at 0 range 5 .. 5;
      SB   at 0 range 6 .. 6;
      DLAB at 0 range 7 .. 7;
   end record;

   function To_U8 is new Ada.Unchecked_Conversion (LCR_Type, Unsigned_8);
   function To_LCR is new Ada.Unchecked_Conversion (Unsigned_8, LCR_Type);

   -- 8.4 Line Status Register

   -- THR = Transmit Holding Register
   -- TSR = Transmit Shift Register
   -- THRE: When set it is possible to write another byte into the THR. The
   --       bit is set when the byte is transferred from the THR to the TSR.
   --       The bit is reset when the processor starts loading a byte into
   --       the THR.
   -- TSRE: When set indicates that the TSR is empty. It is reset when a word
   --       is loaded into it from the THR.
   type LSR_Type is record
      DR     : Boolean;      -- Data Ready
      OE     : Boolean;      -- Overrun Error
      PE     : Boolean;      -- Parity Error
      FE     : Boolean;      -- Framing Error
      BI     : Boolean;      -- Break Interrupt
      THRE   : Boolean;      -- Transmitter Holding Register Empty
      TEMT   : Boolean;      -- Transmitter (Shift Register) Empty
      Unused : Bits_1  := 0;
   end record
      with Bit_Order => Low_Order_First,
           Size      => 8;
   for LSR_Type use record
      DR     at 0 range 0 .. 0;
      OE     at 0 range 1 .. 1;
      PE     at 0 range 2 .. 2;
      FE     at 0 range 3 .. 3;
      BI     at 0 range 4 .. 4;
      THRE   at 0 range 5 .. 5;
      TEMT   at 0 range 6 .. 6;
      Unused at 0 range 7 .. 7;
   end record;

   function To_U8 is new Ada.Unchecked_Conversion (LSR_Type, Unsigned_8);
   function To_LSR is new Ada.Unchecked_Conversion (Unsigned_8, LSR_Type);

   -- 8.5 Interrupt Identification Register

   type Interrupt_Priority_Type is new Bits_2;

   IPL0 : constant Interrupt_Priority_Type := 2#00#; -- 4th:     MODEM Status
   IPL1 : constant Interrupt_Priority_Type := 2#01#; -- 3rd:     Transmitter Holding Register Empty
   IPL2 : constant Interrupt_Priority_Type := 2#10#; -- 2nd:     Received Data Available
   IPL3 : constant Interrupt_Priority_Type := 2#11#; -- highest: Receiver Line Status

   type IIR_Type is record
      IPn    : Boolean;                      -- negated: 0 if Interrupt Pending
      IPL    : Interrupt_Priority_Type;
      Unused : Bits_5                  := 0;
   end record
      with Bit_Order => Low_Order_First,
           Size      => 8;
   for IIR_Type use record
      IPn    at 0 range 0 .. 0;
      IPL    at 0 range 1 .. 2;
      Unused at 0 range 3 .. 7;
   end record;

   function To_U8 is new Ada.Unchecked_Conversion (IIR_Type, Unsigned_8);
   function To_IIR is new Ada.Unchecked_Conversion (Unsigned_8, IIR_Type);

   -- 8.6 Interrupt Enable Register

   type IER_Type is record
      RDA    : Boolean;      -- Received Data Available
      THRE   : Boolean;      -- Transmitter Holding Register Empty
      RLS    : Boolean;      -- Receiver Line Status
      MS     : Boolean;      -- MODEM Status
      Unused : Bits_4  := 0;
   end record
      with Bit_Order => Low_Order_First,
           Size      => 8;
   for IER_Type use record
      RDA    at 0 range 0 .. 0;
      THRE   at 0 range 1 .. 1;
      RLS    at 0 range 2 .. 2;
      MS     at 0 range 3 .. 3;
      Unused at 0 range 4 .. 7;
   end record;

   function To_U8 is new Ada.Unchecked_Conversion (IER_Type, Unsigned_8);
   function To_IER is new Ada.Unchecked_Conversion (Unsigned_8, IER_Type);

   -- 8.7 Modem Control Register

   type MCR_Type is record
      DTR      : Boolean;      -- Data Terminal Ready
      RTS      : Boolean;      -- Request To Send
      OUT1     : Boolean;
      OUT2     : Boolean;
      LOOPBACK : Boolean;
      Unused   : Bits_3  := 0;
   end record
      with Bit_Order => Low_Order_First,
           Size      => 8;
   for MCR_Type use record
      DTR      at 0 range 0 .. 0;
      RTS      at 0 range 1 .. 1;
      OUT1     at 0 range 2 .. 2;
      OUT2     at 0 range 3 .. 3;
      LOOPBACK at 0 range 4 .. 4;
      Unused   at 0 range 5 .. 7;
   end record;

   function To_U8 is new Ada.Unchecked_Conversion (MCR_Type, Unsigned_8);
   function To_MCR is new Ada.Unchecked_Conversion (Unsigned_8, MCR_Type);

   -- 8.8 Modem Status Register

   type MSR_Type is record
      DCTS : Boolean; -- Delta CTS
      DDSR : Boolean; -- Delta DSR
      TERI : Boolean; -- Trailing Edge Ring Indicator
      DDCD : Boolean; -- Delta DCD
      CTS  : Boolean; -- CTS
      DSR  : Boolean; -- DSR
      RI   : Boolean; -- RI
      DCD  : Boolean; -- DCD
   end record
      with Bit_Order => Low_Order_First,
           Size      => 8;
   for MSR_Type use record
      DCTS at 0 range 0 .. 0;
      DDSR at 0 range 1 .. 1;
      TERI at 0 range 2 .. 2;
      DDCD at 0 range 3 .. 3;
      CTS  at 0 range 4 .. 4;
      DSR  at 0 range 5 .. 5;
      RI   at 0 range 6 .. 6;
      DCD  at 0 range 7 .. 7;
   end record;

   function To_U8 is new Ada.Unchecked_Conversion (MSR_Type, Unsigned_8);
   function To_MSR is new Ada.Unchecked_Conversion (Unsigned_8, MSR_Type);

   -- Local declarations

   type Storage_Offset_Mod is mod 2**(Storage_Offset'Size - 1)
      with Size => Storage_Offset'Size;

   function To_SO is new Ada.Unchecked_Conversion (Storage_Offset_Mod, Storage_Offset);

   -- Local subprograms

   function Register_Read
      (D : in Descriptor_Type;
       R : in Register_Type)
      return Unsigned_8
      with Inline => True;

   procedure Register_Write
      (D     : in Descriptor_Type;
       R     : in Register_Type;
       Value : in Unsigned_8)
      with Inline => True;

   procedure Input_Poll
      (D       : in     Descriptor_Type;
       Result  :    out Unsigned_8;
       Success :    out Boolean);

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Package subprograms                          --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   ----------------------------------------------------------------------------
   -- Register_Read
   ----------------------------------------------------------------------------
   function Register_Read
      (D : in Descriptor_Type;
       R : in Register_Type)
      return Unsigned_8
      is
   begin
      return D.Read_8
                (Build_Address
                   (D.Base_Address,
                    To_SO (Register_Type'Enum_Rep (R) and 16#0F#),
                    D.Scale_Address));
   end Register_Read;

   ----------------------------------------------------------------------------
   -- Register_Write
   ----------------------------------------------------------------------------
   procedure Register_Write
      (D     : in Descriptor_Type;
       R     : in Register_Type;
       Value : in Unsigned_8)
      is
   begin
      D.Write_8
         (Build_Address
            (D.Base_Address,
             To_SO (Register_Type'Enum_Rep (R) and 16#0F#),
             D.Scale_Address), Value);
   end Register_Write;

   ----------------------------------------------------------------------------
   -- Baud_Rate_Set
   ----------------------------------------------------------------------------
   procedure Baud_Rate_Set
      (D         : in Descriptor_Type;
       Baud_Rate : in Integer)
      is
   begin
      -- __FIX__
      -- a lock should be used here, because, once DLAB is set, no other
      -- threads should interfere with this statement sequence
      Register_Write
         (D, LCR, To_U8 (LCR_Type'
            (WLS  => 0,
             STB  => 0,
             PEN  => False,
             EPS  => False,
             SP   => False,
             SB   => False,
             DLAB => True)));
      Register_Write (D, DLL, Unsigned_8 ((D.Baud_Clock / (Baud_Rate * 16)) mod 2**8));
      Register_Write (D, DLM, Unsigned_8 ((D.Baud_Clock / (Baud_Rate * 16)) / 2**8));
      Register_Write
         (D, LCR, To_U8 (LCR_Type'
            (WLS  => WORD_LENGTH_8,
             STB  => STOP_BITS_1,
             PEN  => False,
             EPS  => False,
             SP   => False,
             SB   => False,
             DLAB => False)));
   end Baud_Rate_Set;

   ----------------------------------------------------------------------------
   -- Input_Poll
   ----------------------------------------------------------------------------
   procedure Input_Poll
      (D       : in     Descriptor_Type;
       Result  :    out Unsigned_8;
       Success :    out Boolean)
      is
   begin
      Success := False;
      if To_LSR (Register_Read (D, LSR)).DR then
         Result := Register_Read (D, RBR);
         Success := True;
      end if;
   end Input_Poll;

   ----------------------------------------------------------------------------
   -- TX
   ----------------------------------------------------------------------------
   procedure TX
      (D    : in out Descriptor_Type;
       Data : in     Unsigned_8)
      is
   begin
      -- wait for transmitter available
      loop
         exit when To_LSR (Register_Read (D, LSR)).TEMT;
      end loop;
      Register_Write (D, THR, Data);
   end TX;

   ----------------------------------------------------------------------------
   -- RX
   ----------------------------------------------------------------------------
   procedure RX
      (D    : in out Descriptor_Type;
       Data :    out Unsigned_8)
      is
   begin
      -- wait for receiver available
      loop
         exit when To_LSR (Register_Read (D, LSR)).DR;
      end loop;
      Data := Register_Read (D, RBR);
   end RX;

   ----------------------------------------------------------------------------
   -- Receive
   ----------------------------------------------------------------------------
   procedure Receive
      (Descriptor_Address : in System.Address)
      is
      D       : Descriptor_Type with
         Address    => Descriptor_Address,
         Import     => True,
         Convention => Ada;
      Data    : Unsigned_8;
      Success : Boolean with Unreferenced => True;
   begin
      -- wait for receiver available
      loop
         exit when To_LSR (Register_Read (D, LSR)).DR;
      end loop;
      Data := Register_Read (D, RBR);
      FIFO.Put (D.Data_Queue'Access, Data, Success);
   end Receive;

   ----------------------------------------------------------------------------
   -- Init
   ----------------------------------------------------------------------------
   procedure Init
      (D : in out Descriptor_Type)
      is
   begin
      Baud_Rate_Set (D, Definitions.Baud_Rate_Type'Enum_Rep (Definitions.BR_9600));
      Register_Write
         (D, IER, To_U8 (IER_Type'
            (RDA    => True,
             THRE   => False,
             RLS    => False,
             MS     => False,
             Unused => 0)));
      Register_Write
         (D, MCR, To_U8 (MCR_Type'
            (DTR      => True,
             RTS      => True,
             OUT1     => False,
             OUT2     => True,
             LOOPBACK => False,
             Unused   => 0)));
   end Init;

end UART16x50;
