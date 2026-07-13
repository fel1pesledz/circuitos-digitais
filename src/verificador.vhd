library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity verificador is
    Port (
        clk         : in  STD_LOGIC;
        rst         : in  STD_LOGIC;
        rand_a      : in  STD_LOGIC_VECTOR(3 downto 0);
        rand_b      : in  STD_LOGIC_VECTOR(3 downto 0);
        operation   : in  STD_LOGIC_VECTOR(2 downto 0);
        user_answer : in  STD_LOGIC_VECTOR(4 downto 0);
        submit_pulse: in  STD_LOGIC;
        correct     : out STD_LOGIC;
        wrong       : out STD_LOGIC
    );
end verificador;

architecture Behavioral of verificador is
    signal expected_result : unsigned(4 downto 0);
    signal a_un, b_un : unsigned(3 downto 0);
begin
    a_un <= unsigned(rand_a);
    b_un <= unsigned(rand_b);

    -- 1. CALCULA O RESULTADO ESPERADO
    process(rand_a, rand_b, operation, a_un, b_un)
    begin
        case operation is
            when "000" => -- SOMA
                expected_result <= resize(a_un + b_un, 5);
                
            when "001" => -- SUBTRACAO
                expected_result <= resize(a_un - b_un, 5);
                
            when "010" => -- MAIOR
                -- Se A > B, o bit 0 esperado é '1'. Se não, é '0'.
                if a_un > b_un then
                    expected_result <= to_unsigned(1, 5); -- ...00001
                else
                    expected_result <= to_unsigned(0, 5); -- ...00000
                end if;
                
            when "100" => -- XOR
                expected_result <= resize(unsigned(rand_a xor rand_b), 5);
                
            when others => 
                expected_result <= (others => '0');
        end case;
    end process;

    -- 2. COMPARA A RESPOSTA DO USUÁRIO
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                correct <= '0';
                wrong   <= '0';
            elsif submit_pulse = '1' then
                
                -- LÓGICA DIFERENCIADA:
                if operation = "010" then
                    -- Se for MAIOR, olha APENAS o bit 0 (SW0)
                    -- Ignora se o usuário esqueceu SW1-SW4 levantados
                    if user_answer(0) = expected_result(0) then
                        correct <= '1';
                        wrong   <= '0';
                    else
                        correct <= '0';
                        wrong   <= '1';
                    end if;
                else
                    -- Se for SOMA, SUB ou XOR, tem que acertar o número exato
                    if unsigned(user_answer) = expected_result then
                        correct <= '1';
                        wrong   <= '0';
                    else
                        correct <= '0';
                        wrong   <= '1';
                    end if;
                end if;
                
            else
                correct <= '0';
                wrong   <= '0';
            end if;
        end if;
    end process;

end Behavioral;
