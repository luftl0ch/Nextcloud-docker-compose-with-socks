psql --variable=ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    GRANT CREATE ON SCHEMA public TO public;
EOSQL