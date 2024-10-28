# SiennaGridDB

Schema for the SQL database for Sienna Applications

## Set pre-commit environment

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

## How to create the Schema

To create a database with the schema use the following command:

```console
sqlite3 test.db < schema.sql
```

Testing data with some basic queries:

```console
sqlite3 -table < dummy_data.sql
```
