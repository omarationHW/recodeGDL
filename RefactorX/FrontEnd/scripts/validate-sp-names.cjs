#!/usr/bin/env node

/**
 * Script de Validación de Nombres de Stored Procedures
 *
 * Valida que todos los componentes Vue usen nombres de SPs en lowercase
 * y extrae la lista de SPs únicos para verificar contra la base de datos.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const COMPONENTS_DIR = path.join(__dirname, '..', 'src', 'views', 'modules', 'padron_licencias');
const REPORT_FILE = path.join(__dirname, 'sp-validation-report.txt');

// Colores para consola
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function extractSPsFromFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf8');
  const fileName = path.basename(filePath);

  // Patrón para encontrar llamadas a execute() con nombre de SP
  const executePattern = /execute\s*\(\s*['"`]([^'"`]+)['"`]/g;

  const sps = [];
  let match;

  while ((match = executePattern.exec(content)) !== null) {
    const spName = match[1];
    const lineNumber = content.substring(0, match.index).split('\n').length;

    // Verificar si tiene mayúsculas
    const hasUppercase = /[A-Z]/.test(spName);

    sps.push({
      name: spName,
      file: fileName,
      line: lineNumber,
      hasUppercase: hasUppercase,
      isValid: !hasUppercase && spName.startsWith('sp_')
    });
  }

  return sps;
}

function scanAllComponents() {
  const files = fs.readdirSync(COMPONENTS_DIR)
    .filter(file => file.endsWith('.vue') && !file.endsWith('.bak'));

  log(`\n📂 Escaneando ${files.length} componentes en padron_licencias...\n`, 'cyan');

  const allSPs = [];
  const issues = [];

  files.forEach(file => {
    const filePath = path.join(COMPONENTS_DIR, file);
    const sps = extractSPsFromFile(filePath);

    if (sps.length > 0) {
      allSPs.push(...sps);

      const invalidSPs = sps.filter(sp => !sp.isValid);
      if (invalidSPs.length > 0) {
        issues.push({ file, sps: invalidSPs });
      }
    }
  });

  return { allSPs, issues };
}

function generateReport(allSPs, issues) {
  const uniqueSPs = [...new Set(allSPs.map(sp => sp.name))].sort();

  let report = '═══════════════════════════════════════════════════════════════\n';
  report += '  REPORTE DE VALIDACIÓN DE STORED PROCEDURES\n';
  report += '  Módulo: padron_licencias\n';
  report += `  Fecha: ${new Date().toISOString()}\n`;
  report += '═══════════════════════════════════════════════════════════════\n\n';

  // Resumen
  report += '📊 RESUMEN:\n';
  report += `   Total de SPs encontrados: ${allSPs.length}\n`;
  report += `   SPs únicos: ${uniqueSPs.length}\n`;
  report += `   Archivos con issues: ${issues.length}\n\n`;

  // Issues (si existen)
  if (issues.length > 0) {
    report += '❌ ISSUES ENCONTRADOS:\n';
    report += '─────────────────────────────────────────────────────────────\n\n';

    issues.forEach(issue => {
      report += `Archivo: ${issue.file}\n`;
      issue.sps.forEach(sp => {
        report += `  ⚠️  Línea ${sp.line}: "${sp.name}"\n`;
        if (sp.hasUppercase) {
          report += `      Problema: Contiene mayúsculas\n`;
        }
        if (!sp.name.startsWith('sp_')) {
          report += `      Problema: No comienza con "sp_"\n`;
        }
      });
      report += '\n';
    });
  } else {
    report += '✅ NO SE ENCONTRARON ISSUES\n';
    report += '   Todos los SPs están en lowercase y con prefijo sp_\n\n';
  }

  // Lista de SPs únicos
  report += '📋 LISTA DE SPs ÚNICOS:\n';
  report += '─────────────────────────────────────────────────────────────\n';
  uniqueSPs.forEach((sp, index) => {
    const count = allSPs.filter(s => s.name === sp).length;
    const hasUppercase = /[A-Z]/.test(sp);
    const status = hasUppercase ? '❌' : '✅';
    report += `${status} ${index + 1}. ${sp} (usado ${count} veces)\n`;
  });

  report += '\n═══════════════════════════════════════════════════════════════\n';
  report += 'SQL para verificar en la base de datos:\n';
  report += '═══════════════════════════════════════════════════════════════\n\n';
  report += 'SELECT routine_name, routine_schema\n';
  report += 'FROM information_schema.routines\n';
  report += 'WHERE routine_schema = \'public\'\n';
  report += '  AND routine_name IN (\n';
  report += uniqueSPs.map((sp, i) => `    '${sp}'${i < uniqueSPs.length - 1 ? ',' : ''}`).join('\n');
  report += '\n  )\n';
  report += 'ORDER BY routine_name;\n\n';

  return report;
}

function main() {
  log('═══════════════════════════════════════════════════════════════', 'cyan');
  log('  VALIDADOR DE NOMBRES DE STORED PROCEDURES', 'cyan');
  log('═══════════════════════════════════════════════════════════════\n', 'cyan');

  try {
    const { allSPs, issues } = scanAllComponents();
    const report = generateReport(allSPs, issues);

    // Guardar reporte
    fs.writeFileSync(REPORT_FILE, report, 'utf8');

    // Mostrar en consola
    console.log(report);

    // Resultado final
    if (issues.length === 0) {
      log('✅ VALIDACIÓN EXITOSA', 'green');
      log('   Todos los SPs están correctamente nombrados en lowercase\n', 'green');
      log(`📄 Reporte guardado en: ${REPORT_FILE}`, 'blue');
      process.exit(0);
    } else {
      log('❌ VALIDACIÓN FALLIDA', 'red');
      log(`   Se encontraron ${issues.length} archivos con issues\n`, 'red');
      log(`📄 Ver detalles en: ${REPORT_FILE}`, 'blue');
      process.exit(1);
    }
  } catch (error) {
    log(`\n❌ Error: ${error.message}`, 'red');
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}

module.exports = { extractSPsFromFile, scanAllComponents, generateReport };
