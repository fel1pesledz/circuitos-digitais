library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level is
    Port (
        CLK          : in  STD_LOGIC;
        PB1, PB0     : in  STD_LOGIC;  -- Botões
        SW_DEATH     : in  STD_LOGIC;  -- Chave
        sw_answer    : in  STD_LOGIC_VECTOR(4 downto 0); -- Chaves Resposta
        
        -- Saídas Físicas
        HEX5_SEG, HEX4_SEG, HEX3_SEG, HEX2_SEG, HEX0_SEG : out STD_LOGIC_VECTOR(6 downto 0);
        led_warn     : out STD_LOGIC
    );
end top_level;

architecture Behavioral of top_level is

    -- Fios internos para ligar o Cérebro ao Display
    signal core_val_a, core_val_b : STD_LOGIC_VECTOR(3 downto 0);
    signal core_val_op : STD_LOGIC_VECTOR(2 downto 0);
    signal core_score  : STD_LOGIC_VECTOR(3 downto 0);
    signal core_playing_status : STD_LOGIC;

begin

    -------------------------------------------------------------------
    -- 1. O CÉREBRO (Lógica do Jogo)
    -------------------------------------------------------------------
    u_game_core : entity work.game_core
        Port Map (
            clk        => CLK,
            -- Invertendo botões aqui para entrar como '1' = Ativo no core
            btn_start  => not PB1, 
            btn_submit => not PB0,
            sw_death   => SW_DEATH,
            user_answ  => sw_answer,
            
            -- Saídas de dados
            out_val_a  => core_val_a,
            out_val_b  => core_val_b,
            out_val_op => core_val_op,
            out_score  => core_score,
            
            -- Saídas de estado
            is_playing => core_playing_status,
            led_warn   => led_warn
        );

    -------------------------------------------------------------------
    -- 2. O ROSTO (Gerenciador de Displays)
    -------------------------------------------------------------------
    u_display_manager : entity work.display_manager
        Port Map (
            val_a      => core_val_a,
            val_b      => core_val_b,
            val_op     => core_val_op,
            val_score  => core_score,
            
            is_playing => core_playing_status, -- Controla se apaga ou não
            
            HEX5 => HEX5_SEG,
            HEX4 => HEX4_SEG,
            HEX3 => HEX3_SEG,
            HEX2 => HEX2_SEG,
            HEX0 => HEX0_SEG
        );

end Behavioral;