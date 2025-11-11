/**
 * MAPEO COMPLETO: RefactorX/Base/ → Vue Components
 *
 * Este script realiza un análisis exhaustivo de:
 * 1. Qué SPs existen en cada módulo de Base/
 * 2. Qué SPs están siendo usados en Vue
 * 3. Cobertura y faltantes
 * 4. Mapeo de tablas por módulo
 *
 * Autor: Sistema RefactorX
 * Fecha: 2025-11-10
 */

const fs = require('fs')
const path = require('path')

const RESULTS = {
  baseModules: new Map(),
  vueSPs: new Map(),
  spsCoverage: { found: [], missing: [], crossModule: [] },
  stats: { totalBaseModules: 0, totalSPs: 0, totalTables: 0, totalVueFiles: 0 }
}

function exploreBaseStructure() {
  const basePath = path.join(process.cwd(), '..', 'Base')
  if (!fs.existsSync(basePath)) return

  const entries = fs.readdirSync(basePath, { withFileTypes: true })
  entries.forEach(entry => {
    if (!entry.isDirectory() || entry.name === 'db' || entry.name === 'distribucion') return

    const modulePath = path.join(basePath, entry.name)
    const databasePath = path.join(modulePath, 'database')
    if (!fs.existsSync(databasePath)) return

    RESULTS.baseModules.set(entry.name, { path: modulePath, databasePath, sps: [], tables: [], files: [] })
    RESULTS.stats.totalBaseModules++
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
        const moduleData = RESULTS.baseModules.get(moduleName)
        moduleData.files.push(path.relative(process.cwd(), fullPath))
        const content = fs.readFileSync(fullPath, 'utf-8')

        // Extract SPs
        const spPatterns = [
          /CREATE\s+(?:OR\s+REPLACE\s+)?FUNCTION\s+([a-z0-9_]+)/gi,
          /CREATE\s+(?:OR\s+REPLACE\s+)?PROCEDURE\s+([a-z0-9_]+)/gi
        ]
        spPatterns.forEach(pattern => {
          const matches = [...content.matchAll(pattern)]
          matches.forEach(match => {
            const spName = match[1].toLowerCase()
            if (!moduleData.sps.includes(spName)) {
              moduleData.sps.push(spName)
              RESULTS.stats.totalSPs++
            }
          })
        })

        // Extract tables
        const tablePattern = /(?:FROM|JOIN|INTO|UPDATE)\s+(?:([a-z0-9_]+)\.)?(?:([a-z0-9_]+)\.)?([a-z0-9_]+)/gi
        const matches = [...content.matchAll(tablePattern)]
        matches.forEach(match => {
          const tableName = match[3]
          if (tableName && tableName.startsWith('ta_') && !moduleData.tables.includes(tableName)) {
            moduleData.tables.push(tableName)
            RESULTS.stats.totalTables++
          }
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
        RESULTS.stats.totalVueFiles++
        const content = fs.readFileSync(fullPath, 'utf-8')

        const spPatterns = [
          /OP_[A-Z_]+\s*=\s*['"`]([^'"`]+)['"`]/g,
          /const\s+\w+\s*=\s*['"`](sp_|rpt_|rprt_|spd_|apremiossvn_|recaudadora_)([^'"`]+)['"`]/gi,
          /execute\s*\(\s*['"`]([a-z0-9_]+)['"`]/gi
        ]

        spPatterns.forEach(pattern => {
          const matches = [...content.matchAll(pattern)]
          matches.forEach(match => {
            let spName = (match[1] + (match[2] || '')).toLowerCase()
            if (!RESULTS.vueSPs.has(spName)) RESULTS.vueSPs.set(spName, [])
            RESULTS.vueSPs.get(spName).push({ module: moduleName, component: entry.name, path: path.relative(process.cwd(), fullPath) })
          })
        })
      }
    })
  } catch (error) {
    console.error(`Error escaneando Vue ${dir}:`, error.message)
  }
}

function compareAndMap() {
  RESULTS.vueSPs.forEach((usages, spName) => {
    let found = false
    let foundInModule = null

    RESULTS.baseModules.forEach((moduleData, moduleName) => {
      if (moduleData.sps.includes(spName)) {
        found = true
        foundInModule = moduleName
        const vueModule = usages[0].module
        RESULTS.spsCoverage.found.push({
          sp: spName,
          vueModule,
          baseModule: moduleName,
          usages: usages.length,
          status: vueModule === moduleName ? 'correct' : 'cross-module'
        })
      }
    })

    if (!found) {
      RESULTS.spsCoverage.missing.push({
        sp: spName,
        vueModule: usages[0].module,
        usages: usages.length,
        components: usages.map(u => u.component)
      })
    }
  })
}

function generateReport() {
  let report = `# 🔍 MAPEO COMPLETO: RefactorX/Base/ → Vue Components

**Fecha**: ${new Date().toLocaleString('es-MX')}

---

## 📊 RESUMEN EJECUTIVO

### Base/:
- Módulos: ${RESULTS.stats.totalBaseModules}
- SPs definidos: ${RESULTS.stats.totalSPs}
- Tablas detectadas: ${RESULTS.stats.totalTables}

### Vue:
- Archivos: ${RESULTS.stats.totalVueFiles}
- SPs usados: ${RESULTS.vueSPs.size}

### Cobertura:
- ✅ Encontrados: ${RESULTS.spsCoverage.found.length}
- ❌ Faltantes: ${RESULTS.spsCoverage.missing.length}
- 📊 Cobertura: ${(RESULTS.spsCoverage.found.length / RESULTS.vueSPs.size * 100).toFixed(1)}%

---

## 🗂️ MÓDULOS EN BASE/

`
  const sortedModules = Array.from(RESULTS.baseModules.entries()).sort()
  sortedModules.forEach(([moduleName, data]) => {
    report += `\n### ${moduleName}\n`
    report += `- SPs: ${data.sps.length}\n`
    report += `- Tablas: ${data.tables.length}\n`
    report += `- Archivos SQL: ${data.files.length}\n`

    if (data.sps.length > 0) {
      report += `\n**SPs** (primeros 15):\n`
      data.sps.slice(0, 15).forEach(sp => report += `- \`${sp}\`\n`)
      if (data.sps.length > 15) report += `- ...y ${data.sps.length - 15} más\n`
    }
  })

  report += `\n---\n\n## ❌ SPS FALTANTES (${RESULTS.spsCoverage.missing.length})\n\n`

  if (RESULTS.spsCoverage.missing.length > 0) {
    const byModule = {}
    RESULTS.spsCoverage.missing.forEach(sp => {
      if (!byModule[sp.vueModule]) byModule[sp.vueModule] = []
      byModule[sp.vueModule].push(sp)
    })

    Object.keys(byModule).sort().forEach(moduleName => {
      const sps = byModule[moduleName]
      report += `\n### ${moduleName} (${sps.length} faltantes)\n\n`
      report += `| SP | Usos | Componentes |\n|----|----- |-------------|\n`
      sps.slice(0, 30).forEach(sp => {
        const comps = sp.components.slice(0, 2).join(', ')
        report += `| \`${sp.sp}\` | ${sp.usages} | ${comps}${sp.components.length > 2 ? ' +' + (sp.components.length - 2) : ''} |\n`
      })
      if (sps.length > 30) report += `| ...y ${sps.length - 30} más | | |\n`
    })
  }

  report += `\n---\n\n## 📈 ESTADÍSTICAS POR MÓDULO\n\n`
  report += `| Módulo | SPs en Base | SPs Usados en Vue | Faltantes |\n`
  report += `|--------|-------------|-------------------|-----------|`

  const moduleStats = new Map()
  RESULTS.baseModules.forEach((data, moduleName) => {
    moduleStats.set(moduleName, { spsInBase: data.sps.length, spsUsed: 0, missing: 0 })
  })

  RESULTS.spsCoverage.missing.forEach(sp => {
    if (moduleStats.has(sp.vueModule)) {
      moduleStats.get(sp.vueModule).missing++
      moduleStats.get(sp.vueModule).spsUsed++
    }
  })

  RESULTS.spsCoverage.found.forEach(sp => {
    if (moduleStats.has(sp.vueModule)) {
      moduleStats.get(sp.vueModule).spsUsed++
    }
  })

  Array.from(moduleStats.entries()).sort().forEach(([moduleName, stats]) => {
    report += `\n| ${moduleName} | ${stats.spsInBase} | ${stats.spsUsed} | ${stats.missing} |`
  })

  report += `\n\n---\n\n**Generado por**: RefactorX Mapping System v1.0\n`
  return report
}

async function main() {
  console.log('🔍 Iniciando mapeo completo Base/ → Vue...\n')

  console.log('📁 Explorando RefactorX/Base/...')
  exploreBaseStructure()
  console.log(`   ✓ ${RESULTS.stats.totalBaseModules} módulos, ${RESULTS.stats.totalSPs} SPs, ${RESULTS.stats.totalTables} tablas\n`)

  console.log('📁 Extrayendo SPs de Vue...')
  extractVueSPs()
  console.log(`   ✓ ${RESULTS.stats.totalVueFiles} archivos, ${RESULTS.vueSPs.size} SPs únicos\n`)

  console.log('📁 Comparando y mapeando...')
  compareAndMap()
  console.log(`   ✓ ${RESULTS.spsCoverage.found.length} encontrados, ${RESULTS.spsCoverage.missing.length} faltantes\n`)

  console.log('📝 Generando reporte...')
  const report = generateReport()
  const reportPath = path.join(process.cwd(), 'MAP_BASE_TO_VUE.md')
  fs.writeFileSync(reportPath, report, 'utf-8')
  console.log(`   ✓ Guardado en: ${reportPath}\n`)

  console.log('='.repeat(60))
  console.log(`Cobertura: ${(RESULTS.spsCoverage.found.length / RESULTS.vueSPs.size * 100).toFixed(1)}%`)
  console.log(`✅ ${RESULTS.spsCoverage.found.length} encontrados`)
  console.log(`❌ ${RESULTS.spsCoverage.missing.length} faltantes`)
  console.log('='.repeat(60))
}

main().catch(error => {
  console.error('❌ Error:', error)
  process.exit(1)
})
