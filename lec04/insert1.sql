insert into R values (1,null);
insert into S values ('a',null);
insert into R values (2,null);
insert into S values ('b',null);

update R set s = 'a' where id = 1;
update S set r = 2 where id = 'a';
update R set s = 'b' where id = 2;
update S set r = 1 where id = 'b';
