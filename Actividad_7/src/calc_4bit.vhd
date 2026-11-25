library ieee;
use ieee.std_logic_1164.all;


entity edge_detector is
    port (
        clk       : in  std_logic;
        d         : in  std_logic;
        pulse_out : out std_logic
    );
end entity edge_detector;


architecture moore of edge_detector is
    type state_type is (WAIT_0, PULSE_1, WAIT_1);
    signal current_state, next_state : state_type := WAIT_0;
begin


    process(clk)
    begin
        if rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;


    process(current_state, d)
    begin
        case current_state is
            when WAIT_0 =>
                if d = '1' then
                    next_state <= PULSE_1;
                else
                    next_state <= WAIT_0;
                end if;


            when PULSE_1 =>
                if d = '1' then
                    next_state <= WAIT_1;
                else
                    next_state <= WAIT_0;
                end if;


            when WAIT_1 =>
                if d = '1' then
                    next_state <= WAIT_1;
                else
                    next_state <= WAIT_0;
                end if;


            when others =>
                next_state <= WAIT_0;
        end case;
    end process;


    pulse_out <= '1' when current_state = PULSE_1 else '0';


end architecture moore;




library ieee;
use ieee.std_logic_1164.all;


entity hex_to_7seg is
    port (
        hex_in  : in  std_logic_vector(3 downto 0);
        seg_out : out std_logic_vector(6 downto 0)
    );
end entity hex_to_7seg;


architecture behave of hex_to_7seg is
begin
    process(hex_in)
    begin
        case hex_in is
            when "0000" => seg_out <= "1000000";
            when "0001" => seg_out <= "1111001";
            when "0010" => seg_out <= "0100100";
            when "0011" => seg_out <= "0110000";
            when "0100" => seg_out <= "0011001";
            when "0101" => seg_out <= "0010010";
            when "0110" => seg_out <= "0000010";
            when "0111" => seg_out <= "1111000";
            when "1000" => seg_out <= "0000000";
            when "1001" => seg_out <= "0010000";
            when "1010" => seg_out <= "0001000";
            when "1011" => seg_out <= "0000011";
            when "1100" => seg_out <= "1000110";
            when "1101" => seg_out <= "0100001";
            when "1110" => seg_out <= "0000110";
            when "1111" => seg_out <= "0001110";
            when others => seg_out <= "1111111";
        end case;
    end process;
end architecture behave;




library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity alu is
    generic (
        constant N : natural := 32
    );
    port (
        a      : in  std_logic_vector(N-1 downto 0);
        b      : in  std_logic_vector(N-1 downto 0);
        sel_fn : in  std_logic_vector(3 downto 0);
        z      : out std_logic;
        y      : out std_logic_vector(N-1 downto 0)
    );
end entity alu;


architecture arch of alu is
    constant Nd : natural := integer(ceil(log2(real(N))));


    signal y_int : std_logic_vector(N-1 downto 0);


    signal cmp_signed   : std_logic_vector(N-1 downto 0);
    signal cmp_unsigned : std_logic_vector(N-1 downto 0);


begin


    cmp_signed   <= (0 => '1', others => '0') when signed(a) < signed(b) else (others => '0');
    cmp_unsigned <= (0 => '1', others => '0') when unsigned(a) < unsigned(b) else (others => '0');


    with sel_fn select
        y_int <= std_logic_vector(unsigned(a) + unsigned(b))                                         when "0000",
                 std_logic_vector(unsigned(a) - unsigned(b))                                         when "0001",
                 std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(b(Nd-1 downto 0)))))  when "0010" | "0011",
                 cmp_signed                                                                          when "0100" | "0101",
                 cmp_unsigned                                                                        when "0110" | "0111",
                 (a xor b)                                                                           when "1000" | "1001",
                 std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(b(Nd-1 downto 0))))) when "1010",
                 std_logic_vector(shift_right(signed(a), to_integer(unsigned(b(Nd-1 downto 0)))))   when "1011",
                 (a or b)                                                                            when "1100" | "1101",
                 (a and b)                                                                           when others;


    y <= y_int;


    z <= '1' when unsigned(y_int) = 0 else '0';


end architecture arch;




library ieee;
use ieee.std_logic_1164.all;


entity calc_4bit is
    port(
        clk     : in  std_logic;
        x       : in  std_logic_vector(7 downto 0);
        display : out std_logic_vector(7 downto 0)
    );
end entity calc_4bit;


architecture struct of calc_4bit is


    signal reg_a, reg_b : std_logic_vector(3 downto 0) := (others => '0');
    signal y_alu        : std_logic_vector(3 downto 0);
    signal z_alu        : std_logic;
    signal pulse_x4     : std_logic;
    signal pulse_x5     : std_logic;
    signal pulse_x6     : std_logic;
    signal disp_digit   : std_logic_vector(3 downto 0);
    signal seg_7        : std_logic_vector(6 downto 0);


begin


    det_x4: entity work.edge_detector
        port map (clk => clk, d => x(4), pulse_out => pulse_x4);


    det_x5: entity work.edge_detector
        port map (clk => clk, d => x(5), pulse_out => pulse_x5);


    det_x6: entity work.edge_detector
        port map (clk => clk, d => x(6), pulse_out => pulse_x6);


    process(clk)
    begin
        if rising_edge(clk) then
            if pulse_x4 = '1' then
                reg_a <= x(3 downto 0);
            elsif pulse_x6 = '1' then
                reg_a <= y_alu;
            end if;
        end if;
    end process;


    process(clk)
    begin
        if rising_edge(clk) then
            if pulse_x5 = '1' then
                reg_b <= x(3 downto 0);
            end if;
        end if;
    end process;


    u_alu: entity work.alu
        generic map (N => 4)
        port map (
            a      => reg_a,
            b      => reg_b,
            sel_fn => x(3 downto 0),
            z      => z_alu,
            y      => y_alu
        );


    disp_digit <= reg_a when x(7) = '0' else reg_b;


    u_dec: entity work.hex_to_7seg
        port map (
            hex_in  => disp_digit,
            seg_out => seg_7
        );


    display(6 downto 0) <= seg_7;
    display(7)          <= not z_alu;


end architecture struct;


