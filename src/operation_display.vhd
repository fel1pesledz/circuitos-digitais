library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity operation_display is
    Port (
        operation : in  STD_LOGIC_VECTOR(2 downto 0);
        L1        : out STD_LOGIC_VECTOR(6 downto 0);  -- Letra 1 (Esquerda)
        L2        : out STD_LOGIC_VECTOR(6 downto 0)   -- Letra 2 (Direita)
    );
end operation_display;

architecture Behavioral of operation_display is

    -- Função para decodificar caracteres para 7-segmentos
    -- Segmentos: g f e d c b a
    function seg(c : character) return STD_LOGIC_VECTOR is
    begin
        case c is
            -- S: a,c,d,f,g acesos -> "0010010"
            when 'S' => return "0010010"; 
            -- O (Zero): a,b,c,d,e,f acesos -> "1000000"
            when 'O' => return "1000000"; 
            -- U (Maiúsculo): b,c,d,e,f acesos -> "1000001"
            when 'U' => return "1000001"; 
            -- A: a,b,c,e,f,g acesos -> "0001000"
            when 'A' => return "0001000"; 
            -- E: a,d,e,f,g acesos -> "0000110"
            when 'E' => return "0000110"; 
            -- Traço ou Apagado (default)
            when others => return "1111111"; 
        end case;
    end function;

begin
    process(operation)
    begin
        case operation is
            when "000" =>  -- SOMA -> 'S O'
                L1 <= seg('S'); L2 <= seg('O');
            when "001" =>  -- SUBTRAÇÃO -> 'S U'
                L1 <= seg('S'); L2 <= seg('U');
            when "010" =>  -- MAIOR -> 'A O'
                L1 <= seg('A'); L2 <= seg('O');
            when "011" =>  -- MENOR -> 'E O'
                L1 <= seg('E'); L2 <= seg('O');
            when "100" =>  -- XOR -> 'O O'
                L1 <= seg('O'); L2 <= seg('O');
            when others => -- Erro/Default
                L1 <= seg('-'); L2 <= seg('-');
        end case;
    end process;
end Behavioral;
