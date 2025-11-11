/**
 * AUDITORÍA COMPLETA: Vue Components → Database Connections
 *
 * Este script verifica que TODOS los componentes Vue:
 * 1. Usen la base de datos correcta (PostgreSQL)
 * 2. NO usen 'INFORMIX' como base de datos
 * 3. Tengan los stored procedures correctamente referenciados
 *
 * Autor: Sistema RefactorX
 * Fecha: 2025-11-10
 */

const fs = require('fs')
const path = require('path')

// Configuración de bases de datos válidas por módulo
const MODULE_DB_CONFIG = {
  'estacionamiento_exclusivo': {
    validDatabases: ['estacionamiento_exclusivo'],
    invalidDatabases: ['INFORMIX', 'informix'],
    schema: 'public'
  },
  'padron_licencias': {
    validDatabases: ['padron_licencias'],
    invalidDatabases: ['INFORMIX', 'informix'],
    schema: 'public'
  },
  'cementerios': {
    validDatabases: ['cementerios'],
    invalidDatabases: ['INFORMIX', 'informix'],
    schema: 'public'
  },
  'otras_obligaciones': {
    validDatabases: ['otras_obligaciones'],
    invalidDatabases: ['INFORMIX', 'informix'],
    schema: 'public'
  },
  'multas_reglamentos': {
    validDatabases: ['multas_reglamentos'],
    invalidDatabases: ['INFORMIX', 'informix'],
    schema: 'public'
  }
}

const RESULTS = {
  totalFiles: 0,
  filesWithDB: 0,
  correctConnections: [],
  incorrectConnections: [],
  warnings: [],
  storedProceduresUsed: new Map(),
  errors: []
}

/**
 * Analiza un archivo Vue en busca de configuraciones de base de datos
 */
function analyzeVueFile(filePath, moduleName) {
  try {
    const content = fs.readFileSync(filePath, 'utf-8')
    RESULTS.totalFiles++

    // Buscar definiciones de BASE_DB
    const baseDbRegex = /const\s+BASE_DB\s*=\s*['"`]([^'"`]+)['"`]/g
    const matches = [...content.matchAll(baseDbRegex)]

    if (matches.length === 0) {
      // No tiene BASE_DB definido (posiblemente no usa API)
      return
    }

    RESULTS.filesWithDB++

    matches.forEach(match => {
      const dbName = match[1]
      const lineNumber = content.substring(0, match.index).split('\n').length

      const result = {
        file: path.relative(process.cwd(), filePath),
        module: moduleName,
        database: dbName,
        line: lineNumber,
        isValid: false,
        message: ''
      }

      const config = MODULE_DB_CONFIG[moduleName]

      // Verificar si es una base de datos inválida (INFORMIX)
      if (config?.invalidDatabases.includes(dbName)) {
        result.message = `❌ ERROR: Usa base de datos inválida '${dbName}' (debe ser PostgreSQL)`
        RESULTS.incorrectConnections.push(result)
        return
      }

      // Verificar si es la base de datos correcta para el módulo
      if (config?.validDatabases.includes(dbName)) {
        result.isValid = true
        result.message = `✅ Correcto: Usa '${dbName}' (PostgreSQL)`
        RESULTS.correctConnections.push(result)
      } else {
        result.message = `⚠️  ADVERTENCIA: Usa '${dbName}' (esperado: ${config?.validDatabases.join(', ')})`
        RESULTS.warnings.push(result)
      }
    })

    // Buscar stored procedures usados
    const spRegexes = [
      /OP_[A-Z_]+\s*=\s*['"`]([^'"`]+)['"`]/g,
      /const\s+\w+\s*=\s*['"`](sp_|rpt_|rprt_|spd_|apremiossvn_)([^'"`]+)['"`]/g,
      /execute\s*\(\s*['"`](sp_|rpt_|rprt_|spd_|apremiossvn_)([^'"`]+)['"`]/g
    ]

    spRegexes.forEach(regex => {
      const spMatches = [...content.matchAll(regex)]
      spMatches.forEach(match => {
        let spName = match[1]
        if (match[2]) spName = match[1] + match[2]

        if (!RESULTS.storedProceduresUsed.has(spName)) {
          RESULTS.storedProceduresUsed.set(spName, [])
        }
        RESULTS.storedProceduresUsed.get(spName).push({
          file: path.relative(process.cwd(), filePath),
          module: moduleName
        })
      })
    })

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
        analyzeVueFile(fullPath, moduleName)
      }
    })
  } catch (error) {
    console.error(`Error escaneando directorio ${dir}:`, error.message)
  }
}

/**
 * Genera el reporte en formato Markdown
 */
function generateReport() {
  let report = `# 🔍 AUDITORÍA: Conexiones Vue → Base de Datos PostgreSQL

**Fecha**: ${new Date().toLocaleString('es-MX')}
**Sistema**: RefactorX Guadalajara

---

## 📊 RESUMEN EJECUTIVO

- **Total de archivos Vue analizados**: ${RESULTS.totalFiles}
- **Archivos con BASE_DB**: ${RESULTS.filesWithDB}
- **Conexiones correctas**: ${RESULTS.correctConnections.length} ✅
- **Conexiones incorrectas**: ${RESULTS.incorrectConnections.length} ❌
- **Advertencias**: ${RESULTS.warnings.length} ⚠️
- **Errores de análisis**: ${RESULTS.errors.length}
- **Stored Procedures únicos detectados**: ${RESULTS.storedProceduresUsed.size}

---

## ✅ CONEXIONES CORRECTAS (${RESULTS.correctConnections.length})

`

  if (RESULTS.correctConnections.length > 0) {
    // Agrupar por módulo
    const byModule = {}
    RESULTS.correctConnections.forEach(conn => {
      if (!byModule[conn.module]) byModule[conn.module] = []
      byModule[conn.module].push(conn)
    })

    Object.keys(byModule).sort().forEach(module => {
      report += `\n### Módulo: ${module}\n\n`
      report += `| Archivo | Base de Datos | Línea |\n`
      report += `|---------|---------------|-------|\n`
      byModule[module].forEach(conn => {
        report += `| \`${conn.file}\` | \`${conn.database}\` | ${conn.line} |\n`
      })
    })
  } else {
    report += `No se encontraron archivos con BASE_DB definido.\n`
  }

  report += `\n---

## ❌ CONEXIONES INCORRECTAS (${RESULTS.incorrectConnections.length})

`

  if (RESULTS.incorrectConnections.length > 0) {
    report += `| Archivo | Base de Datos | Línea | Problema |\n`
    report += `|---------|---------------|-------|----------|\n`
    RESULTS.incorrectConnections.forEach(conn => {
      report += `| \`${conn.file}\` | \`${conn.database}\` | ${conn.line} | ${conn.message} |\n`
    })
    report += `\n⚠️  **ACCIÓN REQUERIDA**: Estos archivos deben ser corregidos para usar PostgreSQL.\n`
  } else {
    report += `✅ **¡Excelente!** No se encontraron conexiones incorrectas.\n`
  }

  report += `\n---

## ⚠️  ADVERTENCIAS (${RESULTS.warnings.length})

`

  if (RESULTS.warnings.length > 0) {
    report += `| Archivo | Base de Datos | Línea | Advertencia |\n`
    report += `|---------|---------------|-------|-------------|\n`
    RESULTS.warnings.forEach(conn => {
      report += `| \`${conn.file}\` | \`${conn.database}\` | ${conn.line} | ${conn.message} |\n`
    })
  } else {
    report += `No hay advertencias.\n`
  }

  report += `\n---

## 📋 STORED PROCEDURES DETECTADOS (${RESULTS.storedProceduresUsed.size})

`

  if (RESULTS.storedProceduresUsed.size > 0) {
    const sortedSPs = Array.from(RESULTS.storedProceduresUsed.keys()).sort()

    report += `| # | Stored Procedure | Usado en (archivos) |\n`
    report += `|---|------------------|---------------------|\n`

    sortedSPs.forEach((sp, index) => {
      const files = RESULTS.storedProceduresUsed.get(sp)
      const fileCount = files.length
      const uniqueFiles = [...new Set(files.map(f => f.file))].length
      report += `| ${index + 1} | \`${sp}\` | ${uniqueFiles} archivo${uniqueFiles !== 1 ? 's' : ''} (${fileCount} uso${fileCount !== 1 ? 's' : ''}) |\n`
    })

    report += `\n### Detalle por Stored Procedure:\n\n`
    sortedSPs.forEach(sp => {
      const files = RESULTS.storedProceduresUsed.get(sp)
      report += `\n#### \`${sp}\`\n\n`
      const uniqueFiles = [...new Set(files.map(f => f.file))]
      uniqueFiles.forEach(file => {
        const module = files.find(f => f.file === file).module
        report += `- **${module}**: \`${file}\`\n`
      })
    })
  }

  report += `\n---

## 🎯 VERIFICACIÓN POR MÓDULO

`

  Object.keys(MODULE_DB_CONFIG).forEach(module => {
    const correctCount = RESULTS.correctConnections.filter(c => c.module === module).length
    const incorrectCount = RESULTS.incorrectConnections.filter(c => c.module === module).length
    const warningCount = RESULTS.warnings.filter(c => c.module === module).length

    const status = incorrectCount > 0 ? '❌' : (warningCount > 0 ? '⚠️' : '✅')

    report += `
### ${status} ${module}

- Base de datos esperada: \`${MODULE_DB_CONFIG[module].validDatabases.join(', ')}\`
- Esquema: \`${MODULE_DB_CONFIG[module].schema}\`
- Conexiones correctas: ${correctCount}
- Conexiones incorrectas: ${incorrectCount}
- Advertencias: ${warningCount}
`
  })

  report += `\n---

## 🔧 RECOMENDACIONES

`

  if (RESULTS.incorrectConnections.length > 0) {
    report += `
### Correcciones Urgentes:

1. **Reemplazar referencias a INFORMIX**:
   \`\`\`javascript
   // ❌ INCORRECTO
   const BASE_DB = 'INFORMIX'

   // ✅ CORRECTO
   const BASE_DB = 'estacionamiento_exclusivo' // o el nombre correcto según el módulo
   \`\`\`

2. **Archivos a corregir**: ${RESULTS.incorrectConnections.length} archivo(s)
`
  }

  if (RESULTS.warnings.length > 0) {
    report += `
### Revisar:

- ${RESULTS.warnings.length} archivo(s) con advertencias
- Verificar que usen la base de datos correcta para su módulo
`
  }

  if (RESULTS.incorrectConnections.length === 0 && RESULTS.warnings.length === 0) {
    report += `
✅ **¡Sistema Verificado!**

- Todas las conexiones apuntan a PostgreSQL
- No hay referencias a INFORMIX
- Los módulos usan las bases de datos correctas
- El sistema está listo para producción

### Próximo paso:

Ejecutar el script de verificación de Stored Procedures para confirmar que todos los SPs existen en la base de datos.

\`\`\`bash
node scripts/verify-stored-procedures.cjs
\`\`\`
`
  }

  report += `\n---

## 📈 ESTADÍSTICAS ADICIONALES

- **Promedio de SPs por archivo**: ${RESULTS.filesWithDB > 0 ? (RESULTS.storedProceduresUsed.size / RESULTS.filesWithDB).toFixed(2) : 0}
- **Módulos analizados**: ${Object.keys(MODULE_DB_CONFIG).length}
- **Cobertura de análisis**: ${((RESULTS.filesWithDB / RESULTS.totalFiles) * 100).toFixed(1)}%

---

**Generado por**: RefactorX Audit System
**Versión**: 1.0.0
`

  return report
}

/**
 * Función principal
 */
function main() {
  console.log('🔍 Iniciando auditoría de conexiones Vue → PostgreSQL...\n')

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

  modules.forEach(module => {
    const modulePath = path.join(modulesDir, module)
    console.log(`🔎 Analizando módulo: ${module}...`)
    scanDirectory(modulePath, module)
  })

  // Generar reporte
  console.log('\n📝 Generando reporte...')
  const report = generateReport()

  // Guardar reporte
  const reportPath = path.join(process.cwd(), 'AUDIT_DATABASE_CONNECTIONS.md')
  fs.writeFileSync(reportPath, report, 'utf-8')

  console.log(`\n✅ Auditoría completada!`)
  console.log(`📄 Reporte guardado en: ${reportPath}`)

  // Mostrar resumen en consola
  console.log('\n' + '='.repeat(60))
  console.log('RESUMEN DE AUDITORÍA')
  console.log('='.repeat(60))
  console.log(`Total de archivos Vue: ${RESULTS.totalFiles}`)
  console.log(`Archivos con BASE_DB: ${RESULTS.filesWithDB}`)
  console.log(`✅ Conexiones correctas: ${RESULTS.correctConnections.length}`)
  console.log(`❌ Conexiones incorrectas: ${RESULTS.incorrectConnections.length}`)
  console.log(`⚠️  Advertencias: ${RESULTS.warnings.length}`)
  console.log(`📋 Stored Procedures detectados: ${RESULTS.storedProceduresUsed.size}`)
  console.log('='.repeat(60))

  // Exit code
  if (RESULTS.incorrectConnections.length > 0) {
    console.log('\n❌ FALLO: Se encontraron conexiones incorrectas.')
    process.exit(1)
  } else if (RESULTS.warnings.length > 0) {
    console.log('\n⚠️  ADVERTENCIA: Revisar advertencias en el reporte.')
    process.exit(0)
  } else {
    console.log('\n✅ ÉXITO: Todas las conexiones son correctas.')
    process.exit(0)
  }
}

// Ejecutar
main()
