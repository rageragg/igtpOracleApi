declare 
    -- 
    r_reg test%rowtype;
    --
    cursor c_csv is  
      select line_number, line_raw, 
             c001 customer_co, 
             c002 description, 
             c003 telephone_co, 
             c004 fax_co,
             c005 email,
             c006 address,
             c007 type_customer,
             c008 sector,
             c009 category_co,
             c010 fiscal_document_co,
             c011 location_co,
             c012 telephone_contact,
             c013 name_contact
       from sys_k_csv_util.clob_to_csv (
            p_csv_clob  => r_reg.data,
            p_separator => ';',
            p_skip_rows => 0
        );
    --
begin 
    --
    /*
        ;;;;email_contact
    */
    --
    select *
     into r_reg
     from test
     where rownum = 1;
    --
    for r in c_csv loop 
        --
        dbms_output.put_line( 
            r.line_number  ||' '||
            r.customer_co ||' '||
            r.description ||' '||
            r.telephone_co ||' '||
            r.fax_co ||' '||
            r.email ||' '||
            r.address ||' '||
            r.type_customer ||' '||
            r.sector ||' '||
            r.category_co ||' '||
            r.fiscal_document_co ||' '||
            r.location_co ||' '||
            r.telephone_contact ||' '||
            r.name_contact
        );
        --
    end loop;
    --
end;