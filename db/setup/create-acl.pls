BEGIN
    --
    DBMS_NETWORK_ACL_ADMIN.create_acl (
        acl         => 'igtp_acl.xml',
        description => 'ACL iGTP',
        principal   => 'IGTP',
        is_grant    => TRUE,
        privilege   => 'connect',
        start_date  => SYSTIMESTAMP,
        end_date    => NULL
    );
    --
    COMMIT;
    --  
END;