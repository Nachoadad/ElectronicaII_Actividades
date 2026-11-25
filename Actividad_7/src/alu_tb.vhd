library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.finish;


entity alu_tb is
end entity alu_tb;


architecture tb of alu_tb is
    constant N       : natural := 32;
    constant periodo : time := 10 ns;


    signal a      : std_logic_vector(N-1 downto 0) := (others => '0');
    signal b      : std_logic_vector(N-1 downto 0) := (others => '0');
    signal sel_fn : std_logic_vector(3 downto 0)  := (others => '0');
    signal z      : std_logic;
    signal y      : std_logic_vector(N-1 downto 0);


begin


    dut: entity work.alu
        generic map (
            N => N
        )
        port map (
            a      => a,
            b      => b,
            sel_fn => sel_fn,
            z      => z,
            y      => y
        );


    prueba: process
    begin
        a <= x"00000005";
        b <= x"00000003";
        sel_fn <= "0000";
        wait for periodo;
        assert (y = x"00000008" and z = '0') report "Error en Suma (0000)" severity error;


        a <= x"0000000A";
        b <= x"0000000A";
        sel_fn <= "0001";
        wait for periodo;
        assert (y = x"00000000" and z = '1') report "Error en Resta / Flag Z (0001)" severity error;


        a <= x"00000003";
        b <= x"00000002";
        sel_fn <= "0010";
        wait for periodo;
        assert (y = x"0000000C") report "Error en Shift Left (0010)" severity error;


        a <= x"FFFFFFFE";
        b <= x"00000005";
        sel_fn <= "0100";
        wait for periodo;
        assert (y = x"00000001") report "Error en A < B Signed (0100)" severity error;


        a <= x"FFFFFFFE";
        b <= x"00000005";
        sel_fn <= "0110";
        wait for periodo;
        assert (y = x"00000000") report "Error en A < B Unsigned (0110)" severity error;


        a <= x"000000FF";
        b <= x"00000055";
        sel_fn <= "1000";
        wait for periodo;
        assert (y = x"000000AA") report "Error en XOR (1000)" severity error;


        a <= x"80000000";
        b <= x"00000001";
        sel_fn <= "1010";
        wait for periodo;
        assert (y = x"40000000") report "Error en Shift Right Logico (1010)" severity error;


        a <= x"80000000";
        b <= x"00000001";
        sel_fn <= "1011";
        wait for periodo;
        assert (y = x"C0000000") report "Error en Shift Right Aritmetico (1011)" severity error;


        a <= x"0000000F";
        b <= x"000000F0";
        sel_fn <= "1100";
        wait for periodo;
        assert (y = x"000000FF") report "Error en OR (1100)" severity error;


        a <= x"000000FF";
        b <= x"0000000F";
        sel_fn <= "1110";
        wait for periodo;
        assert (y = x"0000000F") report "Error en AND (1110)" severity error;


        report "SIMULACION FINALIZADA CON EXITO: TODAS LAS PRUEBAS PASARON";
        finish;
    end process;


end architecture tb;
