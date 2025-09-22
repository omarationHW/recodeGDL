// Script para corregir el mapeo de campos en sp_dictamen_list
const { Client } = require('pg');

async function fixDictamenListSP() {
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

    // Crear el stored procedure sp_dictamen_list con campos corregidos
    console.log('🔧 Creando sp_dictamen_list con campos corregidos...');
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
        id integer,
        anuncio integer,
        propietarionvo text,
        clasificacion text,
        ubicacion text,
        numext_ubic text,
        letraext_ubic text,
        colonia_ubic text,
        medidas1 double precision,
        medidas2 double precision,
        area_anuncio double precision,
        num_caras integer,
        texto_anuncio text,
        vigente text,
        fecha_otorgamiento date,
        capturista text,
        id_giro integer,
        id_licencia integer,
        cp text
      )
      LANGUAGE plpgsql
      AS $$
      BEGIN
        RETURN QUERY
        SELECT
          d.id_dictamen as id,
          d.id_dictamen as anuncio,
          TRIM(d.propietario)::text as propietarionvo,
          TRIM(d.actividad)::text as clasificacion,
          TRIM(d.domicilio)::text as ubicacion,
          TRIM(d.no_exterior)::text as numext_ubic,
          TRIM(d.no_interior)::text as letraext_ubic,
          ''::text as colonia_ubic,
          d.supconst as medidas1,
          d.area_util as medidas2,
          d.area_util as area_anuncio,
          COALESCE(d.num_cajones, 1) as num_caras,
          TRIM(d.uso_suelo)::text as texto_anuncio,
          CASE
            WHEN TRIM(d.dictamen) = '1' THEN 'V'
            ELSE 'I'
          END::text as vigente,
          d.fecha as fecha_otorgamiento,
          TRIM(d.capturista)::text as capturista,
          d.id_giro,
          d.id_dictamen as id_licencia,
          TRIM(d.no_exterior)::text as cp
        FROM informix.dictamenes d
        WHERE
          (p_anuncio IS NULL OR d.id_dictamen = p_anuncio)
          AND (p_propietario IS NULL OR UPPER(TRIM(d.propietario)) LIKE UPPER('%' || p_propietario || '%'))
          AND (p_clasificacion IS NULL OR UPPER(TRIM(d.actividad)) LIKE UPPER('%' || p_clasificacion || '%'))
          AND (p_ubicacion IS NULL OR UPPER(TRIM(d.domicilio)) LIKE UPPER('%' || p_ubicacion || '%'))
          AND (p_vigente IS NULL OR
               (p_vigente = 'V' AND TRIM(d.dictamen) = '1') OR
               (p_vigente = 'I' AND TRIM(d.dictamen) != '1'))
        ORDER BY d.id_dictamen DESC
        LIMIT p_limite OFFSET p_offset;
      END;
      $$;
    `;

    await client.query(createSP);
    console.log('✅ sp_dictamen_list corregido exitosamente');

    // Probar el stored procedure
    console.log('🧪 Probando sp_dictamen_list corregido...');
    const testResult = await client.query(`
      SELECT * FROM informix.sp_dictamen_list(
        NULL, NULL, NULL, NULL, NULL, 5, 0
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

fixDictamenListSP();