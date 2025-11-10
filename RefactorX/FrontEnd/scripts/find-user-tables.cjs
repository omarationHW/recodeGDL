#!/usr/bin/env node

const { Client } = require('pg');

const dbConfig = {
  host: '192.168.6.146',
  port: 5432,
  database: 'padron_licencias',
  user: 'refact',
  password: 'FF)-BQk2',
};

async function findUserTables() {
  const client = new Client(dbConfig);

  try {
    await client.connect();

    // Buscar tablas con "usuario", "user", "firma" en el nombre
    const query = `
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'public'
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

    const result = await client.query(query);

    console.log('\n🔍 TABLAS RELACIONADAS CON USUARIOS/FIRMA:\n');

    if (result.rows.length > 0) {
      for (const row of result.rows) {
        console.log(`📋 ${row.table_name}`);

        // Mostrar columnas
        const colQuery = `
          SELECT column_name, data_type, character_maximum_length
          FROM information_schema.columns
          WHERE table_schema = 'public' AND table_name = $1
          ORDER BY ordinal_position;
        `;

        const colResult = await client.query(colQuery, [row.table_name]);
        colResult.rows.forEach(col => {
          const type = col.character_maximum_length ?
            `${col.data_type}(${col.character_maximum_length})` :
            col.data_type;
          console.log(`   - ${col.column_name}: ${type}`);
        });
        console.log('');
      }
    } else {
      console.log('❌ No se encontraron tablas con esos nombres\n');
      console.log('Buscando en todas las tablas columnas con "firma"...\n');

      // Buscar columnas que contengan "firma"
      const colQuery = `
        SELECT table_name, column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'public'
          AND LOWER(column_name) LIKE '%firma%'
        ORDER BY table_name, column_name;
      `;

      const colResult = await client.query(colQuery);
      colResult.rows.forEach(row => {
        console.log(`   ${row.table_name}.${row.column_name} (${row.data_type})`);
      });
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
    throw error;
  } finally {
    await client.end();
  }
}

findUserTables()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
