--------------------------------------------------------
--  DDL for Package LGC_API_K_ROUTE
--------------------------------------------------------

  CREATE OR REPLACE NONEDITIONABLE PACKAGE "IGTP"."LGC_API_K_ROUTE" IS
    --
    K_OWNER      CONSTANT VARCHAR2(20)  := 'IGTP';
    K_TABLE_NAME CONSTANT VARCHAR2(30)  := 'ROUTES';
    K_LIMIT_LIST CONSTANT PLS_INTEGER   := 512;
    K_ORDER_LIST CONSTANT PLS_INTEGER   := 2;
    --
    TYPE routes_api_tab IS TABLE OF routes%ROWTYPE;
    --
    -- get DATA RETURN RECORD by ID
    FUNCTION get_record( p_id IN routes.id%TYPE ) RETURN routes%ROWTYPE;
    --
    -- get DATA RETURN RECORD by CO
    FUNCTION get_record( p_route_co IN routes.route_co%TYPE ) RETURN routes%ROWTYPE;    
    --
    -- get DATA Array
    FUNCTION get_list RETURN routes_api_tab;
    --
    -- insert
    PROCEDURE ins (
        p_id                  routes.id%TYPE,
        p_route_co            routes.route_co%TYPE,
        p_description         routes.description%TYPE,
        p_from_city_id        routes.from_city_id%TYPE,
        p_to_city_id          routes.to_city_id%TYPE,
        p_k_level_co          routes.k_level_co%TYPE,
        p_distance_km         routes.distance_km%TYPE,
        p_estimated_time_hrs  routes.estimated_time_hrs%TYPE,
        p_slug                routes.slug%TYPE,
        p_uuid                routes.uuid%TYPE,
        p_user_id             routes.user_id%TYPE,
        p_created_at          routes.created_at%TYPE,
        p_updated_at          routes.updated_at%TYPE
    );
    --
    -- insert RECORD
    PROCEDURE ins ( p_rec IN OUT routes%ROWTYPE );
    --
    -- update
    PROCEDURE upd (
        p_id                  routes.id%TYPE,
        p_route_co            routes.route_co%TYPE,
        p_description         routes.description%TYPE,
        p_from_city_id        routes.from_city_id%TYPE,
        p_to_city_id          routes.to_city_id%TYPE,
        p_k_level_co          routes.k_level_co%TYPE,
        p_distance_km         routes.distance_km%TYPE,
        p_estimated_time_hrs  routes.estimated_time_hrs%TYPE,
        p_slug                routes.slug%TYPE,
        p_uuid                routes.uuid%TYPE,
        p_user_id             routes.user_id%TYPE,
        p_created_at          routes.created_at%TYPE,
        p_updated_at          routes.updated_at%TYPE
    );
    --
    -- update RECORD
    PROCEDURE upd ( p_rec IN OUT routes%ROWTYPE );
    --
    -- delete
    procedure del ( p_id routes.id%TYPE );
    --
END lgc_api_k_route;

/
