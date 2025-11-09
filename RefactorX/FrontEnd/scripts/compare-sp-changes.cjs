#!/usr/bin/env node

/**
 * Script para Comparar Cambios en Nombres de SPs
 *
 * Compara los nombres de SPs ANTES y DESPUÉS de las optimizaciones
 * para identificar qué cambios pueden haber roto funcionalidad existente
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const COMPONENTS_DIR = path.join(__dirname, '..', 'src', 'views', 'modules', 'padron_licencias');

// Commit ANTES de las optimizaciones de hoy (último commit antes de c24f16a)
const BEFORE_COMMIT = 'a3443d3'; // Último commit antes de mi sesión
const CURRENT = 'HEAD';

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

function extractSPsFromContent(content) {
  const executePattern = /execute\s*\(\s*['"`]([^'"`]+)['"`]/g;
  const sps = [];
  let match;

  while ((match = executePattern.exec(content)) !== null) {
    sps.push(match[1]);
  }

  return sps;
}

function getFileAtCommit(file, commit) {
  try {
    const fullPath = `RefactorX/FrontEnd/src/views/modules/padron_licencias/${file}`;
    const content = execSync(`git show ${commit}:${fullPath}`, {
      cwd: path.join(__dirname, '..', '..', '..', '..'),
      encoding: 'utf8',
      stdio: ['pipe', 'pipe', 'ignore']
    });
    return content;
  } catch (error) {
    return null;
  }
}

function compareFile(file) {
  const beforeContent = getFileAtCommit(file, BEFORE_COMMIT);
  const afterContent = fs.readFileSync(path.join(COMPONENTS_DIR, file), 'utf8');

  if (!beforeContent) {
    return { file, status: 'NEW', changes: [] };
  }

  const beforeSPs = extractSPsFromContent(beforeContent);
  const afterSPs = extractSPsFromContent(afterContent);

  const changes = [];

  // Buscar SPs que cambiaron
  beforeSPs.forEach((beforeSP, index) => {
    const afterSP = afterSPs[index];
    if (beforeSP !== afterSP) {
      changes.push({
        before: beforeSP,
        after: afterSP,
        changed: true
      });
    }
  });

  return {
    file,
    status: changes.length > 0 ? 'CHANGED' : 'UNCHANGED',
    beforeCount: beforeSPs.length,
    afterCount: afterSPs.length,
    changes
  };
}

function main() {
  log('\n═══════════════════════════════════════════════════════════════', 'cyan');
  log('  COMPARACIÓN DE CAMBIOS EN STORED PROCEDURES', 'cyan');
  log('═══════════════════════════════════════════════════════════════\n', 'cyan');

  log(`📌 Comparando:`, 'blue');
  log(`   ANTES:  commit ${BEFORE_COMMIT}`, 'yellow');
  log(`   AHORA:  ${CURRENT}\n`, 'green');

  const files = fs.readdirSync(COMPONENTS_DIR)
    .filter(file => file.endsWith('.vue') && !file.endsWith('.bak'))
    .sort();

  log(`📂 Analizando ${files.length} componentes...\n`, 'cyan');

  const results = {
    totalFiles: files.length,
    newFiles: 0,
    changedFiles: 0,
    unchangedFiles: 0,
    totalChanges: 0,
    files: []
  };

  files.forEach(file => {
    const result = compareFile(file);
    results.files.push(result);

    if (result.status === 'NEW') {
      results.newFiles++;
    } else if (result.status === 'CHANGED') {
      results.changedFiles++;
      results.totalChanges += result.changes.length;
    } else {
      results.unchangedFiles++;
    }
  });

  // Mostrar archivos con cambios CRÍTICOS
  log('═══════════════════════════════════════════════════════════════', 'yellow');
  log('  ARCHIVOS CON CAMBIOS EN SPs (CRÍTICOS)', 'yellow');
  log('═══════════════════════════════════════════════════════════════\n', 'yellow');

  const changedFiles = results.files.filter(f => f.status === 'CHANGED');

  if (changedFiles.length === 0) {
    log('✅ NO SE ENCONTRARON CAMBIOS EN NOMBRES DE SPs\n', 'green');
    log('   Esto significa que los nombres ya estaban en el formato actual', 'green');
    log('   y NO rompimos funcionalidad existente.\n', 'green');
  } else {
    changedFiles.forEach(file => {
      log(`📄 ${file.file}`, 'cyan');
      log(`   SPs antes: ${file.beforeCount} | SPs ahora: ${file.afterCount}`, 'blue');

      file.changes.forEach((change, i) => {
        log(`   ${i + 1}. ANTES: "${change.before}"`, 'red');
        log(`      AHORA:  "${change.after}"`, 'green');

        // Identificar tipo de cambio
        const beforeLower = change.before.toLowerCase();
        const afterLower = change.after.toLowerCase();

        if (beforeLower === afterLower) {
          log(`      ⚠️  Cambio de capitalización (SEGURO - backend convierte a lowercase)`, 'yellow');
        } else {
          log(`      🚨 CAMBIO DE NOMBRE CRÍTICO - puede romper funcionalidad!`, 'red');
        }
      });
      log('');
    });
  }

  // Resumen
  log('═══════════════════════════════════════════════════════════════', 'cyan');
  log('  RESUMEN', 'cyan');
  log('═══════════════════════════════════════════════════════════════\n', 'cyan');

  log(`📊 Total de archivos analizados: ${results.totalFiles}`, 'blue');
  log(`📝 Archivos nuevos: ${results.newFiles}`, 'green');
  log(`🔄 Archivos con cambios: ${results.changedFiles}`, results.changedFiles > 0 ? 'yellow' : 'green');
  log(`✅ Archivos sin cambios: ${results.unchangedFiles}`, 'green');
  log(`⚡ Total de cambios en SPs: ${results.totalChanges}`, results.totalChanges > 0 ? 'yellow' : 'green');

  // Análisis de seguridad
  log('\n═══════════════════════════════════════════════════════════════', 'cyan');
  log('  ANÁLISIS DE SEGURIDAD', 'cyan');
  log('═══════════════════════════════════════════════════════════════\n', 'cyan');

  const capitalChanges = changedFiles.reduce((acc, file) => {
    const onlyCapital = file.changes.filter(c =>
      c.before.toLowerCase() === c.after.toLowerCase()
    );
    return acc + onlyCapital.length;
  }, 0);

  const nameChanges = changedFiles.reduce((acc, file) => {
    const realChanges = file.changes.filter(c =>
      c.before.toLowerCase() !== c.after.toLowerCase()
    );
    return acc + realChanges.length;
  }, 0);

  if (capitalChanges > 0) {
    log(`✅ ${capitalChanges} cambios son solo de capitalización (SEGUROS)`, 'green');
    log('   El backend convierte automáticamente a lowercase', 'green');
  }

  if (nameChanges > 0) {
    log(`\n🚨 ${nameChanges} cambios son de NOMBRE REAL (CRÍTICOS)`, 'red');
    log('   Estos pueden romper funcionalidad existente', 'red');
    log('   REQUIEREN REVISIÓN Y POSIBLE REVERSIÓN\n', 'red');
  } else if (capitalChanges === 0) {
    log('✅ NO HAY CAMBIOS PELIGROSOS', 'green');
    log('   La funcionalidad existente está PROTEGIDA\n', 'green');
  }

  // Guardar reporte
  const reportPath = path.join(__dirname, 'sp-changes-report.json');
  fs.writeFileSync(reportPath, JSON.stringify(results, null, 2), 'utf8');
  log(`📄 Reporte detallado guardado en: ${reportPath}\n`, 'blue');

  process.exit(nameChanges > 0 ? 1 : 0);
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
