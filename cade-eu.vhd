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
    fin       :    out std_logic;
    room      :    out std_logic_vector(3 downto 0)
  );
end cade_eu;

architecture arq of cade_eu is
  type coord is record
    x:  std_logic_vector(5 downto 0);
    y:  std_logic_vector(5 downto 0);
  end record;
  constant N_ROOM: integer := 8;
  signal ponto_de_teste, coord_XYMin, coord_XYMax: coord;
  type state is (
                init, idle, 
                search_down, set_wall_down, search_up, set_wall_up, search_left, set_wall_left, search_right, set_wall_right, 
                src_XMin, set_wall_srcXMin, src_YMin, set_wall_srcYMin, src_XMax, set_wall_srcXMax, src_YMax, set_wall_srcYMax, 
                retorno, set_room
                );
  signal EA, PE: state;
  signal is_room: std_logic;
  signal has_wall: std_logic_vector(3 downto 0);
  type ROOM is array(0 to N_ROOM) of coord;
  signal salas : ROOM;
begin
    --prof disse que era pra colocar as saidas fora do process, para não atrasar o clock
    address <= ponto_de_teste.y & ponto_de_teste.x
    when    EA = search_up or EA = search_down or EA = search_left or EA = search_right
    or      EA = src_XMin or EA = src_XMax or EA = src_YMin or EA = src_YMax;

  -- FSM
  process(reset, clock)
  begin
    if reset = '1' then
        EA <= idle;
        is_room <= '0';
        has_wall <= "0000"; --UP , DOWN , LEFT , RIGHT
        room <= "0000";
        address <= x"00";
        fin <= '0';
    else if clock'event and clock = '1' then
        case EA is
            when init => ponto_de_teste.x <= x; -- pega o ponto que vai testar e coloca ele em coord.x
                         ponto_de_teste.y <= y; -- pega o ponto que vai testar e coloca ele em coord.y
            
            when search_up                            => ponto_de_teste.y <= ponto_de_teste.y + '1';
            when search_down                          => ponto_de_teste.y <= ponto_de_teste.y - '1';
            when search_right                         => ponto_de_teste.x <= ponto_de_teste.x + '1';
            when search_left                          => ponto_de_teste.x <= ponto_de_teste.x - '1';

            when src_XMin                             => ponto_de_teste.x <= ponto_de_teste.x + '1';
            when src_XMax                             => ponto_de_teste.x <= ponto_de_teste.x - '1';
            when src_YMin                             => ponto_de_teste.y <= ponto_de_teste.y + '1';
            when src_YMax                             => ponto_de_teste.y <= ponto_de_teste.y - '1';

            when set_wall_up                          => has_wall(3) <= '1';
                                                         coord_XYMax.y <= ponto_de_teste.y;
                                                         ponto_de_teste.y <= y;

            when set_wall_down                        => has_wall(2) <= '1';
                                                         coord_XYMin.y <= ponto_de_teste.y;
                                                         ponto_de_teste.y <= y;

            when set_wall_left                        => has_wall(1) <= '1';
                                                         coord_XYMin.x <= ponto_de_teste.x;
                                                         ponto_de_teste.x <= x;

            when set_wall_right                       => has_wall(0) <= '1';
                                                         coord_XYMax.x <= ponto_de_teste.x;
                                                         ponto_de_teste.x < = x;
                                                         --TODO: setar 
                                                        -- if has_wall = "1111" then
                                                        --    is_room <= '1';
                                                        --    has_wall <= "0000";
                                                        -- else
                                                        --    is_room <= '0';
                                                        --    room <= "0000";
                                                        --    fin <= '1';
                                                        -- end if;
            when set_room                             =>  if has_wall = "1111" then
                                                           is_room <= '1';
                                                           has_wall <= "0000";
                                                        else
                                                           is_room <= '0';
                                                           room <= "0000";
                                                           fin <= '1';
                                                        end if;
                                                                                                                         
            when set_wall_srcXMin                       => if is_room = '1' then                                                                         
                                                            has_wall(3) <= '1';
                                                            coord_XYMin.x <= ponto_de_teste.x;
                                                            is_room <= '0'; -- reset pois foi setado para '1' no fim dos searches para validar os proximos estados, voltara a ser '1' se no fim dos srcs has_wall for "1111"
                                                          else -- failsafe
                                                            is_room <= '0';
                                                            room <= "0000";
                                                            fin <= '1';
                                                          end if;
            when set_wall_srcYMin                       => has_wall(2) <= '1';
                                                         coord_XYMin.y <= ponto_de_teste.y;
            when set_wall_srcXMax                       => has_wall(1) <= '1';
                                                         coord_XYMax.x <= ponto_de_teste.x;
            when set_wall_srcYMax                       => has_wall(0) <= '1';
                                                         coord_XYMax.y <= ponto_de_teste.y;
                                                         if has_wall = "1111" then
                                                          is_room <= '1';
                                                       else
                                                          is_room <= '0';
                                                          room <= "0000";
                                                          fin <= '1';
                                                       end if;
              
            when retorno                              => fin <= '1';
              
            when others                               => address <= x"00";
                                                                         
            -- sim kkkkk
        end case;
    EA <= PE;
    end if;
  end process

  -- logica de estados
  process(EA, find)
  begin
    case EA is
--------------------------------------------------------------------------------
  when init =>
  PE <= search_up;
--------------------------------------------------------------------------------
  when idle =>
  if find = '1' then
    PE <= init;
  else PE <= idle;
  end if;
-------------------------------------------------------------------------------- 
  when search_down => 
if point = '0' and ponto_de_teste.y /= "111111" then --se não achou parede, nem terminou a grade, continua procurando
PE <= search_down;
else if point = '1' then -- achou parede
    PE <= set_wall_down;
 else others
     PE <= retorno;
end if;
--------------------------------------------------------------------------------
  when set_wall_down =>
PE <= search_up;
--------------------------------------------------------------------------------
  when search_up =>
  --while !(is wall) volta pra search_up
if point = '0' and ponto_de_teste.y /= "000000" then -- se não achou parede, nem terminou a grade, continua procurando
    PE <= search_up;
    else if point = '1' then -- achou parede
        PE <= set_wall_up;
    else others -- a grade terminou sem achar parede, logo não é uma sala
        PE <= retorno;
end if;
--------------------------------------------------------------------------------
  when set_wall_up =>
PE <= search_left;
--------------------------------------------------------------------------------
  when search_left =>
if point = '0' and ponto_de_teste.x /= "000000" then --se não achou parede, nem terminou a grade, continua procurando
    PE <= search_left;
    else if point = '1' then -- achou parede
        PE <= set_wall_right;
    else others
        PE <= retorno;
end if;
--------------------------------------------------------------------------------
  when set_wall_left =>
PE <=  search_right;
--------------------------------------------------------------------------------
  when search_right =>
if point = '0' and ponto_de_teste.x /= "111111" then --se não achou parede, nem terminou a grade, continua procurando
  PE <= search_right;
  else if point = '1' then
      PE <= set_wall_right;
  else others
      PE <= retorno;
end if;
--------------------------------------------------------------------------------
  when set_wall_right =>
    PE <= set_room;
--------------------------------------------------------------------------------
  when src_XMin => --acha o valor minimo de X
  if point = '1' and ponto_de_teste.x <= coord_XYMax.x and ponto_de_teste.x >= coord_XYMin.x  then --enquanto for uma parede, continua andando
    PE <= src_XMin;
  else -- se a parede acabar, seta o XY
    PE <= set_wall_srcXMin;
  end if;
--------------------------------------------------------------------------------
  when set_wall_srcXMin =>
PE <= src_YMin;
--------------------------------------------------------------------------------
  when src_YMin => -- --acha o valor minimo de Y
  if point = '1' and ponto_de_teste.y <= coord_XYMax.y and ponto_de_teste.y >= coord_XYMax.y then 
    PE <=  src_YMin;
  else
    PE <= set_wall_srcYMin;
  end if;
--------------------------------------------------------------------------------
  when set_wall_srcYMin =>
PE <= src_XMax;
--------------------------------------------------------------------------------
  when src_XMax => -- acha o valor maximo de X
    if point = '1' and ponto_de_teste.x <= coord_XYMax.x and ponto_de_teste.x >= coord_XYMin.x then 
    PE <=  src_XMax;
  else
    PE <= set_wall_srcXMax;
  end if;
--------------------------------------------------------------------------------
  when set_wall_srcXMax =>
PE <= src_YMax;
--------------------------------------------------------------------------------
  when src_YMax => -- acha o valor maximo de Y
    if point = '1' and ponto_de_teste.y <= coord_XYMax.y and ponto_de_teste.y >= coord_XYMin.y then 
    PE <=  src_YMax;
  else
    PE <= set_wall_srcYMax;
  end if;
--------------------------------------------------------------------------------
  when set_wall_srcYMax =>
PE <= finish;
--------------------------------------------------------------------------------
  when retorno =>
PE <= idle;
--------------------------------------------------------------------------------
  when set_room => 
PE <= src_XMin;
--------------------------------------------------------------------------------