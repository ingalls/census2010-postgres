# Initialize database & load postgis

echo "
    DROP DATABASE IF EXISTS census;
    CREATE DATABASE census;
" | psql -U postgres
        
echo "
    CREATE EXTENSION POSTGIS;
" | psql -U postgres census
