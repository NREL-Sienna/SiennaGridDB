# SiennaGridDB

Schema for the SQL database for Sienna Applications

> [!IMPORTANT]
> The griddb schema was designed using SQLite 3.45 to use some of the jsonb
> functionality. We do not intend to provide backwards compatibility since when
> we deisgined this 3.45 had already a year of being deployed.

## How To(s)

### How to install `just`

> [!NOTE]
> The recommended method to install just is using cargo.
> However, there are multiple ways of installing it see the `just` documentation for [just](https://github.com/casey/just)

```console
cargo install just
```

### Create an example database and run some queries on it

```console
just test
```

### Run example queries on a griddb schema database

To create a database with the schema use the following command:

```console
just queries $DB_NAME
```

## Contributing

### Set pre-commit environment

Install a virtual environment

```console
python -m venv .venv
```

Setup the python environment

```console
python -m pip install -r requirements.txt
```

Setup pre-commit to run automatically on each commit.

```console
pre-commit install
```
