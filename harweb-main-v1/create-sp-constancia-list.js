// Script para crear el stored procedure sp_constancia_list
const { Client } = require('pg');

async function createConstanciaListSP() {
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
    console.log('🔧 Eliminando sp_constancia_list si existe...');
    await client.query(`
      DROP FUNCTION IF EXISTS informix.sp_constancia_list(
        integer, integer, text, text, text, integer, integer
      ) CASCADE;
    `);

    // Crear el stored procedure sp_constancia_list
    console.log('🔧 Creando sp_constancia_list...');
    const createSP = `
      CREATE OR REPLACE FUNCTION informix.sp_constancia_list(
        p_axo integer DEFAULT NULL,
        p_folio integer DEFAULT NULL,
        p_solicita text DEFAULT NULL,
        p_partidapago text DEFAULT NULL,
        p_vigente text DEFAULT NULL,
        p_limite integer DEFAULT 100,
        p_offset integer DEFAULT 0
      )
      RETURNS TABLE(
        axo integer,
        folio integer,
        id_licencia integer,
        solicita text,
        partidapago text,
        domicilio text,
        tipo smallint,
        observacion text,
        vigente text,
        feccap date,
        capturista text
      )
      LANGUAGE plpgsql
      AS $$
      BEGIN
        RETURN QUERY
        SELECT
          c.axo,
          c.folio,
          c.id_licencia,
          TRIM(c.solicita)::text as solicita,
          TRIM(c.partidapago)::text as partidapago,
          TRIM(c.domicilio)::text as domicilio,
          c.tipo,
          TRIM(c.observacion)::text as observacion,
          TRIM(c.vigente)::text as vigente,
          c.feccap,
          TRIM(c.capturista)::text as capturista
        FROM informix.constancias c
        WHERE
          (p_axo IS NULL OR c.axo = p_axo)
          AND (p_folio IS NULL OR c.folio = p_folio)
          AND (p_solicita IS NULL OR UPPER(TRIM(c.solicita)) LIKE UPPER('%' || p_solicita || '%'))
          AND (p_partidapago IS NULL OR UPPER(TRIM(c.partidapago)) LIKE UPPER('%' || p_partidapago || '%'))
          AND (p_vigente IS NULL OR TRIM(c.vigente) = p_vigente)
        ORDER BY c.axo DESC, c.folio DESC
        LIMIT p_limite OFFSET p_offset;
      END;
      $$;
    `;

    await client.query(createSP);
    console.log('✅ sp_constancia_list creado exitosamente');

    // Probar el stored procedure
    console.log('🧪 Probando sp_constancia_list...');
    const testResult = await client.query(`
      SELECT * FROM informix.sp_constancia_list(
        NULL, NULL, NULL, NULL, NULL, 10, 0
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

createConstanciaListSP();