library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity semaforo_tb is
end semaforo_tb;

architecture sim of semaforo_tb is

    signal clk     : STD_LOGIC := '0';
    signal reset   : STD_LOGIC := '0';
    signal E_NS    : STD_LOGIC := '0';
    signal E_EO    : STD_LOGIC := '0';
    signal S_NS    : STD_LOGIC := '0';
    signal S_EO    : STD_LOGIC := '0';
    
    signal L_NS    : STD_LOGIC_VECTOR(2 downto 0);
    signal L_EO    : STD_LOGIC_VECTOR(2 downto 0);

    constant CLK_PERIOD : time := 83.3 ns;

begin

    uut: entity work.semaforo_top
        port map (
            clk     => clk,
            reset   => reset,
            E_NS    => E_NS,
            E_EO    => E_EO,
            S_NS    => S_NS,
            S_EO    => S_EO,
            L_NS    => L_NS,
            L_EO    => L_EO
        );

    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    stim_proc: process
    begin
        reset <= '0';
        E_NS <= '0';
        E_EO <= '0';
        S_NS <= '0';
        S_EO <= '0';
        wait for 300 ns;
        
        reset <= '1';
        wait for 55 sec;

        S_EO <= '1';
        wait for 2 sec;
        S_EO <= '0';
        wait for 105 sec;

        E_NS <= '1';
        wait for 20 sec;
        E_NS <= '0';
        
        wait for 60 sec;
        wait;
    end process;

end sim;