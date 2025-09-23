// Script para verificar la estructura de licencias_400
const { Client } = require('pg');

async function checkLicencias400Structure() {
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

    // Analizar estructura completa de licencias_400
    console.log('🔧 Analizando estructura completa de licencias_400:');
    const columnsResult = await client.query(`
      SELECT column_name, data_type, is_nullable, column_default
      FROM information_schema.columns
      WHERE table_schema = 'informix' AND table_name = 'licencias_400'
      ORDER BY ordinal_position;
    `);

    columnsResult.rows.forEach(col => {
      console.log(`  ${col.column_name}: ${col.data_type} ${col.is_nullable === 'NO' ? 'NOT NULL' : 'NULL'} ${col.column_default ? `DEFAULT ${col.column_default}` : ''}`);
    });

    // Verificar campos específicos de empresa
    console.log('\n🔍 Campos relacionados con empresas en licencias_400:');
    const empresaFields = await client.query(`
      SELECT column_name, data_type
      FROM information_schema.columns
      WHERE table_schema = 'informix' AND table_name = 'licencias_400'
      AND (
        column_name LIKE '%rfc%' OR
        column_name LIKE '%propietario%' OR
        column_name LIKE '%razon%' OR
        column_name LIKE '%social%' OR
        column_name LIKE '%nombre%' OR
        column_name LIKE '%comercial%' OR
        column_name LIKE '%telefono%' OR
        column_name LIKE '%email%' OR
        column_name LIKE '%direccion%' OR
        column_name LIKE '%genero%' OR
        column_name LIKE '%activo%'
      )
      ORDER BY column_name;
    `);

    empresaFields.rows.forEach(col => {
      console.log(`  ${col.column_name}: ${col.data_type}`);
    });

    // Mostrar algunos datos de ejemplo con campos de empresa
    console.log('\n📊 Datos de ejemplo con campos de empresa:');
    try {
      const sampleResult = await client.query(`
        SELECT rfc, propietarionvo, telefono, email, direccion
        FROM informix.licencias_400
        WHERE rfc IS NOT NULL AND TRIM(rfc) != ''
        LIMIT 5;
      `);

      if (sampleResult.rows.length > 0) {
        sampleResult.rows.forEach((row, idx) => {
          console.log(`  Registro ${idx + 1}:`);
          console.log(`    RFC: ${row.rfc}`);
          console.log(`    Propietario: ${row.propietarionvo}`);
          console.log(`    Teléfono: ${row.telefono}`);
          console.log(`    Email: ${row.email}`);
          console.log(`    Dirección: ${row.direccion}`);
          console.log('');
        });
      }
    } catch (error) {
      console.log(`  ⚠️ Error obteniendo datos: ${error.message}`);
    }

    // Contar registros únicos por RFC
    console.log('📊 Estadísticas de empresas en licencias_400:');
    try {
      const statsResult = await client.query(`
        SELECT
          COUNT(*) as total_licencias,
          COUNT(DISTINCT TRIM(rfc)) as empresas_unicas,
          COUNT(CASE WHEN rfc IS NOT NULL AND TRIM(rfc) != '' THEN 1 END) as con_rfc
        FROM informix.licencias_400;
      `);

      const stats = statsResult.rows[0];
      console.log(`  Total licencias: ${stats.total_licencias}`);
      console.log(`  Empresas únicas (RFC): ${stats.empresas_unicas}`);
      console.log(`  Licencias con RFC: ${stats.con_rfc}`);
    } catch (error) {
      console.log(`  ⚠️ Error obteniendo estadísticas: ${error.message}`);
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
    console.log('🔌 Conexión cerrada');
  }
}

checkLicencias400Structure();