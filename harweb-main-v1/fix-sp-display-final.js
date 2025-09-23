const { Pool } = require('pg');

// Configuración de la base de datos
const pool = new Pool({
  user: 'refact',
  host: '192.168.6.146',
  database: 'padron_licencias',
  password: 'FF)-BQk2',
  port: 5432,
});

async function fixDisplayStoredProcedure() {
  try {
    console.log('🔧 Fixing SP_CONSULTALICENCIA_LIST display formatting...');

    // Eliminar stored procedure existente
    console.log('🗑️ Dropping existing SP...');
    const dropSP = `DROP FUNCTION IF EXISTS informix.sp_consultalicencia_list(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER);`;
    await pool.query(dropSP);
    console.log('✅ Dropped existing SP');

    // Crear stored procedure con formateo correcto y TRIM para quitar espacios
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
            AND (p_propietario IS NULL OR UPPER(TRIM(l.propietario)) ILIKE '%' || UPPER(p_propietario) || '%')
            AND (p_rfc IS NULL OR UPPER(TRIM(l.rfc)) ILIKE '%' || UPPER(p_rfc) || '%')
            AND (p_giro IS NULL OR UPPER(TRIM(l.actividad)) ILIKE '%' || UPPER(p_giro) || '%')
            AND (p_estado IS NULL OR TRIM(l.vigente) = p_estado);

          -- Retornar resultados con formato limpio y completo
          RETURN QUERY
          SELECT
              l.id_licencia::INTEGER as id,
              COALESCE(CAST(l.licencia AS VARCHAR(100)), '')::VARCHAR(100) as numero_licencia,
              COALESCE(CAST(l.id_licencia AS VARCHAR(100)), '')::VARCHAR(100) as folio,
              COALESCE(TRIM(l.tipo_registro), '')::VARCHAR(50) as tipo_licencia,
              COALESCE(TRIM(l.propietario), '')::VARCHAR(255) as propietario,
              COALESCE(TRIM(l.rfc), '')::VARCHAR(20) as rfc,
              (COALESCE(TRIM(l.ubicacion), '') ||
               CASE WHEN l.numext_ubic IS NOT NULL THEN ' #' || CAST(l.numext_ubic AS TEXT) ELSE '' END ||
               CASE WHEN TRIM(l.letraext_ubic) IS NOT NULL AND TRIM(l.letraext_ubic) != '' THEN '-' || TRIM(l.letraext_ubic) ELSE '' END ||
               CASE WHEN TRIM(l.numint_ubic) IS NOT NULL AND TRIM(l.numint_ubic) != '' THEN ' INT. ' || TRIM(l.numint_ubic) ELSE '' END ||
               CASE WHEN TRIM(l.colonia_ubic) IS NOT NULL AND TRIM(l.colonia_ubic) != '' THEN ', ' || TRIM(l.colonia_ubic) ELSE '' END)::TEXT as direccion,
              COALESCE(TRIM(l.actividad), '')::VARCHAR(255) as giro,
              COALESCE(TRIM(l.vigente), '')::VARCHAR(20) as estado,
              total_count::BIGINT as total_registros
          FROM informix.licenciasleyenda l
          WHERE 1=1
            AND (p_numero_licencia IS NULL OR CAST(l.licencia AS TEXT) ILIKE '%' || p_numero_licencia || '%')
            AND (p_propietario IS NULL OR UPPER(TRIM(l.propietario)) ILIKE '%' || UPPER(p_propietario) || '%')
            AND (p_rfc IS NULL OR UPPER(TRIM(l.rfc)) ILIKE '%' || UPPER(p_rfc) || '%')
            AND (p_giro IS NULL OR UPPER(TRIM(l.actividad)) ILIKE '%' || UPPER(p_giro) || '%')
            AND (p_estado IS NULL OR TRIM(l.vigente) = p_estado)
          ORDER BY l.id_licencia DESC
          LIMIT p_limite OFFSET p_offset;

      END;
      $$ LANGUAGE plpgsql;
    `;

    await pool.query(createSP);
    console.log('✅ SP_CONSULTALICENCIA_LIST fixed with proper formatting');

    // Probar el stored procedure
    console.log('🧪 Testing fixed version...');

    // Test sin filtros
    const test1 = await pool.query('SELECT * FROM informix.SP_CONSULTALICENCIA_LIST(NULL, NULL, NULL, NULL, NULL, NULL, 3, 0)');
    console.log(`📋 Resultados: ${test1.rows.length} registros`);
    if (test1.rows.length > 0) {
      console.log('\n📄 Ejemplo con formato corregido:');
      const ejemplo = test1.rows[0];
      console.log(`   ID: ${ejemplo.id}`);
      console.log(`   Número: ${ejemplo.numero_licencia}`);
      console.log(`   Propietario: "${ejemplo.propietario}"`);
      console.log(`   RFC: "${ejemplo.rfc}"`);
      console.log(`   Dirección: "${ejemplo.direccion}"`);
      console.log(`   Giro: "${ejemplo.giro}"`);
      console.log(`   Tipo: "${ejemplo.tipo_licencia}"`);
      console.log(`   Estado: "${ejemplo.estado}"`);
      console.log(`   Total: ${ejemplo.total_registros}`);
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

fixDisplayStoredProcedure();