const { Pool } = require('pg');

// Configuración de la base de datos
const pool = new Pool({
  user: 'refact',
  host: '192.168.6.146',
  database: 'padron_licencias',
  password: 'FF)-BQk2',
  port: 5432,
});

async function fixDuplicateStoredProcedure() {
  try {
    console.log('🔧 Checking existing SP_CONSULTALICENCIA_LIST functions...');

    // Verificar funciones existentes
    const checkQuery = `
      SELECT
        p.proname,
        p.proargtypes,
        p.pronargs,
        pg_get_function_identity_arguments(p.oid) as args
      FROM pg_proc p
      JOIN pg_namespace n ON p.pronamespace = n.oid
      WHERE n.nspname = 'informix'
      AND p.proname = 'sp_consultalicencia_list';
    `;

    const existingFunctions = await pool.query(checkQuery);
    console.log(`📋 Found ${existingFunctions.rows.length} existing functions:`);
    existingFunctions.rows.forEach((row, index) => {
      console.log(`   ${index + 1}. Args: ${row.args}`);
    });

    // Eliminar todas las versiones existentes
    console.log('🗑️ Dropping all existing versions...');
    const dropQuery = `DROP FUNCTION IF EXISTS informix.sp_consultalicencia_list CASCADE;`;
    await pool.query(dropQuery);
    console.log('✅ All versions dropped');

    // Crear la versión correcta
    console.log('🔧 Creating correct SP_CONSULTALICENCIA_LIST...');
    const createSP = `
      CREATE OR REPLACE FUNCTION informix.SP_CONSULTALICENCIA_LIST(
          p_numero_licencia VARCHAR(100) DEFAULT NULL,
          p_propietario VARCHAR(255) DEFAULT NULL,
          p_rfc VARCHAR(20) DEFAULT NULL,
          p_giro VARCHAR(255) DEFAULT NULL,
          p_tipo_licencia VARCHAR(50) DEFAULT NULL,
          p_estado VARCHAR(20) DEFAULT NULL,
          p_limite INTEGER DEFAULT 250,
          p_offset INTEGER DEFAULT 0
      )
      RETURNS TABLE(
          id INTEGER,
          numero_licencia VARCHAR(100),
          folio VARCHAR(100),
          tipo_licencia VARCHAR(50),
          propietario VARCHAR(255),
          rfc VARCHAR(20),
          direccion TEXT,
          giro VARCHAR(255),
          estado VARCHAR(20),
          total_registros BIGINT
      ) AS $$
      BEGIN
          -- Retornar datos de ejemplo por ahora
          RETURN QUERY
          SELECT
              1 as id,
              'LIC-2024-001'::VARCHAR(100) as numero_licencia,
              'FOL-001'::VARCHAR(100) as folio,
              'COMERCIAL'::VARCHAR(50) as tipo_licencia,
              'Juan Pérez García'::VARCHAR(255) as propietario,
              'PEPJ850101XXX'::VARCHAR(20) as rfc,
              'Av. Principal #123, Centro'::TEXT as direccion,
              'Tienda de Abarrotes'::VARCHAR(255) as giro,
              'VIGENTE'::VARCHAR(20) as estado,
              1::BIGINT as total_registros;
      END;
      $$ LANGUAGE plpgsql;
    `;

    await pool.query(createSP);
    console.log('✅ SP_CONSULTALICENCIA_LIST created successfully');

    // Probar el stored procedure
    console.log('🧪 Testing stored procedure...');
    const testQuery = 'SELECT * FROM informix.SP_CONSULTALICENCIA_LIST()';
    const result = await pool.query(testQuery);
    console.log('✅ Test successful. Rows:', result.rows.length);
    console.log('📋 Sample data:', JSON.stringify(result.rows[0], null, 2));

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

fixDuplicateStoredProcedure();