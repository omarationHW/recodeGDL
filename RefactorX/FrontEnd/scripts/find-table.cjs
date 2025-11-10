#!/usr/bin/env node

const { Client } = require('pg');

const dbConfig = {
  host: '192.168.6.146',
  port: 5432,
  database: 'padron_licencias',
  user: 'refact',
  password: 'FF)-BQk2',
};

async function findTable(searchTerm) {
  const client = new Client(dbConfig);

  try {
    await client.connect();

    const query = `
      SELECT table_schema, table_name
      FROM information_schema.tables
      WHERE LOWER(table_name) LIKE LOWER($1)
        AND table_type = 'BASE TABLE'
      ORDER BY table_schema, table_name;
    `;

    const result = await client.query(query, [`%${searchTerm}%`]);

    console.log(`\n🔍 Buscando tablas con: "${searchTerm}"\n`);

    if (result.rows.length > 0) {
      result.rows.forEach(row => {
        console.log(`   ${row.table_schema}.${row.table_name}`);
      });
    } else {
      console.log(`   ❌ No se encontraron tablas`);
    }

    console.log('');

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
  }
}

const searchTerm = process.argv[2] || 'giro';
findTable(searchTerm).then(() => process.exit(0));
