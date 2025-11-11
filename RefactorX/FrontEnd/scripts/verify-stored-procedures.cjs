/**
 * VERIFICACIÓN COMPLETA: Stored Procedures
 *
 * Este script verifica que:
 * 1. Todos los SPs usados en Vue existan en archivos SQL
 * 2. Los SPs tengan sintaxis PostgreSQL correcta
 * 3. No haya SPs faltantes
 *
 * Autor: Sistema RefactorX
 * Fecha: 2025-11-10
 */

const fs = require('fs')
const path = require('path')

const RESULTS = {
  storedProceduresInVue: new Map(),
  storedProceduresInSQL: new Map(),
  missing: [],
  found: [],
  syntaxIssues: [],
  totalVueFiles: 0,
  totalSQLFiles: 0
}

/**
 * Extrae SPs usados en archivos Vue
 */
function extractSPsFromVue(dir) {
  function scan(directory) {
    const entries = fs.readdirSync(directory, { withFileTypes: true })

    entries.forEach(entry => {
      const fullPath = path.join(directory, entry.name)

      if (entry.isDirectory()) {
        scan(fullPath)
      } else if (entry.isFile() && entry.name.endsWith('.vue')) {
        RESULTS.totalVueFiles++
        const content = fs.readFileSync(fullPath, 'utf-8')

        // Buscar definiciones de SPs
        const patterns = [
          /OP_[A-Z_]+\s*=\s*['"`]([^'"`]+)['"`]/g,
          /execute\s*\(\s*['"`]([^'"`\s]+)['"`]/g,
          /const\s+\w+\s*=\s*['"`](sp_|rpt_|rprt_|spd_|apremiossvn_)([^'"`]+)['"`]/g
        ]

        patterns.forEach(pattern => {
          const matches = [...content.matchAll(pattern)]
          matches.forEach(match => {
            let spName = match[1]
            if (match[2]) spName = match[1] + match[2]

            // Normalizar a minúsculas (PostgreSQL)
            spName = spName.toLowerCase()

            if (!RESULTS.storedProceduresInVue.has(spName)) {
              RESULTS.storedProceduresInVue.set(spName, [])
            }
            RESULTS.storedProceduresInVue.get(spName).push(fullPath)
          })
        })
      }
    })
  }

  scan(dir)
}

/**
 * Extrae SPs definidos en archivos SQL
 */
function extractSPsFromSQL(basePath) {
  const moduleDirs = fs.readdirSync(basePath, { withFileTypes: true })
    .filter(entry => entry.isDirectory())

  moduleDirs.forEach(moduleDir => {
    const modulePath = path.join(basePath, moduleDir.name)
    const databaseDir = path.join(modulePath, 'database', 'database')

    if (fs.existsSync(databaseDir)) {
      scanSQLFiles(databaseDir)
    }
  })
}

function scanSQLFiles(dir) {
  try {
    const entries = fs.readdirSync(dir, { withFileTypes: true })

    entries.forEach(entry => {
      const fullPath = path.join(dir, entry.name)

      if (entry.isDirectory()) {
        scanSQLFiles(fullPath)
      } else if (entry.isFile() && entry.name.endsWith('.sql')) {
        RESULTS.totalSQLFiles++
        const content = fs.readFileSync(fullPath, 'utf-8')

        // Buscar definiciones de FUNCTION o PROCEDURE
        const patterns = [
          /CREATE\s+(?:OR\s+REPLACE\s+)?FUNCTION\s+([a-z0-9_]+)/gi,
          /CREATE\s+(?:OR\s+REPLACE\s+)?PROCEDURE\s+([a-z0-9_]+)/gi
        ]

        patterns.forEach(pattern => {
          const matches = [...content.matchAll(pattern)]
          matches.forEach(match => {
            const spName = match[1].toLowerCase()

            if (!RESULTS.storedProceduresInSQL.has(spName)) {
              RESULTS.storedProceduresInSQL.set(spName, {
                files: [],
                isFunction: match[0].toUpperCase().includes('FUNCTION'),
                isProcedure: match[0].toUpperCase().includes('PROCEDURE')
              })
            }
            RESULTS.storedProceduresInSQL.get(spName).files.push(fullPath)
          })
        })

        // Verificar sintaxis PostgreSQL vs Informix
        if (content.includes('WITH RESUME')) {
          RESULTS.syntaxIssues.push({
            file: fullPath,
            issue: 'Contiene "WITH RESUME" (sintaxis Informix)',
            severity: 'high'
          })
        }
        if (content.match(/CREATE\s+PROCEDURE.*RETURNING/i)) {
          RESULTS.syntaxIssues.push({
            file: fullPath,
            issue: 'Usa "CREATE PROCEDURE ... RETURNING" (sintaxis Informix)',
            severity: 'high'
          })
        }
        if (!content.includes('LANGUAGE plpgsql') && content.match(/CREATE\s+(OR\s+REPLACE\s+)?FUNCTION/i)) {
          RESULTS.syntaxIssues.push({
            file: fullPath,
            issue: 'Function sin "LANGUAGE plpgsql"',
            severity: 'medium'
          })
        }
      }
    })
  } catch (error) {
    console.error(`Error escaneando ${dir}:`, error.message)
  }
}

/**
 * Compara SPs de Vue con SPs en SQL
 */
function compareStoredProcedures() {
  // Verificar cuáles SPs de Vue existen en SQL
  RESULTS.storedProceduresInVue.forEach((files, spName) => {
    if (RESULTS.storedProceduresInSQL.has(spName)) {
      RESULTS.found.push({
        name: spName,
        usedIn: files,
        definedIn: RESULTS.storedProceduresInSQL.get(spName).files,
        type: RESULTS.storedProceduresInSQL.get(spName).isFunction ? 'FUNCTION' : 'PROCEDURE'
      })
    } else {
      RESULTS.missing.push({
        name: spName,
        usedIn: files
      })
    }
  })
}

/**
 * Genera reporte detallado
 */
function generateReport() {
  let report = `# 🔍 VERIFICACIÓN: Stored Procedures

**Fecha**: ${new Date().toLocaleString('es-MX')}
**Sistema**: RefactorX Guadalajara - PostgreSQL

---

## 📊 RESUMEN EJECUTIVO

- **Total archivos Vue analizados**: ${RESULTS.totalVueFiles}
- **Total archivos SQL analizados**: ${RESULTS.totalSQLFiles}
- **SPs usados en Vue**: ${RESULTS.storedProceduresInVue.size}
- **SPs definidos en SQL**: ${RESULTS.storedProceduresInSQL.size}
- **SPs encontrados**: ${RESULTS.found.length} ✅
- **SPs faltantes**: ${RESULTS.missing.length} ❌
- **Problemas de sintaxis**: ${RESULTS.syntaxIssues.length} ⚠️

### Estado General:
${RESULTS.missing.length === 0 && RESULTS.syntaxIssues.length === 0
    ? '✅ **SISTEMA VERIFICADO**: Todos los SPs existen y tienen sintaxis correcta'
    : '❌ **REQUIERE ATENCIÓN**: Hay SPs faltantes o problemas de sintaxis'}

---

## ❌ STORED PROCEDURES FALTANTES (${RESULTS.missing.length})

`

  if (RESULTS.missing.length > 0) {
    report += `⚠️  **CRÍTICO**: Los siguientes SPs son usados en componentes Vue pero NO existen en archivos SQL:\n\n`
    report += `| # | Stored Procedure | Usado en |\n`
    report += `|---|------------------|----------|\n`

    RESULTS.missing.forEach((sp, index) => {
      const uniqueFiles = [...new Set(sp.usedIn.map(f => path.relative(process.cwd(), f)))]
      report += `| ${index + 1} | \`${sp.name}\` | ${uniqueFiles.length} archivo(s) |\n`
    })

    report += `\n### Detalle de SPs Faltantes:\n\n`
    RESULTS.missing.forEach((sp, index) => {
      report += `#### ${index + 1}. \`${sp.name}\`\n\n`
      report += `**Archivos que lo usan**:\n`
      const uniqueFiles = [...new Set(sp.usedIn.map(f => path.relative(process.cwd(), f)))]
      uniqueFiles.forEach(file => {
        report += `- \`${file}\`\n`
      })
      report += `\n**Acción requerida**: Crear el SP \`${sp.name}\` en la base de datos PostgreSQL.\n\n`
    })
  } else {
    report += `✅ **¡Excelente!** Todos los SPs usados en Vue existen en archivos SQL.\n`
  }

  report += `\n---

## ✅ STORED PROCEDURES ENCONTRADOS (${RESULTS.found.length})

`

  if (RESULTS.found.length > 0) {
    // Agrupar por tipo
    const functions = RESULTS.found.filter(sp => sp.type === 'FUNCTION')
    const procedures = RESULTS.found.filter(sp => sp.type === 'PROCEDURE')

    report += `### Por Tipo:\n\n`
    report += `- **FUNCTION** (PostgreSQL): ${functions.length}\n`
    report += `- **PROCEDURE** (Informix legacy): ${procedures.length}\n\n`

    if (procedures.length > 0) {
      report += `⚠️  **Advertencia**: ${procedures.length} SP(s) usan sintaxis PROCEDURE (deberían ser FUNCTION en PostgreSQL)\n\n`
    }

    report += `### Lista Completa:\n\n`
    report += `| # | Stored Procedure | Tipo | Usado en | Definido en |\n`
    report += `|---|------------------|------|----------|-------------|\n`

    RESULTS.found.forEach((sp, index) => {
      const uniqueUsedIn = [...new Set(sp.usedIn.map(f => path.basename(f)))].length
      const uniqueDefinedIn = sp.definedIn.length
      report += `| ${index + 1} | \`${sp.name}\` | ${sp.type} | ${uniqueUsedIn} | ${uniqueDefinedIn} |\n`
    })
  }

  report += `\n---

## ⚠️  PROBLEMAS DE SINTAXIS (${RESULTS.syntaxIssues.length})

`

  if (RESULTS.syntaxIssues.length > 0) {
    const highSeverity = RESULTS.syntaxIssues.filter(i => i.severity === 'high')
    const mediumSeverity = RESULTS.syntaxIssues.filter(i => i.severity === 'medium')

    report += `- **Alta prioridad** (sintaxis Informix): ${highSeverity.length}\n`
    report += `- **Media prioridad** (mejoras): ${mediumSeverity.length}\n\n`

    if (highSeverity.length > 0) {
      report += `### 🔴 Alta Prioridad (Sintaxis Informix):\n\n`
      report += `| Archivo | Problema |\n`
      report += `|---------|----------|\n`
      highSeverity.forEach(issue => {
        const relPath = path.relative(process.cwd(), issue.file)
        report += `| \`${relPath}\` | ${issue.issue} |\n`
      })
      report += `\n**Acción requerida**: Migrar estos SPs de Informix a PostgreSQL.\n\n`
    }

    if (mediumSeverity.length > 0) {
      report += `### 🟡 Media Prioridad (Mejoras):\n\n`
      report += `| Archivo | Problema |\n`
      report += `|---------|----------|\n`
      mediumSeverity.forEach(issue => {
        const relPath = path.relative(process.cwd(), issue.file)
        report += `| \`${relPath}\` | ${issue.issue} |\n`
      })
    }
  } else {
    report += `✅ **¡Excelente!** Todos los SPs tienen sintaxis PostgreSQL correcta.\n`
  }

  report += `\n---

## 📋 STORED PROCEDURES POR MÓDULO

`

  // Agrupar SPs encontrados por módulo (basado en la ruta del archivo SQL)
  const byModule = {}
  RESULTS.found.forEach(sp => {
    sp.definedIn.forEach(file => {
      const match = file.match(/RefactorX[\\/]Base[\\/]([^\\/]+)/)
      if (match) {
        const module = match[1]
        if (!byModule[module]) byModule[module] = []
        if (!byModule[module].includes(sp.name)) {
          byModule[module].push(sp.name)
        }
      }
    })
  })

  Object.keys(byModule).sort().forEach(module => {
    report += `\n### ${module}\n\n`
    report += `- **Total de SPs**: ${byModule[module].length}\n`
    report += `- **SPs**: ${byModule[module].slice(0, 5).map(sp => `\`${sp}\``).join(', ')}`
    if (byModule[module].length > 5) {
      report += ` y ${byModule[module].length - 5} más...`
    }
    report += `\n`
  })

  report += `\n---

## 🎯 COBERTURA DE STORED PROCEDURES

`

  const coverage = RESULTS.storedProceduresInVue.size > 0
    ? ((RESULTS.found.length / RESULTS.storedProceduresInVue.size) * 100).toFixed(1)
    : 0

  report += `
- **Cobertura**: ${coverage}%
- **SPs requeridos**: ${RESULTS.storedProceduresInVue.size}
- **SPs disponibles**: ${RESULTS.found.length}
- **SPs faltantes**: ${RESULTS.missing.length}

`

  if (coverage < 100) {
    report += `⚠️  **Acción requerida**: Crear los ${RESULTS.missing.length} SP(s) faltante(s) para alcanzar 100% de cobertura.\n`
  } else {
    report += `✅ **¡Perfecto!** Cobertura completa del 100%.\n`
  }

  report += `\n---

## 🔧 RECOMENDACIONES

`

  if (RESULTS.missing.length > 0) {
    report += `
### 1. Crear SPs Faltantes

Para cada SP faltante, crear un archivo SQL con la siguiente estructura:

\`\`\`sql
-- =====================================================
-- SP: {nombre_sp}
-- Descripción: {descripción}
-- Base: {nombre_base}
-- Esquema: public
-- =====================================================

CREATE OR REPLACE FUNCTION {nombre_sp}(
  -- parámetros
)
RETURNS TABLE (
  -- columnas de retorno
) AS $$
BEGIN
  RETURN QUERY
  SELECT ...;
END;
$$ LANGUAGE plpgsql;
\`\`\`
`
  }

  if (RESULTS.syntaxIssues.length > 0) {
    report += `
### 2. Migrar Sintaxis Informix → PostgreSQL

Convertir:
\`\`\`sql
-- ❌ Informix
CREATE PROCEDURE sp_name()
RETURNING ...
WITH RESUME;

-- ✅ PostgreSQL
CREATE OR REPLACE FUNCTION sp_name()
RETURNS TABLE (...) AS $$
BEGIN
  RETURN QUERY ...;
END;
$$ LANGUAGE plpgsql;
\`\`\`
`
  }

  if (RESULTS.missing.length === 0 && RESULTS.syntaxIssues.length === 0) {
    report += `
✅ **¡Sistema Completo y Verificado!**

- Todos los SPs existen
- Sintaxis PostgreSQL correcta
- Cobertura al 100%
- Listo para producción

### Próximo paso:

Ejecutar tests de integración para verificar que los SPs funcionen correctamente:

\`\`\`bash
npm run test:sp
\`\`\`
`
  }

  report += `\n---

## 📈 ESTADÍSTICAS DETALLADAS

- **Archivos Vue con SPs**: ${RESULTS.storedProceduresInVue.size > 0 ? Math.round((RESULTS.totalVueFiles / RESULTS.storedProceduresInVue.size) * 100) : 0}%
- **Archivos SQL con definiciones**: ${RESULTS.totalSQLFiles}
- **Promedio de SPs por módulo**: ${Object.keys(byModule).length > 0 ? (RESULTS.found.length / Object.keys(byModule).length).toFixed(1) : 0}
- **Reutilización de SPs**: ${RESULTS.found.length > 0 ? (RESULTS.storedProceduresInVue.size / RESULTS.found.length).toFixed(2) : 0}x

---

**Generado por**: RefactorX Verification System
**Versión**: 1.0.0
`

  return report
}

/**
 * Función principal
 */
function main() {
  console.log('🔍 Iniciando verificación de Stored Procedures...\n')

  const vueModulesDir = path.join(process.cwd(), 'src', 'views', 'modules')
  const baseDir = path.join(process.cwd(), '..', 'Base')

  console.log('📁 Directorios:')
  console.log(`   Vue: ${vueModulesDir}`)
  console.log(`   Base: ${baseDir}\n`)

  // Paso 1: Extraer SPs de archivos Vue
  console.log('🔎 Paso 1: Extrayendo SPs de archivos Vue...')
  extractSPsFromVue(vueModulesDir)
  console.log(`   ✓ Encontrados ${RESULTS.storedProceduresInVue.size} SPs únicos en ${RESULTS.totalVueFiles} archivos Vue\n`)

  // Paso 2: Extraer SPs de archivos SQL
  console.log('🔎 Paso 2: Extrayendo SPs de archivos SQL...')
  extractSPsFromSQL(baseDir)
  console.log(`   ✓ Encontrados ${RESULTS.storedProceduresInSQL.size} SPs únicos en ${RESULTS.totalSQLFiles} archivos SQL\n`)

  // Paso 3: Comparar
  console.log('🔎 Paso 3: Comparando SPs...')
  compareStoredProcedures()
  console.log(`   ✓ Coincidencias: ${RESULTS.found.length}`)
  console.log(`   ✗ Faltantes: ${RESULTS.missing.length}\n`)

  // Paso 4: Generar reporte
  console.log('📝 Paso 4: Generando reporte...')
  const report = generateReport()

  const reportPath = path.join(process.cwd(), 'VERIFY_STORED_PROCEDURES.md')
  fs.writeFileSync(reportPath, report, 'utf-8')
  console.log(`   ✓ Reporte guardado en: ${reportPath}\n`)

  // Resumen en consola
  console.log('='.repeat(60))
  console.log('RESUMEN DE VERIFICACIÓN')
  console.log('='.repeat(60))
  console.log(`SPs usados en Vue: ${RESULTS.storedProceduresInVue.size}`)
  console.log(`SPs definidos en SQL: ${RESULTS.storedProceduresInSQL.size}`)
  console.log(`✅ Encontrados: ${RESULTS.found.length}`)
  console.log(`❌ Faltantes: ${RESULTS.missing.length}`)
  console.log(`⚠️  Problemas de sintaxis: ${RESULTS.syntaxIssues.length}`)
  console.log(`📊 Cobertura: ${RESULTS.storedProceduresInVue.size > 0 ? ((RESULTS.found.length / RESULTS.storedProceduresInVue.size) * 100).toFixed(1) : 0}%`)
  console.log('='.repeat(60))

  // Exit code
  if (RESULTS.missing.length > 0) {
    console.log('\n❌ FALLO: Hay SPs faltantes.')
    process.exit(1)
  } else if (RESULTS.syntaxIssues.length > 0) {
    console.log('\n⚠️  ADVERTENCIA: Hay problemas de sintaxis.')
    process.exit(0)
  } else {
    console.log('\n✅ ÉXITO: Todos los SPs existen y tienen sintaxis correcta.')
    process.exit(0)
  }
}

// Ejecutar
main()
