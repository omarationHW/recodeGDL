// Script para crear el stored procedure sp_dependencias_list
const { Client } = require('pg');

async function createDependenciasListSP() {
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
    console.log('🔧 Eliminando sp_dependencias_list si existe...');
    await client.query(`
      DROP FUNCTION IF EXISTS informix.sp_dependencias_list(
        text, text, text, text, integer, integer
      ) CASCADE;
    `);

    // Crear el stored procedure sp_dependencias_list
    console.log('🔧 Creando sp_dependencias_list...');
    const createSP = `
      CREATE OR REPLACE FUNCTION informix.sp_dependencias_list(
        p_codigo text DEFAULT NULL,
        p_nombre text DEFAULT NULL,
        p_descripcion text DEFAULT NULL,
        p_activo text DEFAULT NULL,
        p_limite integer DEFAULT 100,
        p_offset integer DEFAULT 0
      )
      RETURNS TABLE(
        id_dependencia integer,
        codigo text,
        nombre text,
        descripcion text,
        tipo text,
        abrevia text,
        activo text,
        vigencia text,
        feccap date,
        capturista text
      )
      LANGUAGE plpgsql
      AS $$
      BEGIN
        RETURN QUERY
        SELECT
          d.id_dependencia,
          TRIM(d.id_dependencia::text)::text as codigo,
          TRIM(d.descripcion)::text as nombre,
          TRIM(d.descripcion)::text as descripcion,
          TRIM(d.tipo)::text as tipo,
          TRIM(d.abrevia)::text as abrevia,
          CASE
            WHEN TRIM(d.vigencia) = 'V' THEN 'S'
            ELSE 'N'
          END::text as activo,
          TRIM(d.vigencia)::text as vigencia,
          d.feccap,
          TRIM(d.capturista)::text as capturista
        FROM informix.c_dependencias d
        WHERE
          (p_codigo IS NULL OR TRIM(d.id_dependencia::text) ILIKE '%' || p_codigo || '%'
           OR TRIM(d.abrevia) ILIKE '%' || p_codigo || '%')
          AND (p_nombre IS NULL OR UPPER(TRIM(d.descripcion)) LIKE UPPER('%' || p_nombre || '%'))
          AND (p_descripcion IS NULL OR UPPER(TRIM(d.descripcion)) LIKE UPPER('%' || p_descripcion || '%'))
          AND (p_activo IS NULL OR
               (p_activo = 'S' AND TRIM(d.vigencia) = 'V') OR
               (p_activo = 'N' AND TRIM(d.vigencia) != 'V'))
        ORDER BY d.id_dependencia
        LIMIT p_limite OFFSET p_offset;
      END;
      $$;
    `;

    await client.query(createSP);
    console.log('✅ sp_dependencias_list creado exitosamente');

    // Probar el stored procedure
    console.log('🧪 Probando sp_dependencias_list...');
    const testResult = await client.query(`
      SELECT * FROM informix.sp_dependencias_list(
        NULL, NULL, NULL, NULL, 10, 0
      );
    `);

    console.log(`✅ SP funciona correctamente. Registros encontrados: ${testResult.rows.length}`);
    if (testResult.rows.length > 0) {
      console.log('📋 Primer registro:', testResult.rows[0]);
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
    console.log('🔌 Conexión cerrada');
  }
}

createDependenciasListSP();