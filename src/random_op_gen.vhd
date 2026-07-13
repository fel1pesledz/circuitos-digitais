library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity random_op_gen is
    Port (
        clk_50MHz : in  STD_LOGIC;
        update    : in  STD_LOGIC;
        rst       : in  STD_LOGIC;

        rand_a    : out STD_LOGIC_VECTOR(3 downto 0);
        rand_b    : out STD_LOGIC_VECTOR(3 downto 0);
        operation : out STD_LOGIC_VECTOR(2 downto 0)
    );
end random_op_gen;

architecture Behavioral of random_op_gen is
    signal lfsr_a   : unsigned(7 downto 0) := "10100101";
    signal lfsr_b   : unsigned(7 downto 0) := "11001011";
    signal lfsr_op  : unsigned(3 downto 0) := "0101";

    signal current_a   : unsigned(3 downto 0) := (others => '0');
    signal current_b   : unsigned(3 downto 0) := (others => '0');
    signal current_op  : unsigned(2 downto 0) := (others => '0');

begin
    -- LFSR rodando livre
    process(clk_50MHz)
    begin
        if rising_edge(clk_50MHz) then
            if rst = '1' then
                lfsr_a <= "10100101";
                lfsr_b <= "11001011";
                lfsr_op <= "0101";
            else
                lfsr_a <= lfsr_a(6 downto 0) & (lfsr_a(7) xor lfsr_a(3) xor lfsr_a(2) xor lfsr_a(1));
                lfsr_b <= lfsr_b(6 downto 0) & (lfsr_b(7) xor lfsr_b(5) xor lfsr_b(4) xor lfsr_b(3));
                lfsr_op <= lfsr_op(2 downto 0) & (lfsr_op(3) xor lfsr_op(1));
            end if;
        end if;
    end process;

    -- Captura e Mapeamento
    process(clk_50MHz)
        variable raw_op : unsigned(2 downto 0);
    begin
        if rising_edge(clk_50MHz) then
            if rst = '1' then
                current_op <= (others => '0');
                current_a <= (others => '0');
                current_b <= (others => '0');
            elsif update = '1' then
                raw_op := lfsr_op(2 downto 0);

                -- MAPEAMENTO DAS OPERAÇÕES
                case raw_op is
                    when "000" => current_op <= "000"; -- Soma
                    when "001" => current_op <= "001"; -- Sub
                    when "010" => current_op <= "010"; -- Maior

                    -- REMOVE MENOR: Se cair 011 (Menor), vira 010 (Maior)
                    when "011" => current_op <= "010";

                    when "100" => current_op <= "100"; -- XOR

                    -- Trata valores inválidos (5, 6, 7)
                    when "101" => current_op <= "000";
                    when "110" => current_op <= "001";
                    when "111" => current_op <= "010";
                    when others => current_op <= "000";
                end case;

                -- Evita subtração negativa
                if (raw_op = "001" or raw_op = "110") and (lfsr_a(3 downto 0) < lfsr_b(3 downto 0)) then
                     current_a <= lfsr_b(3 downto 0);
                     current_b <= lfsr_a(3 downto 0);
                else
                     current_a <= lfsr_a(3 downto 0);
                     current_b <= lfsr_b(3 downto 0);
                end if;

            end if;
        end if;
    end process;

    rand_a    <= std_logic_vector(current_a);
    rand_b    <= std_logic_vector(current_b);
    operation <= std_logic_vector(current_op);
end Behavioral;
