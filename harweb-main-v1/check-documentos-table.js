// Script para verificar la tabla de documentos
const { Client } = require('pg');

async function checkDocumentosTable() {
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

    // Verificar qué tablas existen relacionadas con documentos
    console.log('🔍 Buscando tablas relacionadas con documentos...');
    const tablesResult = await client.query(`
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema = 'informix'
      AND (
        table_name LIKE '%doc%' OR
        table_name LIKE '%documento%' OR
        table_name LIKE '%tramite%' OR
        table_name LIKE '%catalogo%' OR
        table_name LIKE '%requisito%'
      )
      ORDER BY table_name;
    `);

    console.log('📋 Tablas encontradas:', tablesResult.rows.map(r => r.table_name));

    // Si existe una tabla de documentos, analizar su estructura
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
        const sampleResult = await client.query(`SELECT * FROM informix.${tableName} LIMIT 3`);
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

    // Si no hay tablas específicas de documentos, buscar en todas las tablas
    if (tablesResult.rows.length === 0) {
      console.log('\n🔍 No se encontraron tablas específicas de documentos. Buscando en todas las tablas...');
      const allTablesResult = await client.query(`
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'informix'
        ORDER BY table_name;
      `);

      console.log('📋 Todas las tablas disponibles:');
      allTablesResult.rows.forEach(table => {
        console.log(`  - ${table.table_name}`);
      });
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
    console.log('🔌 Conexión cerrada');
  }
}

checkDocumentosTable();