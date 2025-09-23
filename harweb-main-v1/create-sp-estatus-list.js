// Script para crear el stored procedure sp_estatus_list
const { Client } = require('pg');

async function createEstatusListSP() {
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

    // Primero verificar si existe y eliminarlo
    console.log('🔧 Eliminando sp_estatus_list si existe...');
    await client.query(`
      DROP FUNCTION IF EXISTS informix.sp_estatus_list(
        text, text, text, text, integer, integer
      ) CASCADE;
    `);

    // Crear el stored procedure sp_estatus_list basado en c_aplicaciones
    console.log('🔧 Creando sp_estatus_list...');
    const createSP = `
      CREATE OR REPLACE FUNCTION informix.sp_estatus_list(
        p_codigo text DEFAULT NULL,
        p_descripcion text DEFAULT NULL,
        p_activo text DEFAULT NULL,
        p_color text DEFAULT NULL,
        p_limite integer DEFAULT 100,
        p_offset integer DEFAULT 0
      )
      RETURNS TABLE(
        id text,
        codigo text,
        descripcion text,
        color text,
        orden integer,
        activo text,
        created_at date,
        observaciones text,
        total_registros integer
      )
      LANGUAGE plpgsql
      AS $$
      DECLARE
        total_count integer;
      BEGIN
        -- Contar el total de registros que coinciden con los filtros
        SELECT COUNT(*)
        INTO total_count
        FROM informix.c_aplicaciones a
        WHERE
          (p_codigo IS NULL OR UPPER(TRIM(CAST(a.cveapl AS TEXT))) LIKE UPPER('%' || p_codigo || '%'))
          AND (p_descripcion IS NULL OR UPPER(TRIM(a.nombre)) LIKE UPPER('%' || p_descripcion || '%'))
          AND (p_activo IS NULL OR
               (p_activo = 'A' AND a.permite_acceso = 'S') OR
               (p_activo = 'I' AND a.permite_acceso = 'N'));

        RETURN QUERY
        SELECT
          CAST(a.cveapl AS TEXT) as id,
          CAST(a.cveapl AS TEXT) as codigo,
          TRIM(a.nombre)::text as descripcion,
          CASE
            WHEN a.permite_acceso = 'S' THEN '#28a745'
            ELSE '#dc3545'
          END::text as color,
          a.cveapl as orden,
          CASE
            WHEN a.permite_acceso = 'S' THEN 'A'
            ELSE 'I'
          END::text as activo,
          a.feccap as created_at,
          COALESCE(TRIM(a.descripcion), '')::text as observaciones,
          total_count as total_registros
        FROM informix.c_aplicaciones a
        WHERE
          (p_codigo IS NULL OR UPPER(TRIM(CAST(a.cveapl AS TEXT))) LIKE UPPER('%' || p_codigo || '%'))
          AND (p_descripcion IS NULL OR UPPER(TRIM(a.nombre)) LIKE UPPER('%' || p_descripcion || '%'))
          AND (p_activo IS NULL OR
               (p_activo = 'A' AND a.permite_acceso = 'S') OR
               (p_activo = 'I' AND a.permite_acceso = 'N'))
        ORDER BY a.cveapl ASC
        LIMIT p_limite OFFSET p_offset;
      END;
      $$;
    `;

    await client.query(createSP);
    console.log('✅ sp_estatus_list creado exitosamente');

    // Probar el stored procedure
    console.log('🧪 Probando sp_estatus_list...');
    const testResult = await client.query(`
      SELECT * FROM informix.sp_estatus_list(
        NULL, NULL, NULL, NULL, 5, 0
      );
    `);

    console.log(`✅ SP funciona correctamente. Registros encontrados: ${testResult.rows.length}`);
    if (testResult.rows.length > 0) {
      console.log('📋 Primer registro:', testResult.rows[0]);
      console.log('📋 Campos del primer registro:');
      Object.keys(testResult.rows[0]).forEach(key => {
        console.log(`  ${key}: ${testResult.rows[0][key]}`);
      });
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
    console.log('🔌 Conexión cerrada');
  }
}

createEstatusListSP();