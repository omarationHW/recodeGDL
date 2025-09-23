// Script para verificar la estructura de la tabla constancias
const { Client } = require('pg');

async function checkConstanciasTable() {
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

    // Verificar estructura de la tabla constancias
    console.log('🔍 Verificando estructura de la tabla constancias...');
    const tableStructure = await client.query(`
      SELECT column_name, data_type, is_nullable, column_default
      FROM information_schema.columns
      WHERE table_schema = 'informix'
      AND table_name = 'constancias'
      ORDER BY ordinal_position;
    `);

    console.log('📋 Estructura de informix.constancias:');
    tableStructure.rows.forEach(row => {
      console.log(`  ${row.column_name} - ${row.data_type} (nullable: ${row.is_nullable})`);
    });

    // Verificar algunos registros de muestra
    console.log('\n🧪 Verificando registros de muestra...');
    const sampleData = await client.query(`
      SELECT * FROM informix.constancias
      LIMIT 3;
    `);

    console.log(`📊 Registros encontrados: ${sampleData.rows.length}`);
    if (sampleData.rows.length > 0) {
      console.log('🔍 Primer registro:', sampleData.rows[0]);
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
    console.log('🔌 Conexión cerrada');
  }
}

checkConstanciasTable();