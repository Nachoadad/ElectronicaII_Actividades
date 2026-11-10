library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity semaforo_top is
    Port (
        clk     : in  STD_LOGIC;
        reset   : in  STD_LOGIC;
        E_NS    : in  STD_LOGIC;
        E_EO    : in  STD_LOGIC;
        S_NS    : in  STD_LOGIC;
        S_EO    : in  STD_LOGIC;
        L_NS    : out STD_LOGIC_VECTOR(2 downto 0);
        L_EO    : out STD_LOGIC_VECTOR(2 downto 0)
    );
end semaforo_top;

architecture arq of semaforo_top is

    constant R : STD_LOGIC_VECTOR(2 downto 0) := "100";
    constant A : STD_LOGIC_VECTOR(2 downto 0) := "010";
    constant V : STD_LOGIC_VECTOR(2 downto 0) := "001";

    type state_type is (RV, RVExt, RA, VR, VRExt, AR);
    signal estado, estado_sig : state_type;

    signal clk_1s       : STD_LOGIC;
    signal counter_1s   : integer range 0 to 6000000 := 0;
    signal Q            : integer range 0 to 120 := 0;
    signal z            : STD_LOGIC;
    signal target_time  : integer;
    
    signal l_ns_int, l_eo_int : STD_LOGIC_VECTOR(2 downto 0);

begin

    process(clk, reset)
    begin
        if reset = '0' then
            counter_1s <= 0;
            clk_1s <= '0';
        elsif rising_edge(clk) then
            if counter_1s = 5999999 then
                counter_1s <= 0;
                clk_1s <= not clk_1s;
            else
                counter_1s <= counter_1s + 1;
            end if;
        end if;
    end process;

    process(clk, reset)
    begin
        if reset = '0' then
            estado <= RV;
            Q <= 0;
        elsif rising_edge(clk) then
            if clk_1s = '1' then
                estado <= estado_sig;
                if estado /= estado_sig then
                    Q <= 0;
                else
                    Q <= Q + 1;
                end if;
            end if;
        end if;
    end process;

    logica_de_estado_siguiente: process (all) is
    begin
        estado_sig <= estado;
        z <= '0';
        target_time <= 50;

        case estado is
            when RV =>
                if Q >= target_time then
                    z <= '1';
                end if;
            when RVExt =>
                if Q >= 100 then
                    z <= '1';
                end if;
            when RA =>
                if Q >= 10 then
                    z <= '1';
                end if;
            when VR =>
                if Q >= target_time then
                    z <= '1';
                end if;
            when VRExt =>
                if Q >= 100 then
                    z <= '1';
                end if;
            when AR =>
                if Q >= 10 then
                    z <= '1';
                end if;
            when others =>
                z <= '0';
        end case;

        if reset = '0' then
            estado_sig <= RV;
        else
            case estado is
                when RV =>
                    if S_EO = '1' then
                        target_time <= 100;
                    else
                        target_time <= 50;
                    end if;

                    if (z or E_NS) and S_EO and not E_EO then
                        estado_sig <= RVExt;
                    elsif (z or E_NS) and not S_EO and not E_EO then
                        estado_sig <= RA;
                    end if;

                when RVExt =>
                    if not z and not E_EO then
                        estado_sig <= RVExt;
                    elsif (z or E_EO) then
                        estado_sig <= RA;
                    end if;

                when RA =>
                    if not z then
                        estado_sig <= RA;
                    elsif z then
                        estado_sig <= VR;
                    end if;

                when VR =>
                    if S_NS = '1' then
                        target_time <= 100;
                    else
                        target_time <= 50;
                    end if;

                    if (z or E_EO) and S_NS and not E_NS then
                        estado_sig <= VRExt;
                    elsif (z or E_EO) and not S_NS and not E_NS then
                        estado_sig <= AR;
                    end if;

                when VRExt =>
                    if not z and not E_NS then
                        estado_sig <= VRExt;
                    elsif (z or E_NS) then
                        estado_sig <= AR;
                    end if;

                when AR =>
                    if not z then
                        estado_sig <= AR;
                    elsif z then
                        estado_sig <= RV;
                    end if;

                when others =>
                    estado_sig <= RV;
            end case;
        end if;
    end process;

    process(estado)
    begin
        case estado is
            when RV | RVExt =>
                l_ns_int <= R;
                l_eo_int <= V;
            when RA =>
                l_ns_int <= R;
                l_eo_int <= A;
            when VR | VRExt =>
                l_ns_int <= V;
                l_eo_int <= R;
            when AR =>
                l_ns_int <= A;
                l_eo_int <= R;
            when others =>
                l_ns_int <= R;
                l_eo_int <= R;
        end case;
    end process;

    L_NS <= l_ns_int;
    L_EO <= l_eo_int;

end arq;