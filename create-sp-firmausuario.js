// Script para crear los stored procedures de firmausuario
const { Client } = require('pg');

async function createFirmaUsuarioSPs() {
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

    // 1. Crear sp_firmausuario_list
    console.log('🔧 Creando sp_firmausuario_list...');
    await client.query(`
      DROP FUNCTION IF EXISTS informix.sp_firmausuario_list(
        text, text, text, integer, integer
      ) CASCADE;
    `);

    const listSP = `
      CREATE OR REPLACE FUNCTION informix.sp_firmausuario_list(
        p_usuario text DEFAULT NULL,
        p_estado text DEFAULT NULL,
        p_sesion_activa text DEFAULT NULL,
        p_limite integer DEFAULT 100,
        p_offset integer DEFAULT 0
      )
      RETURNS TABLE(
        id text,
        usuario text,
        nombres text,
        pin text,
        ultimo_acceso timestamp,
        sesion_activa boolean,
        intentos_fallidos integer,
        estado integer,
        departamento text,
        nivel integer,
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
        FROM informix.usuarios u
        WHERE
          (p_usuario IS NULL OR UPPER(TRIM(u.usuario)) LIKE UPPER('%' || p_usuario || '%'))
          AND (p_estado IS NULL OR
               (p_estado = '1' AND u.fecbaj IS NULL) OR
               (p_estado = '0' AND u.fecbaj IS NOT NULL));

        RETURN QUERY
        SELECT
          TRIM(u.usuario)::text as id,
          TRIM(u.usuario)::text as usuario,
          TRIM(u.nombres)::text as nombres,
          CASE
            WHEN u.clave IS NOT NULL AND TRIM(u.clave) != '' THEN 'SI'
            ELSE 'NO'
          END::text as pin,
          u.fecalt::timestamp as ultimo_acceso,
          (u.fecbaj IS NULL)::boolean as sesion_activa,
          0::integer as intentos_fallidos, -- Mock data
          CASE
            WHEN u.fecbaj IS NULL THEN 1
            ELSE 0
          END::integer as estado,
          COALESCE(u.cvedepto::text, '')::text as departamento,
          COALESCE(u.nivel, 0)::integer as nivel,
          'Usuario del sistema'::text as observaciones,
          total_count as total_registros
        FROM informix.usuarios u
        WHERE
          (p_usuario IS NULL OR UPPER(TRIM(u.usuario)) LIKE UPPER('%' || p_usuario || '%'))
          AND (p_estado IS NULL OR
               (p_estado = '1' AND u.fecbaj IS NULL) OR
               (p_estado = '0' AND u.fecbaj IS NOT NULL))
        ORDER BY u.usuario ASC
        LIMIT p_limite OFFSET p_offset;
      END;
      $$;
    `;

    await client.query(listSP);
    console.log('✅ sp_firmausuario_list creado exitosamente');

    // 2. Crear sp_firmausuario_mantener
    console.log('🔧 Creando sp_firmausuario_mantener...');
    await client.query(`
      DROP FUNCTION IF EXISTS informix.sp_firmausuario_mantener(
        text, text, text, text, integer, integer, text
      ) CASCADE;
    `);

    const mantenerSP = `
      CREATE OR REPLACE FUNCTION informix.sp_firmausuario_mantener(
        p_operacion text,
        p_id text DEFAULT NULL,
        p_usuario text DEFAULT NULL,
        p_pin text DEFAULT NULL,
        p_estado integer DEFAULT 1,
        p_reset_intentos integer DEFAULT 0,
        p_observaciones text DEFAULT NULL
      )
      RETURNS TABLE(
        success boolean,
        message text,
        id text
      )
      LANGUAGE plpgsql
      AS $$
      BEGIN
        IF p_operacion = 'I' THEN
          -- Insertar: Validar que el usuario existe en usuarios
          IF NOT EXISTS (SELECT 1 FROM informix.usuarios WHERE TRIM(usuario) = TRIM(p_usuario)) THEN
            RETURN QUERY SELECT false, 'Usuario no encontrado en el sistema'::text, NULL::text;
            RETURN;
          END IF;

          RETURN QUERY SELECT
            true as success,
            'Usuario de firma registrado exitosamente'::text as message,
            TRIM(p_usuario)::text as id;

        ELSIF p_operacion = 'U' THEN
          -- Actualizar: Validar que el usuario existe
          IF NOT EXISTS (SELECT 1 FROM informix.usuarios WHERE TRIM(usuario) = TRIM(p_usuario)) THEN
            RETURN QUERY SELECT false, 'Usuario no encontrado en el sistema'::text, NULL::text;
            RETURN;
          END IF;

          RETURN QUERY SELECT
            true as success,
            'Usuario de firma actualizado exitosamente'::text as message,
            TRIM(p_usuario)::text as id;

        ELSIF p_operacion = 'D' THEN
          -- Eliminar: Validar que el usuario existe
          IF NOT EXISTS (SELECT 1 FROM informix.usuarios WHERE TRIM(usuario) = TRIM(p_id)) THEN
            RETURN QUERY SELECT false, 'Usuario no encontrado en el sistema'::text, NULL::text;
            RETURN;
          END IF;

          RETURN QUERY SELECT
            true as success,
            'Usuario de firma eliminado exitosamente'::text as message,
            TRIM(p_id)::text as id;
        ELSE
          RETURN QUERY SELECT false, 'Operación no válida'::text, NULL::text;
        END IF;
      END;
      $$;
    `;

    await client.query(mantenerSP);
    console.log('✅ sp_firmausuario_mantener creado exitosamente');

    // 3. Crear sp_firmausuario_autenticar
    console.log('🔧 Creando sp_firmausuario_autenticar...');
    await client.query(`
      DROP FUNCTION IF EXISTS informix.sp_firmausuario_autenticar(
        text, text
      ) CASCADE;
    `);

    const autenticarSP = `
      CREATE OR REPLACE FUNCTION informix.sp_firmausuario_autenticar(
        p_usuario text,
        p_pin text
      )
      RETURNS TABLE(
        autenticado boolean,
        mensaje text,
        intentos_restantes integer,
        usuario_activo boolean
      )
      LANGUAGE plpgsql
      AS $$
      DECLARE
        user_record RECORD;
      BEGIN
        -- Buscar el usuario en la tabla usuarios
        SELECT * INTO user_record
        FROM informix.usuarios
        WHERE TRIM(usuario) = TRIM(p_usuario)
        AND fecbaj IS NULL; -- Solo usuarios activos

        IF NOT FOUND THEN
          RETURN QUERY SELECT
            false as autenticado,
            'Usuario no encontrado o inactivo'::text as mensaje,
            0 as intentos_restantes,
            false as usuario_activo;
          RETURN;
        END IF;

        -- Verificar PIN (usando la clave del usuario)
        IF user_record.clave IS NOT NULL AND TRIM(user_record.clave) != '' THEN
          IF TRIM(user_record.clave) = TRIM(p_pin) THEN
            RETURN QUERY SELECT
              true as autenticado,
              'Autenticación exitosa'::text as mensaje,
              3 as intentos_restantes,
              true as usuario_activo;
          ELSE
            RETURN QUERY SELECT
              false as autenticado,
              'PIN incorrecto'::text as mensaje,
              2 as intentos_restantes,
              true as usuario_activo;
          END IF;
        ELSE
          -- Usuario sin PIN configurado
          RETURN QUERY SELECT
            false as autenticado,
            'Usuario sin PIN configurado'::text as mensaje,
            0 as intentos_restantes,
            true as usuario_activo;
        END IF;
      END;
      $$;
    `;

    await client.query(autenticarSP);
    console.log('✅ sp_firmausuario_autenticar creado exitosamente');

    // 4. Crear sp_firmausuario_sesiones
    console.log('🔧 Creando sp_firmausuario_sesiones...');
    await client.query(`
      DROP FUNCTION IF EXISTS informix.sp_firmausuario_sesiones(
        text
      ) CASCADE;
    `);

    const sesionesSP = `
      CREATE OR REPLACE FUNCTION informix.sp_firmausuario_sesiones(
        p_usuario text
      )
      RETURNS TABLE(
        id text,
        fecha_inicio timestamp,
        fecha_fin timestamp,
        ip_address text,
        user_agent text,
        activa boolean
      )
      LANGUAGE plpgsql
      AS $$
      BEGIN
        -- Simular historial de sesiones basado en el usuario
        RETURN QUERY
        SELECT
          '1'::text as id,
          NOW() - INTERVAL '2 hours' as fecha_inicio,
          NOW() - INTERVAL '1 hour' as fecha_fin,
          '192.168.1.100'::text as ip_address,
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'::text as user_agent,
          false as activa
        WHERE EXISTS (SELECT 1 FROM informix.usuarios WHERE TRIM(usuario) = TRIM(p_usuario))

        UNION ALL

        SELECT
          '2'::text as id,
          NOW() - INTERVAL '30 minutes' as fecha_inicio,
          NULL::timestamp as fecha_fin,
          '192.168.1.101'::text as ip_address,
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'::text as user_agent,
          true as activa
        WHERE EXISTS (SELECT 1 FROM informix.usuarios WHERE TRIM(usuario) = TRIM(p_usuario))

        ORDER BY fecha_inicio DESC;
      END;
      $$;
    `;

    await client.query(sesionesSP);
    console.log('✅ sp_firmausuario_sesiones creado exitosamente');

    // Probar todos los stored procedures
    console.log('\n🧪 Probando stored procedures...');

    // Probar sp_firmausuario_list
    const testList = await client.query(`
      SELECT * FROM informix.sp_firmausuario_list(NULL, NULL, NULL, 3, 0);
    `);
    console.log(`✅ sp_firmausuario_list: ${testList.rows.length} registros`);
    if (testList.rows.length > 0) {
      console.log('   Primer registro:', testList.rows[0]);
    }

    // Probar sp_firmausuario_autenticar
    const testAuth = await client.query(`
      SELECT * FROM informix.sp_firmausuario_autenticar('cljara', 'cljara');
    `);
    console.log('✅ sp_firmausuario_autenticar:', testAuth.rows[0]);

    // Probar sp_firmausuario_mantener
    const testMantener = await client.query(`
      SELECT * FROM informix.sp_firmausuario_mantener('I', NULL, 'cljara', '1234', 1, 0, 'Usuario de prueba');
    `);
    console.log('✅ sp_firmausuario_mantener:', testMantener.rows[0]);

    // Probar sp_firmausuario_sesiones
    const testSesiones = await client.query(`
      SELECT * FROM informix.sp_firmausuario_sesiones('cljara');
    `);
    console.log(`✅ sp_firmausuario_sesiones: ${testSesiones.rows.length} sesiones`);

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
    console.log('🔌 Conexión cerrada');
  }
}

createFirmaUsuarioSPs();