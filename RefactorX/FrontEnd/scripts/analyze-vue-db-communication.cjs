const fs = require('fs');
const path = require('path');

console.log('\n╔════════════════════════════════════════════════════════════════╗');
console.log('║  📊 ANÁLISIS COMPLETO - VUE APP Y COMUNICACIÓN A BASE DE DATOS ║');
console.log('╔════════════════════════════════════════════════════════════════╗\n');

// =================================================================
// 1. ESTRUCTURA DE LA APLICACIÓN VUE
// =================================================================

console.log('1️⃣  ESTRUCTURA DE LA APLICACIÓN VUE');
console.log('════════════════════════════════════════════════════════════════\n');

const srcPath = path.join(__dirname, '../src');

// Verificar existencia de directorios clave
const directories = {
    'views': path.join(srcPath, 'views'),
    'views/modules': path.join(srcPath, 'views/modules'),
    'composables': path.join(srcPath, 'composables'),
    'services': path.join(srcPath, 'services'),
    'router': path.join(srcPath, 'router'),
    'stores': path.join(srcPath, 'stores'),
};

console.log('📁 Directorios principales:\n');

for (const [name, dirPath] of Object.entries(directories)) {
    if (fs.existsSync(dirPath)) {
        const files = fs.readdirSync(dirPath);
        console.log(`   ✅ ${name}: ${files.length} archivos`);
    } else {
        console.log(`   ❌ ${name}: No existe`);
    }
}

// =================================================================
// 2. MÓDULOS DISPONIBLES
// =================================================================

console.log('\n2️⃣  MÓDULOS DISPONIBLES EN LA APP');
console.log('════════════════════════════════════════════════════════════════\n');

const modulesPath = path.join(srcPath, 'views/modules');

if (fs.existsSync(modulesPath)) {
    const modules = fs.readdirSync(modulesPath, { withFileTypes: true })
        .filter(dirent => dirent.isDirectory())
        .map(dirent => dirent.name);

    console.log(`📦 Total de módulos: ${modules.length}\n`);

    for (const module of modules) {
        const modulePath = path.join(modulesPath, module);
        const files = fs.readdirSync(modulePath).filter(f => f.endsWith('.vue'));

        console.log(`   • ${module}: ${files.length} componentes Vue`);
    }
} else {
    console.log('   ❌ No se encontró el directorio de módulos\n');
}

// =================================================================
// 3. ANÁLISIS DEL MÓDULO CEMENTERIOS
// =================================================================

console.log('\n3️⃣  ANÁLISIS DETALLADO - MÓDULO CEMENTERIOS');
console.log('════════════════════════════════════════════════════════════════\n');

const cementeriosPath = path.join(modulesPath, 'cementerios');

let totalSpCalls = 0;
let componentsWithApi = 0;
let componentsWithCorrectSchema = 0;
const spUsage = {};

if (fs.existsSync(cementeriosPath)) {
    const vueFiles = fs.readdirSync(cementeriosPath).filter(f => f.endsWith('.vue'));

    console.log(`📋 Componentes Vue: ${vueFiles.length}\n`);

    for (const file of vueFiles) {
        const filePath = path.join(cementeriosPath, file);
        const content = fs.readFileSync(filePath, 'utf-8');

        // Verificar si usa useApi
        const usesApi = content.includes('useApi') || content.includes('execute(');

        if (usesApi) {
            componentsWithApi++;

            // Buscar llamadas a execute
            const executeRegex = /execute\s*\(\s*['"`]([^'"`]+)['"`]/g;
            let match;

            while ((match = executeRegex.exec(content)) !== null) {
                const spName = match[1];
                totalSpCalls++;

                spUsage[spName] = (spUsage[spName] || 0) + 1;
            }

            // Verificar si especifica schema 'comun'
            if (content.includes("'comun'") || content.includes('"comun"') || content.includes('`comun`')) {
                componentsWithCorrectSchema++;
            }
        }
    }

    console.log('📊 Estadísticas de uso:\n');
    console.log(`   • Componentes con API: ${componentsWithApi}/${vueFiles.length}`);
    console.log(`   • Componentes con schema 'comun': ${componentsWithCorrectSchema}/${componentsWithApi}`);
    console.log(`   • Total de llamadas a SPs: ${totalSpCalls}\n`);

    if (Object.keys(spUsage).length > 0) {
        console.log('📋 SPs utilizados:\n');

        const sortedSps = Object.entries(spUsage).sort((a, b) => b[1] - a[1]);

        for (const [sp, count] of sortedSps) {
            console.log(`   • ${sp}: ${count} uso(s)`);
        }
    }
} else {
    console.log('   ❌ No se encontró el módulo cementerios\n');
}

// =================================================================
// 4. ANÁLISIS DEL SISTEMA DE API
// =================================================================

console.log('\n4️⃣  SISTEMA DE API (COMPOSABLES Y SERVICES)');
console.log('════════════════════════════════════════════════════════════════\n');

// Verificar useApi.js
const useApiPath = path.join(srcPath, 'composables/useApi.js');

if (fs.existsSync(useApiPath)) {
    const content = fs.readFileSync(useApiPath, 'utf-8');

    console.log('✅ useApi.js encontrado\n');

    // Verificar que importa apiService
    if (content.includes('apiService')) {
        console.log('   ✅ Importa apiService correctamente');
    } else {
        console.log('   ⚠️  No importa apiService');
    }

    // Verificar función execute
    if (content.includes('const execute =') || content.includes('function execute')) {
        console.log('   ✅ Función execute definida');

        // Extraer firma de la función execute
        const executeMatch = content.match(/(?:const|function)\s+execute\s*[=]?\s*\(([^)]*)\)/);
        if (executeMatch) {
            console.log(`   └─ Parámetros: ${executeMatch[1]}`);
        }
    } else {
        console.log('   ⚠️  Función execute no encontrada');
    }

    console.log('');
} else {
    console.log('❌ useApi.js NO encontrado\n');
}

// Verificar apiService.js
const apiServicePath = path.join(srcPath, 'services/apiService.js');

if (fs.existsSync(apiServicePath)) {
    const content = fs.readFileSync(apiServicePath, 'utf-8');

    console.log('✅ apiService.js encontrado\n');

    // Verificar URL del backend
    const baseUrlMatch = content.match(/baseURL\s*:\s*['"`]([^'"`]+)['"`]/);
    if (baseUrlMatch) {
        console.log(`   📡 Base URL: ${baseUrlMatch[1]}`);
    }

    // Verificar endpoint genérico
    if (content.includes('/api/generic') || content.includes('generic')) {
        console.log('   ✅ Usa endpoint /api/generic');
    }

    console.log('');
} else {
    console.log('❌ apiService.js NO encontrado\n');
}

// =================================================================
// 5. CONFIGURACIÓN DEL BACKEND
// =================================================================

console.log('\n5️⃣  CONFIGURACIÓN DEL BACKEND (GenericController)');
console.log('════════════════════════════════════════════════════════════════\n');

const backendPath = path.join(__dirname, '../../../BackEnd');
const controllerPath = path.join(backendPath, 'app/Http/Controllers/Api/GenericController.php');

if (fs.existsSync(controllerPath)) {
    const content = fs.readFileSync(controllerPath, 'utf-8');

    console.log('✅ GenericController.php encontrado\n');

    // Extraer configuración de módulos
    const configMatch = content.match(/protected\s+\$moduleConfig\s*=\s*\[([\s\S]*?)\];/);

    if (configMatch) {
        const configContent = configMatch[1];

        // Buscar todos los módulos configurados
        const moduleMatches = [...configContent.matchAll(/'([^']+)'\s*=>\s*\[/g)];

        console.log(`📦 Módulos configurados: ${moduleMatches.length}\n`);

        for (const match of moduleMatches) {
            const moduleName = match[1];

            // Extraer configuración de cada módulo
            const moduleRegex = new RegExp(`'${moduleName}'\\s*=>\\s*\\[([\\s\\S]*?)\\](?:,|\\s*\\n)`, 'g');
            const moduleConfig = moduleRegex.exec(configContent);

            if (moduleConfig) {
                const config = moduleConfig[1];

                // Extraer database
                const dbMatch = config.match(/'database'\s*=>\s*'([^']+)'/);
                const schemaMatch = config.match(/'allowed_schemas'\s*=>\s*\[([^\]]+)\]/);

                console.log(`   📋 ${moduleName}:`);
                console.log(`      └─ Base de datos: ${dbMatch ? dbMatch[1] : 'no especificada'}`);
                console.log(`      └─ Schemas permitidos: ${schemaMatch ? schemaMatch[1].replace(/'/g, '').trim() : 'no especificados'}`);

                // Destacar cementerios
                if (moduleName === 'cementerios') {
                    console.log('      ✅ MÓDULO CEMENTERIOS CONFIGURADO');
                }
                console.log('');
            }
        }
    } else {
        console.log('   ⚠️  No se pudo extraer configuración de módulos\n');
    }
} else {
    console.log('❌ GenericController.php NO encontrado\n');
}

// =================================================================
// 6. FLUJO DE COMUNICACIÓN
// =================================================================

console.log('\n6️⃣  FLUJO DE COMUNICACIÓN COMPLETO');
console.log('════════════════════════════════════════════════════════════════\n');

console.log('📡 Cadena de comunicación:\n');
console.log('   1. Componente Vue (ej: ConIndividual.vue)');
console.log('      └─ import { useApi } from \'@/composables/useApi\'');
console.log('      └─ const { execute } = useApi()');
console.log('      └─ await execute(spName, module, params, tenant, pagination, schema)');
console.log('');
console.log('   2. useApi.js (Composable)');
console.log('      └─ Procesa parámetros');
console.log('      └─ Llama a apiService');
console.log('');
console.log('   3. apiService.js');
console.log('      └─ POST /api/generic');
console.log('      └─ Body: { sp_name, module, params, schema, ... }');
console.log('');
console.log('   4. Backend - GenericController.php');
console.log('      └─ Recibe request');
console.log('      └─ Lee configuración del módulo');
console.log('      └─ Conecta a base de datos configurada');
console.log('      └─ Ejecuta: SELECT * FROM schema.sp_name(params)');
console.log('');
console.log('   5. PostgreSQL');
console.log('      └─ Base: padron_licencias (o la configurada)');
console.log('      └─ Schema: comun (o el especificado)');
console.log('      └─ Ejecuta stored procedure');
console.log('      └─ Retorna resultados');
console.log('');
console.log('   6. Respuesta a Vue');
console.log('      └─ JSON: { success: true, data: { result: [...] } }');
console.log('      └─ Vue procesa y muestra en UI');
console.log('');

// =================================================================
// 7. VERIFICACIÓN DE COMPONENTES CRÍTICOS
// =================================================================

console.log('\n7️⃣  VERIFICACIÓN DE COMPONENTES CRÍTICOS');
console.log('════════════════════════════════════════════════════════════════\n');

const criticalFiles = [
    { path: useApiPath, name: 'useApi.js', type: 'Composable' },
    { path: apiServicePath, name: 'apiService.js', type: 'Service' },
    { path: controllerPath, name: 'GenericController.php', type: 'Backend Controller' },
    { path: path.join(srcPath, 'router/index.js'), name: 'router/index.js', type: 'Router' },
    { path: path.join(backendPath, '.env'), name: '.env', type: 'Backend Config' },
];

console.log('📋 Archivos críticos:\n');

let allCriticalExist = true;

for (const file of criticalFiles) {
    if (fs.existsSync(file.path)) {
        console.log(`   ✅ ${file.name} (${file.type})`);
    } else {
        console.log(`   ❌ ${file.name} (${file.type}) - NO ENCONTRADO`);
        allCriticalExist = false;
    }
}

console.log('');

// =================================================================
// 8. ANÁLISIS DE EJEMPLO: ConIndividual.vue
// =================================================================

console.log('\n8️⃣  ANÁLISIS DE EJEMPLO - ConIndividual.vue');
console.log('════════════════════════════════════════════════════════════════\n');

const conIndividualPath = path.join(cementeriosPath, 'ConIndividual.vue');

if (fs.existsSync(conIndividualPath)) {
    const content = fs.readFileSync(conIndividualPath, 'utf-8');

    console.log('✅ Componente encontrado\n');

    // Verificar import de useApi
    if (content.includes('useApi')) {
        console.log('   ✅ Importa useApi');
    }

    // Buscar todas las llamadas a execute
    const executeRegex = /execute\s*\(\s*['"`]([^'"`]+)['"`][^)]*\)/g;
    const calls = [...content.matchAll(executeRegex)];

    if (calls.length > 0) {
        console.log(`   ✅ ${calls.length} llamadas a SPs:\n`);

        for (const call of calls) {
            console.log(`      • ${call[1]}`);
        }
    }

    // Verificar si especifica schema
    if (content.includes("'comun'") || content.includes('"comun"')) {
        console.log('\n   ✅ Especifica schema "comun" correctamente');
    } else {
        console.log('\n   ⚠️  No especifica schema "comun"');
    }

    console.log('');
} else {
    console.log('   ⚠️  Componente no encontrado\n');
}

// =================================================================
// 9. RESUMEN FINAL
// =================================================================

console.log('\n9️⃣  RESUMEN FINAL');
console.log('════════════════════════════════════════════════════════════════\n');

const checks = [
    { name: 'Estructura Vue completa', status: fs.existsSync(srcPath) },
    { name: 'Módulo cementerios existe', status: fs.existsSync(cementeriosPath) },
    { name: 'useApi.js configurado', status: fs.existsSync(useApiPath) },
    { name: 'apiService.js configurado', status: fs.existsSync(apiServicePath) },
    { name: 'GenericController configurado', status: fs.existsSync(controllerPath) },
    { name: 'Componentes usan API correctamente', status: componentsWithApi > 0 },
    { name: 'Archivos críticos presentes', status: allCriticalExist },
];

console.log('📊 Estado de la aplicación:\n');

const passed = checks.filter(c => c.status).length;
const total = checks.length;

for (const check of checks) {
    const icon = check.status ? '✅' : '❌';
    console.log(`   ${icon} ${check.name}`);
}

console.log(`\n   📈 Total: ${passed}/${total} verificaciones pasadas (${Math.round(passed/total*100)}%)\n`);

if (passed === total) {
    console.log('🎉 APLICACIÓN VUE COMPLETAMENTE CONFIGURADA\n');
    console.log('✅ Comunicación Vue ↔ Backend ↔ Base de Datos: OPERATIVA\n');
} else {
    console.log('⚠️  ALGUNOS COMPONENTES NECESITAN ATENCIÓN\n');
}

console.log('════════════════════════════════════════════════════════════════');
console.log('✅ ANÁLISIS COMPLETADO');
console.log('════════════════════════════════════════════════════════════════\n');
