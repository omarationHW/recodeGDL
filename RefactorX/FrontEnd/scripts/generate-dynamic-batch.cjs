#!/usr/bin/env node

/**
 * Generador Dinámico de Batches desde JSON
 * Lee sp-audit-complete.json y genera batches automáticamente
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

// Mapeo de nombres de SP a definiciones de tabla
const SP_TO_TABLE_MAP = {
  // Patrón: nombre_sp -> { table, pk, type }
  'sp_get_': { type: 'READ' },
  'sp_list_': { type: 'READ' },
  'sp_create_': { type: 'CREATE' },
  'sp_update_': { type: 'UPDATE' },
  'sp_delete_': { type: 'DELETE' },
  'sp_cancel_': { type: 'UPDATE' }, // Cancel es un UPDATE que marca como cancelado
  '_create': { type: 'CREATE' },
  '_update': { type: 'UPDATE' },
  '_delete': { type: 'DELETE' },
  '_list': { type: 'READ' },
};

function inferSPType(spName) {
  for (const [pattern, def] of Object.entries(SP_TO_TABLE_MAP)) {
    if (spName.includes(pattern)) {
      return def.type;
    }
  }
  return 'READ'; // Por defecto
}

function inferTableName(spName) {
  // Extraer nombre de tabla del nombre del SP
  // Ejemplos:
  // sp_doctos_create -> c_doctos
  // sp_get_empresa -> empresas
  // certificaciones_create -> certificaciones

  let tableName = spName;

  // Remover prefijos comunes
  tableName = tableName.replace(/^sp_/, '');
  tableName = tableName.replace(/^get_/, '');
  tableName = tableName.replace(/^list_/, '');

  // Remover sufijos comunes
  tableName = tableName.replace(/_create$/, '');
  tableName = tableName.replace(/_update$/, '');
  tableName = tableName.replace(/_delete$/, '');
  tableName = tableName.replace(/_cancel$/, '');
  tableName = tableName.replace(/_list$/, '');
  tableName = tableName.replace(/_by_id$/, '');

  // Casos especiales
  const tableMap = {
    'giro': 'c_giros',
    'actividad': 'c_actividades_lic',
    'tramite': 'h_tramites',
    'licencia': 'h_licencias',
    'anuncio': 'h_anuncios',
    'empresa': 'empresasfrm',
    'dependencia': 'c_dependencias',
    'docto': 'c_doctos',
    'dictamen': 'dictamenes',
    'constancia': 'constancias',
    'certificacion': 'certificaciones',
    'responsiva': 'responsivas',
  };

  for (const [key, value] of Object.entries(tableMap)) {
    if (tableName.includes(key)) {
      return value;
    }
  }

  // Si tiene prefijo c_ o h_ ya es nombre de tabla
  if (tableName.startsWith('c_') || tableName.startsWith('h_')) {
    return tableName;
  }

  // Por defecto, agregar c_ para catálogos
  return `c_${tableName}`;
}

function loadSPsFromJSON() {
  const jsonPath = path.join(__dirname, 'sp-audit-results', 'sp-audit-complete.json');
  const data = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

  const allSPs = [];

  // Agregar SPs importantes
  if (data.classification && data.classification.importantList) {
    data.classification.importantList.forEach(sp => {
      if (!sp.exists) {
        allSPs.push({
          name: sp.name,
          priority: sp.priority || 50,
          tier: 'IMPORTANT'
        });
      }
    });
  }

  // Agregar SPs opcionales
  if (data.classification && data.classification.optionalList) {
    data.classification.optionalList.forEach(sp => {
      if (!sp.exists) {
        allSPs.push({
          name: sp.name,
          priority: sp.priority || 25,
          tier: 'OPTIONAL'
        });
      }
    });
  }

  return allSPs.sort((a, b) => b.priority - a.priority);
}

function createBatchDefinitions(allSPs, batchSize = 10) {
  const batches = [];
  let currentBatch = [];
  let batchNumber = 3; // Empezamos desde el batch 3 (ya hicimos 1 y 2)
  let spCount = 78; // SPs actuales en BD (después de batch 1 y 2)

  // Saltar los primeros 20 SPs (ya fueron procesados en batch 1 y 2)
  const remainingSPs = allSPs.slice(20);

  remainingSPs.forEach((sp, index) => {
    const spDef = {
      name: sp.name,
      type: inferSPType(sp.name),
      table: inferTableName(sp.name),
      pk: 'id',
      description: `Operación ${inferSPType(sp.name)} para ${sp.name}`,
      priority: sp.priority,
      tier: sp.tier
    };

    currentBatch.push(spDef);

    if (currentBatch.length === batchSize || index === remainingSPs.length - 1) {
      batches.push({
        number: batchNumber,
        sps: [...currentBatch],
        from: spCount,
        to: spCount + currentBatch.length,
        tier: currentBatch[0].tier
      });

      spCount += currentBatch.length;
      batchNumber++;
      currentBatch = [];
    }
  });

  return batches;
}

async function getTableColumns(client, tableName) {
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

// Funciones de generación de SQL (copiadas del script anterior)
function generateReadSP(spDef, columns) {
  const pkCol = columns.find(c => c.column_name === spDef.pk) || columns[0];
  const pkType = pkCol ? pkCol.data_type.toUpperCase() : 'INTEGER';

  const returnCols = columns.map(c => {
    const type = c.character_maximum_length
      ? `CHARACTER VARYING(${c.character_maximum_length})`
      : c.data_type.toUpperCase();
    return `    ${c.column_name} ${type}`;
  }).join(',\n');

  const selectCols = columns.map(c => `        t.${c.column_name}`).join(',\n');

  return `-- SP: ${spDef.name} (${spDef.description})
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
`;
}

function generateGenericCRUDSP(spDef) {
  // Para tablas no encontradas, generar un stub básico
  return `-- SP: ${spDef.name} (${spDef.description})
-- NOTA: Tabla ${spDef.table} no encontrada, requiere implementación manual
CREATE OR REPLACE FUNCTION ${spDef.name}()
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
)
AS $$
BEGIN
    -- TODO: Implementar lógica del SP
    RETURN QUERY SELECT TRUE, 'SP stub - requiere implementación'::TEXT;
END;
$$ LANGUAGE plpgsql;
`;
}

async function generateBatchSQL(batchNumber) {
  const client = new Client(dbConfig);

  try {
    await client.connect();
    console.log(`\n✅ Conectado a la base de datos\n`);

    // Cargar todos los SPs del JSON
    const allSPs = loadSPsFromJSON();
    console.log(`📋 Total de SPs por procesar: ${allSPs.length}\n`);

    // Crear definiciones de batches
    const batches = createBatchDefinitions(allSPs);

    // Buscar el batch solicitado
    const batch = batches.find(b => b.number === batchNumber);

    if (!batch) {
      throw new Error(`Batch #${batchNumber} no encontrado. Rango válido: 3-${batches.length + 2}`);
    }

    console.log(`📦 Procesando BATCH #${batchNumber} (${batch.tier})`);
    console.log(`📊 Progreso: ${batch.from} → ${batch.to} SPs\n`);

    let sqlContent = `-- ============================================================
-- DEPLOY BATCH #${batchNumber}: ${batch.sps.length} SPs ${batch.tier}
-- Base de datos: padron_licencias
-- Fecha: ${new Date().toISOString().split('T')[0]}
-- ============================================================

`;

    for (const spDef of batch.sps) {
      console.log(`   🔧 ${spDef.name} (${spDef.type})`);

      const { schema, columns } = await getTableColumns(client, spDef.table);

      if (columns.length > 0) {
        const fullTableName = `${schema}.${spDef.table}`;
        sqlContent += generateReadSP({ ...spDef, table: fullTableName }, columns) + '\n\n';
      } else {
        sqlContent += generateGenericCRUDSP(spDef) + '\n\n';
      }
    }

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
      `DEPLOY_BATCH_${batchStr}_${batch.tier}.sql`
    );

    fs.writeFileSync(outputPath, sqlContent, 'utf8');

    console.log(`\n✅ Script generado: DEPLOY_BATCH_${batchStr}_${batch.tier}.sql`);
    console.log(`📊 Total de SPs: ${batch.sps.length}\n`);

  } catch (error) {
    console.error('❌ Error:', error.message);
    throw error;
  } finally {
    await client.end();
  }
}

if (require.main === module) {
  const batchNumber = parseInt(process.argv[2]) || 3;
  generateBatchSQL(batchNumber)
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
}

module.exports = { generateBatchSQL, loadSPsFromJSON, createBatchDefinitions };
