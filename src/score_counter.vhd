library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity score_counter is
    Port (
        clk          : in  STD_LOGIC;
        rst          : in  STD_LOGIC; -- Reset quando aperta PB1 para reiniciar
        correct      : in  STD_LOGIC;
        score        : out unsigned(3 downto 0)
    );
end score_counter;

architecture Behavioral of score_counter is
    signal score_reg : unsigned(3 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                score_reg <= (others => '0');
            elsif correct = '1' then
                -- Conta livremente. Se passar de 15 (F), volta para 0.
                score_reg <= score_reg + 1;
            end if;
        end if;
    end process;

    score <= score_reg;
end Behavioral;