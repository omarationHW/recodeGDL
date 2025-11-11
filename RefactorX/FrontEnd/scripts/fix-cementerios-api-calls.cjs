#!/usr/bin/env node

/**
 * Script para corregir TODOS los llamados a SPs en componentes de Cementerios
 *
 * Cambios:
 * 1. SP names: MAYÚSCULAS → minúsculas
 * 2. Schema: agregar 'comun' como 6to parámetro
 * 3. Response access: response → response.result
 */

const fs = require('fs');
const path = require('path');

const componentsDir = path.join(__dirname, '../src/views/modules/cementerios');

console.log('\n🔧 Corrigiendo llamadas API en componentes de Cementerios...\n');

const files = fs.readdirSync(componentsDir).filter(f => f.endsWith('.vue'));
let fixed = 0;
let changes = 0;

files.forEach(filename => {
  const file = path.join(componentsDir, filename);
  let content = fs.readFileSync(file, 'utf8');
  const original = content;

  // 1. Cambiar nombres de SP de MAYÚSCULAS a minúsculas
  content = content.replace(/'SP_CEM_([A-Z_]+)'/g, (match, spName) => {
    return `'sp_cem_${spName.toLowerCase()}'`;
  });

  // 2. Agregar schema 'comun' a llamadas execute() que no lo tengan
  // Buscar patrones de execute( sin el 6to parámetro
  content = content.replace(
    /execute\(\s*'sp_cem_([^']+)',\s*'cementerios',\s*({[^}]*}|\[[\s\S]*?\])\s*\)/g,
    (match, spName, params) => {
      return `execute(\n      'sp_cem_${spName}',\n      'cementerios',\n      ${params},\n      '',\n      null,\n      'comun'\n    )`;
    }
  );

  // 3. Corregir acceso a response: response.length → response.result?.length
  content = content.replace(/if \(response && response\.length > 0\)/g,
    'if (response && response.result && response.result.length > 0)');

  // 4. Corregir asignaciones: = response → = response.result
  content = content.replace(/cementerios\.value = response(\s)/g, 'cementerios.value = response.result$1');
  content = content.replace(/datos\.value = response(\s)/g, 'datos.value = response.result$1');
  content = content.replace(/folios\.value = response(\s)/g, 'folios.value = response.result$1');
  content = content.replace(/pagos\.value = response(\s)/g, 'pagos.value = response.result$1');
  content = content.replace(/movimientos\.value = response(\s)/g, 'movimientos.value = response.result$1');
  content = content.replace(/titulos\.value = response(\s)/g, 'titulos.value = response.result$1');
  content = content.replace(/bonificaciones\.value = response(\s)/g, 'bonificaciones.value = response.result$1');

  // 5. Corregir accesos directos: response[0] → response.result[0]
  content = content.replace(/= response\[0\]/g, '= response.result[0]');
  content = content.replace(/const result = response\[0\]/g, 'const result = response.result[0]');

  // 6. Corregir iteraciones: response.forEach → response.result.forEach
  content = content.replace(/response\.forEach\(/g, 'response.result.forEach(');

  if (content !== original) {
    fs.writeFileSync(file, content, 'utf8');
    console.log(`✓ ${filename}`);
    fixed++;

    // Contar número de cambios
    const originalLines = original.split('\n');
    const newLines = content.split('\n');
    let lineChanges = 0;
    for (let i = 0; i < Math.max(originalLines.length, newLines.length); i++) {
      if (originalLines[i] !== newLines[i]) lineChanges++;
    }
    changes += lineChanges;
  }
});

console.log(`\n✅ ${fixed} archivos corregidos`);
console.log(`📝 ${changes} líneas modificadas\n`);
