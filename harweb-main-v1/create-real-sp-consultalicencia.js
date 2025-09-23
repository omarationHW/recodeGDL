const { Pool } = require('pg');

// Configuración de la base de datos
const pool = new Pool({
  user: 'refact',
  host: '192.168.6.146',
  database: 'padron_licencias',
  password: 'FF)-BQk2',
  port: 5432,
});

async function createRealStoredProcedure() {
  try {
    console.log('🔧 Creating real SP_CONSULTALICENCIA_LIST from database...');

    // Eliminar stored procedure existente
    console.log('🗑️ Dropping existing SP...');
    const dropSP = `DROP FUNCTION IF EXISTS informix.sp_consultalicencia_list(VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER);`;
    await pool.query(dropSP);
    console.log('✅ Dropped existing SP');

    // Crear stored procedure real que consulta licenciasleyenda
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
          base_query TEXT;
          count_query TEXT;
          where_conditions TEXT := '';
      BEGIN
          -- Construir condiciones WHERE dinámicamente
          IF p_numero_licencia IS NOT NULL AND p_numero_licencia != '' THEN
              where_conditions := where_conditions || ' AND CAST(l.licencia AS TEXT) ILIKE ''%' || p_numero_licencia || '%''';
          END IF;

          IF p_propietario IS NOT NULL AND p_propietario != '' THEN
              where_conditions := where_conditions || ' AND UPPER(l.propietario) ILIKE ''%' || UPPER(p_propietario) || '%''';
          END IF;

          IF p_rfc IS NOT NULL AND p_rfc != '' THEN
              where_conditions := where_conditions || ' AND UPPER(l.rfc) ILIKE ''%' || UPPER(p_rfc) || '%''';
          END IF;

          IF p_giro IS NOT NULL AND p_giro != '' THEN
              where_conditions := where_conditions || ' AND UPPER(l.actividad) ILIKE ''%' || UPPER(p_giro) || '%''';
          END IF;

          IF p_estado IS NOT NULL AND p_estado != '' THEN
              where_conditions := where_conditions || ' AND UPPER(l.vigente) = ''' || UPPER(p_estado) || '''';
          END IF;

          -- Contar total de registros
          count_query := 'SELECT COUNT(*) FROM informix.licenciasleyenda l WHERE 1=1' || where_conditions;
          EXECUTE count_query INTO total_count;

          -- Consulta principal con paginación
          base_query := '
              SELECT
                  l.id_licencia as id,
                  CAST(l.licencia AS VARCHAR(100)) as numero_licencia,
                  CAST(l.id_licencia AS VARCHAR(100)) as folio,
                  CASE
                      WHEN l.tipo_registro = ''C'' THEN ''COMERCIAL''
                      WHEN l.tipo_registro = ''I'' THEN ''INDUSTRIAL''
                      WHEN l.tipo_registro = ''S'' THEN ''SERVICIOS''
                      ELSE ''OTRO''
                  END as tipo_licencia,
                  COALESCE(l.propietario, '''') as propietario,
                  COALESCE(l.rfc, '''') as rfc,
                  COALESCE(l.ubicacion, '''') ||
                  CASE
                      WHEN l.numext_ubic IS NOT NULL THEN '' #'' || CAST(l.numext_ubic AS TEXT)
                      ELSE ''''
                  END ||
                  CASE
                      WHEN l.colonia_ubic IS NOT NULL THEN '', '' || l.colonia_ubic
                      ELSE ''''
                  END as direccion,
                  COALESCE(l.actividad, '''') as giro,
                  CASE
                      WHEN l.vigente = ''S'' THEN ''VIGENTE''
                      WHEN l.vigente = ''N'' THEN ''NO VIGENTE''
                      ELSE ''PENDIENTE''
                  END as estado,
                  ' || total_count || ' as total_registros
              FROM informix.licenciasleyenda l
              WHERE 1=1' || where_conditions || '
              ORDER BY l.id_licencia DESC
              LIMIT ' || p_limite || ' OFFSET ' || p_offset;

          -- Ejecutar y retornar resultados
          RETURN QUERY EXECUTE base_query;

      END;
      $$ LANGUAGE plpgsql;
    `;

    await pool.query(createSP);
    console.log('✅ Real SP_CONSULTALICENCIA_LIST created successfully');

    // Probar el stored procedure con datos reales
    console.log('🧪 Testing with real data...');

    // Test 1: Sin filtros
    console.log('📋 Test 1: Sin filtros (primeros 5 registros)');
    const test1 = await pool.query('SELECT * FROM informix.SP_CONSULTALICENCIA_LIST(NULL, NULL, NULL, NULL, NULL, NULL, 5, 0)');
    console.log(`   Resultados: ${test1.rows.length} registros`);
    if (test1.rows.length > 0) {
      console.log(`   Ejemplo: ${test1.rows[0].propietario} - ${test1.rows[0].giro}`);
      console.log(`   Total en DB: ${test1.rows[0].total_registros}`);
    }

    // Test 2: Con filtro de propietario
    console.log('📋 Test 2: Buscar propietarios con "JUAN"');
    const test2 = await pool.query("SELECT * FROM informix.SP_CONSULTALICENCIA_LIST(NULL, 'JUAN', NULL, NULL, NULL, NULL, 3, 0)");
    console.log(`   Resultados: ${test2.rows.length} registros`);
    if (test2.rows.length > 0) {
      console.log(`   Ejemplo: ${test2.rows[0].propietario}`);
    }

    // Test 3: Con filtro de estado vigente
    console.log('📋 Test 3: Licencias vigentes');
    const test3 = await pool.query("SELECT * FROM informix.SP_CONSULTALICENCIA_LIST(NULL, NULL, NULL, NULL, NULL, 'S', 3, 0)");
    console.log(`   Resultados: ${test3.rows.length} registros`);
    if (test3.rows.length > 0) {
      console.log(`   Total vigentes: ${test3.rows[0].total_registros}`);
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

createRealStoredProcedure();