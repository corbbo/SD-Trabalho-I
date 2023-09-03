library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_unsigned.all;
use IEEE.std_logic_arith.all;

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
  signal ponto_de_teste, coord_XYMin, coord_XYMax, coord_sala: coord;
  type state is (
                init, idle, 
                search_down, search_up, search_left, search_right, 
                src_XMin, set_wall_srcXMin, src_YMin, set_wall_srcYMin, src_XMax, set_wall_srcXMax, src_YMax, set_wall_srcYMax, 
                retorno, set_room, final_test, room_n_check
                );
  signal EA, PE: state;
  signal is_room: std_logic;
  signal has_wall: std_logic_vector(3 downto 0);
  type ROOMS is array(0 to N_ROOM) of coord;
  signal salas : ROOMS;
  signal cont_sala, cont_sala2 : STD_LOGIC_VECTOR(3 downto 0);
begin
    address <= ponto_de_teste.y & ponto_de_teste.x when EA = search_up or EA = search_down or EA = search_left or EA = search_right
                                                        or EA = src_XMin or EA = src_XMax or EA = src_YMin or EA = src_YMax 
                                                   else y & x when EA = idle                                                
                                                   else x"000";

   -- registro de salas
   process (reset, clock)
   begin
      if reset='1' then 
            cont_sala <= (others=>'0');
            salas <= (others => (x => "000000", y => "000000"));
      elsif clock'event and clock='1' and cont_sala<N_ROOM then
            if  prog='1' then
               salas(conv_integer(cont_sala)).x <= x;
               salas(conv_integer(cont_sala)).y <= y;
               if cont_sala<N_ROOM then
                     cont_sala <= cont_sala + 1;
               end if;
            end if;
      end if;
   end process;

  -- FSM
  process(reset, clock)
  begin
    if reset = '1' then
        EA <= idle;
        is_room <= '0';
        has_wall <= "0000"; --UP , DOWN , LEFT , RIGHT
        room <= "0000";
        fin <= '0';
        ponto_de_teste.x <= "000000";
        ponto_de_teste.y <= "000000";
        coord_XYMin.x <= "000000";
        coord_XYMin.y <= "000000";
        coord_XYMax.x <= "000000";
        coord_XYMax.y <= "000000";
        coord_sala.x <= "000000";
        coord_sala.y <= "000000";
        cont_sala2 <= "0000";
    else if clock'event and clock = '1' then
        case EA is          
            when init                                 => ponto_de_teste.x <= x; -- pega o ponto que vai testar e coloca ele em coord.x
                                                         ponto_de_teste.y <= y; -- pega o ponto que vai testar e coloca ele em coord.y
            
            when search_up                            => ponto_de_teste.y <= ponto_de_teste.y + '1';
                                                         if point = '1' then
                                                            coord_XYMax.y <= ponto_de_teste.y; -- recebe coords maximas para teste em src_XMax
                                                            ponto_de_teste.y <= y; -- volta para o ponto inicial
                                                            has_wall(3) <= '1';
                                                         end if;

            when search_down                          => ponto_de_teste.y <= ponto_de_teste.y - '1';
                                                         if point = '1' then
                                                            coord_XYMin.y <= ponto_de_teste.y; -- recebe coords minimas para teste em src_XMin
                                                            ponto_de_teste.y <= y; -- volta para o ponto inicial
                                                            has_wall(2) <= '1';
                                                         end if;

            when search_right                         => ponto_de_teste.x <= ponto_de_teste.x + '1';
                                                          if point = '1' then
                                                              coord_XYMax.x <= ponto_de_teste.x; -- recebe coords maximas para teste em src_YMax
                                                              ponto_de_teste.x <= x; -- volta para o ponto inicial
                                                              has_wall(1) <= '1';
                                                          end if;

            when search_left                          => ponto_de_teste.x <= ponto_de_teste.x - '1';
                                                          if point = '1' then
                                                              coord_XYMin.x <= ponto_de_teste.x; -- recebe coords minimas para teste em src_YMin
                                                              ponto_de_teste.x <= x; -- volta para o ponto inicial
                                                              has_wall(0) <= '1';
                                                          end if;

            when src_XMin                             => ponto_de_teste.x <= ponto_de_teste.x + '1';
            when src_XMax                             => ponto_de_teste.x <= ponto_de_teste.x - '1';
            when src_YMin                             => ponto_de_teste.y <= ponto_de_teste.y + '1';
            when src_YMax                             => ponto_de_teste.y <= ponto_de_teste.y - '1';

            when set_room                             =>  if has_wall = "1111" then
                                                           is_room <= '1';
                                                           has_wall <= "0000";
                                                           ponto_de_teste.x <= coord_XYMin.x; -- recebe coords minimas para teste em src_XMin
                                                           ponto_de_teste.y <= coord_XYMin.y;
                                                          else
                                                           is_room <= '0';
                                                           room <= "0000";
                                                           fin <= '1';
                                                          end if;
                                                                                                                         
            when set_wall_srcXMin                       => if is_room = '1' then                                                                         
                                                            has_wall(3) <= '1';
                                                            ponto_de_teste.x <= coord_XYMin.x; -- recebe coords minimas para teste em src_YMin
                                                            -- nao recebe coord_XYMin.y pois ja recebeu no set_room
                                                            is_room <= '0'; -- reset pois foi setado para '1' no fim dos searches para validar os proximos estados, voltara a ser '1' se no fim dos srcs has_wall for "1111"
                                                          else -- failsafe
                                                            is_room <= '0';
                                                            room <= "0000";
                                                            fin <= '1';
                                                          end if;

            when set_wall_srcYMin                       => has_wall(2) <= '1';
                                                           ponto_de_teste.y <= coord_XYMax.y; -- recebe coords maximas para teste em src_XMax
                                                           ponto_de_teste.x <= coord_XYMax.x; 
                                                           
            when set_wall_srcXMax                       => has_wall(1) <= '1';
                                                           ponto_de_teste.x <= coord_XYMax.x; -- recebe coords maximas para teste em src_YMax
                                                           -- nao recebe coord_XYMax.y pois ja recebeu no set_wall_srcYMin
            when set_wall_srcYMax                       => has_wall(0) <= '1';

            when final_test                             => if has_wall = "1111" then
                                                            is_room <= '1';
                                                            coord_sala.x <= coord_XYMax.x - coord_XYMin.x;
                                                            coord_sala.y <= coord_XYMax.y - coord_XYMin.y;
                                                           else
                                                            is_room <= '0';
                                                            room <= "0000";
                                                            fin <= '1';
                                                           end if;

            when room_n_check                           => if is_room = '1' then
                                                            if salas(conv_integer(cont_sala2)).x = coord_sala.x and salas(conv_integer(cont_sala2)).y = coord_sala.y then
                                                              room <= cont_sala2;
                                                              end if;
                                                            cont_sala2 <= cont_sala2 + 1;
                                                           else
                                                            is_room <= '0';
                                                            cont_sala2 <= "0000";
                                                            room <= "0000";
                                                            fin <= '1';
                                                           end if;
              
            when others                               => null;
        end case;
      EA <= PE;
    end if;                                                             
  end if;
end process;

  -- logica de estados
  process(EA, find, point, is_room)
  begin
    case EA is
--------------------------------------------------------------------------------
  when init =>
    PE <= search_up;
--------------------------------------------------------------------------------
  when idle =>
    if find = '1' then
        PE <= init;
    else 
        PE <= idle;
    end if;
-------------------------------------------------------------------------------- 
  when search_down => 
   if point = '1' then -- achou parede
        PE <= search_left;
    elsif point = '0' and ponto_de_teste.y = "000000" then
        PE <= final_test;
    else
        PE <= search_down;
    end if;
--------------------------------------------------------------------------------
  when search_up =>
    if point = '1' then -- achou parede
        PE <= search_right;
    elsif point = '0' and ponto_de_teste.y = "111111" then
        PE <= final_test;
    else
        PE <= search_up;
    end if;
--------------------------------------------------------------------------------
  when search_left =>
    if point = '1' then
        PE <= search_right;
    elsif point = '0' and ponto_de_teste.x = "000000" then
        PE <= final_test;
    else
        PE <= search_left;
    end if;
--------------------------------------------------------------------------------
  when search_right =>
    if point = '1' then
        PE <= set_room;
    elsif point = '0' and ponto_de_teste.x = "111111" then
        PE <= final_test;
    else
        PE <= search_right;
    end if;
--------------------------------------------------------------------------------
  when src_XMin => --verificar se a parede eh continua a partir do X minimo ate o X maximo, com Y = Y minimo
    if point = '1' and ponto_de_teste.x <= coord_XYMax.x and ponto_de_teste.x >= coord_XYMin.x  then --enquanto for uma parede, continua andando
        PE <= src_XMin;
    else -- se a parede acabar, seta o XY
        PE <= set_wall_srcXMin;
    end if;
--------------------------------------------------------------------------------
  when set_wall_srcXMin =>
    PE <= src_YMin;
--------------------------------------------------------------------------------
  when src_YMin => -- --verificar se a parede eh continua a partir do Y minimo ate o Y maximo, com X = X minimo
    if point = '1' and ponto_de_teste.y <= coord_XYMax.y and ponto_de_teste.y >= coord_XYMax.y then 
        PE <=  src_YMin;
    else
        PE <= set_wall_srcYMin;
    end if;
--------------------------------------------------------------------------------
  when set_wall_srcYMin =>
    PE <= src_XMax;
--------------------------------------------------------------------------------
  when src_XMax => -- verificar se a parede eh continua a partir do X maximo ate o X minimo, com Y = Y maximo
    if point = '1' and ponto_de_teste.x <= coord_XYMax.x and ponto_de_teste.x >= coord_XYMin.x then 
        PE <=  src_XMax;
    else
        PE <= set_wall_srcXMax;
    end if;
--------------------------------------------------------------------------------
  when set_wall_srcXMax =>
    PE <= src_YMax;
--------------------------------------------------------------------------------
  when src_YMax => -- verificar se a parede eh continua a partir do Y maximo ate o Y minimo, com X = X maximo
    if point = '1' and ponto_de_teste.y <= coord_XYMax.y and ponto_de_teste.y >= coord_XYMin.y then 
        PE <=  src_YMax;
    else
        PE <= set_wall_srcYMax;
    end if;
--------------------------------------------------------------------------------
  when set_wall_srcYMax =>
    PE <= final_test;
--------------------------------------------------------------------------------
  when set_room => 
    PE <= src_XMin;
--------------------------------------------------------------------------------
  when room_n_check => 
    if is_room = '1' and cont_sala2 < N_ROOM then
        PE <= room_n_check;
    else 
        PE <= idle;
    end if;
--------------------------------------------------------------------------------
  when final_test => 
    if is_room = '1' then
        PE <= room_n_check;
    else 
        PE <= idle;
    end if;
--------------------------------------------------------------------------------
  when others => PE <= idle;
--------------------------------------------------------------------------------
  end case;
  end process;
end architecture arq;
