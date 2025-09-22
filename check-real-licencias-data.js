const { Pool } = require('pg');

// Configuración de la base de datos
const pool = new Pool({
  user: 'refact',
  host: '192.168.6.146',
  database: 'padron_licencias',
  password: 'FF)-BQk2',
  port: 5432,
});

async function checkRealLicenciasData() {
  try {
    console.log('🔍 Analizando datos reales de licenciasleyenda...');

    // Verificar estructura completa de la tabla
    const structureQuery = `
      SELECT
        column_name,
        data_type,
        is_nullable,
        character_maximum_length,
        column_default
      FROM information_schema.columns
      WHERE table_schema = 'informix'
      AND table_name = 'licenciasleyenda'
      ORDER BY ordinal_position;
    `;

    const structure = await pool.query(structureQuery);
    console.log('\n📋 Estructura completa de licenciasleyenda:');
    structure.rows.forEach(col => {
      console.log(`   ${col.column_name}: ${col.data_type}${col.character_maximum_length ? `(${col.character_maximum_length})` : ''} ${col.is_nullable === 'YES' ? 'NULL' : 'NOT NULL'}`);
    });

    // Analizar datos reales - muestras representativas
    console.log('\n🧪 Analizando datos reales...');

    // Verificar tipos de registro únicos
    const tiposQuery = `
      SELECT
        tipo_registro,
        COUNT(*) as cantidad,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as porcentaje
      FROM informix.licenciasleyenda
      GROUP BY tipo_registro
      ORDER BY cantidad DESC;
    `;
    const tipos = await pool.query(tiposQuery);
    console.log('\n📊 Tipos de registro (tipo_licencia):');
    tipos.rows.forEach(row => {
      console.log(`   '${row.tipo_registro}': ${row.cantidad} registros (${row.porcentaje}%)`);
    });

    // Verificar estados únicos
    const estadosQuery = `
      SELECT
        vigente,
        COUNT(*) as cantidad,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as porcentaje
      FROM informix.licenciasleyenda
      GROUP BY vigente
      ORDER BY cantidad DESC;
    `;
    const estados = await pool.query(estadosQuery);
    console.log('\n📊 Estados vigente:');
    estados.rows.forEach(row => {
      console.log(`   '${row.vigente}': ${row.cantidad} registros (${row.porcentaje}%)`);
    });

    // Mostrar ejemplos reales completos
    console.log('\n📋 Ejemplos reales de registros:');
    const samplesQuery = `
      SELECT
        id_licencia,
        licencia,
        tipo_registro,
        propietario,
        rfc,
        ubicacion,
        numext_ubic,
        colonia_ubic,
        actividad,
        vigente,
        fecha_otorgamiento,
        fecha_baja
      FROM informix.licenciasleyenda
      ORDER BY id_licencia DESC
      LIMIT 3;
    `;

    const samples = await pool.query(samplesQuery);
    samples.rows.forEach((row, index) => {
      console.log(`\n   Ejemplo ${index + 1}:`);
      console.log(`     ID: ${row.id_licencia}`);
      console.log(`     Licencia: ${row.licencia}`);
      console.log(`     Tipo: '${row.tipo_registro}'`);
      console.log(`     Propietario: ${row.propietario}`);
      console.log(`     RFC: ${row.rfc}`);
      console.log(`     Ubicación: ${row.ubicacion}`);
      console.log(`     Num ext: ${row.numext_ubic}`);
      console.log(`     Colonia: ${row.colonia_ubic}`);
      console.log(`     Actividad: ${row.actividad}`);
      console.log(`     Vigente: '${row.vigente}'`);
      console.log(`     Fecha otorg: ${row.fecha_otorgamiento}`);
      console.log(`     Fecha baja: ${row.fecha_baja}`);
    });

    // Verificar si hay campos nulos importantes
    console.log('\n🔍 Análisis de campos nulos:');
    const nullAnalysisQuery = `
      SELECT
        'tipo_registro' as campo,
        COUNT(*) as total,
        COUNT(tipo_registro) as no_nulos,
        COUNT(*) - COUNT(tipo_registro) as nulos
      FROM informix.licenciasleyenda
      UNION ALL
      SELECT
        'vigente' as campo,
        COUNT(*) as total,
        COUNT(vigente) as no_nulos,
        COUNT(*) - COUNT(vigente) as nulos
      FROM informix.licenciasleyenda
      UNION ALL
      SELECT
        'propietario' as campo,
        COUNT(*) as total,
        COUNT(propietario) as no_nulos,
        COUNT(*) - COUNT(propietario) as nulos
      FROM informix.licenciasleyenda;
    `;

    const nulls = await pool.query(nullAnalysisQuery);
    nulls.rows.forEach(row => {
      console.log(`   ${row.campo}: ${row.no_nulos} no nulos, ${row.nulos} nulos de ${row.total} total`);
    });

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

checkRealLicenciasData();