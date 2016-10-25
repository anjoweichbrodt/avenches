#!/bin/bash

psql "service=pg_avenches" -v ON_ERROR_STOP=1 -f schema.sql
