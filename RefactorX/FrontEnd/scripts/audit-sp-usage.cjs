#!/usr/bin/env node

/**
 * Script de Auditoría de Uso de Stored Procedures
 *
 * Analiza:
 * 1. Qué SPs se usan en cada componente
 * 2. Frecuencia de uso de cada SP
 * 3. Contexto de uso (CRUD operations, reports, etc.)
 * 4. Prioridad basada en uso
 * 5. Genera templates SQL para SPs faltantes
 */

const fs = require('fs');
const path = require('path');

const COMPONENTS_DIR = path.join(__dirname, '..', 'src', 'views', 'modules', 'padron_licencias');
const OUTPUT_DIR = path.join(__dirname, 'sp-audit-results');
const TEMPLATES_DIR = path.join(OUTPUT_DIR, 'sql-templates');

// Cargar resultados de validación de BD
const DB_VALIDATION = require('./sp-database-test-report.json');

const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  magenta: '\x1b[35m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

// Crear directorios si no existen
if (!fs.existsSync(OUTPUT_DIR)) fs.mkdirSync(OUTPUT_DIR, { recursive: true });
if (!fs.existsSync(TEMPLATES_DIR)) fs.mkdirSync(TEMPLATES_DIR, { recursive: true });

// ==================== ANÁLISIS DE USO ====================

function analyzeComponentUsage(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const fileName = path.basename(filePath, '.vue');

  const spUsages = [];
  const executePattern = /execute\s*\(\s*['"`]([^'"`]+)['"`]\s*,\s*['"`]([^'"`]+)['"`]\s*,\s*\[([^\]]*)\]/g;

  let match;
  while ((match = executePattern.exec(content)) !== null) {
    const spName = match[1].toLowerCase();
    const module = match[2];
    const paramsRaw = match[3];
    const lineNumber = content.substring(0, match.index).split('\n').length;

    // Extraer contexto (función que lo llama)
    const beforeContext = content.substring(Math.max(0, match.index - 500), match.index);
    const functionMatch = beforeContext.match(/(?:const|async function)\s+(\w+)/);
    const callingFunction = functionMatch ? functionMatch[1] : 'unknown';

    // Determinar tipo de operación
    let operationType = 'QUERY';
    if (spName.includes('create') || spName.includes('insert') || spName.includes('save')) operationType = 'CREATE';
    else if (spName.includes('update') || spName.includes('edit') || spName.includes('modify')) operationType = 'UPDATE';
    else if (spName.includes('delete') || spName.includes('remove') || spName.includes('cancel')) operationType = 'DELETE';
    else if (spName.includes('list') || spName.includes('get') || spName.includes('search') || spName.includes('consulta')) operationType = 'READ';
    else if (spName.includes('report') || spName.includes('reporte') || spName.includes('estadistica')) operationType = 'REPORT';

    // Extraer parámetros
    const params = [];
    const paramMatches = paramsRaw.matchAll(/nombre:\s*['"`]([^'"`]+)['"`]/g);
    for (const pm of paramMatches) {
      params.push(pm[1]);
    }

    spUsages.push({
      sp: spName,
      module,
      line: lineNumber,
      function: callingFunction,
      operation: operationType,
      params,
      component: fileName
    });
  }

  return spUsages;
}

function analyzeAllComponents() {
  log('\n📂 Analizando uso de SPs en componentes...', 'cyan');

  const files = fs.readdirSync(COMPONENTS_DIR)
    .filter(file => file.endsWith('.vue') && !file.endsWith('.bak'));

  const allUsages = [];
  const spStats = new Map();

  files.forEach(file => {
    const filePath = path.join(COMPONENTS_DIR, file);
    const usages = analyzeComponentUsage(filePath);

    usages.forEach(usage => {
      allUsages.push(usage);

      if (!spStats.has(usage.sp)) {
        spStats.set(usage.sp, {
          name: usage.sp,
          usageCount: 0,
          components: new Set(),
          operations: new Set(),
          parameters: new Set(),
          exists: false,
          priority: 0
        });
      }

      const stats = spStats.get(usage.sp);
      stats.usageCount++;
      stats.components.add(usage.component);
      stats.operations.add(usage.operation);
      usage.params.forEach(p => stats.parameters.add(p));
    });
  });

  // Verificar cuáles existen en BD
  DB_VALIDATION.sps.forEach(sp => {
    if (sp.exists && spStats.has(sp.name)) {
      spStats.get(sp.name).exists = true;
    }
  });

  // Calcular prioridad
  spStats.forEach((stats, spName) => {
    let priority = 0;

    // +10 puntos por cada uso
    priority += stats.usageCount * 10;

    // +50 puntos si es CREATE/UPDATE/DELETE (operaciones críticas)
    if (stats.operations.has('CREATE')) priority += 50;
    if (stats.operations.has('UPDATE')) priority += 50;
    if (stats.operations.has('DELETE')) priority += 50;

    // +20 puntos por cada componente que lo usa
    priority += stats.components.size * 20;

    // -1000 puntos si ya existe (no necesita crearse)
    if (stats.exists) priority = -1000;

    stats.priority = priority;
  });

  return { allUsages, spStats };
}

// ==================== CLASIFICACIÓN ====================

function classifySPs(spStats) {
  const spsArray = Array.from(spStats.values());

  const missing = spsArray.filter(sp => !sp.exists);
  const existing = spsArray.filter(sp => sp.exists);

  // Clasificar por prioridad
  missing.sort((a, b) => b.priority - a.priority);

  const critical = missing.filter(sp => sp.priority >= 100);
  const important = missing.filter(sp => sp.priority >= 50 && sp.priority < 100);
  const optional = missing.filter(sp => sp.priority < 50);

  return {
    total: spsArray.length,
    existing: existing.length,
    missing: missing.length,
    critical: critical.length,
    important: important.length,
    optional: optional.length,
    criticalList: critical,
    importantList: important,
    optionalList: optional,
    existingList: existing
  };
}

// ==================== GENERACIÓN DE TEMPLATES ====================

function generateSQLTemplate(sp) {
  const params = Array.from(sp.parameters);
  const hasParams = params.length > 0;

  let paramDeclarations = '';
  let paramComments = '';

  if (hasParams) {
    paramDeclarations = params.map(p => `    p_${p} VARCHAR`).join(',\n');
    paramComments = params.map(p => `  -- @param p_${p}: [Descripción del parámetro]`).join('\n');
  } else {
    paramDeclarations = '    -- Sin parámetros';
  }

  const operations = Array.from(sp.operations);
  const opType = operations[0] || 'QUERY';

  let returnType = 'TABLE';
  let returnColumns = '    -- Definir columnas de retorno';

  if (opType === 'CREATE' || opType === 'UPDATE' || opType === 'DELETE') {
    returnType = 'INTEGER'; // Rows affected
  }

  const template = `-- ============================================================
-- Stored Procedure: ${sp.name}
-- ============================================================
-- Tipo de Operación: ${operations.join(', ')}
-- Usado en: ${Array.from(sp.components).join(', ')}
-- Frecuencia de uso: ${sp.usageCount} veces
-- Prioridad: ${sp.priority >= 100 ? 'CRÍTICA' : sp.priority >= 50 ? 'IMPORTANTE' : 'OPCIONAL'}
--
-- Descripción:
--   [TODO: Agregar descripción de la funcionalidad]
--
-- Parámetros:
${paramComments || '  -- Sin parámetros'}
--
-- Retorna:
--   ${returnType}${returnType === 'TABLE' ? ' con las siguientes columnas:' : ' (número de filas afectadas)'}
${returnType === 'TABLE' ? returnColumns : ''}
--
-- Ejemplo de uso:
--   SELECT * FROM ${sp.name}(${params.map(p => `'valor_${p}'`).join(', ')});
--
-- ============================================================

CREATE OR REPLACE FUNCTION ${sp.name}(
${paramDeclarations}
)
RETURNS ${returnType === 'TABLE' ? 'TABLE (\n    -- TODO: Definir columnas\n    id INTEGER,\n    nombre VARCHAR\n)' : returnType}
AS $$
BEGIN
    -- ============================================================
    -- TODO: Implementar lógica del stored procedure
    -- ============================================================

    ${returnType === 'TABLE' ? 'RETURN QUERY\n    SELECT \n        1 as id,\n        \'Ejemplo\' as nombre;\n    -- TODO: Reemplazar con query real' : 'RETURN 0; -- TODO: Implementar'}

END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- Verificación de creación
-- ============================================================
-- SELECT routine_name FROM information_schema.routines
-- WHERE routine_name = '${sp.name}' AND routine_schema = 'public';
`;

  return template;
}

function generateAllTemplates(classification) {
  log('\n📝 Generando templates SQL para SPs faltantes...', 'cyan');

  const categories = [
    { name: 'critical', list: classification.criticalList, dir: 'critical' },
    { name: 'important', list: classification.importantList, dir: 'important' },
    { name: 'optional', list: classification.optionalList, dir: 'optional' }
  ];

  categories.forEach(cat => {
    const catDir = path.join(TEMPLATES_DIR, cat.dir);
    if (!fs.existsSync(catDir)) fs.mkdirSync(catDir, { recursive: true });

    cat.list.forEach((sp, index) => {
      const template = generateSQLTemplate(sp);
      // Sanitizar nombre para Windows (remover caracteres inválidos)
      const safeName = sp.name.replace(/[<>:"/\\|?*\x00-\x1F]/g, '_');
      const fileName = `${String(index + 1).padStart(3, '0')}_${safeName}.sql`;
      const filePath = path.join(catDir, fileName);
      fs.writeFileSync(filePath, template, 'utf8');
    });

    log(`   ✅ ${cat.list.length} templates en: ${cat.dir}/`, 'green');
  });
}

// ==================== GENERACIÓN DE REPORTES ====================

function generateHTMLReport(classification, spStats) {
  const html = `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Auditoría de Stored Procedures - Priorización</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: #f5f5f5;
      padding: 20px;
    }
    .container { max-width: 1600px; margin: 0 auto; }
    .header {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 30px;
      border-radius: 10px;
      margin-bottom: 20px;
      box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }
    .summary {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      gap: 15px;
      margin-bottom: 20px;
    }
    .stat-card {
      background: white;
      padding: 20px;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      border-left: 4px solid #667eea;
    }
    .stat-card.critical { border-left-color: #dc2626; }
    .stat-card.important { border-left-color: #f59e0b; }
    .stat-card.optional { border-left-color: #10b981; }
    .stat-card.existing { border-left-color: #3b82f6; }
    .stat-card h3 { font-size: 13px; color: #6b7280; margin-bottom: 5px; text-transform: uppercase; }
    .stat-card .value { font-size: 36px; font-weight: bold; color: #1f2937; }
    .stat-card .label { font-size: 12px; color: #9ca3af; margin-top: 5px; }
    .section {
      background: white;
      border-radius: 8px;
      padding: 20px;
      margin-bottom: 20px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .section h2 {
      font-size: 18px;
      margin-bottom: 15px;
      color: #1f2937;
      border-bottom: 2px solid #e5e7eb;
      padding-bottom: 10px;
    }
    .section h2.critical { border-bottom-color: #dc2626; color: #dc2626; }
    .section h2.important { border-bottom-color: #f59e0b; color: #f59e0b; }
    .section h2.optional { border-bottom-color: #10b981; color: #10b981; }
    table { width: 100%; border-collapse: collapse; }
    th {
      background: #f9fafb;
      padding: 10px;
      text-align: left;
      font-size: 11px;
      font-weight: 600;
      color: #6b7280;
      text-transform: uppercase;
      border-bottom: 2px solid #e5e7eb;
    }
    td {
      padding: 10px;
      border-bottom: 1px solid #f3f4f6;
      font-size: 13px;
    }
    tr:hover { background: #f9fafb; }
    .priority { font-weight: bold; font-size: 14px; }
    .priority.critical { color: #dc2626; }
    .priority.important { color: #f59e0b; }
    .priority.optional { color: #10b981; }
    code {
      background: #f3f4f6;
      padding: 2px 6px;
      border-radius: 3px;
      font-family: 'Courier New', monospace;
      font-size: 12px;
    }
    .badge {
      display: inline-block;
      padding: 3px 8px;
      border-radius: 4px;
      font-size: 11px;
      font-weight: 500;
      margin-right: 5px;
    }
    .badge.create { background: #dbeafe; color: #1e40af; }
    .badge.read { background: #d1fae5; color: #065f46; }
    .badge.update { background: #fef3c7; color: #92400e; }
    .badge.delete { background: #fee2e2; color: #991b1b; }
    .badge.report { background: #e0e7ff; color: #3730a3; }
    .components { font-size: 11px; color: #6b7280; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>📊 Auditoría y Priorización de Stored Procedures</h1>
      <p>Módulo: padron_licencias | Generado: ${new Date().toLocaleString('es-MX')}</p>
    </div>

    <div class="summary">
      <div class="stat-card">
        <h3>Total SPs</h3>
        <div class="value">${classification.total}</div>
        <div class="label">Identificados en código</div>
      </div>
      <div class="stat-card existing">
        <h3>Existentes</h3>
        <div class="value">${classification.existing}</div>
        <div class="label">${((classification.existing/classification.total)*100).toFixed(1)}% ya en BD</div>
      </div>
      <div class="stat-card critical">
        <h3>Críticos</h3>
        <div class="value">${classification.critical}</div>
        <div class="label">Prioridad ALTA</div>
      </div>
      <div class="stat-card important">
        <h3>Importantes</h3>
        <div class="value">${classification.important}</div>
        <div class="label">Prioridad MEDIA</div>
      </div>
      <div class="stat-card optional">
        <h3>Opcionales</h3>
        <div class="value">${classification.optional}</div>
        <div class="label">Prioridad BAJA</div>
      </div>
    </div>

    <div class="section">
      <h2 class="critical">🔴 SPs CRÍTICOS - Crear Primero (${classification.critical})</h2>
      <table>
        <thead>
          <tr>
            <th>#</th>
            <th>Stored Procedure</th>
            <th>Prioridad</th>
            <th>Usos</th>
            <th>Operaciones</th>
            <th>Componentes</th>
            <th>Parámetros</th>
          </tr>
        </thead>
        <tbody>
          ${classification.criticalList.map((sp, i) => `
            <tr>
              <td>${i + 1}</td>
              <td><code>${sp.name}</code></td>
              <td class="priority critical">${sp.priority}</td>
              <td>${sp.usageCount}</td>
              <td>
                ${Array.from(sp.operations).map(op =>
                  `<span class="badge ${op.toLowerCase()}">${op}</span>`
                ).join('')}
              </td>
              <td class="components">${Array.from(sp.components).slice(0, 3).join(', ')}${sp.components.size > 3 ? '...' : ''}</td>
              <td>${sp.parameters.size}</td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    </div>

    <div class="section">
      <h2 class="important">🟡 SPs IMPORTANTES - Crear Después (${classification.important})</h2>
      <table>
        <thead>
          <tr>
            <th>#</th>
            <th>Stored Procedure</th>
            <th>Prioridad</th>
            <th>Usos</th>
            <th>Operaciones</th>
            <th>Componentes</th>
          </tr>
        </thead>
        <tbody>
          ${classification.importantList.map((sp, i) => `
            <tr>
              <td>${i + 1}</td>
              <td><code>${sp.name}</code></td>
              <td class="priority important">${sp.priority}</td>
              <td>${sp.usageCount}</td>
              <td>
                ${Array.from(sp.operations).map(op =>
                  `<span class="badge ${op.toLowerCase()}">${op}</span>`
                ).join('')}
              </td>
              <td class="components">${Array.from(sp.components).slice(0, 2).join(', ')}</td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    </div>

    <div class="section">
      <h2 class="optional">🟢 SPs OPCIONALES - Evaluar Necesidad (${classification.optional})</h2>
      <p style="color: #6b7280; font-size: 13px; margin-bottom: 15px;">
        Estos SPs tienen baja prioridad. Evaluar si realmente se necesitan antes de crear.
      </p>
      <table>
        <thead>
          <tr>
            <th>Stored Procedure</th>
            <th>Prioridad</th>
            <th>Usos</th>
            <th>Operaciones</th>
          </tr>
        </thead>
        <tbody>
          ${classification.optionalList.slice(0, 20).map(sp => `
            <tr>
              <td><code>${sp.name}</code></td>
              <td class="priority optional">${sp.priority}</td>
              <td>${sp.usageCount}</td>
              <td>
                ${Array.from(sp.operations).map(op =>
                  `<span class="badge ${op.toLowerCase()}">${op}</span>`
                ).join('')}
              </td>
            </tr>
          `).join('')}
          ${classification.optional > 20 ? `
            <tr>
              <td colspan="4" style="text-align: center; color: #6b7280; font-style: italic;">
                ... y ${classification.optional - 20} más
              </td>
            </tr>
          ` : ''}
        </tbody>
      </table>
    </div>

  </div>
</body>
</html>`;

  const htmlPath = path.join(OUTPUT_DIR, 'sp-priority-report.html');
  fs.writeFileSync(htmlPath, html, 'utf8');
  return htmlPath;
}

// ==================== MAIN ====================

function main() {
  log('═══════════════════════════════════════════════════════════════', 'cyan');
  log('  AUDITORÍA Y PRIORIZACIÓN DE STORED PROCEDURES', 'cyan');
  log('═══════════════════════════════════════════════════════════════\n', 'cyan');

  // Paso 1: Analizar uso
  const { allUsages, spStats } = analyzeAllComponents();
  log(`   ✅ Analizados ${allUsages.length} usos de SPs`, 'green');
  log(`   ✅ Identificados ${spStats.size} SPs únicos\n`, 'green');

  // Paso 2: Clasificar
  log('📋 Clasificando SPs por prioridad...', 'cyan');
  const classification = classifySPs(spStats);

  log(`\n📊 CLASIFICACIÓN:`, 'blue');
  log(`   🔴 CRÍTICOS:    ${classification.critical} SPs (crear primero)`, 'red');
  log(`   🟡 IMPORTANTES: ${classification.important} SPs (crear después)`, 'yellow');
  log(`   🟢 OPCIONALES:  ${classification.optional} SPs (evaluar necesidad)`, 'green');
  log(`   ✅ EXISTENTES:  ${classification.existing} SPs (ya en BD)\n`, 'blue');

  // Paso 3: Generar templates
  generateAllTemplates(classification);

  // Paso 4: Generar reporte HTML
  log('\n📄 Generando reporte HTML...', 'cyan');
  const htmlPath = generateHTMLReport(classification, spStats);
  log(`   ✅ Reporte: ${htmlPath}\n`, 'green');

  // Paso 5: Guardar JSON
  const jsonPath = path.join(OUTPUT_DIR, 'sp-audit-complete.json');
  fs.writeFileSync(jsonPath, JSON.stringify({
    classification,
    spStats: Array.from(spStats.entries()).map(([name, stats]) => ({
      name,
      ...stats,
      components: Array.from(stats.components),
      operations: Array.from(stats.operations),
      parameters: Array.from(stats.parameters)
    }))
  }, null, 2), 'utf8');
  log(`   ✅ Datos completos: ${jsonPath}\n`, 'green');

  // Resumen final
  log('═══════════════════════════════════════════════════════════════', 'cyan');
  log('  PRÓXIMOS PASOS', 'cyan');
  log('═══════════════════════════════════════════════════════════════\n', 'cyan');

  log(`1️⃣  Revisar reporte HTML: ${path.basename(htmlPath)}`, 'yellow');
  log(`2️⃣  Templates SQL generados en: sql-templates/`, 'yellow');
  log(`3️⃣  Crear primero los ${classification.critical} SPs CRÍTICOS`, 'red');
  log(`4️⃣  Validar funcionalidad después de cada lote`, 'yellow');
  log(`5️⃣  Continuar con IMPORTANTES y OPCIONALES\n`, 'yellow');

  // Abrir reporte
  log('🌐 Abriendo reporte en navegador...\n', 'cyan');
  require('child_process').exec(`start ${htmlPath}`);

  process.exit(0);
}

if (require.main === module) {
  try {
    main();
  } catch (error) {
    log(`\n❌ Error: ${error.message}`, 'red');
    console.error(error);
    process.exit(1);
  }
}
