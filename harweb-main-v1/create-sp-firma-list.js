// Script para crear el stored procedure sp_firma_list
const { Client } = require('pg');

async function createFirmaListSP() {
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
    console.log('🔧 Eliminando sp_firma_list si existe...');
    await client.query(`
      DROP FUNCTION IF EXISTS informix.sp_firma_list(
        text, text, text, integer, integer
      ) CASCADE;
    `);

    // Crear el stored procedure sp_firma_list basado en usuarios
    console.log('🔧 Creando sp_firma_list...');
    const createSP = `
      CREATE OR REPLACE FUNCTION informix.sp_firma_list(
        p_usuario text DEFAULT NULL,
        p_estado text DEFAULT NULL,
        p_nivel text DEFAULT NULL,
        p_limite integer DEFAULT 100,
        p_offset integer DEFAULT 0
      )
      RETURNS TABLE(
        id text,
        usuario text,
        nombre text,
        departamento text,
        nivel integer,
        estado text,
        fecha_alta date,
        fecha_baja date,
        activo text,
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
        FROM informix.usuarios u
        WHERE
          (p_usuario IS NULL OR UPPER(TRIM(u.usuario)) LIKE UPPER('%' || p_usuario || '%'))
          AND (p_estado IS NULL OR
               (p_estado = 'A' AND u.fecbaj IS NULL) OR
               (p_estado = 'I' AND u.fecbaj IS NOT NULL))
          AND (p_nivel IS NULL OR u.nivel::text = p_nivel);

        RETURN QUERY
        SELECT
          TRIM(u.usuario)::text as id,
          TRIM(u.usuario)::text as usuario,
          TRIM(u.nombres)::text as nombre,
          COALESCE(u.cvedepto::text, '')::text as departamento,
          COALESCE(u.nivel, 0) as nivel,
          CASE
            WHEN u.fecbaj IS NULL THEN 'A'
            ELSE 'I'
          END::text as estado,
          u.fecalt as fecha_alta,
          u.fecbaj as fecha_baja,
          CASE
            WHEN u.fecbaj IS NULL THEN 'S'
            ELSE 'N'
          END::text as activo,
          total_count as total_registros
        FROM informix.usuarios u
        WHERE
          (p_usuario IS NULL OR UPPER(TRIM(u.usuario)) LIKE UPPER('%' || p_usuario || '%'))
          AND (p_estado IS NULL OR
               (p_estado = 'A' AND u.fecbaj IS NULL) OR
               (p_estado = 'I' AND u.fecbaj IS NOT NULL))
          AND (p_nivel IS NULL OR u.nivel::text = p_nivel)
        ORDER BY u.usuario ASC
        LIMIT p_limite OFFSET p_offset;
      END;
      $$;
    `;

    await client.query(createSP);
    console.log('✅ sp_firma_list creado exitosamente');

    // Probar el stored procedure
    console.log('🧪 Probando sp_firma_list...');
    const testResult = await client.query(`
      SELECT * FROM informix.sp_firma_list(
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

createFirmaListSP();