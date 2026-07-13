library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity timer is
    Port (
        clk        : in  STD_LOGIC;  -- 50 MHz
        rst        : in  STD_LOGIC;  -- Reset do jogo
        start      : in  STD_LOGIC;  -- Sinal para começar a contar

        time_done  : out STD_LOGIC;  -- Pulso de fim de tempo
        led_warn   : out STD_LOGIC   -- LED piscante
    );
end timer;

architecture Behavioral of timer is

    constant CLK_FREQ : integer := 50_000_000;
    
    -- Contadores
    signal ticks      : integer range 0 to CLK_FREQ := 0;
    signal seconds    : integer range 0 to 60 := 0;
    
    -- Controle do LED
    signal blink_cnt  : unsigned(25 downto 0) := (others => '0'); -- Contador livre para piscar
    signal led_status : STD_LOGIC := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ticks      <= 0;
                seconds    <= 0;
                blink_cnt  <= (others => '0');
                led_status <= '0';
                time_done  <= '0';
            elsif start = '1' then
                -- 1. Base de Tempo
                if seconds < 60 then
                    if ticks = CLK_FREQ - 1 then
                        ticks   <= 0;
                        seconds <= seconds + 1;
                    else
                        ticks   <= ticks + 1;
                    end if;
                end if;

                -- 2. Sinal de Fim
                if seconds = 60 then
                    time_done <= '1';
                else
                    time_done <= '0';
                end if;

                -- 3. Lógica do LED (Piscar)
                blink_cnt <= blink_cnt + 1;

                if seconds = 60 then
                    led_status <= '0'; -- Apaga no fim
                elsif seconds >= 50 then
                    -- Faltam 10 segundos: Pisca RÁPIDO (Aprox 6Hz)
                    -- Bit 22 muda a cada ~0.08s
                    led_status <= std_logic(blink_cnt(22)); 
                else
                    -- Normal: Pisca LENTO (Aprox 1.5Hz)
                    -- Bit 24 muda a cada ~0.6s
                    led_status <= std_logic(blink_cnt(24));
                end if;

            else
                -- Se start = 0 mas não é reset, congela ou mantem estado
                led_status <= '0';
            end if;
        end if;
    end process;

    led_warn <= led_status;

end Behavioral;
