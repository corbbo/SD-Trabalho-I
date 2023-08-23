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
  type state is (init, idle, search_down, search_up, search_left, search_right, src_X0, src_Y0, src_X1, src_Y1, retorno);
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
              when init =>
                      ponto_de_teste.x <= x; -- pega o ponto que vai testar e coloca ele em coord.x
                      ponto_de_teste.y <= y; -- pega o ponto que vai testar e coloca ele em coord.y

              when search_up => --while !(is wall) volta pra search_up
                      address <= ponto_de_teste.y & ponto_de_teste.x;
                        has_wall(3) => '1'; -- 3 downto 0, bit 3 setado pra 1

              when search_down => 
                        has_wall(2) => '1'; -- 3 downto 0, bit 2 setado pra 1
              when search_left => 
                        has_wall(1) => '1'; -- 3 downto 0, bit 1 setado pra 1
              when search_right => 
                        has_wall(0) => '1'; -- 3 downto 0, bit 0 setado pra 1
              when src_X0 =>
              when src_Y0 =>
              when src_X1 =>
              when src_Y1 =>
              when retorno =>

      EA <= PE;
    end if;
  end process;
  -- logica de estados
  process(EA, find)
  begin
    case EA is
      when idle =>  
      if find = '1' then
                      PE <= init;
                    else PE <= idle;

      when init =>
                      PE <= search_up;
      when search_up => --while !(is wall) volta pra search_up
                      if point = '0' and ponto_de_teste.y /= '0' then --se não achou parede, nem terminou a grade, continua procurando
                        PE <= search_up;
                      else if point = '1' then
                        -- tem que setar "has_wall" => '1000' e PE => search_down
                        PE <= search_down;
                      else others
                        PE <= idle;


      when search_down => 
                      if point = '0' and ponto_de_teste.y /= '63' then --se não achou parede, nem terminou a grade, continua procurando
                        PE <= search_down;
                      else if point = '1' then
                        -- tem que setar "has_wall" => '1000' e PE => search_down
                        PE <= search_left;
                      else others
                        PE <= idle;

      when search_left => 
                      if point = '0' and ponto_de_teste.x /= '0' then --se não achou parede, nem terminou a grade, continua procurando
                        PE <= search_left;
                      else if point = '1' then
                        -- tem que setar "has_wall" => '1000' e PE => search_down
                        PE <= search_right;
                      else others
                        PE <= idle;
      when search_right => 
                      if point = '0' and ponto_de_teste.x /= '63' then --se não achou parede, nem terminou a grade, continua procurando
                        PE <= search_right;
                      else if point = '1' then
                        -- tem que setar "has_wall" => '1000' e PE => search_down
                        PE <= src_X0;
                      else others
                        PE <= idle;
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
