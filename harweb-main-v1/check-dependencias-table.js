// Script para verificar la estructura de la tabla dependencias
const { Client } = require('pg');

async function checkDependenciasTable() {
  const client = new Client({
    host: '192.168.6.146',
    port: 5432,
    database: 'padron_licencias',
    user: 'refact',
    password: 'FF)-BQk2'
  });

  try {
    await client.connect();
    console.log('✅ Conectado a PostgreSQL');

    // Buscar tablas que contengan "depend" en el nombre
    console.log('🔍 Buscando tablas relacionadas con dependencias...');
    const tables = await client.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'informix'
      AND table_name ILIKE '%depend%'
      ORDER BY table_name;
    `);

    console.log('📋 Tablas encontradas con "depend":');
    tables.rows.forEach(row => {
      console.log(`  - ${row.table_name}`);
    });

    // También buscar otras posibles tablas relacionadas
    console.log('\n🔍 Buscando otras tablas que podrían contener dependencias...');
    const otherTables = await client.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'informix'
      AND (table_name ILIKE '%depart%' OR table_name ILIKE '%dept%' OR table_name ILIKE '%unidad%')
      ORDER BY table_name;
    `);

    console.log('📋 Otras tablas relacionadas:');
    otherTables.rows.forEach(row => {
      console.log(`  - ${row.table_name}`);
    });

    // Si encontramos alguna tabla, verificar su estructura
    if (tables.rows.length > 0) {
      const tableName = tables.rows[0].table_name;
      console.log(`\n🔍 Verificando estructura de la tabla ${tableName}...`);

      const tableStructure = await client.query(`
        SELECT column_name, data_type, is_nullable, column_default
        FROM information_schema.columns
        WHERE table_schema = 'informix'
        AND table_name = $1
        ORDER BY ordinal_position;
      `, [tableName]);

      console.log(`📋 Estructura de informix.${tableName}:`);
      tableStructure.rows.forEach(row => {
        console.log(`  ${row.column_name} - ${row.data_type} (nullable: ${row.is_nullable})`);
      });

      // Verificar algunos registros de muestra
      console.log(`\n🧪 Verificando registros de muestra en ${tableName}...`);
      const sampleData = await client.query(`
        SELECT * FROM informix.${tableName}
        LIMIT 3;
      `);

      console.log(`📊 Registros encontrados: ${sampleData.rows.length}`);
      if (sampleData.rows.length > 0) {
        console.log('🔍 Primer registro:', sampleData.rows[0]);
      }
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
    console.log('🔌 Conexión cerrada');
  }
}

checkDependenciasTable();