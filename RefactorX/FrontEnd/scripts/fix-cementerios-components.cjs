#!/usr/bin/env node

/**
 * Script automatizado para corregir TODOS los componentes de Cementerios
 * Convierte del formato antiguo de API al formato nuevo (execute)
 *
 * USO:
 *   node scripts/fix-cementerios-components.cjs
 */

const fs = require('fs');
const path = require('path');

// Colores para la terminal
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  red: '\x1b[31m'
};

// Componentes a corregir (excluir index.vue, Menu.vue, Modulo.vue - son diferentes)
const componentsToFix = [
  'ABCFolio.vue',
  'ABCPagos.vue',
  'ABCPagosxfol.vue',
  'ABCRecargos.vue',
  'ABCementer.vue',
  'Acceso.vue',
  'Bonificacion1.vue',
  'Bonificaciones.vue',
  'ConIndividual.vue',
  'Consulta400.vue',
  'ConsultaFol.vue',
  'ConsultaGuad.vue',
  'ConsultaJardin.vue',
  'ConsultaMezq.vue',
  'ConsultaNombre.vue',
  'ConsultaRCM.vue',
  'ConsultaSAndres.vue',
  'Descuentos.vue',
  'Duplicados.vue',
  'Estad_adeudo.vue',
  'Liquidaciones.vue',
  'List_Mov.vue',
  'Multiplefecha.vue',
  'MultipleNombre.vue',
  'MultipleRCM.vue',
  'Rep_Bon.vue',
  'Rep_a_Cobrar.vue',
  'RptTitulos.vue',
  'Titulos.vue',
  'TitulosSin.vue',
  'TrasladoFol.vue',
  'TrasladoFolSin.vue',
  'Traslados.vue',
  'sfrm_chgpass.vue'
];

const componentsDir = path.join(__dirname, '../src/views/modules/cementerios');
const backupDir = path.join(componentsDir, '_BACKUP_ORIGINAL');

let stats = {
  processed: 0,
  fixed: 0,
  skipped: 0,
  errors: 0
};

console.log(`\n${colors.bright}${colors.cyan}===============================================${colors.reset}`);
console.log(`${colors.bright}${colors.cyan}CORRECCIÓN AUTOMÁTICA - COMPONENTES CEMENTERIOS${colors.reset}`);
console.log(`${colors.bright}${colors.cyan}===============================================${colors.reset}\n`);

// Crear directorio de backup si no existe
if (!fs.existsSync(backupDir)) {
  fs.mkdirSync(backupDir, { recursive: true });
  console.log(`${colors.green}✓${colors.reset} Creado directorio de backup: ${backupDir}\n`);
}

/**
 * Función principal de corrección
 */
function fixComponent(componentName) {
  const filePath = path.join(componentsDir, componentName);
  const backupPath = path.join(backupDir, componentName);

  console.log(`${colors.blue}[${stats.processed + 1}/${componentsToFix.length}]${colors.reset} Procesando: ${colors.bright}${componentName}${colors.reset}`);

  if (!fs.existsSync(filePath)) {
    console.log(`  ${colors.yellow}⚠${colors.reset} Archivo no encontrado, omitiendo...\n`);
    stats.skipped++;
    return;
  }

  try {
    // Leer contenido original
    let content = fs.readFileSync(filePath, 'utf8');
    let originalContent = content;
    let changed = false;

    // ==================================================
    // 1. CORRECCIONES EN <script setup>
    // ==================================================

    // 1.1 Cambiar importación de useApi
    if (content.includes('const api = useApi()') || content.includes('const api=useApi()')) {
      content = content.replace(
        /const\s+api\s*=\s*useApi\(\)/g,
        'const { execute } = useApi()'
      );
      changed = true;
    }

    // 1.2 Agregar import de useGlobalLoading si no existe
    if (!content.includes('useGlobalLoading') && content.includes('from \'@/composables/useApi\'')) {
      content = content.replace(
        /(import.*from\s+'@\/composables\/useApi')/,
        `$1\nimport { useGlobalLoading } from '@/composables/useGlobalLoading'`
      );
      changed = true;
    }

    // 1.3 Inicializar useGlobalLoading si no existe
    if (content.includes('useGlobalLoading') && !content.includes('showLoading, hideLoading')) {
      content = content.replace(
        /(const\s+\{\s*execute\s*\}\s*=\s*useApi\(\))/,
        `$1\nconst { showLoading, hideLoading } = useGlobalLoading()`
      );
      changed = true;
    }

    // 1.4 Agregar variables para DocumentationModal si no existen
    if (!content.includes('showDocumentation')) {
      // Buscar después de las importaciones de composables
      content = content.replace(
        /(const\s+toast\s*=\s*useToast\(\))/,
        `$1\n\n// Modal de documentación\nconst showDocumentation = ref(false)\nconst openDocumentation = () => showDocumentation.value = true\nconst closeDocumentation = () => showDocumentation.value = false`
      );
      changed = true;
    }

    // 1.5 Convertir llamadas api.callStoredProcedure a execute
    const apiCallRegex = /await\s+api\.callStoredProcedure\s*\(\s*['"]([^'"]+)['"]\s*,\s*\{([^}]+)\}\s*\)/g;

    if (apiCallRegex.test(content)) {
      content = content.replace(apiCallRegex, (match, spName, params) => {
        // Extraer parámetros del formato antiguo {p_param1: valor1, p_param2: valor2}
        const paramMatches = Array.from(params.matchAll(/(\w+)\s*:\s*([^,}]+)/g));
        const paramsArray = [];

        for (const matchItem of paramMatches) {
          const paramName = matchItem[1];
          const paramValue = matchItem[2];
          const cleanValue = paramValue.trim();
          let tipo = 'string';

          // Intentar detectar tipo
          if (cleanValue.includes('value') || cleanValue.includes('ref') || cleanValue.includes('.')) {
            // Es una variable, intentar detectar tipo por nombre
            if (paramName.includes('id') || paramName.includes('anio') || paramName.includes('año')) {
              tipo = 'integer';
            } else if (paramName.includes('fecha') || paramName.includes('date')) {
              tipo = 'date';
            }
          }

          paramsArray.push(`      {\n        nombre: '${paramName}',\n        valor: ${cleanValue},\n        tipo: '${tipo}'\n      }`);
        }

        const spNameLower = spName.toLowerCase();
        const paramsStr = paramsArray.length > 0
          ? `const params = [\n${paramsArray.join(',\n')}\n    ]\n\n    const response = await execute(\n      '${spNameLower}',\n      'cementerios',\n      params,\n      'cementerios',\n      null,\n      'public'\n    )`
          : `const response = await execute(\n      '${spNameLower}',\n      'cementerios',\n      [],\n      'cementerios',\n      null,\n      'public'\n    )`;

        return paramsStr;
      });
      changed = true;
    }

    // 1.6 Cambiar response.data a response.result
    if (content.includes('response.data')) {
      content = content.replace(/response\.data/g, 'response.result');
      changed = true;
    }

    // ==================================================
    // 2. CORRECCIONES EN <template>
    // ==================================================

    // 2.1 Cambiar module-container a module-view
    content = content.replace(/<div class="module-container">/g, '<div class="module-view">');
    content = content.replace(/class="module-container"/g, 'class="module-view"');

    // 2.2 Cambiar module-header a module-view-header
    content = content.replace(/class="module-header"/g, 'class="module-view-header"');

    // 2.3 Cambiar module-title
    content = content.replace(/class="module-title"/g, 'class="module-view-info"');

    // 2.4 Cambiar card a municipal-card
    content = content.replace(/<div class="card( [^"]*)?">/g, '<div class="municipal-card$1">');
    content = content.replace(/class="card"/g, 'class="municipal-card"');
    content = content.replace(/class="card /g, 'class="municipal-card ');

    // 2.5 Cambiar card-header a municipal-card-header
    content = content.replace(/class="card-header"/g, 'class="municipal-card-header"');

    // 2.6 Cambiar card-body a municipal-card-body
    content = content.replace(/class="card-body"/g, 'class="municipal-card-body"');

    // 2.7 Cambiar form-control a municipal-form-control
    content = content.replace(/class="form-control"/g, 'class="municipal-form-control"');

    // 2.8 Cambiar form-label a municipal-form-label
    content = content.replace(/class="form-label"/g, 'class="municipal-form-label"');

    // 2.9 Cambiar data-table a municipal-table
    content = content.replace(/class="data-table"/g, 'class="municipal-table"');

    // 2.10 Agregar municipal-table-header a thead
    content = content.replace(/<thead>/g, '<thead class="municipal-table-header">');

    // 2.11 Cambiar iconos <i class="fas fa-..."> a <font-awesome-icon icon="...">
    content = content.replace(/<i class="fas fa-([^"]+)"><\/i>/g, '<font-awesome-icon icon="$1" />');

    // 2.12 Agregar DocumentationModal al final del template si no existe
    if (!content.includes('<DocumentationModal')) {
      const templateEndRegex = /(<\/template>)/;
      const componentNameMatch = componentName.match(/^(.+)\.vue$/);
      const componentNameBase = componentNameMatch ? componentNameMatch[1] : 'Component';

      const docModalCode = `
  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'${componentNameBase}'"
    :moduleName="'cementerios'"
    @close="closeDocumentation"
  />
</template>`;

      content = content.replace(templateEndRegex, docModalCode);
      changed = true;
    }

    // ==================================================
    // 3. GUARDAR CAMBIOS
    // ==================================================

    if (changed || content !== originalContent) {
      // Hacer backup del original
      fs.copyFileSync(filePath, backupPath);

      // Guardar archivo corregido
      fs.writeFileSync(filePath, content, 'utf8');

      console.log(`  ${colors.green}✓${colors.reset} Corregido y guardado\n`);
      stats.fixed++;
    } else {
      console.log(`  ${colors.yellow}○${colors.reset} Sin cambios necesarios\n`);
      stats.skipped++;
    }

    stats.processed++;

  } catch (error) {
    console.log(`  ${colors.red}✗${colors.reset} Error: ${error.message}\n`);
    stats.errors++;
  }
}

// ==================================================
// PROCESO PRINCIPAL
// ==================================================

console.log(`${colors.cyan}Componentes a procesar: ${componentsToFix.length}${colors.reset}\n`);

componentsToFix.forEach(fixComponent);

// ==================================================
// RESUMEN FINAL
// ==================================================

console.log(`\n${colors.bright}${colors.cyan}===============================================${colors.reset}`);
console.log(`${colors.bright}${colors.cyan}RESUMEN DE CORRECCIÓN${colors.reset}`);
console.log(`${colors.bright}${colors.cyan}===============================================${colors.reset}\n`);

console.log(`  Total procesados:     ${colors.bright}${stats.processed}${colors.reset}`);
console.log(`  ${colors.green}Corregidos:          ${stats.fixed}${colors.reset}`);
console.log(`  ${colors.yellow}Omitidos:            ${stats.skipped}${colors.reset}`);
console.log(`  ${colors.red}Errores:             ${stats.errors}${colors.reset}`);

console.log(`\n${colors.bright}Backup guardado en:${colors.reset} ${backupDir}`);

if (stats.fixed > 0) {
  console.log(`\n${colors.green}${colors.bright}✓ CORRECCIÓN COMPLETADA EXITOSAMENTE${colors.reset}`);
  console.log(`\n${colors.cyan}Siguiente paso:${colors.reset}`);
  console.log(`  1. Verificar que no haya errores de compilación: ${colors.bright}npm run lint${colors.reset}`);
  console.log(`  2. Iniciar el servidor de desarrollo: ${colors.bright}npm run dev${colors.reset}`);
  console.log(`  3. Probar componentes en el navegador`);
} else {
  console.log(`\n${colors.yellow}${colors.bright}⚠ No se realizaron cambios${colors.reset}`);
}

console.log(`\n${colors.bright}${colors.cyan}===============================================${colors.reset}\n`);

process.exit(stats.errors > 0 ? 1 : 0);
