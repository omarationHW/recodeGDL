// Script para verificar las tablas relacionadas con estatus
const { Client } = require('pg');

async function checkEstatusTables() {
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

    // Verificar qué tablas existen relacionadas con estatus
    console.log('🔍 Buscando tablas relacionadas con estatus...');
    const tablesResult = await client.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'informix'
      AND (
        table_name LIKE '%estatus%' OR
        table_name LIKE '%status%' OR
        table_name LIKE '%estado%' OR
        table_name LIKE '%c_%'
      )
      ORDER BY table_name;
    `);

    console.log('📋 Tablas encontradas:', tablesResult.rows.map(r => r.table_name));

    // Si existe una tabla de estatus, analizar su estructura
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

      // Mostrar algunos datos de ejemplo si la tabla parece ser de estatus
      if (tableName.includes('estatus') || tableName.includes('status') ||
          (tableName.startsWith('c_') && tableName.length < 15)) {
        try {
          const sampleResult = await client.query(`SELECT * FROM informix.${tableName} LIMIT 5`);
          if (sampleResult.rows.length > 0) {
            console.log(`\n📊 Datos de ejemplo de ${tableName}:`);
            sampleResult.rows.forEach((row, idx) => {
              console.log(`  Registro ${idx + 1}:`, row);
            });
          }
        } catch (error) {
          console.log(`  ⚠️ No se pudieron obtener datos de ejemplo: ${error.message}`);
        }
      }
    }

    // Buscar tablas que contengan campos como 'estatus', 'estado'
    console.log('\n🔍 Buscando tablas con campos de estatus...');
    const estatusFieldsResult = await client.query(`
      SELECT DISTINCT table_name
      FROM information_schema.columns
      WHERE table_schema = 'informix'
      AND (
        column_name LIKE '%estatus%' OR
        column_name LIKE '%status%' OR
        column_name LIKE '%estado%'
      )
      ORDER BY table_name;
    `);

    console.log('📋 Tablas con campos de estatus:');
    estatusFieldsResult.rows.forEach(table => {
      console.log(`  - ${table.table_name}`);
    });

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
    console.log('🔌 Conexión cerrada');
  }
}

checkEstatusTables();