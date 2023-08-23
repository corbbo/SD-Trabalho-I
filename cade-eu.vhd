library IEEE;
use IEEE.std_logic.all;
use IEEE.std_logic_vector.all;

entity cade_eu is
  port (
    clock     :    in  std_logic;
    reset     :    in  std_logic;
    x, y      :    in  std_logic_vector(5 downto 0);
    find      :    in  std_logic;
    prog      :    in  std_logic;
    point     :    in  std_logic;
    address   :    out std_logic_vector(11 downto 0);
    finish    :    out std_logic;
    room      :    out std_logic_vector(3 downto 0)
  );
end cade_eu;

architecture arq of cade_eu is
  type coord is record
    x:  std_logic_vector(5 downto 0);
    y:  std_logic_vector(5 downto 0);
  end record;
  constant N_ROOM: integer := 8;
  signal ponto_de_teste: coord;
  type state is (init, idle, search_down, set_wall_down, search_up, set_wall_up, search_left, set_wall_left, search_right, set_wall_right, src_X0, set_wall_srcX0, src_Y0, set_wall_srcY0, src_X1, set_wall_srcX1, src_Y1, set_wall_srcY1, retorno);
  signal EA, PE: state;
  signal is_room: std_logic;
  signal has_wall: std_logic_vector(3 downto 0);
  type ROOM is array(0 to N_ROOM) of coord;
  signal salas : ROOM;
begin
  -- FSM
  process(reset, clock)
  begin
    if reset = '1' then
        EA <= idle;
        is_room <= '0';
        has_wall <= "0000"; --UP , DOWN , LEFT , RIGHT
        room <= "0000";
        address <= x"00";
        finish <= '0';
    else if clock'event and clock = '1' then
        case EA is
            when init => ponto_de_teste.x <= x; -- pega o ponto que vai testar e coloca ele em coord.x
                         ponto_de_teste.y <= y; -- pega o ponto que vai testar e coloca ele em coord.y

            when search_up, search_down, search_left, search_right => address <= ponto_de_teste.y & ponto_de_teste.x;
              
            when src_X0, src_X1, src_Y0, src_Y1 => address <= ponto_de_teste.y & ponto_de_teste.x;
              
            when retorno =>
        end case;
    EA <= PE;
    end if;
  end process

  -- logica de estados
  process(EA, find)
  begin
    case EA is
      when idle =>      if find = '1' then
                            PE <= init;
                            else PE <= idle;
                        end if;

      when init =>      PE <= search_up;

      when search_up => --while !(is wall) volta pra search_up
                            if point = '0' and ponto_de_teste.y /= "00000" then -- se não achou parede, nem terminou a grade, continua procurando
                                PE <= search_up;
                                else if point = '1' then -- achou parede
                                    PE <= search_down;
                                else others -- a grade terminou sem achar parede, logo não é uma sala
                                    PE <= retorno;
                            end if;

      when search_down =>   if point = '0' and ponto_de_teste.y /= "11111" then --se não achou parede, nem terminou a grade, continua procurando
                                PE <= search_down;
                                else if point = '1' then -- achou parede
                                    PE <= search_left;
                                else others
                                    PE <= retorno;
                            end if;

      when search_left =>   if point = '0' and ponto_de_teste.x /= "00000" then --se não achou parede, nem terminou a grade, continua procurando
                                PE <= search_left;
                                else if point = '1' then -- achou parede
                                    PE <= search_right;
                                else others
                                    PE <= retorno;
                            end if;

      when search_right =>  if point = '0' and ponto_de_teste.x /= "11111" then --se não achou parede, nem terminou a grade, continua procurando
                                PE <= search_right;
                                else if point = '1' then
                                    if has_wall = "1111" then -- continua procurando apenas se tiver encontrado paredes em todos os lados (failsafe)
                                        PE <= src_X0;
                                    end if;
                                else others
                                    PE <= retorno;
                            end if;

      when src_X0 =>        
                            PE <= src_Y0;
      when src_Y0 =>
                      PE <= src_X1;
      when src_X1 =>
                      PE <= src_Y1;
      when src_Y1 =>
                      PE <= retorno;
      when retorno =>
                      PE <= idle;
