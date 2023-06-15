BEGIN
  --
  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL (
     acl => 'igtp_acl.xml',
     host => '192.168.0.*',
     lower_port => 80,
     upper_port => 3020
  );
  --
  COMMIT;
  --  
END;