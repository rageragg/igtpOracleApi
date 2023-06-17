--------------------------------------------------------
--  DDL for Package CFG_API_K_ROUTE_LOCATION
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "IGTP"."CFG_API_K_ROUTE_LOCATION" IS
    --
    TYPE route_locations_api_rec IS RECORD (
        id              igtp.route_locations.id%TYPE,
        route_id        igtp.route_locations.route_id%TYPE,
        location_id     igtp.route_locations.location_id%TYPE,
        description     igtp.route_locations.description%TYPE,
        user_id         igtp.route_locations.user_id%TYPE,
        updated_at      igtp.route_locations.updated_at%TYPE,
        created_at      igtp.route_locations.created_at%TYPE
    );
    --
    TYPE route_locations_tab IS TABLE OF route_locations_api_rec;
    --
    -- insert
    PROCEDURE ins (
        p_created_at    IN igtp.route_locations.created_at%TYPE DEFAULT NULL,
        p_description   IN igtp.route_locations.description%TYPE DEFAULT NULL,
        p_route_id      IN igtp.route_locations.route_id%TYPE DEFAULT NULL,
        p_user_id       IN igtp.route_locations.user_id%TYPE DEFAULT NULL,
        p_location_id   IN igtp.route_locations.location_id%TYPE DEFAULT NULL, 
        p_updated_at    IN igtp.route_locations.updated_at%TYPE DEFAULT NULL, 
        p_id            IN igtp.route_locations.id%type
    );
    --
    -- insert RECORD
    PROCEDURE ins( 
        p_record IN OUT cfg_api_k_route_location.route_locations_api_rec
    );
    --
    -- update
    PROCEDURE upd (
        p_created_at    IN igtp.route_locations.created_at%TYPE DEFAULT NULL,
        p_description   IN igtp.route_locations.description%TYPE DEFAULT NULL,
        p_route_id      IN igtp.route_locations.route_id%TYPE DEFAULT NULL,
        p_user_id       IN igtp.route_locations.user_id%TYPE DEFAULT NULL,
        p_location_id   IN igtp.route_locations.location_id%TYPE DEFAULT NULL, 
        p_updated_at    IN igtp.route_locations.updated_at%TYPE DEFAULT NULL, 
        p_id            IN igtp.route_locations.id%TYPE
    );
    --
    -- update RECORD
    PROCEDURE upd ( 
            p_record IN OUT cfg_api_k_route_location.route_locations_api_rec
    );
    --
    -- delete
    PROCEDURE del (
        p_ID IN igtp.route_locations.id%TYPE
    );
    --
    -- exist record
    FUNCTION existe_record ( 
        p_route_id      IN igtp.route_locations.route_id%TYPE DEFAULT NULL,
        p_location_id   IN igtp.route_locations.location_id%TYPE DEFAULT NULL
    ) RETURN BOOLEAN;
    --
    -- build from route
    PROCEDURE build_from_route( 
        p_route_id IN igtp.route_locations.route_id%TYPE DEFAULT NULL 
    );
    --
    -- bulding all
    PROCEDURE build_all;
    --
END cfg_api_k_route_location;


/
