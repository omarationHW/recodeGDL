#!/usr/bin/env node

/**
 * Script para analizar qué SPs usan los componentes de Cementerios
 */

const fs = require('fs');
const path = require('path');

const componentsDir = path.join(__dirname, '../src/views/modules/cementerios');

console.log('\n📊 ANÁLISIS DE SPs USADOS EN COMPONENTES\n');
console.log('='.repeat(80));

const files = fs.readdirSync(componentsDir).filter(f => f.endsWith('.vue') && !f.includes('_BACKUP'));
const spUsage = {};

files.forEach(filename => {
  const file = path.join(componentsDir, filename);
  const content = fs.readFileSync(file, 'utf8');

  // Buscar todas las llamadas a execute( con 'sp_
  const regex = /execute\(\s*'(sp_[^']+)'/g;
  let match;

  while ((match = regex.exec(content)) !== null) {
    const spName = match[1];

    if (!spUsage[spName]) {
      spUsage[spName] = [];
    }
    spUsage[spName].push(filename);
  }
});

// Ordenar SPs alfabéticamente
const sortedSPs = Object.keys(spUsage).sort();

console.log(`\nTotal de SPs únicos: ${sortedSPs.length}`);
console.log(`\nLISTA DE SPs NECESARIOS:\n`);

sortedSPs.forEach((sp, index) => {
  const components = spUsage[sp];
  console.log(`${(index + 1).toString().padStart(2)}. ${sp}`);
  console.log(`    Usado en: ${components.join(', ')}`);
  console.log('');
});

console.log('='.repeat(80));
console.log('\n✅ Análisis completado\n');

// Guardar resultado en archivo
const result = {
  total: sortedSPs.length,
  stored_procedures: sortedSPs.map(sp => ({
    name: sp,
    used_in: spUsage[sp]
  }))
};

const outputFile = path.join(__dirname, '../../../RefactorX/Base/cementerios/database/SPS_NECESARIOS.json');
fs.writeFileSync(outputFile, JSON.stringify(result, null, 2), 'utf8');
console.log(`📄 Resultado guardado en: SPS_NECESARIOS.json\n`);
