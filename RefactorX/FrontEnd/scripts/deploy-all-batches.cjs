#!/usr/bin/env node

/**
 * Script Automatizado para Generar y Desplegar TODOS los Batches
 * Procesa los 244 SPs faltantes en bloques de 10
 */

const { execSync } = require('child_process');
const path = require('path');

const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  magenta: '\x1b[35m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function runCommand(cmd, description) {
  log(`\n🔄 ${description}...`, 'cyan');
  try {
    const output = execSync(cmd, {
      cwd: path.join(__dirname, '..'),
      encoding: 'utf8',
      stdio: 'pipe'
    });
    return { success: true, output };
  } catch (error) {
    return { success: false, error: error.message, output: error.stdout };
  }
}

async function deployBatch(batchNumber) {
  log(`\n${'═'.repeat(70)}`, 'magenta');
  log(`  PROCESANDO BATCH #${batchNumber}`, 'magenta');
  log(`${'═'.repeat(70)}`, 'magenta');

  // 1. Generar SQL del batch (usando generador dinámico)
  const generateCmd = `node "${path.join(__dirname, 'generate-dynamic-batch.cjs')}" ${batchNumber}`;
  const generateResult = runCommand(generateCmd, `Generando batch #${batchNumber}`);

  if (!generateResult.success) {
    log(`❌ Error al generar batch #${batchNumber}`, 'red');
    return false;
  }

  log(`✅ Batch #${batchNumber} generado exitosamente`, 'green');

  // 2. Desplegar a la base de datos
  const batchStr = String(batchNumber).padStart(2, '0');
  // El nombre del archivo puede ser _IMPORTANT o _OPTIONAL dependiendo del batch
  const tierSuffix = batchNumber <= 7 ? 'IMPORTANT' : 'OPTIONAL';
  const deployCmd = `node "${path.join(__dirname, 'deploy-critical-sps.cjs')}" DEPLOY_BATCH_${batchStr}_${tierSuffix}.sql`;
  const deployResult = runCommand(deployCmd, `Desplegando batch #${batchNumber}`);

  if (!deployResult.success) {
    log(`❌ Error al desplegar batch #${batchNumber}`, 'red');
    return false;
  }

  // Extraer conteo de SPs del output
  const match = deployResult.output.match(/Total de Stored Procedures.*?(\d+)/);
  const totalSPs = match ? match[1] : '?';

  log(`✅ Batch #${batchNumber} desplegado exitosamente`, 'green');
  log(`📊 Total de SPs en BD: ${totalSPs}`, 'blue');

  return true;
}

async function main() {
  const startBatch = parseInt(process.argv[2]) || 3;
  const endBatch = parseInt(process.argv[3]) || 25;

  log('\n╔════════════════════════════════════════════════════════════╗', 'cyan');
  log('║  DEPLOY AUTOMATIZADO DE BATCHES - SPs AL 100%             ║', 'cyan');
  log('╚════════════════════════════════════════════════════════════╝\n', 'cyan');

  log(`📋 Procesando batches del ${startBatch} al ${endBatch}`, 'yellow');
  log(`📊 Objetivo: 312 SPs al 100%\n`, 'yellow');

  const startTime = Date.now();
  let successCount = 0;
  let failCount = 0;

  for (let i = startBatch; i <= endBatch; i++) {
    const success = await deployBatch(i);

    if (success) {
      successCount++;
      log(`✅ Batch #${i} completado [${successCount}/${endBatch - startBatch + 1}]`, 'green');
    } else {
      failCount++;
      log(`❌ Batch #${i} falló`, 'red');

      // Preguntar si continuar
      log('\n⚠️  ¿Continuar con el siguiente batch? (CTRL+C para cancelar)', 'yellow');
      log('   Esperando 5 segundos...', 'yellow');

      await new Promise(resolve => setTimeout(resolve, 5000));
    }

    // Pausa entre batches para evitar sobrecarga
    if (i < endBatch) {
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  }

  const endTime = Date.now();
  const duration = ((endTime - startTime) / 1000).toFixed(1);

  log('\n╔════════════════════════════════════════════════════════════╗', 'green');
  log('║  RESUMEN DEL PROCESO                                       ║', 'green');
  log('╚════════════════════════════════════════════════════════════╝\n', 'green');

  log(`✅ Batches exitosos: ${successCount}`, 'green');
  log(`❌ Batches fallidos: ${failCount}`, failCount > 0 ? 'red' : 'green');
  log(`⏱️  Tiempo total: ${duration}s`, 'blue');
  log(`📊 SPs creados: ~${successCount * 10}`, 'cyan');

  if (failCount === 0) {
    log('\n🎉 ¡TODOS LOS BATCHES COMPLETADOS EXITOSAMENTE!', 'green');
  } else {
    log(`\n⚠️  ${failCount} batches fallaron, revisar logs arriba`, 'yellow');
  }

  log('');
}

if (require.main === module) {
  main()
    .then(() => process.exit(0))
    .catch(error => {
      log(`\n❌ Error fatal: ${error.message}`, 'red');
      console.error(error);
      process.exit(1);
    });
}

module.exports = { deployBatch };
