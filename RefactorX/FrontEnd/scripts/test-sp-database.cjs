#!/usr/bin/env node

/**
 * Script de Testing de Stored Procedures contra Base de Datos
 *
 * Este script:
 * 1. Extrae todos los SPs únicos de los componentes Vue
 * 2. Se conecta a PostgreSQL
 * 3. Verifica la existencia de cada SP en la BD
 * 4. Intenta ejecutar cada SP con parámetros de prueba
 * 5. Genera reporte detallado de funcionamiento
 */

const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

// ==================== CONFIGURACIÓN ====================

const COMPONENTS_DIR = path.join(__dirname, '..', 'src', 'views', 'modules', 'padron_licencias');
const REPORT_FILE = path.join(__dirname, 'sp-database-test-report.json');
const REPORT_HTML = path.join(__dirname, 'sp-database-test-report.html');

// Configuración de BD (desde .env del BackEnd)
const DB_CONFIG = {
  host: '192.168.6.146',
  port: 5432,
  database: 'padron_licencias',
  user: 'refact',
  password: 'FF)-BQk2',
};

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

// ==================== EXTRACCIÓN DE SPs ====================

function extractSPsFromFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const fileName = path.basename(filePath);
  const executePattern = /execute\s*\(\s*['"`]([^'"`]+)['"`]/g;
  const sps = new Set();
  let match;

  while ((match = executePattern.exec(content)) !== null) {
    sps.add(match[1].toLowerCase()); // Normalizar a lowercase
  }

  return Array.from(sps);
}

function extractAllSPs() {
  log('\n📂 Extrayendo SPs de componentes Vue...', 'cyan');

  const files = fs.readdirSync(COMPONENTS_DIR)
    .filter(file => file.endsWith('.vue') && !file.endsWith('.bak'));

  const allSPs = new Set();

  files.forEach(file => {
    const filePath = path.join(COMPONENTS_DIR, file);
    const sps = extractSPsFromFile(filePath);
    sps.forEach(sp => allSPs.add(sp));
  });

  const uniqueSPs = Array.from(allSPs).sort();
  log(`   ✅ Encontrados ${uniqueSPs.length} SPs únicos en ${files.length} componentes\n`, 'green');

  return uniqueSPs;
}

// ==================== VALIDACIÓN EN BASE DE DATOS ====================

async function connectToDB() {
  const client = new Client(DB_CONFIG);
  await client.connect();
  return client;
}

async function checkSPExists(client, spName) {
  const query = `
    SELECT
      routine_name,
      routine_schema,
      routine_type,
      data_type as return_type,
      (
        SELECT COUNT(*)
        FROM information_schema.parameters
        WHERE specific_name = r.specific_name
      ) as param_count
    FROM information_schema.routines r
    WHERE routine_schema = 'public'
      AND LOWER(routine_name) = LOWER($1)
    LIMIT 1
  `;

  const result = await client.query(query, [spName]);
  return result.rows[0] || null;
}

async function getSPParameters(client, spName) {
  const query = `
    SELECT
      parameter_name,
      data_type,
      parameter_mode,
      ordinal_position
    FROM information_schema.parameters
    WHERE specific_schema = 'public'
      AND LOWER(specific_name) = LOWER($1)
    ORDER BY ordinal_position
  `;

  const result = await client.query(query, [spName]);
  return result.rows;
}

async function testSPExecution(client, spName, spInfo) {
  try {
    // Intentar ejecutar el SP con parámetros NULL
    const paramCount = parseInt(spInfo.param_count) || 0;
    const params = Array(paramCount).fill(null);
    const placeholders = params.map((_, i) => `$${i + 1}`).join(', ');

    const testQuery = `SELECT * FROM ${spName}(${placeholders}) LIMIT 1`;

    const result = await client.query(testQuery, params);

    return {
      success: true,
      rowCount: result.rowCount,
      hasResults: result.rows.length > 0,
      error: null
    };
  } catch (error) {
    return {
      success: false,
      rowCount: 0,
      hasResults: false,
      error: error.message
    };
  }
}

// ==================== PROCESO PRINCIPAL ====================

async function validateAllSPs() {
  log('═══════════════════════════════════════════════════════════════', 'cyan');
  log('  VALIDADOR DE STORED PROCEDURES - BASE DE DATOS', 'cyan');
  log('═══════════════════════════════════════════════════════════════\n', 'cyan');

  // Paso 1: Extraer SPs
  const allSPs = extractAllSPs();

  // Paso 2: Conectar a BD
  log('🔌 Conectando a PostgreSQL...', 'yellow');
  let client;

  try {
    client = await connectToDB();
    log(`   ✅ Conectado a ${DB_CONFIG.database}@${DB_CONFIG.host}\n`, 'green');
  } catch (error) {
    log(`   ❌ Error de conexión: ${error.message}`, 'red');
    log('\n💡 Verifica la configuración de BD en el script:', 'yellow');
    log(`   - Host: ${DB_CONFIG.host}`, 'yellow');
    log(`   - Puerto: ${DB_CONFIG.port}`, 'yellow');
    log(`   - Base: ${DB_CONFIG.database}`, 'yellow');
    log(`   - Usuario: ${DB_CONFIG.user}\n`, 'yellow');
    process.exit(1);
  }

  // Paso 3: Validar cada SP
  log(`🔍 Validando ${allSPs.length} stored procedures...\n`, 'cyan');

  const results = {
    timestamp: new Date().toISOString(),
    totalSPs: allSPs.length,
    database: DB_CONFIG.database,
    sps: []
  };

  let existCount = 0;
  let notExistCount = 0;
  let executableCount = 0;
  let errorCount = 0;

  for (let i = 0; i < allSPs.length; i++) {
    const spName = allSPs[i];
    const progress = `[${i + 1}/${allSPs.length}]`;

    process.stdout.write(`${progress} Validando ${spName}...`);

    const spResult = {
      name: spName,
      exists: false,
      info: null,
      parameters: [],
      execution: null
    };

    // Verificar existencia
    const spInfo = await checkSPExists(client, spName);

    if (spInfo) {
      spResult.exists = true;
      spResult.info = spInfo;
      existCount++;

      // Obtener parámetros
      const params = await getSPParameters(client, spName);
      spResult.parameters = params;

      // Probar ejecución
      const execResult = await testSPExecution(client, spName, spInfo);
      spResult.execution = execResult;

      if (execResult.success) {
        executableCount++;
        process.stdout.write(` ${colors.green}✓${colors.reset}\n`);
      } else {
        errorCount++;
        process.stdout.write(` ${colors.yellow}⚠${colors.reset}\n`);
      }
    } else {
      notExistCount++;
      process.stdout.write(` ${colors.red}✗${colors.reset}\n`);
    }

    results.sps.push(spResult);
  }

  await client.end();

  // Paso 4: Generar estadísticas
  results.summary = {
    exist: existCount,
    notExist: notExistCount,
    executable: executableCount,
    withErrors: errorCount,
    percentageExist: ((existCount / allSPs.length) * 100).toFixed(2),
    percentageExecutable: ((executableCount / existCount) * 100).toFixed(2)
  };

  // Paso 5: Guardar reporte
  fs.writeFileSync(REPORT_FILE, JSON.stringify(results, null, 2), 'utf8');

  // Generar HTML
  generateHTMLReport(results);

  // Mostrar resumen
  log('\n═══════════════════════════════════════════════════════════════', 'cyan');
  log('  RESUMEN DE VALIDACIÓN', 'cyan');
  log('═══════════════════════════════════════════════════════════════\n', 'cyan');

  log(`📊 Total de SPs analizados: ${allSPs.length}`, 'blue');
  log(`✅ Existen en BD: ${existCount} (${results.summary.percentageExist}%)`, 'green');
  log(`❌ NO existen en BD: ${notExistCount}`, 'red');
  log(`🟢 Ejecutables sin error: ${executableCount} (${results.summary.percentageExecutable}% de los existentes)`, 'green');
  log(`⚠️  Con errores de ejecución: ${errorCount}`, 'yellow');

  log(`\n📄 Reportes generados:`, 'blue');
  log(`   JSON: ${REPORT_FILE}`, 'cyan');
  log(`   HTML: ${REPORT_HTML}`, 'cyan');

  if (notExistCount > 0) {
    log(`\n⚠️  ATENCIÓN: ${notExistCount} SPs NO existen en la base de datos`, 'yellow');
    log(`   Revisar el reporte para ver cuáles faltan\n`, 'yellow');
  } else {
    log(`\n✅ ÉXITO: Todos los SPs existen en la base de datos\n`, 'green');
  }

  return results;
}

// ==================== GENERACIÓN DE REPORTE HTML ====================

function generateHTMLReport(results) {
  const html = `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reporte de Validación de SPs - ${results.database}</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: #f5f5f5;
      padding: 20px;
    }
    .container { max-width: 1400px; margin: 0 auto; }
    .header {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 30px;
      border-radius: 10px;
      margin-bottom: 20px;
      box-shadow: 0 4px 6px rgba(0,0,0,0.1);
    }
    .header h1 { margin-bottom: 10px; }
    .header .meta { opacity: 0.9; font-size: 14px; }
    .summary {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
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
    .stat-card.success { border-left-color: #10b981; }
    .stat-card.error { border-left-color: #ef4444; }
    .stat-card.warning { border-left-color: #f59e0b; }
    .stat-card h3 { font-size: 14px; color: #6b7280; margin-bottom: 5px; }
    .stat-card .value { font-size: 32px; font-weight: bold; color: #1f2937; }
    .filters {
      background: white;
      padding: 15px;
      border-radius: 8px;
      margin-bottom: 20px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .filters label { margin-right: 15px; font-size: 14px; }
    .filters input { margin-right: 5px; }
    .sp-table {
      background: white;
      border-radius: 8px;
      overflow: hidden;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    table {
      width: 100%;
      border-collapse: collapse;
    }
    th {
      background: #f9fafb;
      padding: 12px;
      text-align: left;
      font-size: 12px;
      font-weight: 600;
      color: #6b7280;
      text-transform: uppercase;
      border-bottom: 2px solid #e5e7eb;
    }
    td {
      padding: 12px;
      border-bottom: 1px solid #f3f4f6;
      font-size: 14px;
    }
    tr:hover { background: #f9fafb; }
    .badge {
      display: inline-block;
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 12px;
      font-weight: 500;
    }
    .badge.success { background: #d1fae5; color: #065f46; }
    .badge.error { background: #fee2e2; color: #991b1b; }
    .badge.warning { background: #fef3c7; color: #92400e; }
    code {
      background: #f3f4f6;
      padding: 2px 6px;
      border-radius: 3px;
      font-family: 'Courier New', monospace;
      font-size: 13px;
    }
    .params { font-size: 12px; color: #6b7280; }
    .error-msg { color: #dc2626; font-size: 12px; margin-top: 4px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>📊 Reporte de Validación de Stored Procedures</h1>
      <div class="meta">
        <div>Base de datos: <strong>${results.database}</strong></div>
        <div>Fecha: ${new Date(results.timestamp).toLocaleString('es-MX')}</div>
      </div>
    </div>

    <div class="summary">
      <div class="stat-card">
        <h3>Total SPs</h3>
        <div class="value">${results.totalSPs}</div>
      </div>
      <div class="stat-card success">
        <h3>Existen en BD</h3>
        <div class="value">${results.summary.exist}</div>
        <small>${results.summary.percentageExist}%</small>
      </div>
      <div class="stat-card error">
        <h3>No Existen</h3>
        <div class="value">${results.summary.notExist}</div>
      </div>
      <div class="stat-card success">
        <h3>Ejecutables</h3>
        <div class="value">${results.summary.executable}</div>
        <small>${results.summary.percentageExecutable}% de existentes</small>
      </div>
      <div class="stat-card warning">
        <h3>Con Errores</h3>
        <div class="value">${results.summary.withErrors}</div>
      </div>
    </div>

    <div class="filters">
      <label><input type="checkbox" id="filterExist" checked> Mostrar existentes</label>
      <label><input type="checkbox" id="filterNotExist" checked> Mostrar no existentes</label>
      <label><input type="checkbox" id="filterErrors" checked> Mostrar con errores</label>
    </div>

    <div class="sp-table">
      <table id="spTable">
        <thead>
          <tr>
            <th>Stored Procedure</th>
            <th>Estado</th>
            <th>Tipo</th>
            <th>Parámetros</th>
            <th>Ejecución</th>
          </tr>
        </thead>
        <tbody>
          ${results.sps.map(sp => `
            <tr class="sp-row ${!sp.exists ? 'not-exist' : ''} ${sp.execution && !sp.execution.success ? 'has-error' : ''}">
              <td><code>${sp.name}</code></td>
              <td>
                ${sp.exists
                  ? '<span class="badge success">✓ Existe</span>'
                  : '<span class="badge error">✗ No existe</span>'}
              </td>
              <td>${sp.info ? sp.info.routine_type : '-'}</td>
              <td class="params">
                ${sp.parameters.length > 0
                  ? sp.parameters.map(p => `${p.parameter_name || 'param'} (${p.data_type})`).join(', ')
                  : 'Sin parámetros'}
              </td>
              <td>
                ${sp.execution
                  ? (sp.execution.success
                    ? '<span class="badge success">✓ OK</span>'
                    : `<span class="badge warning">⚠ Error</span><div class="error-msg">${sp.execution.error}</div>`)
                  : '-'}
              </td>
            </tr>
          `).join('')}
        </tbody>
      </table>
    </div>
  </div>

  <script>
    const filterExist = document.getElementById('filterExist');
    const filterNotExist = document.getElementById('filterNotExist');
    const filterErrors = document.getElementById('filterErrors');

    function applyFilters() {
      const rows = document.querySelectorAll('.sp-row');
      rows.forEach(row => {
        const isNotExist = row.classList.contains('not-exist');
        const hasError = row.classList.contains('has-error');
        const isExist = !isNotExist;

        let show = false;
        if (isExist && filterExist.checked) show = true;
        if (isNotExist && filterNotExist.checked) show = true;
        if (hasError && filterErrors.checked) show = true;

        row.style.display = show ? '' : 'none';
      });
    }

    filterExist.addEventListener('change', applyFilters);
    filterNotExist.addEventListener('change', applyFilters);
    filterErrors.addEventListener('change', applyFilters);
  </script>
</body>
</html>`;

  fs.writeFileSync(REPORT_HTML, html, 'utf8');
}

// ==================== EJECUCIÓN ====================

if (require.main === module) {
  validateAllSPs()
    .then(results => {
      process.exit(results.summary.notExist > 0 ? 1 : 0);
    })
    .catch(error => {
      log(`\n❌ Error fatal: ${error.message}`, 'red');
      console.error(error);
      process.exit(1);
    });
}

module.exports = { extractAllSPs, validateAllSPs };
