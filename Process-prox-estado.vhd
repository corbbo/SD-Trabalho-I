when finaleira_fim  =>  coord_sala.x <= coord_XYMax.x - coord_XYMin.x;
                        coord_sala.y <= coord_XYMax.y - coord_XYMin.y;
                        cont_sala <= "0000";
                        for cont_sala in 0 to N_ROOM loop
                          if salas(conv_integer(cont_sala)).x = coord_sala.x
                          and salas(conv_integer(cont_sala)).y = coord_sala.y then
                            room <= cont_sala;
                            else
                              cont_sala <= cont_sala + '1';
                            end if;
                          end loop;
                        end if;
when count          => -----------------------------------------------------
                        if salas(conv_integer(cont_sala)).x = coord_sala.x
                          and salas(conv_integer(cont_sala)).y = coord_sala.y then
                            room <= cont_sala;
                            else
                              cont_sala <= cont_sala + '1';
                            end if;