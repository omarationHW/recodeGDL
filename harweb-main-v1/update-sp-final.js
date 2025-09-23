const { Pool } = require('pg');

// Configuración de la base de datos
const pool = new Pool({
  user: 'refact',
  host: '192.168.6.146',
  database: 'padron_licencias',
  password: 'FF)-BQk2',
  port: 5432,
});

async function updateSPWithoutHardcoded() {
  try {
    console.log('🔧 Creating SP_CONSULTALICENCIA_LIST without hardcoded values...');

    // Eliminar stored procedure existente
    console.log('🗑️ Dropping existing SP...');
    const dropSP = `DROP FUNCTION IF EXISTS informix.sp_consultalicencia_list(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER);`;
    await pool.query(dropSP);
    console.log('✅ Dropped existing SP');

    // Crear stored procedure sin valores hardcodeados - usar valores directos de la DB
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
      DECLARE
          total_count BIGINT;
      BEGIN
          -- Obtener el total de registros para paginación
          SELECT COUNT(*) INTO total_count
          FROM informix.licenciasleyenda l
          WHERE 1=1
            AND (p_numero_licencia IS NULL OR CAST(l.licencia AS TEXT) ILIKE '%' || p_numero_licencia || '%')
            AND (p_propietario IS NULL OR UPPER(l.propietario) ILIKE '%' || UPPER(p_propietario) || '%')
            AND (p_rfc IS NULL OR UPPER(l.rfc) ILIKE '%' || UPPER(p_rfc) || '%')
            AND (p_giro IS NULL OR UPPER(l.actividad) ILIKE '%' || UPPER(p_giro) || '%')
            AND (p_estado IS NULL OR l.vigente = p_estado);

          -- Retornar resultados con paginación - sin valores hardcodeados
          RETURN QUERY
          SELECT
              l.id_licencia::INTEGER as id,
              COALESCE(CAST(l.licencia AS VARCHAR(100)), '')::VARCHAR(100) as numero_licencia,
              COALESCE(CAST(l.id_licencia AS VARCHAR(100)), '')::VARCHAR(100) as folio,
              COALESCE(l.tipo_registro, '')::VARCHAR(50) as tipo_licencia,
              COALESCE(l.propietario, '')::VARCHAR(255) as propietario,
              COALESCE(l.rfc, '')::VARCHAR(20) as rfc,
              (COALESCE(l.ubicacion, '') ||
               CASE WHEN l.numext_ubic IS NOT NULL THEN ' #' || CAST(l.numext_ubic AS TEXT) ELSE '' END ||
               CASE WHEN l.colonia_ubic IS NOT NULL THEN ', ' || l.colonia_ubic ELSE '' END)::TEXT as direccion,
              COALESCE(l.actividad, '')::VARCHAR(255) as giro,
              COALESCE(l.vigente, '')::VARCHAR(20) as estado,
              total_count::BIGINT as total_registros
          FROM informix.licenciasleyenda l
          WHERE 1=1
            AND (p_numero_licencia IS NULL OR CAST(l.licencia AS TEXT) ILIKE '%' || p_numero_licencia || '%')
            AND (p_propietario IS NULL OR UPPER(l.propietario) ILIKE '%' || UPPER(p_propietario) || '%')
            AND (p_rfc IS NULL OR UPPER(l.rfc) ILIKE '%' || UPPER(p_rfc) || '%')
            AND (p_giro IS NULL OR UPPER(l.actividad) ILIKE '%' || UPPER(p_giro) || '%')
            AND (p_estado IS NULL OR l.vigente = p_estado)
          ORDER BY l.id_licencia DESC
          LIMIT p_limite OFFSET p_offset;

      END;
      $$ LANGUAGE plpgsql;
    `;

    await pool.query(createSP);
    console.log('✅ SP_CONSULTALICENCIA_LIST updated without hardcoded values');

    // Probar el stored procedure
    console.log('🧪 Testing updated version...');

    // Test sin filtros
    const test1 = await pool.query('SELECT * FROM informix.SP_CONSULTALICENCIA_LIST(NULL, NULL, NULL, NULL, NULL, NULL, 3, 0)');
    console.log(`📋 Resultados: ${test1.rows.length} registros`);
    if (test1.rows.length > 0) {
      console.log(`   Ejemplo: ${test1.rows[0].propietario} - ${test1.rows[0].giro}`);
      console.log(`   Tipo: '${test1.rows[0].tipo_licencia}' (valor directo de DB)`);
      console.log(`   Estado: '${test1.rows[0].estado}' (valor directo de DB)`);
      console.log(`   Total en DB: ${test1.rows[0].total_registros}`);
    }

    // Test con filtro de estado
    console.log('\n🧪 Testing con filtro de estado S...');
    const test2 = await pool.query("SELECT * FROM informix.SP_CONSULTALICENCIA_LIST(NULL, NULL, NULL, NULL, NULL, 'S', 2, 0)");
    console.log(`   Resultados con estado S: ${test2.rows.length} registros`);
    if (test2.rows.length > 0) {
      console.log(`   Total con estado S: ${test2.rows[0].total_registros}`);
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

updateSPWithoutHardcoded();