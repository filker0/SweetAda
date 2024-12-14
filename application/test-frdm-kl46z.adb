
with Interfaces;
with CPU;
with KL46Z;
with Console;

package body Application
   is

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Local declarations                           --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   use Interfaces;
   use KL46Z;

   --========================================================================--
   --                                                                        --
   --                                                                        --
   --                           Package subprograms                          --
   --                                                                        --
   --                                                                        --
   --========================================================================--

   ----------------------------------------------------------------------------
   -- Run
   ----------------------------------------------------------------------------
   procedure Run
      is
   begin
      -------------------------------------------------------------------------
      -- blink on-board GREEN LED
      declare
         Delay_Count : constant := 10_000_000;
      begin
         -- LED1 (GREEN)
         PORTD_MUXCTRL.PCR (5).MUX := MUX_ALT1_GPIO;
         GPIOD.PDDR (5) := True;
         while True loop
            GPIOD.PTOR (5) := True;
            Console.Print (".");
            for Delay_Loop_Count in 1 .. Delay_Count loop CPU.NOP; end loop;
         end loop;
      end;
      -------------------------------------------------------------------------
      loop null; end loop;
      -------------------------------------------------------------------------
   end Run;

end Application;
