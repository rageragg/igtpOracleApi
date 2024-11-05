-- use select * from mcr_cities( p_municipality_id => 9 );
create or replace function mcr_cities( p_municipality_id number ) return varchar2 sql_macro(table)
is
begin 
    return q'[
        select id city_id, city_co, description, municipality_id
          from cities 
         where municipality_id = p_municipality_id
    ]';
end;