#!/usr/bin/env node

/**
 * Generador Automático de Stored Procedures en Batch
 * Genera SPs basándose en las tablas de la BD y patrones CRUD
 */

const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const dbConfig = {
  host: '192.168.6.146',
  port: 5432,
  database: 'padron_licencias',
  user: 'refact',
  password: 'FF)-BQk2',
};

// Batch #2: Siguientes 10 SPs IMPORTANTES
const BATCH_2_SPS = [
  {
    name: 'sp_solicnooficial_create',
    type: 'CREATE',
    table: 'solicnooficial',
    pk: 'axo',
    description: 'Crea nueva solicitud no oficial'
  },
  {
    name: 'sp_solicnooficial_update',
    type: 'UPDATE',
    table: 'solicnooficial',
    pk: 'axo',
    description: 'Actualiza solicitud no oficial'
  },
  {
    name: 'sp_solicnooficial_cancel',
    type: 'DELETE',
    table: 'solicnooficial',
    pk: 'axo',
    description: 'Cancela solicitud no oficial'
  },
  {
    name: 'sp_dependencias_create',
    type: 'CREATE',
    table: 'c_dependencias',
    pk: 'id',
    description: 'Crea nueva dependencia'
  },
  {
    name: 'sp_dependencias_update',
    type: 'UPDATE',
    table: 'c_dependencias',
    pk: 'id',
    description: 'Actualiza dependencia'
  },
  {
    name: 'sp_dependencias_delete',
    type: 'DELETE',
    table: 'c_dependencias',
    pk: 'id',
    description: 'Elimina dependencia'
  },
  {
    name: 'sp_dictamenes_create',
    type: 'CREATE',
    table: 'dictamenes',
    pk: 'id',
    description: 'Crea nuevo dictamen'
  },
  {
    name: 'sp_dictamenes_update',
    type: 'UPDATE',
    table: 'dictamenes',
    pk: 'id',
    description: 'Actualiza dictamen'
  },
  {
    name: 'sp_create_constancia',
    type: 'CREATE',
    table: 'constancias',
    pk: 'axo',
    description: 'Crea nueva constancia'
  },
  {
    name: 'sp_update_constancia',
    type: 'UPDATE',
    table: 'constancias',
    pk: 'axo',
    description: 'Actualiza constancia'
  }
];

// Batch #1: 10 SPs IMPORTANTES prioritarios (YA COMPLETADO)
const BATCH_1_SPS = [
  {
    name: 'sp_get_giro_by_id',
    type: 'READ',
    table: 'c_giros',
    pk: 'id_giro',
    description: 'Obtiene información de un giro por ID'
  },
  {
    name: 'sp_cancel_tramite',
    type: 'UPDATE',
    table: 'h_tramites',
    pk: 'id_tramite',
    description: 'Cancela un trámite (marca estatus como cancelado)'
  },
  {
    name: 'carga_delete_predio',
    type: 'DELETE',
    table: 'catastro',
    pk: 'cvecuenta',
    description: 'Elimina información de predio de la carga temporal'
  },
  {
    name: 'sp_save_cargadatos',
    type: 'CREATE',
    table: 'catastro',
    pk: 'cvecuenta',
    description: 'Guarda datos de carga temporal de predios'
  },
  {
    name: 'carga_imagen_sp_delete_document_image',
    type: 'DELETE',
    table: 'digital_docs',
    pk: 'id_imagen',
    description: 'Elimina imagen de documento digital'
  },
  {
    name: 'sp_catalogo_actividades_create',
    type: 'CREATE',
    table: 'c_actividades_lic',
    pk: 'id_actividad',
    description: 'Crea nueva actividad en catálogo'
  },
  {
    name: 'sp_catalogo_actividades_update',
    type: 'UPDATE',
    table: 'c_actividades_lic',
    pk: 'id_actividad',
    description: 'Actualiza actividad existente'
  },
  {
    name: 'sp_catalogo_actividades_delete',
    type: 'DELETE',
    table: 'c_actividades_lic',
    pk: 'id_actividad',
    description: 'Elimina/inactiva actividad del catálogo'
  },
  {
    name: 'sp_catalogogiros_create',
    type: 'CREATE',
    table: 'c_giros',
    pk: 'id_giro',
    description: 'Crea nuevo giro en catálogo'
  },
  {
    name: 'sp_catalogogiros_update',
    type: 'UPDATE',
    table: 'c_giros',
    pk: 'id_giro',
    description: 'Actualiza giro existente'
  }
];

async function getTableColumns(client, tableName) {
  // Buscar tabla en múltiples esquemas
  const schemas = ['public', 'comun', 'catastro_gdl', 'informix'];

  for (const schema of schemas) {
    const query = `
      SELECT
        column_name,
        data_type,
        character_maximum_length,
        is_nullable,
        column_default
      FROM information_schema.columns
      WHERE table_schema = $1
        AND table_name = $2
      ORDER BY ordinal_position;
    `;

    const result = await client.query(query, [schema, tableName]);

    if (result.rows.length > 0) {
      return { schema, columns: result.rows };
    }
  }

  return { schema: null, columns: [] };
}

function generateReadSP(spDef, columns) {
  const pkCol = columns.find(c => c.column_name === spDef.pk);
  const pkType = pkCol ? pkCol.data_type.toUpperCase() : 'INTEGER';

  const returnCols = columns.map(c => {
    const type = c.character_maximum_length
      ? `CHARACTER VARYING(${c.character_maximum_length})`
      : c.data_type.toUpperCase();
    return `    ${c.column_name} ${type}`;
  }).join(',\n');

  const selectCols = columns.map(c => `        t.${c.column_name}`).join(',\n');

  return `-- ============================================================
-- SP: ${spDef.name}
-- ============================================================
-- Descripción: ${spDef.description}
-- Tabla: ${spDef.table}
-- Tipo: ${spDef.type}
-- ============================================================

CREATE OR REPLACE FUNCTION ${spDef.name}(
    p_${spDef.pk} ${pkType}
)
RETURNS TABLE (
${returnCols}
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
${selectCols}
    FROM ${spDef.table} t
    WHERE t.${spDef.pk} = p_${spDef.pk};
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION ${spDef.name}(${pkType}) IS
'${spDef.description}. Tabla: ${spDef.table}';
`;
}

function generateCreateSP(spDef, columns) {
  const insertCols = columns
    .filter(c => c.column_default === null || !c.column_default.includes('nextval'))
    .map(c => c.column_name);

  const params = insertCols.map(col => {
    const colDef = columns.find(c => c.column_name === col);
    const type = colDef.character_maximum_length
      ? `CHARACTER VARYING(${colDef.character_maximum_length})`
      : colDef.data_type.toUpperCase();
    return `    p_${col} ${type}`;
  }).join(',\n');

  const colList = insertCols.join(', ');
  const valList = insertCols.map(c => `p_${c}`).join(', ');

  return `-- ============================================================
-- SP: ${spDef.name}
-- ============================================================
-- Descripción: ${spDef.description}
-- Tabla: ${spDef.table}
-- Tipo: ${spDef.type}
-- ============================================================

CREATE OR REPLACE FUNCTION ${spDef.name}(
${params}
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    ${spDef.pk} INTEGER
)
AS $$
DECLARE
    v_new_id INTEGER;
BEGIN
    INSERT INTO ${spDef.table} (${colList})
    VALUES (${valList})
    RETURNING ${spDef.pk} INTO v_new_id;

    RETURN QUERY SELECT TRUE, 'Registro creado exitosamente'::TEXT, v_new_id;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM::TEXT, NULL::INTEGER;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION ${spDef.name} IS
'${spDef.description}. Tabla: ${spDef.table}';
`;
}

function generateUpdateSP(spDef, columns) {
  const updateCols = columns
    .filter(c => c.column_name !== spDef.pk)
    .map(c => c.column_name);

  const params = columns.map(col => {
    const colDef = columns.find(c => c.column_name === col.column_name);
    const type = colDef.character_maximum_length
      ? `CHARACTER VARYING(${colDef.character_maximum_length})`
      : colDef.data_type.toUpperCase();
    return `    p_${col.column_name} ${type}`;
  }).join(',\n');

  const setClause = updateCols.map(c => `        ${c} = p_${c}`).join(',\n');

  return `-- ============================================================
-- SP: ${spDef.name}
-- ============================================================
-- Descripción: ${spDef.description}
-- Tabla: ${spDef.table}
-- Tipo: ${spDef.type}
-- ============================================================

CREATE OR REPLACE FUNCTION ${spDef.name}(
${params}
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
AS $$
BEGIN
    UPDATE ${spDef.table}
    SET
${setClause}
    WHERE ${spDef.pk} = p_${spDef.pk};

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Registro actualizado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Registro no encontrado'::TEXT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION ${spDef.name} IS
'${spDef.description}. Tabla: ${spDef.table}';
`;
}

function generateDeleteSP(spDef, columns) {
  const pkCol = columns.find(c => c.column_name === spDef.pk);
  const pkType = pkCol ? pkCol.data_type.toUpperCase() : 'INTEGER';

  // Verificar si la tabla tiene campo "vigente"
  const hasVigente = columns.some(c => c.column_name === 'vigente');

  const deleteLogic = hasVigente
    ? `UPDATE ${spDef.table}
    SET vigente = '0'
    WHERE ${spDef.pk} = p_${spDef.pk};`
    : `DELETE FROM ${spDef.table}
    WHERE ${spDef.pk} = p_${spDef.pk};`;

  return `-- ============================================================
-- SP: ${spDef.name}
-- ============================================================
-- Descripción: ${spDef.description}
-- Tabla: ${spDef.table}
-- Tipo: ${spDef.type}
-- ============================================================

CREATE OR REPLACE FUNCTION ${spDef.name}(
    p_${spDef.pk} ${pkType}
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
AS $$
BEGIN
    ${deleteLogic}

    IF FOUND THEN
        RETURN QUERY SELECT TRUE, 'Registro eliminado exitosamente'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Registro no encontrado'::TEXT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN QUERY SELECT FALSE, SQLERRM::TEXT;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION ${spDef.name}(${pkType}) IS
'${spDef.description}. Tabla: ${spDef.table}';
`;
}

async function generateBatchSQL(batchNumber = 1) {
  const client = new Client(dbConfig);

  // Seleccionar el batch correcto
  const batches = {
    1: { sps: BATCH_1_SPS, from: 68, to: 78 },
    2: { sps: BATCH_2_SPS, from: 78, to: 88 }
  };

  const selectedBatch = batches[batchNumber];
  if (!selectedBatch) {
    throw new Error(`Batch ${batchNumber} no encontrado`);
  }

  try {
    await client.connect();
    console.log('✅ Conectado a la base de datos\n');

    const fromPct = ((selectedBatch.from / 312) * 100).toFixed(1);
    const toPct = ((selectedBatch.to / 312) * 100).toFixed(1);

    let sqlContent = `-- ============================================================
-- DEPLOY BATCH #${batchNumber}: 10 SPs IMPORTANTES
-- Base de datos: padron_licencias
-- Fecha: ${new Date().toISOString().split('T')[0]}
-- ============================================================
--
-- Este script crea el BATCH #${batchNumber} de 10 Stored Procedures IMPORTANTES
-- Progreso: De ${selectedBatch.from}/312 (${fromPct}%) → ${selectedBatch.to}/312 (${toPct}%)
--
-- ============================================================

`;

    for (const spDef of selectedBatch.sps) {
      console.log(`📋 Generando ${spDef.name} (${spDef.type})...`);

      const { schema, columns } = await getTableColumns(client, spDef.table);

      if (columns.length === 0) {
        console.log(`   ⚠️  Tabla ${spDef.table} no encontrada, generando SP genérico...`);
        sqlContent += `-- NOTA: Tabla ${spDef.table} no encontrada, requiere implementación manual\n\n`;
        continue;
      }

      console.log(`   ✅ Tabla encontrada: ${schema}.${spDef.table} (${columns.length} columnas)`);

      // Actualizar nombre de tabla con esquema
      const fullTableName = `${schema}.${spDef.table}`;

      let spSQL;
      switch (spDef.type) {
        case 'READ':
          spSQL = generateReadSP({ ...spDef, table: fullTableName }, columns);
          break;
        case 'CREATE':
          spSQL = generateCreateSP({ ...spDef, table: fullTableName }, columns);
          break;
        case 'UPDATE':
          spSQL = generateUpdateSP({ ...spDef, table: fullTableName }, columns);
          break;
        case 'DELETE':
          spSQL = generateDeleteSP({ ...spDef, table: fullTableName }, columns);
          break;
      }

      sqlContent += spSQL + '\n\n';
    }

    // Agregar verificación al final
    sqlContent += `-- ============================================================
-- VERIFICACIÓN DE CREACIÓN
-- ============================================================

SELECT
    routine_schema,
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_name IN (
    'sp_get_giro_by_id',
    'sp_cancel_tramite',
    'carga_delete_predio',
    'sp_save_cargadatos',
    'carga_imagen_sp_delete_document_image',
    'sp_catalogo_actividades_create',
    'sp_catalogo_actividades_update',
    'sp_catalogo_actividades_delete',
    'sp_catalogogiros_create',
    'sp_catalogogiros_update'
)
AND routine_schema = 'public'
ORDER BY routine_name;

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
`;

    // Guardar archivo
    const batchStr = String(batchNumber).padStart(2, '0');
    const outputPath = path.join(
      __dirname,
      '..',
      '..',
      'Base',
      'padron_licencias',
      'database',
      'deploy',
      `DEPLOY_BATCH_${batchStr}_IMPORTANT.sql`
    );

    fs.writeFileSync(outputPath, sqlContent, 'utf8');

    console.log(`\n✅ Script SQL generado: ${outputPath}\n`);
    console.log(`📊 Total de SPs generados: ${selectedBatch.sps.length}`);

  } catch (error) {
    console.error('❌ Error:', error.message);
    throw error;
  } finally {
    await client.end();
  }
}

if (require.main === module) {
  const batchNumber = parseInt(process.argv[2]) || 1;
  generateBatchSQL(batchNumber)
    .then(() => {
      console.log('\n✅ Generación completada\n');
      process.exit(0);
    })
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
}

module.exports = { generateBatchSQL };
