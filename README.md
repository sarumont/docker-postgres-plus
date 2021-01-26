Docker image with Postgres, pgtap, and plv8 installed.

# Usage

Fire up a database via docker:

```
docker run --rm --name pg-docker -e POSTGRES_PASSWORD=p0stgr3s -d -p 5432:5432 -v $HOME/.docker/volumes/postgres:/var/lib/postgresql/data sarumont/postgres-pgtap:latest
```

This can be connected to via `localhost:5432`:

```
psql -h localhost -U postgres postgres
```

You can now apply your schema, etc.

## Running tests

To run pgtap tests, 

```
docker run -i -t --rm --name pgtap --link pg-docker:db -ePGPASSWORD=p0stgr3s -v <local path to tests>:/test sarumont/postgres-pgtap:latest pg_prove -Upostgres -h db -d <database name> -v /test/<test file>
```
