CREATE OR REPLACE TYPE typ_aq_notification AS OBJECT (
    id              NUMBER,
    to_user         VARCHAR2(100),
    from_user       VARCHAR2(100),
    message         VARCHAR2(4000),
    create_at       DATE
);
/