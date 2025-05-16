--
-- This SQL script demonstrates how to use JSON functions in SQL to aggregate data from two tables: cities and locations.
-- The script retrieves city information and associated location IDs, formats them as JSON objects, and aggregates them into a JSON array.        
        SELECT 
           json_arrayagg(
            json_object( 
                  'id' VALUE a.id,
                  'description' VALUE a.description,
                  'city_co' VALUE a.city_co,
                  'postal_co' VALUE a.postal_co,
                  'telephone_co' VALUE a.telephone_co,
                  'municipality_id' VALUE a.municipality_id,
                  'slug' VALUE a.slug,
                  'uuid' VALUE a.uuid,
                  'user_id' VALUE a.user_id,
                  'nu_gps_lat' VALUE a.nu_gps_lat,
                  'nu_gps_lon' VALUE a.nu_gps_lon,
                  'locations' VALUE json_arrayagg(b.id ORDER BY b.id)
                  FORMAT JSON
              )
            ) json_cities
          FROM cities a 
          INNER JOIN locations b ON a.id = b.city_id
          WHERE a.municipality_id = 166
          GROUP BY a.id, a.description, a.city_co, a.postal_co, 
                   a.telephone_co, a.municipality_id, a.slug, a.uuid,
                   a.user_id, a.nu_gps_lat, a.nu_gps_lon;