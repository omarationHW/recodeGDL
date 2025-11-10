#!/usr/bin/env node

const { Client } = require('pg');

const dbConfig = {
  host: '192.168.6.146',
  port: 5432,
  database: 'padron_licencias',
  user: 'refact',
  password: 'FF)-BQk2',
};

async function checkSchemas() {
  const client = new Client(dbConfig);

  try {
    await client.connect();

    // Listar todos los esquemas
    const schemasQuery = `
      SELECT schema_name
      FROM information_schema.schemata
      WHERE schema_name NOT IN ('pg_catalog', 'information_schema')
      ORDER BY schema_name;
    `;

    const schemasResult = await client.query(schemasQuery);

    console.log('\n📂 ESQUEMAS DISPONIBLES:\n');
    schemasResult.rows.forEach(row => {
      console.log(`   - ${row.schema_name}`);
    });

    // Para cada esquema, buscar tablas de usuarios
    console.log('\n\n🔍 BUSCANDO TABLAS DE USUARIOS EN CADA ESQUEMA:\n');

    for (const schemaRow of schemasResult.rows) {
      const schema = schemaRow.schema_name;

      const tablesQuery = `
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = $1
          AND table_type = 'BASE TABLE'
          AND (
            LOWER(table_name) LIKE '%usuario%' OR
            LOWER(table_name) LIKE '%user%' OR
            LOWER(table_name) LIKE '%firma%' OR
            LOWER(table_name) LIKE '%login%' OR
            LOWER(table_name) LIKE '%auth%'
          )
        ORDER BY table_name;
      `;

      const tablesResult = await client.query(tablesQuery, [schema]);

      if (tablesResult.rows.length > 0) {
        console.log(`\n📋 Esquema: ${schema}`);
        for (const tableRow of tablesResult.rows) {
          console.log(`   - ${tableRow.table_name}`);

          // Mostrar columnas
          const colQuery = `
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = $1 AND table_name = $2
            ORDER BY ordinal_position;
          `;

          const colResult = await client.query(colQuery, [schema, tableRow.table_name]);
          colResult.rows.forEach(col => {
            const type = col.character_maximum_length ?
              `${col.data_type}(${col.character_maximum_length})` :
              col.data_type;
            console.log(`      ${col.column_name}: ${type}`);
          });
        }
      }
    }

    // Buscar en esquema "comun" específicamente
    console.log('\n\n📋 TABLAS EN ESQUEMA "comun":\n');
    const comunQuery = `
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'comun'
        AND table_type = 'BASE TABLE'
      ORDER BY table_name;
    `;

    const comunResult = await client.query(comunQuery);
    if (comunResult.rows.length > 0) {
      comunResult.rows.forEach(row => console.log(`   - ${row.table_name}`));
    } else {
      console.log('   (No se encontraron tablas en esquema "comun")');
    }

  } catch (error) {
    console.error('\n❌ Error:', error.message);
  } finally {
    await client.end();
  }
}

checkSchemas()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
