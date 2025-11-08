#!/bin/bash
psql -U postgres -d "BasePHP" -f 01_catalogs.sql
psql -U postgres -d "BasePHP" -f 02_crud.sql
psql -U postgres -d "BasePHP" -f 03_reports.sql