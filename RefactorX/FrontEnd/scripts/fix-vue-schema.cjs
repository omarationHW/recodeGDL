const fs = require('fs');
const path = require('path');

console.log('\n╔════════════════════════════════════════════════════════════════╗');
console.log('║  🔧 ACTUALIZACIÓN DE COMPONENTES VUE - Schema "comun"         ║');
console.log('╔════════════════════════════════════════════════════════════════╗\n');

const cementeriosPath = path.join(__dirname, '../src/views/modules/cementerios');

// Componentes que necesitan actualización (sin schema 'comun')
const componentsToFix = [
    'ABCPagosxfol.vue',
    'Acceso.vue',
    'Bonificacion1.vue',
    'ConIndividual.vue',
    'ConIndividual_CORREGIDO.vue',
    'Consulta400.vue',
    'ConsultaGuad.vue',
    'ConsultaJardin.vue',
    'ConsultaMezq.vue',
    'ConsultaNombre.vue',
    'ConsultaRCM.vue',
    'ConsultaSAndres.vue',
    'Duplicados.vue',
    'Estad_adeudo.vue',
    'List_Mov.vue',
    'Multiplefecha.vue',
    'MultipleNombre.vue',
    'MultipleRCM.vue',
    'Rep_a_Cobrar.vue',
    'Rep_Bon.vue',
    'RptTitulos.vue',
    'sfrm_chgpass.vue',
    'TitulosSin.vue',
    'TrasladoFolSin.vue'
];

let totalUpdated = 0;
let totalErrors = 0;

console.log('1️⃣  ACTUALIZANDO COMPONENTES');
console.log('════════════════════════════════════════════════════════════════\n');

for (const filename of componentsToFix) {
    const filePath = path.join(cementeriosPath, filename);

    if (!fs.existsSync(filePath)) {
        console.log(`   ⚠️  ${filename} - No encontrado`);
        totalErrors++;
        continue;
    }

    try {
        let content = fs.readFileSync(filePath, 'utf-8');
        let modified = false;
        let changes = 0;

        // Patrón para encontrar llamadas a execute sin schema o con schema incorrecto
        // execute('sp_name', 'module', params, '', null) o execute('sp_name', 'module', params)
        const patterns = [
            // Patrón 1: execute(...params, '', null) sin schema
            {
                regex: /execute\s*\(\s*(['"`])([^'"`]+)\1\s*,\s*(['"`])([^'"`]+)\3\s*,\s*([^,]+)\s*,\s*(['"`])\6\s*,\s*null\s*\)/g,
                replacement: (match, q1, spName, q3, module, params, q6) => {
                    return `execute(${q1}${spName}${q1}, ${q3}${module}${q3}, ${params}, ${q6}${q6}, null, 'comun')`;
                }
            },
            // Patrón 2: execute(...params) sin tenant ni pagination ni schema
            {
                regex: /execute\s*\(\s*(['"`])([^'"`]+)\1\s*,\s*(['"`])([^'"`]+)\3\s*,\s*([^)]+)\s*\)/g,
                replacement: (match, q1, spName, q3, module, params) => {
                    // Solo agregar si no tiene ya los parámetros adicionales
                    if (!match.includes('comun')) {
                        return `execute(${q1}${spName}${q1}, ${q3}${module}${q3}, ${params}, '', null, 'comun')`;
                    }
                    return match;
                }
            }
        ];

        // Aplicar cada patrón
        for (const pattern of patterns) {
            const newContent = content.replace(pattern.regex, pattern.replacement);
            if (newContent !== content) {
                const oldMatches = (content.match(pattern.regex) || []).length;
                content = newContent;
                changes += oldMatches;
                modified = true;
            }
        }

        if (modified) {
            fs.writeFileSync(filePath, content, 'utf-8');
            console.log(`   ✅ ${filename} - ${changes} llamada(s) actualizada(s)`);
            totalUpdated++;
        } else {
            console.log(`   ℹ️  ${filename} - Ya está correcto`);
        }

    } catch (error) {
        console.log(`   ❌ ${filename} - Error: ${error.message}`);
        totalErrors++;
    }
}

console.log('\n2️⃣  RESUMEN');
console.log('════════════════════════════════════════════════════════════════\n');

console.log(`   ✅ Componentes actualizados: ${totalUpdated}`);
console.log(`   ℹ️  Ya correctos: ${componentsToFix.length - totalUpdated - totalErrors}`);
console.log(`   ❌ Errores: ${totalErrors}`);
console.log(`   📊 Total procesado: ${componentsToFix.length}\n`);

if (totalErrors === 0) {
    console.log('🎉 ACTUALIZACIÓN COMPLETADA EXITOSAMENTE\n');
    console.log('✅ Todos los componentes ahora especifican schema "comun"\n');
} else {
    console.log('⚠️  ACTUALIZACIÓN COMPLETADA CON ERRORES\n');
}

console.log('════════════════════════════════════════════════════════════════\n');
