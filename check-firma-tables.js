// Script para verificar las tablas relacionadas con firmas
const { Client } = require('pg');

async function checkFirmaTables() {
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

    // Verificar qué tablas existen relacionadas con firmas
    console.log('🔍 Buscando tablas relacionadas con firmas...');
    const tablesResult = await client.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'informix'
      AND (
        table_name LIKE '%firma%' OR
        table_name LIKE '%sign%' OR
        table_name LIKE '%auth%' OR
        table_name LIKE '%usuario%' OR
        table_name LIKE '%user%'
      )
      ORDER BY table_name;
    `);

    console.log('📋 Tablas encontradas:', tablesResult.rows.map(r => r.table_name));

    // Analizar estructura de cada tabla encontrada
    for (const table of tablesResult.rows) {
      const tableName = table.table_name;
      console.log(`\n🔧 Analizando estructura de ${tableName}:`);

      const columnsResult = await client.query(`
        SELECT column_name, data_type, is_nullable, column_default
        FROM information_schema.columns
        WHERE table_schema = 'informix' AND table_name = $1
        ORDER BY ordinal_position;
      `, [tableName]);

      columnsResult.rows.forEach(col => {
        console.log(`  ${col.column_name}: ${col.data_type} ${col.is_nullable === 'NO' ? 'NOT NULL' : 'NULL'} ${col.column_default ? `DEFAULT ${col.column_default}` : ''}`);
      });

      // Mostrar algunos datos de ejemplo
      try {
        const sampleResult = await client.query(`SELECT * FROM informix.${tableName} LIMIT 5`);
        if (sampleResult.rows.length > 0) {
          console.log(`\n📊 Datos de ejemplo de ${tableName}:`);
          sampleResult.rows.forEach((row, idx) => {
            console.log(`  Registro ${idx + 1}:`, row);
          });
          console.log(`\n📊 Total de registros en ${tableName}:`);
          const countResult = await client.query(`SELECT COUNT(*) as total FROM informix.${tableName}`);
          console.log(`  Total: ${countResult.rows[0].total}`);
        }
      } catch (error) {
        console.log(`  ⚠️ No se pudieron obtener datos de ejemplo: ${error.message}`);
      }
    }

    // Buscar tablas que contengan campos como 'firma', 'usuario', 'nivel'
    console.log('\n🔍 Buscando tablas con campos de firma/usuario...');
    const firmaFieldsResult = await client.query(`
      SELECT DISTINCT table_name, column_name
      FROM information_schema.columns
      WHERE table_schema = 'informix'
      AND (
        column_name LIKE '%firma%' OR
        column_name LIKE '%sign%' OR
        column_name LIKE '%usuario%' OR
        column_name LIKE '%user%' OR
        column_name LIKE '%nivel%' OR
        column_name LIKE '%auth%'
      )
      ORDER BY table_name, column_name;
    `);

    console.log('📋 Tablas con campos relacionados:');
    firmaFieldsResult.rows.forEach(field => {
      console.log(`  - ${field.table_name}.${field.column_name}`);
    });

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
    console.log('🔌 Conexión cerrada');
  }
}

checkFirmaTables();