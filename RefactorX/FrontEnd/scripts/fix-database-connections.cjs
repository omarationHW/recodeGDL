/**
 * CORRECCIÓN MASIVA: INFORMIX → PostgreSQL
 *
 * Este script corrige TODAS las referencias de BASE_DB = 'INFORMIX'
 * a la base de datos correcta según el módulo.
 *
 * Autor: Sistema RefactorX
 * Fecha: 2025-11-10
 */

const fs = require('fs')
const path = require('path')

// Configuración: Módulo → Base de datos PostgreSQL
const MODULE_DB_MAPPING = {
  'estacionamiento_exclusivo': 'estacionamiento_exclusivo',
  'padron_licencias': 'padron_licencias',
  'cementerios': 'cementerios',
  'aseo_contratado': 'aseo_contratado',
  'multas_reglamentos': 'multas_reglamentos',
  'otras_obligaciones': 'otras_obligaciones',
  'estacionamiento_publico': 'estacionamiento_publico',
  'mercados': 'mercados'
}

const RESULTS = {
  totalFiles: 0,
  filesScanned: 0,
  filesWithInformix: 0,
  filesCorrected: 0,
  filesSkipped: 0,
  corrections: [],
  errors: []
}

/**
 * Corrige un archivo Vue reemplazando INFORMIX por la base correcta
 */
function fixVueFile(filePath, moduleName) {
  try {
    RESULTS.filesScanned++
    const content = fs.readFileSync(filePath, 'utf-8')

    // Buscar todas las referencias a INFORMIX
    const informixPatterns = [
      /const\s+BASE_DB\s*=\s*['"`]INFORMIX['"`]/g,
      /const\s+BASE_DB\s*=\s*['"`]informix['"`]/g,
      /BASE_DB:\s*['"`]INFORMIX['"`]/g,
      /BASE_DB:\s*['"`]informix['"`]/g
    ]

    let hasInformix = false
    let newContent = content

    informixPatterns.forEach(pattern => {
      if (pattern.test(content)) {
        hasInformix = true
      }
    })

    if (!hasInformix) {
      return // No tiene INFORMIX, saltar
    }

    RESULTS.filesWithInformix++

    // Obtener base de datos correcta para este módulo
    const correctDB = MODULE_DB_MAPPING[moduleName]

    if (!correctDB) {
      RESULTS.errors.push({
        file: filePath,
        error: `Módulo '${moduleName}' no tiene base de datos mapeada`
      })
      RESULTS.filesSkipped++
      return
    }

    // Realizar reemplazos
    const replacements = [
      { from: /const\s+BASE_DB\s*=\s*['"`]INFORMIX['"`]/g, to: `const BASE_DB = '${correctDB}'` },
      { from: /const\s+BASE_DB\s*=\s*['"`]informix['"`]/g, to: `const BASE_DB = '${correctDB}'` },
      { from: /BASE_DB:\s*['"`]INFORMIX['"`]/g, to: `BASE_DB: '${correctDB}'` },
      { from: /BASE_DB:\s*['"`]informix['"`]/g, to: `BASE_DB: '${correctDB}'` }
    ]

    let changesMade = 0
    replacements.forEach(({ from, to }) => {
      const matches = content.match(from)
      if (matches) {
        changesMade += matches.length
        newContent = newContent.replace(from, to)
      }
    })

    if (changesMade > 0) {
      // Escribir archivo corregido
      fs.writeFileSync(filePath, newContent, 'utf-8')

      RESULTS.filesCorrected++
      RESULTS.corrections.push({
        file: path.relative(process.cwd(), filePath),
        module: moduleName,
        database: correctDB,
        changes: changesMade
      })

      console.log(`✓ ${path.basename(filePath)} → ${correctDB} (${changesMade} cambios)`)
    }

  } catch (error) {
    RESULTS.errors.push({
      file: filePath,
      error: error.message
    })
  }
}

/**
 * Escanea recursivamente un directorio en busca de archivos .vue
 */
function scanDirectory(dir, moduleName) {
  try {
    const entries = fs.readdirSync(dir, { withFileTypes: true })

    entries.forEach(entry => {
      const fullPath = path.join(dir, entry.name)

      if (entry.isDirectory()) {
        scanDirectory(fullPath, moduleName)
      } else if (entry.isFile() && entry.name.endsWith('.vue')) {
        RESULTS.totalFiles++
        fixVueFile(fullPath, moduleName)
      }
    })
  } catch (error) {
    console.error(`Error escaneando directorio ${dir}:`, error.message)
  }
}

/**
 * Genera reporte de correcciones
 */
function generateReport() {
  let report = `# 🔧 CORRECCIÓN MASIVA: INFORMIX → PostgreSQL

**Fecha**: ${new Date().toLocaleString('es-MX')}
**Sistema**: RefactorX Guadalajara

---

## 📊 RESUMEN EJECUTIVO

- **Total de archivos Vue**: ${RESULTS.totalFiles}
- **Archivos escaneados**: ${RESULTS.filesScanned}
- **Archivos con INFORMIX**: ${RESULTS.filesWithInformix}
- **✅ Archivos corregidos**: ${RESULTS.filesCorrected}
- **⏭️  Archivos omitidos**: ${RESULTS.filesSkipped}
- **❌ Errores**: ${RESULTS.errors.length}

### Estado:
${RESULTS.filesCorrected > 0
  ? `✅ **ÉXITO**: Se corrigieron ${RESULTS.filesCorrected} archivo(s) de ${RESULTS.filesWithInformix}`
  : '⚠️  **SIN CAMBIOS**: No se encontraron archivos con INFORMIX'}

---

## ✅ ARCHIVOS CORREGIDOS (${RESULTS.filesCorrected})

`

  if (RESULTS.corrections.length > 0) {
    // Agrupar por módulo
    const byModule = {}
    RESULTS.corrections.forEach(corr => {
      if (!byModule[corr.module]) byModule[corr.module] = []
      byModule[corr.module].push(corr)
    })

    Object.keys(byModule).sort().forEach(module => {
      report += `\n### Módulo: ${module} → \`${MODULE_DB_MAPPING[module]}\`\n\n`
      report += `**Total corregido**: ${byModule[module].length} archivo(s)\n\n`
      report += `| Archivo | Cambios |\n`
      report += `|---------|--------|\n`

      byModule[module].forEach(corr => {
        report += `| \`${corr.file}\` | ${corr.changes} |\n`
      })
    })
  } else {
    report += `No se realizaron correcciones.\n`
  }

  report += `\n---

## ❌ ERRORES (${RESULTS.errors.length})

`

  if (RESULTS.errors.length > 0) {
    report += `| Archivo | Error |\n`
    report += `|---------|-------|\n`
    RESULTS.errors.forEach(err => {
      report += `| \`${err.file}\` | ${err.error} |\n`
    })
  } else {
    report += `No se encontraron errores.\n`
  }

  report += `\n---

## 📋 MAPEO DE BASES DE DATOS

| Módulo | Base de Datos PostgreSQL | Esquema |
|--------|--------------------------|---------|
`

  Object.keys(MODULE_DB_MAPPING).forEach(module => {
    report += `| ${module} | \`${MODULE_DB_MAPPING[module]}\` | public |\n`
  })

  report += `\n### Base Común:

- **Base**: \`padron_licencias\`
- **Esquema**: \`comun\`
- **Tablas compartidas**: ta_12_*, ta_cat_*, etc.
- **Acceso**: Todos los módulos pueden referenciar \`padron_licencias.comun.tabla\`

---

## 🎯 VERIFICACIÓN

Para verificar que todos los cambios se aplicaron correctamente:

\`\`\`bash
# Buscar si aún quedan referencias a INFORMIX
cd RefactorX/FrontEnd
grep -r "BASE_DB.*INFORMIX" src/views/modules/

# Debería retornar: (sin resultados)
\`\`\`

---

## 📈 ESTADÍSTICAS

- **Módulos procesados**: ${Object.keys(MODULE_DB_MAPPING).length}
- **Tasa de éxito**: ${RESULTS.filesWithInformix > 0 ? ((RESULTS.filesCorrected / RESULTS.filesWithInformix) * 100).toFixed(1) : 0}%
- **Total de cambios aplicados**: ${RESULTS.corrections.reduce((sum, c) => sum + c.changes, 0)}

---

**Generado por**: RefactorX Fix System
**Versión**: 1.0.0
`

  return report
}

/**
 * Función principal
 */
function main() {
  console.log('🔧 Iniciando corrección masiva INFORMIX → PostgreSQL...\n')

  const modulesDir = path.join(process.cwd(), 'src', 'views', 'modules')

  if (!fs.existsSync(modulesDir)) {
    console.error('❌ Error: No se encontró el directorio de módulos:', modulesDir)
    process.exit(1)
  }

  // Escanear cada módulo
  const modules = fs.readdirSync(modulesDir, { withFileTypes: true })
    .filter(entry => entry.isDirectory())
    .map(entry => entry.name)

  console.log(`📁 Módulos encontrados: ${modules.length}`)
  modules.forEach(module => console.log(`   - ${module}`))
  console.log()

  // Procesar cada módulo
  modules.forEach(module => {
    const modulePath = path.join(modulesDir, module)
    console.log(`🔎 Procesando módulo: ${module}...`)
    scanDirectory(modulePath, module)
  })

  // Generar reporte
  console.log('\n📝 Generando reporte...')
  const report = generateReport()

  const reportPath = path.join(process.cwd(), 'FIX_DATABASE_CONNECTIONS.md')
  fs.writeFileSync(reportPath, report, 'utf-8')

  console.log(`\n✅ Corrección completada!`)
  console.log(`📄 Reporte guardado en: ${reportPath}`)

  // Mostrar resumen en consola
  console.log('\n' + '='.repeat(60))
  console.log('RESUMEN DE CORRECCIONES')
  console.log('='.repeat(60))
  console.log(`Total de archivos Vue: ${RESULTS.totalFiles}`)
  console.log(`Archivos con INFORMIX: ${RESULTS.filesWithInformix}`)
  console.log(`✅ Archivos corregidos: ${RESULTS.filesCorrected}`)
  console.log(`❌ Errores: ${RESULTS.errors.length}`)
  console.log(`📊 Total de cambios: ${RESULTS.corrections.reduce((sum, c) => sum + c.changes, 0)}`)
  console.log('='.repeat(60))

  // Exit code
  if (RESULTS.errors.length > 0) {
    console.log('\n⚠️  ADVERTENCIA: Se encontraron errores durante la corrección.')
    process.exit(0)
  } else if (RESULTS.filesCorrected > 0) {
    console.log('\n✅ ÉXITO: Todos los archivos fueron corregidos.')
    process.exit(0)
  } else {
    console.log('\n✅ SISTEMA LIMPIO: No se encontraron referencias a INFORMIX.')
    process.exit(0)
  }
}

// Ejecutar
main()
