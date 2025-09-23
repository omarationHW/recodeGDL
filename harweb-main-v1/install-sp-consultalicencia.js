const { Pool } = require('pg');
const fs = require('fs');

// Configuración de la base de datos
const pool = new Pool({
  user: 'refact',
  host: '192.168.6.146',
  database: 'padron_licencias',
  password: 'FF)-BQk2',
  port: 5432,
});

async function installStoredProcedure() {
  try {
    console.log('🔧 Installing SP_CONSULTALICENCIA_LIST...');

    // Crear el esquema informix si no existe
    const createSchema = `CREATE SCHEMA IF NOT EXISTS informix;`;
    await pool.query(createSchema);
    console.log('✅ Schema informix created/verified');

    // Crear el stored procedure
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
    const testQuery = 'SELECT * FROM informix.SP_CONSULTALICENCIA_LIST()';
    const result = await pool.query(testQuery);
    console.log('✅ Test query successful. Rows:', result.rows.length);
    console.log('📋 Sample data:', result.rows[0]);

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

installStoredProcedure();