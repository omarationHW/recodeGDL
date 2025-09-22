// Script para crear el stored procedure sp_dictamen_list
const { Client } = require('pg');

async function createDictamenListSP() {
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
    console.log('🔧 Eliminando sp_dictamen_list si existe...');
    await client.query(`
      DROP FUNCTION IF EXISTS informix.sp_dictamen_list(
        integer, text, text, text, text, integer, integer
      ) CASCADE;
    `);

    // Crear el stored procedure sp_dictamen_list
    console.log('🔧 Creando sp_dictamen_list...');
    const createSP = `
      CREATE OR REPLACE FUNCTION informix.sp_dictamen_list(
        p_anuncio integer DEFAULT NULL,
        p_propietario text DEFAULT NULL,
        p_clasificacion text DEFAULT NULL,
        p_ubicacion text DEFAULT NULL,
        p_vigente text DEFAULT NULL,
        p_limite integer DEFAULT 100,
        p_offset integer DEFAULT 0
      )
      RETURNS TABLE(
        id_dictamen integer,
        id_giro integer,
        propietario text,
        domicilio text,
        no_exterior text,
        no_interior text,
        supconst double precision,
        area_util double precision,
        num_cajones integer,
        actividad text,
        uso_suelo text,
        desc_uso text,
        zona integer,
        subzona integer,
        dictamen text,
        capturista text,
        fecha date
      )
      LANGUAGE plpgsql
      AS $$
      BEGIN
        RETURN QUERY
        SELECT
          d.id_dictamen,
          d.id_giro,
          TRIM(d.propietario)::text as propietario,
          TRIM(d.domicilio)::text as domicilio,
          TRIM(d.no_exterior)::text as no_exterior,
          TRIM(d.no_interior)::text as no_interior,
          d.supconst,
          d.area_util,
          d.num_cajones,
          TRIM(d.actividad)::text as actividad,
          TRIM(d.uso_suelo)::text as uso_suelo,
          TRIM(d.desc_uso)::text as desc_uso,
          d.zona,
          d.subzona,
          TRIM(d.dictamen)::text as dictamen,
          TRIM(d.capturista)::text as capturista,
          d.fecha
        FROM informix.dictamenes d
        WHERE
          (p_anuncio IS NULL OR d.id_dictamen = p_anuncio)
          AND (p_propietario IS NULL OR UPPER(TRIM(d.propietario)) LIKE UPPER('%' || p_propietario || '%'))
          AND (p_clasificacion IS NULL OR UPPER(TRIM(d.actividad)) LIKE UPPER('%' || p_clasificacion || '%'))
          AND (p_ubicacion IS NULL OR UPPER(TRIM(d.domicilio)) LIKE UPPER('%' || p_ubicacion || '%'))
          AND (p_vigente IS NULL OR p_vigente = 'V')
        ORDER BY d.id_dictamen DESC
        LIMIT p_limite OFFSET p_offset;
      END;
      $$;
    `;

    await client.query(createSP);
    console.log('✅ sp_dictamen_list creado exitosamente');

    // Probar el stored procedure
    console.log('🧪 Probando sp_dictamen_list...');
    const testResult = await client.query(`
      SELECT * FROM informix.sp_dictamen_list(
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

createDictamenListSP();