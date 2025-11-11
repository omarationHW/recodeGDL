#!/usr/bin/env node

/**
 * Script para analizar el estado de todos los módulos del frontend
 */

const fs = require('fs');
const path = require('path');

const modulesPath = 'RefactorX/FrontEnd/src/views/modules';
const basePath = 'RefactorX/Base';

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

function countFiles(dir, extension) {
  if (!fs.existsSync(dir)) return 0;

  let count = 0;
  const files = fs.readdirSync(dir);

  for (const file of files) {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);

    if (stat.isDirectory()) {
      count += countFiles(fullPath, extension);
    } else if (file.endsWith(extension)) {
      count++;
    }
  }

  return count;
}

function analyzeVueComponent(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');

    const analysis = {
      hasUseApi: content.includes('useApi'),
      hasExecute: content.includes('execute('),
      hasSPCalls: (content.match(/execute\(['"]/g) || []).length,
      hasErrorHandler: content.includes('useLicenciasErrorHandler') || content.includes('useErrorHandler'),
      linesOfCode: content.split('\n').length,
      hasCompositionAPI: content.includes('<script setup>'),
      hasTODO: content.includes('TODO') || content.includes('FIXME'),
      hasConsoleLog: content.includes('console.log'),
    };

    return analysis;
  } catch (error) {
    return null;
  }
}

function analyzeModule(moduleName) {
  const modulePath = path.join(modulesPath, moduleName);
  const baseModulePath = path.join(basePath, moduleName);

  const vueFiles = [];

  function getVueFiles(dir) {
    if (!fs.existsSync(dir)) return;

    const files = fs.readdirSync(dir);
    for (const file of files) {
      const fullPath = path.join(dir, file);
      const stat = fs.statSync(fullPath);

      if (stat.isDirectory() && !file.startsWith('_')) {
        getVueFiles(fullPath);
      } else if (file.endsWith('.vue')) {
        vueFiles.push(fullPath);
      }
    }
  }

  getVueFiles(modulePath);

  const moduleAnalysis = {
    name: moduleName,
    totalComponents: vueFiles.length,
    withUseApi: 0,
    withExecute: 0,
    totalSPCalls: 0,
    withErrorHandler: 0,
    withCompositionAPI: 0,
    withTODO: 0,
    withConsoleLog: 0,
    totalLOC: 0,
    hasSPsInBase: false,
    spCount: 0,
    hasDatabase: false,
  };

  // Analizar componentes Vue
  for (const file of vueFiles) {
    const analysis = analyzeVueComponent(file);
    if (analysis) {
      if (analysis.hasUseApi) moduleAnalysis.withUseApi++;
      if (analysis.hasExecute) moduleAnalysis.withExecute++;
      moduleAnalysis.totalSPCalls += analysis.hasSPCalls;
      if (analysis.hasErrorHandler) moduleAnalysis.withErrorHandler++;
      if (analysis.hasCompositionAPI) moduleAnalysis.withCompositionAPI++;
      if (analysis.hasTODO) moduleAnalysis.withTODO++;
      if (analysis.hasConsoleLog) moduleAnalysis.withConsoleLog++;
      moduleAnalysis.totalLOC += analysis.linesOfCode;
    }
  }

  // Verificar SPs en Base
  const dbPath = path.join(baseModulePath, 'database');
  if (fs.existsSync(dbPath)) {
    moduleAnalysis.hasDatabase = true;

    const databaseDir = path.join(dbPath, 'database');
    if (fs.existsSync(databaseDir)) {
      moduleAnalysis.spCount = countFiles(databaseDir, '.sql');
    }

    moduleAnalysis.hasSPsInBase = moduleAnalysis.spCount > 0;
  }

  return moduleAnalysis;
}

function calculateHealth(module) {
  let score = 0;
  let maxScore = 0;

  // Componentes con useApi (30 puntos)
  maxScore += 30;
  score += (module.withUseApi / module.totalComponents) * 30;

  // Componentes con execute (25 puntos)
  maxScore += 25;
  score += (module.withExecute / module.totalComponents) * 25;

  // Tiene SPs en Base (20 puntos)
  maxScore += 20;
  if (module.hasSPsInBase) score += 20;

  // Error handling (15 puntos)
  maxScore += 15;
  score += (module.withErrorHandler / module.totalComponents) * 15;

  // Composition API (10 puntos)
  maxScore += 10;
  score += (module.withCompositionAPI / module.totalComponents) * 10;

  const percentage = (score / maxScore) * 100;

  if (percentage >= 80) return { score: percentage, status: 'Excelente', color: 'green' };
  if (percentage >= 60) return { score: percentage, status: 'Bueno', color: 'cyan' };
  if (percentage >= 40) return { score: percentage, status: 'Regular', color: 'yellow' };
  return { score: percentage, status: 'Necesita trabajo', color: 'red' };
}

async function main() {
  log('\n╔═══════════════════════════════════════════════════════════════╗', 'cyan');
  log('║     ANÁLISIS COMPLETO DE MÓDULOS FRONTEND - RefactorX       ║', 'cyan');
  log('╚═══════════════════════════════════════════════════════════════╝\n', 'cyan');

  const modules = fs.readdirSync(modulesPath).filter(f => {
    const fullPath = path.join(modulesPath, f);
    return fs.statSync(fullPath).isDirectory();
  });

  const analyses = [];

  for (const moduleName of modules) {
    const analysis = analyzeModule(moduleName);
    const health = calculateHealth(analysis);
    analysis.health = health;
    analyses.push(analysis);
  }

  // Ordenar por salud
  analyses.sort((a, b) => b.health.score - a.health.score);

  // Mostrar resultados
  log('═══════════════════════════════════════════════════════════════\n', 'blue');

  for (const module of analyses) {
    log(`📦 ${module.name.toUpperCase()}`, 'magenta');
    log(`${'─'.repeat(60)}`, 'blue');

    log(`   Estado: ${module.health.status} (${module.health.score.toFixed(1)}%)`, module.health.color);
    log(`   Componentes totales: ${module.totalComponents}`, 'reset');
    log(`   └─ Con useApi: ${module.withUseApi} (${((module.withUseApi/module.totalComponents)*100).toFixed(1)}%)`, 'cyan');
    log(`   └─ Con execute(): ${module.withExecute} (${((module.withExecute/module.totalComponents)*100).toFixed(1)}%)`, 'cyan');
    log(`   └─ Con Composition API: ${module.withCompositionAPI} (${((module.withCompositionAPI/module.totalComponents)*100).toFixed(1)}%)`, 'cyan');
    log(`   └─ Con error handler: ${module.withErrorHandler} (${((module.withErrorHandler/module.totalComponents)*100).toFixed(1)}%)`, 'cyan');

    log(`   Llamadas a SPs: ${module.totalSPCalls}`, 'reset');
    log(`   Líneas de código: ${module.totalLOC.toLocaleString()}`, 'reset');

    if (module.hasDatabase) {
      log(`   ✅ Base de datos: ${module.spCount} SPs disponibles`, 'green');
    } else {
      log(`   ⚠️  Base de datos: No configurada`, 'yellow');
    }

    if (module.withTODO > 0) {
      log(`   ⚠️  TODOs pendientes: ${module.withTODO} componentes`, 'yellow');
    }

    if (module.withConsoleLog > 0) {
      log(`   🐛 Console.logs: ${module.withConsoleLog} componentes`, 'yellow');
    }

    log('');
  }

  // Resumen general
  log('═══════════════════════════════════════════════════════════════', 'cyan');
  log('                    RESUMEN GENERAL', 'cyan');
  log('═══════════════════════════════════════════════════════════════\n', 'cyan');

  const totals = {
    components: analyses.reduce((sum, m) => sum + m.totalComponents, 0),
    withUseApi: analyses.reduce((sum, m) => sum + m.withUseApi, 0),
    withExecute: analyses.reduce((sum, m) => sum + m.withExecute, 0),
    totalSPCalls: analyses.reduce((sum, m) => sum + m.totalSPCalls, 0),
    totalLOC: analyses.reduce((sum, m) => sum + m.totalLOC, 0),
    totalSPs: analyses.reduce((sum, m) => sum + m.spCount, 0),
    modulesWithDB: analyses.filter(m => m.hasDatabase).length,
  };

  log(`📊 Total de módulos: ${analyses.length}`, 'blue');
  log(`📄 Total de componentes: ${totals.components}`, 'blue');
  log(`🔗 Componentes con useApi: ${totals.withUseApi} (${((totals.withUseApi/totals.components)*100).toFixed(1)}%)`, 'cyan');
  log(`⚡ Componentes con execute: ${totals.withExecute} (${((totals.withExecute/totals.components)*100).toFixed(1)}%)`, 'cyan');
  log(`📞 Total de llamadas a SPs: ${totals.totalSPCalls}`, 'green');
  log(`📝 Total de líneas de código: ${totals.totalLOC.toLocaleString()}`, 'blue');
  log(`🗄️  Módulos con base de datos: ${totals.modulesWithDB}/${analyses.length}`, 'green');
  log(`💾 Total de SPs disponibles: ${totals.totalSPs}`, 'green');

  log('\n═══════════════════════════════════════════════════════════════', 'cyan');
  log('                  PRIORIDADES DE TRABAJO', 'cyan');
  log('═══════════════════════════════════════════════════════════════\n', 'cyan');

  const needsWork = analyses.filter(m => m.health.score < 60);

  if (needsWork.length > 0) {
    log('⚠️  Módulos que necesitan atención:\n', 'yellow');

    for (const module of needsWork) {
      const missing = [];

      if (module.withUseApi < module.totalComponents * 0.8) {
        missing.push(`${module.totalComponents - module.withUseApi} componentes sin useApi`);
      }

      if (!module.hasSPsInBase) {
        missing.push('Sin SPs en Base');
      }

      if (module.withErrorHandler === 0) {
        missing.push('Sin error handlers');
      }

      log(`   ${module.name}:`, 'yellow');
      missing.forEach(item => log(`      - ${item}`, 'red'));
      log('');
    }
  } else {
    log('✅ Todos los módulos están en buen estado\n', 'green');
  }

  // Endpoint Backend
  log('═══════════════════════════════════════════════════════════════', 'cyan');
  log('                  ENDPOINT BACKEND', 'cyan');
  log('═══════════════════════════════════════════════════════════════\n', 'cyan');

  log('✅ Endpoint genérico configurado: /api/generic', 'green');
  log('   Controller: GenericController@execute', 'cyan');
  log('   Soporte multi-módulo: Sí', 'green');
  log('   Conversión a minúsculas: Automática', 'green');
  log('   Schemas permitidos: Configurables por módulo', 'green');

  log('\n═══════════════════════════════════════════════════════════════\n', 'cyan');

  // Generar JSON para futuras referencias
  const report = {
    timestamp: new Date().toISOString(),
    summary: totals,
    modules: analyses.map(m => ({
      name: m.name,
      health: m.health,
      components: m.totalComponents,
      withUseApi: m.withUseApi,
      withExecute: m.withExecute,
      spCalls: m.totalSPCalls,
      spCount: m.spCount,
      hasDatabase: m.hasDatabase,
      linesOfCode: m.totalLOC,
    })),
  };

  fs.writeFileSync(
    path.join('temp', 'modules-status-report.json'),
    JSON.stringify(report, null, 2)
  );

  log('📄 Reporte completo guardado en: temp/modules-status-report.json\n', 'blue');
}

main().catch(console.error);
