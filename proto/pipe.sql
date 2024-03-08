--First, create employees example table.
create table employees(
   name varchar2(30),
   sal number
);
--
create or replace package test_dbms_pipe as
    procedure send_message_pipe (v_name in varchar2, v_sal in number, v_date in date default sysdate);
    procedure receive_message_pipe;
    procedure log_message (v_name in out varchar2, v_sal in out number, v_date in out date);
end test_dbms_pipe;
--
create or replace package body test_dbms_pipe as

    procedure send_message_pipe(
            v_name in varchar2,
            v_sal  in number,
            v_date in date
        ) as
        --
        v_status number;
        --
    begin
        --
        dbms_pipe.pack_message(v_name);
        dbms_pipe.pack_message(v_sal);
        dbms_pipe.pack_message(v_date);
        --
        v_status := dbms_pipe.send_message('message from pipe!');
        --
        if v_status != 0 then
            raise_application_error(-20001, '!! message pipe error !!');
        end if;
        --
    end send_message_pipe;
    --
    --Create the procedure that will receive the message pipe
    procedure receive_message_pipe as
        --
        v_result integer;
        v_name_r varchar2(3000);
        v_sal_r  number;
        --
    begin
        --
        v_result := dbms_pipe.receive_message(
            pipename => 'message from pipe!',
            timeout  => 10
        );
        --
        if v_result = 0 then
            --
            while v_result = 0 loop
                --
                v_result := dbms_pipe.receive_message(
                    pipename => 'message from pipe!',
                    timeout  => 10
                );
                --
                dbms_pipe.unpack_message(v_name_r);
                dbms_pipe.unpack_message(v_sal_r);
                --
                dbms_output.put_line('Full Name: ' || v_name_r);
                dbms_output.put_line('Salary: ' || v_sal_r);
                --
            end loop;
            --
        else
            --
            if v_result = 1 then
                --
                dbms_output.put_line('Timeout limit exceeded!');
                --
            else
                --
                raise_application_error(-20002, 'error receiving message pipe: ' || v_result);
                --
            end if;
            --
        end if;
        --
    exception
        when others then
            null;
    end receive_message_pipe;

end test_dbms_pipe;
--
--Create the trigger on employee table using the send procedure
create or replace trigger employees_upd_sal
        after insert on employees
        for each row
    declare
        --
        v_date_1 date;
        --
    begin
        --
        v_date_1 := sysdate;
        --
        test_dbms_pipe.send_message_pipe(v_name => :new.name, v_sal => :new.sal);
        --
        exception
            when others then
                raise_application_error(
                    num => -20002,
                    msg => 'error message on trigger!'
                );
        --
end employees_upd_sal;
--
set serveroutput on
exec test_dbms_pipe.receive_message_pipe;
--On the second session execute some insert commands on employees table.
insert into employees (name,sal) values ('John Paul',300000);
insert into employees (name,sal) values ('Mike',350000);
insert into employees (name,sal) values ('Brad',400000);
--
commit;
--
select * from v$db_pipes;
