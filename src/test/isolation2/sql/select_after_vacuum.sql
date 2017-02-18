-- @Description Ensures that a select after a vacuum operation is ok
-- 
DROP TABLE IF EXISTS ao;
DROP TABLE IF EXISTS ao2;
CREATE TABLE ao2 (a INT) WITH (appendonly=true);
CREATE TABLE ao (a INT) WITH (appendonly=true);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao select generate_series(1,1000);
insert into ao2 select generate_series(1,1000);

DROP VIEW IF EXISTS locktest;
create view locktest as select coalesce(
	case when relname like 'pg_toast%index' then 'toast index'
	when relname like 'pg_toast%' then 'toast table'
	else relname end, 'dropped table'),
	mode,
	locktype from
	pg_locks l left outer join pg_class c on (l.relation = c.oid),
	pg_database d where relation is not null and l.database = d.oid and
	l.gp_segment_id = -1 and
	relname != 'gp_fault_strategy' and
	d.datname = current_database() order by 1, 3, 2;

-- The actual test begins
DELETE FROM ao WHERE a < 128;
1: BEGIN;
1: SELECT COUNT(*) FROM ao2;
2U: SELECT segno, case when tupcount = 0 then 'zero' when tupcount = 1 then 'one' when tupcount <= 5 then 'few' else 'many' end FROM gp_toolkit.__gp_aoseg_name('ao');
2: VACUUM ao;
1: SELECT COUNT(*) FROM ao;
1: SELECT * FROM locktest WHERE coalesce = 'ao';
1: COMMIT;
1: SELECT COUNT(*) FROM ao;
3: INSERT INTO ao VALUES (0);
2U: SELECT segno, case when tupcount = 0 then 'zero' when tupcount = 1 then 'one' when tupcount <= 5 then 'few' else 'many' end FROM gp_toolkit.__gp_aoseg_name('ao');
