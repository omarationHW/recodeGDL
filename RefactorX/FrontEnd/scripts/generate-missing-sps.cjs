/**
 * GENERADOR DE SPs FALTANTES
 *
 * Este script:
 * 1. Extrae la lista COMPLETA de los 179 SPs faltantes
 * 2. Genera archivos SQL para cada SP con sintaxis PostgreSQL
 * 3. Organiza por módulo y prioridad de uso
 * 4. Crea scripts de deployment
 *
 * IMPORTANTE: NO TOCA nada existente, solo crea SPs nuevos
 *
 * Autor: Sistema RefactorX
 * Fecha: 2025-11-10
 */

const fs = require('fs')
const path = require('path')

// Re-usar la lógica de validate-all-sps.cjs para obtener la lista completa
const RESULTS = {
  baseModules: new Map(),
  vueSPs: new Map(),
  missingSPs: {
    aseo_contratado: [],
    cementerios: [],
    estacionamiento_exclusivo: [],
    estacionamiento_publico: [],
    multas_reglamentos: [],
    otras_obligaciones: [],
    padron_licencias: []
  },
  stats: { totalMissing: 0 }
}

function exploreBaseStructure() {
  const basePath = path.join(process.cwd(), '..', 'Base')
  if (!fs.existsSync(basePath)) {
    console.error('❌ No se encontró RefactorX/Base/')
    return
  }

  const entries = fs.readdirSync(basePath, { withFileTypes: true })
  entries.forEach(entry => {
    if (!entry.isDirectory() || entry.name === 'db' || entry.name === 'distribucion') return

    const modulePath = path.join(basePath, entry.name)
    const databasePath = path.join(modulePath, 'database')
    if (!fs.existsSync(databasePath)) return

    RESULTS.baseModules.set(entry.name, { sps: new Set() })
    exploreDatabaseDirectory(entry.name, databasePath)
  })
}

function exploreDatabaseDirectory(moduleName, dir) {
  try {
    const entries = fs.readdirSync(dir, { withFileTypes: true })
    entries.forEach(entry => {
      const fullPath = path.join(dir, entry.name)
      if (entry.isDirectory()) {
        exploreDatabaseDirectory(moduleName, fullPath)
      } else if (entry.isFile() && entry.name.endsWith('.sql')) {
        const content = fs.readFileSync(fullPath, 'utf-8')
        const spPatterns = [
          /CREATE\s+(?:OR\s+REPLACE\s+)?FUNCTION\s+([a-z0-9_]+)/gi,
          /CREATE\s+(?:OR\s+REPLACE\s+)?PROCEDURE\s+([a-z0-9_]+)/gi
        ]
        spPatterns.forEach(pattern => {
          const matches = [...content.matchAll(pattern)]
          matches.forEach(match => {
            RESULTS.baseModules.get(moduleName).sps.add(match[1].toLowerCase())
          })
        })
      }
    })
  } catch (error) {
    console.error(`Error explorando ${dir}:`, error.message)
  }
}

function extractVueSPs() {
  const vueModulesDir = path.join(process.cwd(), 'src', 'views', 'modules')
  if (!fs.existsSync(vueModulesDir)) return

  const modules = fs.readdirSync(vueModulesDir, { withFileTypes: true })
    .filter(entry => entry.isDirectory())
    .map(entry => entry.name)

  modules.forEach(module => scanVueDirectory(module, path.join(vueModulesDir, module)))
}

function scanVueDirectory(moduleName, dir) {
  try {
    const entries = fs.readdirSync(dir, { withFileTypes: true })
    entries.forEach(entry => {
      const fullPath = path.join(dir, entry.name)
      if (entry.isDirectory()) {
        scanVueDirectory(moduleName, fullPath)
      } else if (entry.isFile() && entry.name.endsWith('.vue')) {
        const content = fs.readFileSync(fullPath, 'utf-8')

        const spPatterns = [
          /OP_[A-Z_]+\s*=\s*['\"`]([^'\"`]+)['\"`]/g,
          /const\s+\w+\s*=\s*['\"`](sp_|rpt_|rprt_|spd_|apremiossvn_|recaudadora_)([^'\"`]+)['\"`]/gi,
          /execute\s*\(\s*['\"`]([a-z0-9_]+)['\"`]/gi
        ]

        spPatterns.forEach(pattern => {
          const matches = [...content.matchAll(pattern)]
          matches.forEach(match => {
            let spName = (match[1] + (match[2] || '')).toLowerCase()
            if (!RESULTS.vueSPs.has(spName)) {
              RESULTS.vueSPs.set(spName, { module: moduleName, usages: 0, components: [] })
            }
            RESULTS.vueSPs.get(spName).usages++
            if (!RESULTS.vueSPs.get(spName).components.includes(entry.name)) {
              RESULTS.vueSPs.get(spName).components.push(entry.name)
            }
          })
        })
      }
    })
  } catch (error) {
    console.error(`Error escaneando Vue ${dir}:`, error.message)
  }
}

function identifyMissingSPs() {
  RESULTS.vueSPs.forEach((data, spName) => {
    const vueModule = data.module

    // Verificar si existe en el módulo de Base
    if (!RESULTS.baseModules.has(vueModule)) return

    const baseSPs = RESULTS.baseModules.get(vueModule).sps
    if (!baseSPs.has(spName)) {
      // SP faltante real
      if (RESULTS.missingSPs[vueModule]) {
        RESULTS.missingSPs[vueModule].push({
          name: spName,
          usages: data.usages,
          components: data.components
        })
        RESULTS.stats.totalMissing++
      }
    }
  })
}

function generateSPSQL(spName, moduleName) {
  // Generar SQL base para PostgreSQL
  return `-- ================================================================
-- SP: ${spName}
-- Módulo: ${moduleName}
-- Autor: Sistema RefactorX
-- Fecha: ${new Date().toISOString().split('T')[0]}
-- ================================================================

CREATE OR REPLACE FUNCTION ${spName}()
RETURNS TABLE (
  -- TODO: Definir columnas de retorno basándose en el uso en Vue
  result JSONB
)
LANGUAGE plpgsql
AS $$
BEGIN
  -- TODO: Implementar lógica del SP
  -- Este es un placeholder generado automáticamente

  RETURN QUERY
  SELECT jsonb_build_object(
    'success', true,
    'message', 'SP ${spName} pendiente de implementación',
    'data', '[]'::jsonb
  );

END;
$$;

-- Comentario del SP
COMMENT ON FUNCTION ${spName}() IS 'SP generado automáticamente - REQUIERE IMPLEMENTACIÓN';
`
}

function createSQLFiles() {
  let totalFiles = 0

  Object.keys(RESULTS.missingSPs).forEach(moduleName => {
    const sps = RESULTS.missingSPs[moduleName]
    if (sps.length === 0) return

    // Ordenar por uso (más usados primero)
    sps.sort((a, b) => b.usages - a.usages)

    // Crear directorio de salida
    const outputDir = path.join(process.cwd(), '..', 'Base', moduleName, 'database', 'generated')
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true })
    }

    // Generar archivo SQL por cada SP
    sps.forEach((sp, index) => {
      const sqlContent = generateSPSQL(sp.name, moduleName)
      const fileName = `${sp.name}.sql`
      const filePath = path.join(outputDir, fileName)

      fs.writeFileSync(filePath, sqlContent, 'utf-8')
      totalFiles++

      console.log(`   ✓ ${moduleName}/${fileName} (${sp.usages} usos)`)
    })

    // Generar script de deployment para el módulo
    generateDeploymentScript(moduleName, sps)
  })

  return totalFiles
}

function generateDeploymentScript(moduleName, sps) {
  const deployDir = path.join(process.cwd(), '..', 'Base', moduleName, 'database', 'deploy')
  if (!fs.existsSync(deployDir)) {
    fs.mkdirSync(deployDir, { recursive: true })
  }

  let deploySQL = `-- ================================================================
-- DEPLOYMENT SCRIPT: ${moduleName}
-- SPs Faltantes: ${sps.length}
-- Fecha: ${new Date().toISOString().split('T')[0]}
-- ================================================================
--
-- INSTRUCCIONES:
-- 1. Revisar cada SP generado en: ../generated/
-- 2. Implementar la lógica específica de cada SP
-- 3. Ejecutar este script en la base de datos: ${moduleName}
-- 4. Verificar que todos los SPs se crearon correctamente
--
-- ================================================================

\\echo ''
\\echo '=================================================='
\\echo 'DEPLOYMENT: ${moduleName} - ${sps.length} SPs'
\\echo '=================================================='
\\echo ''

-- Establecer schema
SET search_path TO public;

`

  // Agregar archivos por prioridad
  sps.forEach((sp, index) => {
    const priority = sp.usages >= 5 ? '🔴 ALTA' : sp.usages >= 2 ? '🟡 MEDIA' : '⚪ BAJA'
    deploySQL += `
-- [${index + 1}/${sps.length}] ${sp.name} - ${sp.usages} usos (${priority})
\\echo 'Creando: ${sp.name}...'
\\i ../generated/${sp.name}.sql
\\echo '   ✓ OK'
`
  })

  deploySQL += `
\\echo ''
\\echo '=================================================='
\\echo 'DEPLOYMENT COMPLETADO: ${sps.length} SPs creados'
\\echo '=================================================='
\\echo ''
`

  const deployPath = path.join(deployDir, `DEPLOY_MISSING_SPS_${new Date().toISOString().split('T')[0]}.sql`)
  fs.writeFileSync(deployPath, deploySQL, 'utf-8')

  console.log(`   📦 Deployment script: ${path.basename(deployPath)}`)
}

function generateSummaryReport() {
  let report = `# 📊 REPORTE: SPs Faltantes Generados

**Fecha**: ${new Date().toLocaleString('es-MX')}
**Total de SPs creados**: ${RESULTS.stats.totalMissing}

---

## 📋 RESUMEN POR MÓDULO

`

  Object.keys(RESULTS.missingSPs).forEach(moduleName => {
    const sps = RESULTS.missingSPs[moduleName]
    if (sps.length === 0) return

    const highPriority = sps.filter(sp => sp.usages >= 5).length
    const medPriority = sps.filter(sp => sp.usages >= 2 && sp.usages < 5).length
    const lowPriority = sps.filter(sp => sp.usages < 2).length

    report += `
### ${moduleName}

- **Total SPs creados**: ${sps.length}
- 🔴 Alta prioridad (≥5 usos): ${highPriority}
- 🟡 Media prioridad (2-4 usos): ${medPriority}
- ⚪ Baja prioridad (<2 usos): ${lowPriority}

**Ubicación**:
- Archivos SQL: \`RefactorX/Base/${moduleName}/database/generated/\`
- Script deployment: \`RefactorX/Base/${moduleName}/database/deploy/\`

**Top 5 más usados**:
`
    sps.slice(0, 5).forEach((sp, i) => {
      report += `${i + 1}. \`${sp.name}\` - ${sp.usages} usos en ${sp.components.length} componentes\n`
    })
  })

  report += `
---

## 🚀 SIGUIENTE PASO

1. **Revisar archivos SQL generados** en cada módulo
2. **Implementar lógica específica** de cada SP (actualmente tienen placeholders)
3. **Ejecutar scripts de deployment** en cada base de datos PostgreSQL
4. **Verificar funcionamiento** en componentes Vue

---

**IMPORTANTE**: Los archivos SQL generados son PLANTILLAS que requieren implementación.
Cada SP tiene un placeholder que retorna JSON básico - debe ser reemplazado con la lógica real.

---

**Generado por**: RefactorX SP Generator v1.0
`

  const reportPath = path.join(process.cwd(), 'MISSING_SPS_GENERATED.md')
  fs.writeFileSync(reportPath, report, 'utf-8')

  return reportPath
}

async function main() {
  console.log('🚀 Iniciando generación de SPs faltantes...\n')

  console.log('📁 Explorando RefactorX/Base/...')
  exploreBaseStructure()
  console.log(`   ✓ ${RESULTS.baseModules.size} módulos encontrados\n`)

  console.log('📁 Extrayendo SPs de Vue...')
  extractVueSPs()
  console.log(`   ✓ ${RESULTS.vueSPs.size} SPs únicos en Vue\n`)

  console.log('🔍 Identificando SPs faltantes...')
  identifyMissingSPs()
  console.log(`   ✓ ${RESULTS.stats.totalMissing} SPs faltantes detectados\n`)

  console.log('📝 Generando archivos SQL...')
  const filesCreated = createSQLFiles()
  console.log(`   ✓ ${filesCreated} archivos SQL creados\n`)

  console.log('📄 Generando reporte...')
  const reportPath = generateSummaryReport()
  console.log(`   ✓ Reporte guardado: ${reportPath}\n`)

  console.log('='.repeat(60))
  console.log(`✅ COMPLETADO: ${RESULTS.stats.totalMissing} SPs generados`)
  console.log(`📦 Archivos SQL: RefactorX/Base/[modulo]/database/generated/`)
  console.log(`🚀 Deployment: RefactorX/Base/[modulo]/database/deploy/`)
  console.log('='.repeat(60))
  console.log('\n⚠️  IMPORTANTE: Los SPs generados son PLANTILLAS')
  console.log('   Requieren implementación de la lógica específica')
  console.log('   antes de ser desplegados en producción.\n')
}

main().catch(error => {
  console.error('❌ Error:', error)
  process.exit(1)
})
