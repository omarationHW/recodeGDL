// Script para crear el stored procedure sp_documentos_list
const { Client } = require('pg');

async function createDocumentosListSP() {
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
    console.log('🔧 Eliminando sp_documentos_list si existe...');
    await client.query(`
      DROP FUNCTION IF EXISTS informix.sp_documentos_list(
        text, text, text, integer, integer
      ) CASCADE;
    `);

    // Crear el stored procedure sp_documentos_list
    console.log('🔧 Creando sp_documentos_list...');
    const createSP = `
      CREATE OR REPLACE FUNCTION informix.sp_documentos_list(
        p_codigo text DEFAULT NULL,
        p_descripcion text DEFAULT NULL,
        p_activo text DEFAULT NULL,
        p_limite integer DEFAULT 100,
        p_offset integer DEFAULT 0
      )
      RETURNS TABLE(
        id integer,
        codigo text,
        descripcion text,
        obligatorio text,
        orden integer,
        activo text,
        observaciones text,
        fecha_registro date,
        capturista text,
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
        FROM informix.c_doctos cd
        WHERE
          (p_codigo IS NULL OR CAST(cd.cvedocto AS TEXT) LIKE '%' || p_codigo || '%')
          AND (p_descripcion IS NULL OR UPPER(TRIM(cd.documento)) LIKE UPPER('%' || p_descripcion || '%'))
          AND (p_activo IS NULL OR 'S' = p_activo); -- Todos los documentos en c_doctos se consideran activos

        RETURN QUERY
        SELECT
          cd.cvedocto as id,
          CAST(cd.cvedocto AS TEXT) as codigo,
          TRIM(cd.documento)::text as descripcion,
          'S'::text as obligatorio, -- Por defecto todos son obligatorios
          cd.cvedocto as orden,
          'S'::text as activo, -- Todos los documentos en la tabla se consideran activos
          ''::text as observaciones,
          cd.feccap as fecha_registro,
          TRIM(cd.capturista)::text as capturista,
          total_count as total_registros
        FROM informix.c_doctos cd
        WHERE
          (p_codigo IS NULL OR CAST(cd.cvedocto AS TEXT) LIKE '%' || p_codigo || '%')
          AND (p_descripcion IS NULL OR UPPER(TRIM(cd.documento)) LIKE UPPER('%' || p_descripcion || '%'))
          AND (p_activo IS NULL OR 'S' = p_activo)
        ORDER BY cd.cvedocto ASC
        LIMIT p_limite OFFSET p_offset;
      END;
      $$;
    `;

    await client.query(createSP);
    console.log('✅ sp_documentos_list creado exitosamente');

    // Probar el stored procedure
    console.log('🧪 Probando sp_documentos_list...');
    const testResult = await client.query(`
      SELECT * FROM informix.sp_documentos_list(
        NULL, NULL, NULL, 5, 0
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

createDocumentosListSP();