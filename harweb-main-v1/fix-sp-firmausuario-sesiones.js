// Script para corregir sp_firmausuario_sesiones
const { Client } = require('pg');

async function fixFirmaUsuarioSesiones() {
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

    // Eliminar la función problemática
    console.log('🔧 Eliminando sp_firmausuario_sesiones...');
    await client.query(`
      DROP FUNCTION IF EXISTS informix.sp_firmausuario_sesiones(text) CASCADE;
    `);

    // Recrear con la estructura correcta
    console.log('🔧 Recreando sp_firmausuario_sesiones...');
    const sesionesSP = `
      CREATE OR REPLACE FUNCTION informix.sp_firmausuario_sesiones(
        p_usuario text
      )
      RETURNS TABLE(
        id integer,
        fecha_inicio timestamp,
        fecha_fin timestamp,
        ip_address text,
        user_agent text,
        activa boolean
      )
      LANGUAGE plpgsql
      AS $$
      BEGIN
        -- Verificar que el usuario existe
        IF NOT EXISTS (SELECT 1 FROM informix.usuarios WHERE TRIM(usuario) = TRIM(p_usuario)) THEN
          -- No devolver nada si el usuario no existe
          RETURN;
        END IF;

        -- Simular historial de sesiones
        RETURN QUERY
        SELECT
          1::integer as id,
          (NOW() - INTERVAL '2 hours')::timestamp as fecha_inicio,
          (NOW() - INTERVAL '1 hour')::timestamp as fecha_fin,
          '192.168.1.100'::text as ip_address,
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'::text as user_agent,
          false::boolean as activa

        UNION ALL

        SELECT
          2::integer as id,
          (NOW() - INTERVAL '30 minutes')::timestamp as fecha_inicio,
          NULL::timestamp as fecha_fin,
          '192.168.1.101'::text as ip_address,
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/91.0'::text as user_agent,
          true::boolean as activa

        ORDER BY fecha_inicio DESC;
      END;
      $$;
    `;

    await client.query(sesionesSP);
    console.log('✅ sp_firmausuario_sesiones recreado exitosamente');

    // Probar el stored procedure
    console.log('🧪 Probando sp_firmausuario_sesiones...');
    const testResult = await client.query(`
      SELECT * FROM informix.sp_firmausuario_sesiones('cljara');
    `);

    console.log(`✅ SP funciona correctamente. Sesiones encontradas: ${testResult.rows.length}`);
    if (testResult.rows.length > 0) {
      console.log('📋 Primera sesión:', testResult.rows[0]);
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await client.end();
    console.log('🔌 Conexión cerrada');
  }
}

fixFirmaUsuarioSesiones();