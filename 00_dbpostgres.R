require("RPostgreSQL", quietly = TRUE)

drv <- dbDriver('PostgreSQL')  
db <- 'ildar'  
host_db <- 'localhost'  
db_port <- '5432'  
db_user <- 'ildar'  
db_password <- 'ghtdtl'

con <- dbConnect(drv, dbname=db, host=host_db, port=db_port, user=db_user, password=db_password)

dbListTables(con)

sql_command <- "CREATE TABLE cartable
(
  carname character varying NOT NULL,
  mpg numeric(3,1),
  cyl numeric(1,0),
  disp numeric(4,1),  
  hp numeric(3,0),
  drat numeric(3,2),
  wt numeric(4,3),
  qsec numeric(4,2),
  vs numeric(1,0),
  am numeric(1,0),
  gear numeric(1,0),
  carb numeric(1,0),
  CONSTRAINT cartable_pkey PRIMARY KEY (carname)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cartable
  OWNER TO ildar;
COMMENT ON COLUMN cartable.disp IS '
';"
# sends the command and creates the table
dbGetQuery(con, sql_command)

dbDisconnect(con)
dbUnloadDriver(drv)