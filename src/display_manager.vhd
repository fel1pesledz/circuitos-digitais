library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity display_manager is
    Port (
        -- Entradas de Dados
        val_a     : in  STD_LOGIC_VECTOR(3 downto 0);
        val_b     : in  STD_LOGIC_VECTOR(3 downto 0);
        val_score : in  STD_LOGIC_VECTOR(3 downto 0);
        val_op    : in  STD_LOGIC_VECTOR(2 downto 0);
        
        -- Controle de Estado (1 = Jogo Rodando / 0 = Espera ou Fim)
        is_playing : in STD_LOGIC; 
        
        -- Saídas Físicas para os Displays
        HEX5      : out STD_LOGIC_VECTOR(6 downto 0); -- A
        HEX4      : out STD_LOGIC_VECTOR(6 downto 0); -- B
        HEX3      : out STD_LOGIC_VECTOR(6 downto 0); -- Op L1
        HEX2      : out STD_LOGIC_VECTOR(6 downto 0); -- Op L2
        HEX0      : out STD_LOGIC_VECTOR(6 downto 0)  -- Score
    );
end display_manager;

architecture Behavioral of display_manager is

    -- Sinais internos decodificados
    signal seg_a, seg_b, seg_score, seg_op1, seg_op2 : STD_LOGIC_VECTOR(6 downto 0);

begin

    -- 1. Instância dos Conversores (Internos)
    u_hex_a : entity work.hex_to_7seg
        Port Map (hex_in => val_a, seg_out => seg_a);

    u_hex_b : entity work.hex_to_7seg
        Port Map (hex_in => val_b, seg_out => seg_b);

    u_hex_score : entity work.hex_to_7seg
        Port Map (hex_in => val_score, seg_out => seg_score);

    u_op_disp : entity work.operation_display
        Port Map (operation => val_op, L1 => seg_op1, L2 => seg_op2);

    -- 2. Lógica de Controle de Visibilidade (MUX)
    
    -- Se não estiver jogando, apaga A, B e Operação
    HEX5 <= seg_a   when is_playing = '1' else "1111111";
    HEX4 <= seg_b   when is_playing = '1' else "1111111";
    HEX3 <= seg_op1 when is_playing = '1' else "1111111";
    HEX2 <= seg_op2 when is_playing = '1' else "1111111";

    -- Score sempre aparece (No IDLE é 0, no Game Over é o final)
    HEX0 <= seg_score;

end Behavioral;