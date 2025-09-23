// Script para crear el stored procedure sp_empresas_list
const { Client } = require('pg');

async function createEmpresasListSP() {
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
    console.log('🔧 Eliminando sp_empresas_list si existe...');
    await client.query(`
      DROP FUNCTION IF EXISTS informix.sp_empresas_list(
        text, text, text, text, integer, integer
      ) CASCADE;
    `);

    // Crear el stored procedure sp_empresas_list basado en apptp_adquirientes
    console.log('🔧 Creando sp_empresas_list...');
    const createSP = `
      CREATE OR REPLACE FUNCTION informix.sp_empresas_list(
        p_rfc text DEFAULT NULL,
        p_razon_social text DEFAULT NULL,
        p_nombre_comercial text DEFAULT NULL,
        p_activo text DEFAULT NULL,
        p_limite integer DEFAULT 100,
        p_offset integer DEFAULT 0
      )
      RETURNS TABLE(
        id text,
        rfc text,
        razon_social text,
        nombre_comercial text,
        telefono text,
        email text,
        direccion text,
        genero text,
        activo text,
        observaciones text,
        total_registros integer
      )
      LANGUAGE plpgsql
      AS $$
      DECLARE
        total_count integer;
      BEGIN
        -- Contar el total de registros que coinciden con los filtros
        SELECT COUNT(DISTINCT TRIM(a.rfc))
        INTO total_count
        FROM informix.apptp_adquirientes a
        WHERE
          TRIM(a.rfc) IS NOT NULL
          AND TRIM(a.rfc) != ''
          AND (p_rfc IS NULL OR UPPER(TRIM(a.rfc)) LIKE UPPER('%' || p_rfc || '%'))
          AND (p_razon_social IS NULL OR
               (a.razonsocial IS NOT NULL AND TRIM(a.razonsocial) != '' AND
                UPPER(TRIM(a.razonsocial)) LIKE UPPER('%' || p_razon_social || '%')) OR
               (a.nombres IS NOT NULL AND TRIM(a.nombres) != '' AND
                UPPER(TRIM(a.nombres)) LIKE UPPER('%' || p_razon_social || '%')))
          AND (p_nombre_comercial IS NULL OR
               (a.razonsocial IS NOT NULL AND TRIM(a.razonsocial) != '' AND
                UPPER(TRIM(a.razonsocial)) LIKE UPPER('%' || p_nombre_comercial || '%')));

        RETURN QUERY
        SELECT DISTINCT
          a.id::text as id,
          TRIM(a.rfc)::text as rfc,
          CASE
            WHEN a.razonsocial IS NOT NULL AND TRIM(a.razonsocial) != ''
            THEN TRIM(a.razonsocial)::text
            ELSE TRIM(a.nombres)::text
          END as razon_social,
          CASE
            WHEN a.razonsocial IS NOT NULL AND TRIM(a.razonsocial) != ''
            THEN TRIM(a.nombres)::text
            ELSE ''::text
          END as nombre_comercial,
          COALESCE(TRIM(a.telefono), '')::text as telefono,
          COALESCE(TRIM(a.correo), '')::text as email,
          CASE
            WHEN a.noexterior IS NOT NULL AND TRIM(a.noexterior) != ''
            THEN TRIM(a.noexterior) || ' ' || COALESCE(TRIM(a.colonia), '')
            ELSE COALESCE(TRIM(a.colonia), '')
          END::text as direccion,
          CASE
            WHEN a.tipo = 'F' THEN 'HOMBRE'
            WHEN a.tipo = 'M' THEN 'SOCIEDAD'
            ELSE 'HOMBRE'
          END::text as genero,
          'S'::text as activo, -- Asumimos que están activos si están en la tabla
          ''::text as observaciones, -- Campo vacío para observaciones
          total_count as total_registros
        FROM informix.apptp_adquirientes a
        WHERE
          TRIM(a.rfc) IS NOT NULL
          AND TRIM(a.rfc) != ''
          AND (p_rfc IS NULL OR UPPER(TRIM(a.rfc)) LIKE UPPER('%' || p_rfc || '%'))
          AND (p_razon_social IS NULL OR
               (a.razonsocial IS NOT NULL AND TRIM(a.razonsocial) != '' AND
                UPPER(TRIM(a.razonsocial)) LIKE UPPER('%' || p_razon_social || '%')) OR
               (a.nombres IS NOT NULL AND TRIM(a.nombres) != '' AND
                UPPER(TRIM(a.nombres)) LIKE UPPER('%' || p_razon_social || '%')))
          AND (p_nombre_comercial IS NULL OR
               (a.razonsocial IS NOT NULL AND TRIM(a.razonsocial) != '' AND
                UPPER(TRIM(a.razonsocial)) LIKE UPPER('%' || p_nombre_comercial || '%')))
        ORDER BY
          CASE
            WHEN a.razonsocial IS NOT NULL AND TRIM(a.razonsocial) != ''
            THEN TRIM(a.razonsocial)
            ELSE TRIM(a.nombres)
          END ASC
        LIMIT p_limite OFFSET p_offset;
      END;
      $$;
    `;

    await client.query(createSP);
    console.log('✅ sp_empresas_list creado exitosamente');

    // Probar el stored procedure
    console.log('🧪 Probando sp_empresas_list...');
    const testResult = await client.query(`
      SELECT * FROM informix.sp_empresas_list(
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

createEmpresasListSP();