const fs = require('fs');
const path = require('path');

console.log('\n╔════════════════════════════════════════════════════════════════╗');
console.log('║  📋 MAPEO COMPLETO - SPs ↔ Componentes Vue                    ║');
console.log('╔════════════════════════════════════════════════════════════════╗\n');

const cementeriosPath = path.join(__dirname, '../src/views/modules/cementerios');
const outputPath = path.join(__dirname, '../../BackEnd');

// SPs ya instalados
const installedSPs = [
    'sp_cem_listar_cementerios',
    'sp_cem_consultar_folio',
    'sp_cem_consultar_pagos_folio',
    'sp_cem_consultar_cementerio',
    'sp_cem_buscar_folio',
    'sp_cem_consultar_folios_por_nombre',
    'sp_cem_listar_movimientos',
    'sp_cem_reporte_bonificaciones',
    'sp_cem_reporte_cuentas_cobrar',
    'sp_cem_reporte_titulos',
];

const spMapping = {};
const componentDetails = {};

// Analizar todos los componentes
const vueFiles = fs.readdirSync(cementeriosPath).filter(f => f.endsWith('.vue'));

console.log('1️⃣  ANALIZANDO COMPONENTES VUE');
console.log('════════════════════════════════════════════════════════════════\n');

for (const file of vueFiles) {
    const filePath = path.join(cementeriosPath, file);
    const content = fs.readFileSync(filePath, 'utf-8');

    // Extraer todas las llamadas a execute
    const executeRegex = /execute\s*\(\s*['"`]([^'"`]+)['"`][^)]*\)/g;
    const matches = [...content.matchAll(executeRegex)];

    if (matches.length > 0) {
        componentDetails[file] = {
            sps: [],
            hasSchema: content.includes("'comun'") || content.includes('"comun"') || content.includes('`comun`'),
            usesApi: true
        };

        for (const match of matches) {
            const spName = match[1];
            componentDetails[file].sps.push(spName);

            if (!spMapping[spName]) {
                spMapping[spName] = {
                    components: [],
                    installed: installedSPs.includes(spName),
                    count: 0
                };
            }

            spMapping[spName].components.push(file);
            spMapping[spName].count++;
        }
    }
}

console.log(`   Componentes analizados: ${Object.keys(componentDetails).length}\n`);

// Clasificar SPs
const pendingSPs = Object.keys(spMapping).filter(sp => !spMapping[sp].installed);
const sortedPending = pendingSPs.sort((a, b) => spMapping[b].count - spMapping[a].count);

console.log('2️⃣  CLASIFICACIÓN DE SPs');
console.log('════════════════════════════════════════════════════════════════\n');

console.log(`   ✅ SPs instalados: ${installedSPs.length}`);
console.log(`   ❌ SPs pendientes: ${pendingSPs.length}`);
console.log(`   📊 Total: ${Object.keys(spMapping).length}\n`);

// Categorizar SPs pendientes
const categories = {
    abc: [],
    pagos: [],
    bonificaciones: [],
    reportes: [],
    auth: [],
    otros: []
};

for (const sp of sortedPending) {
    if (sp.includes('abc')) {
        categories.abc.push(sp);
    } else if (sp.includes('pago') || sp.includes('liquidacion')) {
        categories.pagos.push(sp);
    } else if (sp.includes('bonificacion')) {
        categories.bonificaciones.push(sp);
    } else if (sp.includes('reporte') || sp.includes('listar') || sp.includes('estadisticas')) {
        categories.reportes.push(sp);
    } else if (sp.includes('validar') || sp.includes('password') || sp.includes('acceso')) {
        categories.auth.push(sp);
    } else {
        categories.otros.push(sp);
    }
}

console.log('3️⃣  SPs PENDIENTES POR CATEGORÍA');
console.log('════════════════════════════════════════════════════════════════\n');

const catNames = {
    abc: 'Alta/Baja/Cambio (ABC)',
    pagos: 'Pagos y Liquidaciones',
    bonificaciones: 'Bonificaciones',
    reportes: 'Reportes y Listados',
    auth: 'Autenticación',
    otros: 'Otros'
};

for (const [key, sps] of Object.entries(categories)) {
    if (sps.length > 0) {
        console.log(`   📁 ${catNames[key]}: ${sps.length} SPs\n`);

        for (const sp of sps) {
            const count = spMapping[sp].count;
            const comps = spMapping[sp].components.length;
            console.log(`      • ${sp} (${count} usos en ${comps} componentes)`);
        }
        console.log('');
    }
}

// Generar archivo JSON con el mapeo
const mappingData = {
    summary: {
        totalSPs: Object.keys(spMapping).length,
        installed: installedSPs.length,
        pending: pendingSPs.length,
        totalComponents: Object.keys(componentDetails).length,
        componentsWithoutSchema: Object.values(componentDetails).filter(c => !c.hasSchema).length
    },
    spMapping: {},
    componentMapping: componentDetails,
    categories: {}
};

// Construir mapeo detallado
for (const [sp, data] of Object.entries(spMapping)) {
    mappingData.spMapping[sp] = {
        installed: data.installed,
        usageCount: data.count,
        components: [...new Set(data.components)].sort()
    };
}

// Agregar categorías
for (const [key, sps] of Object.entries(categories)) {
    if (sps.length > 0) {
        mappingData.categories[key] = sps.map(sp => ({
            name: sp,
            usageCount: spMapping[sp].count,
            components: [...new Set(spMapping[sp].components)].sort()
        }));
    }
}

fs.writeFileSync(
    path.join(outputPath, 'sp-vue-mapping.json'),
    JSON.stringify(mappingData, null, 2)
);

console.log('4️⃣  COMPONENTES SIN SCHEMA "comun"');
console.log('════════════════════════════════════════════════════════════════\n');

const withoutSchema = Object.entries(componentDetails).filter(([_, data]) => !data.hasSchema && data.sps.length > 0);

console.log(`   Total: ${withoutSchema.length} componentes\n`);

for (const [comp, data] of withoutSchema) {
    console.log(`   ⚠️  ${comp}`);
    console.log(`      └─ Llama a: ${data.sps.join(', ')}\n`);
}

// Generar lista priorizada de SPs a crear
console.log('5️⃣  PRIORIDAD DE CREACIÓN (Top 15)');
console.log('════════════════════════════════════════════════════════════════\n');

const prioritized = sortedPending.slice(0, 15);

for (let i = 0; i < prioritized.length; i++) {
    const sp = prioritized[i];
    const count = spMapping[sp].count;
    const comps = [...new Set(spMapping[sp].components)];

    console.log(`   ${i + 1}. ${sp}`);
    console.log(`      └─ Usos: ${count} en ${comps.length} componentes`);
    console.log(`      └─ Componentes: ${comps.slice(0, 3).join(', ')}${comps.length > 3 ? '...' : ''}\n`);
}

// Generar archivo de trabajo para crear SPs
const workPlan = {
    priority1_abc: categories.abc.map(sp => ({
        sp,
        components: [...new Set(spMapping[sp].components)],
        usageCount: spMapping[sp].count
    })),
    priority2_pagos: categories.pagos.map(sp => ({
        sp,
        components: [...new Set(spMapping[sp].components)],
        usageCount: spMapping[sp].count
    })),
    priority3_bonificaciones: categories.bonificaciones.map(sp => ({
        sp,
        components: [...new Set(spMapping[sp].components)],
        usageCount: spMapping[sp].count
    })),
    priority4_reportes: categories.reportes.map(sp => ({
        sp,
        components: [...new Set(spMapping[sp].components)],
        usageCount: spMapping[sp].count
    })),
    priority5_auth: categories.auth.map(sp => ({
        sp,
        components: [...new Set(spMapping[sp].components)],
        usageCount: spMapping[sp].count
    })),
    priority6_otros: categories.otros.map(sp => ({
        sp,
        components: [...new Set(spMapping[sp].components)],
        usageCount: spMapping[sp].count
    }))
};

fs.writeFileSync(
    path.join(outputPath, 'sps-work-plan.json'),
    JSON.stringify(workPlan, null, 2)
);

console.log('6️⃣  ARCHIVOS GENERADOS');
console.log('════════════════════════════════════════════════════════════════\n');

console.log('   ✅ sp-vue-mapping.json - Mapeo completo');
console.log('   ✅ sps-work-plan.json - Plan de trabajo priorizado\n');

console.log('7️⃣  RESUMEN');
console.log('════════════════════════════════════════════════════════════════\n');

console.log(`   📊 SPs a crear: ${pendingSPs.length}`);
console.log(`   📋 Componentes a actualizar: ${withoutSchema.length}`);
console.log(`   🎯 Prioridad 1 (ABC): ${categories.abc.length} SPs`);
console.log(`   💰 Prioridad 2 (Pagos): ${categories.pagos.length} SPs`);
console.log(`   🎁 Prioridad 3 (Bonificaciones): ${categories.bonificaciones.length} SPs`);
console.log(`   📈 Prioridad 4 (Reportes): ${categories.reportes.length} SPs`);
console.log(`   🔐 Prioridad 5 (Auth): ${categories.auth.length} SPs`);
console.log(`   📦 Prioridad 6 (Otros): ${categories.otros.length} SPs\n`);

console.log('════════════════════════════════════════════════════════════════');
console.log('✅ ANÁLISIS COMPLETADO');
console.log('════════════════════════════════════════════════════════════════\n');
