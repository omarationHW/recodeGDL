const fs = require('fs');
const path = require('path');

const BASE_PATH = 'C:\Sistemas\RefactorX\Guadalajara\RecodePHP\GDL';
const VUE_PATHS = [
  path.join(BASE_PATH, 'RefactorX', 'Base', 'estacionamiento_publico'),
  path.join(BASE_PATH, 'RefactorX', 'FrontEnd', 'src', 'views', 'modules', 'estacionamiento_publico')
];
const CATALOG_PATH = path.join(BASE_PATH, 'RefactorX', 'Base', 'estacionamiento_publico', 'database', 'sp-catalog.json');
const OUTPUT_PATH = path.join(BASE_PATH, 'RefactorX', 'Base', 'estacionamiento_publico', 'vue-sp-usage.json');

// Patrones para detectar SPs y llamadas
const PATTERNS = {
  apiServiceExecute: /apiService\.execute\(['"]([^'"]+)['"]/g,
  action: /action:\s*['"]([^'"]+)['"]/g,
  procedure: /procedure:\s*['"]([^'"]+)['"]/g,
  spCall: /CALL\s+(sp_\w+)/gi,
  spName: /sp_\w+/g,
  tables: /(?:FROM|UPDATE|INSERT INTO|DELETE FROM)\s+(\w+)/gi
};

function getAllVueFiles(dir) {
  const files = [];
  if (!fs.existsSync(dir)) return files;
  
  const items = fs.readdirSync(dir);
  for (const item of items) {
    const fullPath = path.join(dir, item);
    const stat = fs.statSync(fullPath);
    if (stat.isDirectory() && item !== 'node_modules' && item !== 'dist') {
      files.push(...getAllVueFiles(fullPath));
    } else if (item.endsWith('.vue')) {
      files.push(fullPath);
    }
  }
  return files;
}

function extractSPsFromContent(content, filePath) {
  const sps = [];
  const endpoints = [];
  const tables = new Set();
  const lines = content.split('\n');
  
  lines.forEach((line, idx) => {
    const lineNum = idx + 1;
    
    // apiService.execute
    let match;
    const execRegex = /apiService\.execute\(['"]([^'"]+)['"],\s*['"]([^'"]+)['"]/g;
    while ((match = execRegex.exec(line)) !== null) {
      sps.push({
        nombre: match[1],
        metodo: 'apiService.execute',
        linea: lineNum,
        modulo: match[2],
        tipo: 'apiService'
      });
    }
    
    // action: pattern
    const actionRegex = /action:\s*['"]([^'"]+)['"]/g;
    while ((match = actionRegex.exec(line)) !== null) {
      endpoints.push({
        action: match[1],
        linea: lineNum,
        tipo: 'action'
      });
    }
    
    // Direct SP names
    const spRegex = /sp_\w+/g;
    while ((match = spRegex.exec(line)) !== null) {
      if (!match[0].includes('execute')) {
        sps.push({
          nombre: match[0],
          metodo: 'direct-reference',
          linea: lineNum,
          tipo: 'direct'
        });
      }
    }
    
    // Tables
    const tableRegex = /(?:FROM|UPDATE|INSERT INTO|DELETE FROM)\s+(\w+)/gi;
    while ((match = tableRegex.exec(line)) !== null) {
      tables.add(match[1]);
    }
  });
  
  return { sps, endpoints, tables: Array.from(tables) };
}

function analyzeVueFiles() {
  console.log('Analizando componentes Vue...');
  
  const allFiles = [];
  VUE_PATHS.forEach(vuePath => {
    console.log(`Buscando en: ${vuePath}`);
    const files = getAllVueFiles(vuePath);
    allFiles.push(...files);
  });
  
  console.log(`Total de archivos Vue encontrados: ${allFiles.length}`);
  
  const componentes = {};
  const allSPs = new Set();
  const allEndpoints = new Set();
  const spFrequency = {};
  const tablesUsed = new Set();
  
  allFiles.forEach(filePath => {
    const fileName = path.basename(filePath);
    const content = fs.readFileSync(filePath, 'utf-8');
    
    const { sps, endpoints, tables } = extractSPsFromContent(content, filePath);
    
    // Deduplicar SPs por nombre
    const uniqueSPs = [];
    const spNames = new Set();
    sps.forEach(sp => {
      if (!spNames.has(sp.nombre)) {
        spNames.add(sp.nombre);
        uniqueSPs.push(sp);
        allSPs.add(sp.nombre);
        spFrequency[sp.nombre] = (spFrequency[sp.nombre] || 0) + 1;
      }
    });
    
    endpoints.forEach(ep => allEndpoints.add(ep.action));
    tables.forEach(t => tablesUsed.add(t));
    
    if (uniqueSPs.length > 0 || endpoints.length > 0) {
      componentes[fileName] = {
        ruta: filePath,
        sps_llamados: uniqueSPs,
        endpoints_api: endpoints,
        tablas_usadas: tables,
        total_sps: uniqueSPs.length,
        tiene_queries_directos: tables.length > 0
      };
    }
  });
  
  return {
    componentes,
    allSPs: Array.from(allSPs),
    allEndpoints: Array.from(allEndpoints),
    spFrequency,
    tablesUsed: Array.from(tablesUsed)
  };
}

function loadCatalog() {
  try {
    const catalogContent = fs.readFileSync(CATALOG_PATH, 'utf-8');
    const catalog = JSON.parse(catalogContent);
    return catalog.sps_unicos || [];
  } catch (e) {
    console.error('Error leyendo catálogo:', e.message);
    return [];
  }
}

function generateReport() {
  const { componentes, allSPs, allEndpoints, spFrequency, tablesUsed } = analyzeVueFiles();
  const catalogSPs = loadCatalog();
  
  // Verificar SPs contra catálogo
  const spsInCatalog = new Set(catalogSPs);
  const spsUsedNotInCatalog = allSPs.filter(sp => !spsInCatalog.has(sp));
  const spsInCatalogNotUsed = catalogSPs.filter(sp => !allSPs.includes(sp));
  
  // Enriquecer componentes con información del catálogo
  Object.keys(componentes).forEach(compName => {
    const comp = componentes[compName];
    comp.sps_llamados = comp.sps_llamados.map(sp => ({
      ...sp,
      existe_en_catalogo: spsInCatalog.has(sp.nombre)
    }));
    comp.sps_faltantes = comp.sps_llamados
      .filter(sp => !sp.existe_en_catalogo)
      .map(sp => sp.nombre);
  });
  
  const componentesArray = Object.values(componentes);
  const componentesConSPs = componentesArray.filter(c => c.total_sps > 0);
  const componentesConQueriesDirectos = componentesArray.filter(c => c.tiene_queries_directos);
  
  const report = {
    fecha_analisis: new Date().toISOString().split('T')[0],
    componentes,
    resumen: {
      total_componentes_analizados: Object.keys(componentes).length,
      componentes_con_sps: componentesConSPs.length,
      componentes_sin_sps: Object.keys(componentes).length - componentesConSPs.length,
      total_sps_llamados: allSPs.length,
      total_endpoints_unicos: allEndpoints.length,
      sps_no_existen_en_catalogo: spsUsedNotInCatalog.length,
      componentes_con_queries_directos: componentesConQueriesDirectos.length,
      tablas_referenciadas: tablesUsed.length
    },
    sps_llamados_frecuentemente: Object.fromEntries(
      Object.entries(spFrequency)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 20)
    ),
    sps_en_catalogo_no_usados: spsInCatalogNotUsed,
    sps_usados_no_en_catalogo: spsUsedNotInCatalog,
    endpoints_api_encontrados: allEndpoints,
    tablas_referenciadas: tablesUsed,
    componentes_con_queries_directos: componentesConQueriesDirectos.map(c => path.basename(c.ruta))
  };
  
  fs.writeFileSync(OUTPUT_PATH, JSON.stringify(report, null, 2), 'utf-8');
  console.log(`\nReporte generado: ${OUTPUT_PATH}`);
  console.log(`\nEstadísticas:`);
  console.log(`- Componentes analizados: ${report.resumen.total_componentes_analizados}`);
  console.log(`- SPs únicos encontrados: ${report.resumen.total_sps_llamados}`);
  console.log(`- SPs NO en catálogo: ${report.resumen.sps_no_existen_en_catalogo}`);
  console.log(`- Endpoints únicos: ${report.resumen.total_endpoints_unicos}`);
  console.log(`- Tablas referenciadas: ${report.resumen.tablas_referenciadas}`);
}

generateReport();
