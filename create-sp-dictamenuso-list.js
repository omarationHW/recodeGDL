// Script para crear el stored procedure sp_dictamenuso_list
const { Client } = require('pg');

async function createDictamenUsoListSP() {
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
    console.log('🔧 Eliminando sp_dictamenuso_list si existe...');
    await client.query(`
      DROP FUNCTION IF EXISTS informix.sp_dictamenuso_list(
        integer, integer, text, integer, text, date, date, integer, integer
      ) CASCADE;
    `);

    // Crear el stored procedure sp_dictamenuso_list
    console.log('🔧 Creando sp_dictamenuso_list...');
    const createSP = `
      CREATE OR REPLACE FUNCTION informix.sp_dictamenuso_list(
        p_axo integer DEFAULT NULL,
        p_folio integer DEFAULT NULL,
        p_solicita text DEFAULT NULL,
        p_licencia integer DEFAULT NULL,
        p_vigente text DEFAULT NULL,
        p_fecha_ini date DEFAULT NULL,
        p_fecha_fin date DEFAULT NULL,
        p_limite integer DEFAULT 100,
        p_offset integer DEFAULT 0
      )
      RETURNS TABLE(
        id integer,
        axo integer,
        folio integer,
        solicita text,
        partidapago text,
        domicilio text,
        tipo smallint,
        observacion text,
        vigente text,
        feccap date,
        capturista text,
        id_licencia integer,
        fecha_otorgamiento date,
        estado_solicitud text
      )
      LANGUAGE plpgsql
      AS $$
      BEGIN
        RETURN QUERY
        SELECT
          c.axo as id,
          c.axo,
          c.folio,
          TRIM(c.solicita)::text as solicita,
          TRIM(c.partidapago)::text as partidapago,
          TRIM(c.domicilio)::text as domicilio,
          c.tipo,
          TRIM(c.observacion)::text as observacion,
          CASE
            WHEN TRIM(c.vigente) = 'V' THEN 'V'
            WHEN TRIM(c.vigente) = 'C' THEN 'C'
            ELSE 'I'
          END::text as vigente,
          c.feccap,
          TRIM(c.capturista)::text as capturista,
          c.id_licencia,
          c.feccap as fecha_otorgamiento,
          CASE
            WHEN TRIM(c.vigente) = 'V' THEN 'Vigente'
            WHEN TRIM(c.vigente) = 'C' THEN 'Cancelado'
            ELSE 'Inactivo'
          END::text as estado_solicitud
        FROM informix.constancias c
        WHERE
          (p_axo IS NULL OR c.axo = p_axo)
          AND (p_folio IS NULL OR c.folio = p_folio)
          AND (p_solicita IS NULL OR UPPER(TRIM(c.solicita)) LIKE UPPER('%' || p_solicita || '%'))
          AND (p_licencia IS NULL OR c.id_licencia = p_licencia)
          AND (p_vigente IS NULL OR TRIM(c.vigente) = p_vigente)
          AND (p_fecha_ini IS NULL OR c.feccap >= p_fecha_ini)
          AND (p_fecha_fin IS NULL OR c.feccap <= p_fecha_fin)
        ORDER BY c.axo DESC, c.folio DESC
        LIMIT p_limite OFFSET p_offset;
      END;
      $$;
    `;

    await client.query(createSP);
    console.log('✅ sp_dictamenuso_list creado exitosamente');

    // Probar el stored procedure
    console.log('🧪 Probando sp_dictamenuso_list...');
    const testResult = await client.query(`
      SELECT * FROM informix.sp_dictamenuso_list(
        NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5, 0
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

createDictamenUsoListSP();