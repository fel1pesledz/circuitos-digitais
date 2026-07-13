library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity game_core is
    Port (
        clk          : in  STD_LOGIC;
        btn_start    : in  STD_LOGIC; -- Botão físico (PB1)
        btn_submit   : in  STD_LOGIC; -- Botão físico (PB0)
        sw_death     : in  STD_LOGIC; -- Chave Morte
        user_answ    : in  STD_LOGIC_VECTOR(4 downto 0); -- Chaves resposta

        -- Saídas de Dados para o Display Manager
        out_val_a    : out STD_LOGIC_VECTOR(3 downto 0);
        out_val_b    : out STD_LOGIC_VECTOR(3 downto 0);
        out_val_op   : out STD_LOGIC_VECTOR(2 downto 0);
        out_score    : out STD_LOGIC_VECTOR(3 downto 0);

        -- Saídas de Controle
        is_playing   : out STD_LOGIC;
        led_warn     : out STD_LOGIC
    );
end game_core;

architecture Behavioral of game_core is

    -- Sinais de Botão (Tratados)
    signal start_pulse, submit_pulse : STD_LOGIC;
    signal submit_pulse_delayed : STD_LOGIC := '0';

    -- Estado
    type state_type is (IDLE, PLAYING, GAME_OVER);
    signal current_state : state_type := IDLE;

    -- Sinais Internos
    signal modules_rst, timer_enable : STD_LOGIC;
    signal time_done_sig, correct_sig, wrong_sig : STD_LOGIC;

    signal rand_a, rand_b : STD_LOGIC_VECTOR(3 downto 0);
    signal rand_op : STD_LOGIC_VECTOR(2 downto 0);
    signal score_val : unsigned(3 downto 0);

begin

    -- 1. TRATAMENTO DOS BOTÕES E ESTADOS
    process(clk)
        variable btn_sub_prev : std_logic := '0';
    begin
        if rising_edge(clk) then
            -- Detector Start
            if btn_start = '1' then
                if current_state /= PLAYING then
                    start_pulse <= '1';
                    current_state <= PLAYING;
                else
                    start_pulse <= '0';
                end if;
            else
                start_pulse <= '0';
            end if;

            -- Máquina de Estados
            case current_state is
                when IDLE => null;
                when PLAYING =>
                    if (time_done_sig = '1') or (wrong_sig = '1' and sw_death = '1') then
                        current_state <= GAME_OVER;
                    end if;
                when GAME_OVER => null;
            end case;

            -- Detector Submit
            if btn_submit = '1' and btn_sub_prev = '0' and current_state = PLAYING then
                submit_pulse <= '1';
            else
                submit_pulse <= '0';
            end if;
            submit_pulse_delayed <= submit_pulse;
            btn_sub_prev := btn_submit;
        end if;
    end process;

    -- Lógica Auxiliar
    modules_rst  <= '1' when (current_state = IDLE or start_pulse = '1') else '0';
    timer_enable <= '1' when current_state = PLAYING else '0';
    is_playing   <= '1' when current_state = PLAYING else '0';

    -- 2. INSTANCIAÇÃO DOS MÓDULOS DE LÓGICA
    u_random : entity work.random_op_gen
        Port Map (
            clk_50MHz => clk,
            update    => start_pulse or (submit_pulse_delayed and not time_done_sig),
            rst       => '0',
            rand_a => rand_a, rand_b => rand_b, operation => rand_op
        );

    u_timer : entity work.timer
        Port Map (
            clk => clk, rst => modules_rst, start => timer_enable,
            time_done => time_done_sig, led_warn => led_warn
        );

    u_check : entity work.verificador
        Port Map (
            clk => clk, rst => modules_rst,
            rand_a => rand_a, rand_b => rand_b, operation => rand_op,
            user_answer => user_answ, submit_pulse => submit_pulse,
            correct => correct_sig, wrong => wrong_sig
        );

    u_score : entity work.score_counter
        Port Map (
            clk => clk, rst => modules_rst, correct => correct_sig, score => score_val
        );

    -- 3. SAÍDAS PARA O EXTERIOR
    out_val_a  <= rand_a;
    out_val_b  <= rand_b;
    out_val_op <= rand_op;
    out_score  <= std_logic_vector(score_val);

end Behavioral;
