#!/usr/bin/env node

/**
 * Script para corregir errores de sintaxis (código duplicado)
 * Arregla el patrón: const response = const params = [...]
 */

const fs = require('fs');
const path = require('path');

const componentsDir = path.join(__dirname, '../src/views/modules/cementerios');

console.log('\n🔧 Corrigiendo errores de sintaxis...\n');

const files = fs.readdirSync(componentsDir).filter(f => f.endsWith('.vue'));
let fixed = 0;

files.forEach(filename => {
  const file = path.join(componentsDir, filename);
  let content = fs.readFileSync(file, 'utf8');
  const original = content;

  // Arreglar: const response = const params = [...]
  content = content.replace(/const response = const params = \[/g, 'const params = [');

  // Arreglar cualquier variante de doble declaración
  content = content.replace(/const response = (const|let|var) \w+ = /g, 'const ');

  if (content !== original) {
    fs.writeFileSync(file, content, 'utf8');
    console.log(`✓ ${filename}`);
    fixed++;
  }
});

console.log(`\n✅ ${fixed} archivos corregidos\n`);
