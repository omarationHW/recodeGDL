// Script para corregir el stored procedure sp_empleados_list
const { Client } = require('pg');

async function fixEmpleadosListSP() {
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
    console.log('🔧 Eliminando sp_empleados_list si existe...');
    await client.query(`
      DROP FUNCTION IF EXISTS informix.sp_empleados_list(
        text, text, text, integer, integer
      ) CASCADE;
    `);

    // Crear el stored procedure sp_empleados_list corregido
    console.log('🔧 Creando sp_empleados_list corregido...');
    const createSP = `
      CREATE OR REPLACE FUNCTION informix.sp_empleados_list(
        p_nombre text DEFAULT NULL,
        p_correo text DEFAULT NULL,
        p_activo text DEFAULT NULL,
        p_limite integer DEFAULT 100,
        p_offset integer DEFAULT 0
      )
      RETURNS TABLE(
        id text,
        nombre text,
        correo text,
        departamento integer,
        activo text,
        observaciones text,
        created_at date,
        nivel smallint,
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
          (p_nombre IS NULL OR UPPER(TRIM(u.nombres)) LIKE UPPER('%' || p_nombre || '%'))
          AND (p_correo IS NULL OR UPPER(TRIM(u.usuario)) LIKE UPPER('%' || p_correo || '%'))
          AND (p_activo IS NULL OR
               (p_activo = 'S' AND u.fecbaj IS NULL) OR
               (p_activo = 'N' AND u.fecbaj IS NOT NULL));

        RETURN QUERY
        SELECT
          TRIM(u.usuario)::text as id,
          TRIM(u.nombres)::text as nombre,
          TRIM(u.usuario)::text as correo, -- Usando usuario como correo ya que no hay campo email
          u.cvedepto as departamento,
          CASE
            WHEN u.fecbaj IS NULL THEN 'S'
            ELSE 'N'
          END::text as activo,
          ''::text as observaciones, -- Campo vacío ya que no existe en la tabla original
          u.fecalt as created_at,
          u.nivel as nivel,
          total_count as total_registros
        FROM informix.usuarios u
        WHERE
          (p_nombre IS NULL OR UPPER(TRIM(u.nombres)) LIKE UPPER('%' || p_nombre || '%'))
          AND (p_correo IS NULL OR UPPER(TRIM(u.usuario)) LIKE UPPER('%' || p_correo || '%'))
          AND (p_activo IS NULL OR
               (p_activo = 'S' AND u.fecbaj IS NULL) OR
               (p_activo = 'N' AND u.fecbaj IS NOT NULL))
        ORDER BY u.fecalt DESC, u.usuario ASC
        LIMIT p_limite OFFSET p_offset;
      END;
      $$;
    `;

    await client.query(createSP);
    console.log('✅ sp_empleados_list corregido exitosamente');

    // Probar el stored procedure
    console.log('🧪 Probando sp_empleados_list corregido...');
    const testResult = await client.query(`
      SELECT * FROM informix.sp_empleados_list(
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

fixEmpleadosListSP();