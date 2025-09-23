// Script para verificar la estructura específica de la tabla dictamen
const { Client } = require('pg');

async function checkDictamenTableSpecific() {
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

    // Verificar estructura de la tabla dictamen
    console.log('🔍 Verificando estructura de la tabla dictamen...');
    const dictamenStructure = await client.query(`
      SELECT column_name, data_type, is_nullable, column_default
      FROM information_schema.columns
      WHERE table_schema = 'informix'
      AND table_name = 'dictamen'
      ORDER BY ordinal_position;
    `);

    console.log('📋 Estructura de informix.dictamen:');
    dictamenStructure.rows.forEach(row => {
      console.log(`  ${row.column_name} - ${row.data_type} (nullable: ${row.is_nullable})`);
    });

    // Verificar algunos registros de muestra
    console.log('\n🧪 Verificando registros de muestra en dictamen...');
    const sampleData = await client.query(`
      SELECT * FROM informix.dictamen
      LIMIT 5;
    `);

    console.log(`📊 Registros encontrados: ${sampleData.rows.length}`);
    if (sampleData.rows.length > 0) {
      console.log('🔍 Registros de muestra:');
      sampleData.rows.forEach((row, index) => {
        console.log(`  ${index + 1}:`, row);
      });
    }

    // También verificar la tabla dictamenes
    console.log('\n🔍 Verificando estructura de la tabla dictamenes...');
    const dictamenesStructure = await client.query(`
      SELECT column_name, data_type, is_nullable, column_default
      FROM information_schema.columns
      WHERE table_schema = 'informix'
      AND table_name = 'dictamenes'
      ORDER BY ordinal_position;
    `);

    console.log('📋 Estructura de informix.dictamenes:');
    dictamenesStructure.rows.forEach(row => {
      console.log(`  ${row.column_name} - ${row.data_type} (nullable: ${row.is_nullable})`);
    });

    // Verificar algunos registros de muestra de dictamenes
    console.log('\n🧪 Verificando registros de muestra en dictamenes...');
    const sampleDictamenes = await client.query(`
      SELECT * FROM informix.dictamenes
      LIMIT 5;
    `);

    console.log(`📊 Registros encontrados en dictamenes: ${sampleDictamenes.rows.length}`);
    if (sampleDictamenes.rows.length > 0) {
      console.log('🔍 Registros de muestra dictamenes:');
      sampleDictamenes.rows.forEach((row, index) => {
        console.log(`  ${index + 1}:`, row);
      });
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
    console.log('🔌 Conexión cerrada');
  }
}

checkDictamenTableSpecific();