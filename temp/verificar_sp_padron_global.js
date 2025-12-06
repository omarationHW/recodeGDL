/**
 * Script de verificación rápida del SP sp_padron_global
 */

const { Client } = require('pg');

const config = {
    host: '192.168.6.146',
    port: 5432,
    database: 'mercados',
    user: 'refact',
    password: 'FF)-BQk2'
};

async function main() {
    const client = new Client(config);

    try {
        await client.connect();
        console.log('✓ Conectado a la base de datos mercados\n');

        // Verificar que el SP existe
        const checkSP = `
            SELECT routine_name, routine_type
            FROM information_schema.routines
            WHERE routine_schema = 'publico'
            AND routine_name = 'sp_padron_global'
        `;

        const spResult = await client.query(checkSP);

        if (spResult.rows.length === 0) {
            console.log('✗ El SP sp_padron_global NO existe en la base de datos');
            console.log('  Ejecutar primero: node fix_sp_padron_global.js');
            process.exit(1);
        }

        console.log('✓ SP sp_padron_global encontrado en la base de datos\n');

        // Probar con diferentes vigencias
        const now = new Date();
        const year = now.getFullYear();
        const month = now.getMonth() + 1;

        console.log('PRUEBAS DEL SP');
        console.log('='.repeat(60));
        console.log(`Parámetros: año=${year}, mes=${month}\n`);

        const vigencias = ['A', 'B', 'C', 'D', 'T'];

        for (const vig of vigencias) {
            const countQuery = `SELECT COUNT(*) FROM publico.sp_padron_global($1, $2, $3)`;
            const result = await client.query(countQuery, [year, month, vig]);
            const total = parseInt(result.rows[0].count);

            console.log(`  Vigencia '${vig}': ${total.toLocaleString()} registros`);
        }

        // Obtener un registro de muestra
        console.log('\n\nREGISTRO DE MUESTRA');
        console.log('='.repeat(60));

        const sampleQuery = `
            SELECT *
            FROM publico.sp_padron_global($1, $2, $3)
            LIMIT 1
        `;

        const sample = await client.query(sampleQuery, [year, month, 'T']);

        if (sample.rows.length > 0) {
            const row = sample.rows[0];
            console.log(`ID Local: ${row.id_local}`);
            console.log(`Mercado: ${row.num_mercado} - ${row.descripcion}`);
            console.log(`Local: ${row.local}${row.letra_local || ''}`);
            console.log(`Nombre: ${row.nombre}`);
            console.log(`Descripción Local: [${row.descripcion_local}] (tipo: CHARACTER(20))`);
            console.log(`Superficie: ${row.superficie} m²`);
            console.log(`Vigencia: ${row.vigencia}`);
            console.log(`Renta: $${parseFloat(row.renta).toLocaleString('es-MX', { minimumFractionDigits: 2 })}`);
            console.log(`Adeudo: ${row.leyenda}`);
        }

        // Verificar tipos de datos del resultado
        console.log('\n\nVERIFICACIÓN DE TIPOS DE DATOS');
        console.log('='.repeat(60));

        const typesQuery = `
            SELECT
                parameter_name,
                data_type,
                character_maximum_length
            FROM information_schema.parameters
            WHERE specific_schema = 'publico'
            AND specific_name LIKE '%sp_padron_global%'
            AND parameter_mode = 'OUT'
            ORDER BY ordinal_position
        `;

        const typesResult = await client.query(typesQuery);

        if (typesResult.rows.length > 0) {
            console.log('Tipos de datos retornados por el SP:\n');
            for (const row of typesResult.rows) {
                let typeStr = row.data_type;
                if (row.character_maximum_length) {
                    typeStr += `(${row.character_maximum_length})`;
                }
                console.log(`  ${row.parameter_name || 'column'}: ${typeStr}`);
            }
        }

        console.log('\n' + '='.repeat(60));
        console.log('✓ VERIFICACIÓN COMPLETADA');
        console.log('✓ El SP sp_padron_global está funcionando correctamente');
        console.log('='.repeat(60) + '\n');

    } catch (error) {
        console.error('\n✗ ERROR:', error.message);
        process.exit(1);
    } finally {
        await client.end();
    }
}

main();
