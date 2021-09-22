create table order_items(
   order_code integer unique,
   product_id varchar unique,
   quantity integer not null,
   check ( quantity > 0 )
);

create table products(
   id varchar,
   name varchar unique ,
   description text not null ,
   price double precision not null,
   foreign key (id) references order_items(product_id)
);

create table orders(
   code integer,
   customer_id integer unique ,
   total_sum double precision not null ,
   is_paid boolean not null ,
   check ( total_sum > 0 ),
   foreign key (code) references order_items(order_code)
);

create table customers(
   id integer,
   full_name varchar(50) not null ,
   timestamp timestamp not null ,
   delivery_address text not null,
   foreign key (id) references orders(customer_id)
);

drop table order_items;
drop table orders;
drop table customers;
drop table products;

--------------------------------------------------------------


create table students(
    id integer not null ,
    full_name varchar not null,
    age integer not null,
    birth_date varchar not null ,
    gender char not null ,
    average_grade double precision not null ,
    info text not null ,
    need_dorm boolean default false,
    additional_info text
);

create table instructors(
    full_name varchar unique not null,
    remote boolean not null,
    experience integer not null,
    check ( experience > 2 )
);

create table languages(
    instructor varchar not null,
    language varchar not null,
    foreign key (instructor) references instructors(full_name)
);

create table lesson_participants(
    lesson_title varchar not null,
    instructor varchar unique not null,
    room integer not null,
    primary key (lesson_title, instructor),
    foreign key (instructor) references instructors(full_name)
);

create table studying_students(
    full_name varchar not null ,
    lesson varchar not null ,
    instructor varchar not null ,
    primary key (full_name, lesson),
    foreign key (lesson, instructor) references lesson_participants,
    foreign key (full_name) references students(full_name)
);

-------------------------------------------------------------------------------------

insert into order_items(order_code, product_id, quantity) values (1, '1', 2);
insert into products (id, name, description, price) values (1, 'phone', 'iphone', 800.30);
insert into orders(code, customer_id, total_sum, is_paid) VALUES (1, 1, 800.30*2, true);
insert into customers(id, full_name, timestamp, delivery_address)
VALUES (1, 'Seit', '2021-09-22 22:44:50', '221B Baker Street');

update customers set full_name = 'Bruce Wayne' where id = 1;
update products set description = 'sony ericson' where id = '1';
update order_items set quantity = 3 where order_code = 1;
update orders set total_sum = 3 * 800.30 where customer_id = 1;

delete from products where description = 'sony ericson';
delete from orders where customer_id = '1';
delete from order_items where order_code = 1;
delete from customers where full_name = 'Bruce Wayne';
