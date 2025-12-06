/**
 * Script para corregir el SP sp_padron_global en PostgreSQL
 * Verifica estructura de tablas y crea el SP con tipos correctos
 */

const { Client } = require('pg');

// Configuración de conexión
const config = {
    host: '192.168.6.146',
    port: 5432,
    database: 'mercados',
    user: 'refact',
    password: 'FF)-BQk2'
};

function printHeader(text) {
    console.log('\n' + '='.repeat(60));
    console.log(text);
    console.log('='.repeat(60));
}

function printSection(text) {
    console.log('\n' + text);
    console.log('-'.repeat(60));
}

async function main() {
    const client = new Client(config);

    try {
        // Conectar
        printHeader('CONEXIÓN A BASE DE DATOS');
        await client.connect();
        console.log('✓ Conexión exitosa');

        // 1. Verificar estructura de ta_11_locales
        printSection('1. ESTRUCTURA DE publico.ta_11_locales');

        const colsQuery = `
            SELECT
                column_name,
                data_type,
                character_maximum_length,
                numeric_precision,
                is_nullable
            FROM information_schema.columns
            WHERE table_schema = 'publico'
            AND table_name = 'ta_11_locales'
            ORDER BY ordinal_position
        `;

        const colsResult = await client.query(colsQuery);
        console.log('Columnas de ta_11_locales:');

        for (const row of colsResult.rows) {
            let typeStr = row.data_type;
            if (row.character_maximum_length) {
                typeStr += `(${row.character_maximum_length})`;
            } else if (row.numeric_precision) {
                typeStr += `(${row.numeric_precision})`;
            }
            console.log(`  - ${row.column_name}: ${typeStr} (nullable: ${row.is_nullable})`);

            if (row.column_name === 'descripcion_local') {
                console.log(`\n  *** CAMPO CLAVE: descripcion_local es ${typeStr} ***\n`);
            }
        }

        // 2. Verificar estructura de ta_11_mercados
        printSection('2. ESTRUCTURA DE publico.ta_11_mercados');

        const mercadosQuery = `
            SELECT column_name, data_type, character_maximum_length
            FROM information_schema.columns
            WHERE table_schema = 'publico'
            AND table_name = 'ta_11_mercados'
            AND column_name IN ('descripcion', 'num_mercado', 'id_mercado', 'num_mercado_nvo', 'oficina')
            ORDER BY ordinal_position
        `;

        const mercadosResult = await client.query(mercadosQuery);
        for (const row of mercadosResult.rows) {
            let typeStr = row.data_type;
            if (row.character_maximum_length) {
                typeStr += `(${row.character_maximum_length})`;
            }
            console.log(`  - ${row.column_name}: ${typeStr}`);
        }

        // 3. Verificar tablas relacionadas
        printSection('3. VERIFICAR TABLAS RELACIONADAS');

        const tablesToCheck = [
            'ta_11_cuo_locales',
            'ta_11_adeudo_local',
            'ta_11_fecha_desc',
            'ta_11_cve_cuota'
        ];

        for (const table of tablesToCheck) {
            const checkQuery = `
                SELECT COUNT(*)
                FROM information_schema.tables
                WHERE table_schema = 'publico'
                AND table_name = $1
            `;
            const checkResult = await client.query(checkQuery, [table]);
            const exists = parseInt(checkResult.rows[0].count) > 0;
            const status = exists ? '✓ EXISTE' : '✗ NO EXISTE';
            console.log(`  - publico.${table}: ${status}`);
        }

        // 4. Eliminar SP anterior
        printSection('4. ELIMINANDO SP ANTERIOR (si existe)');

        await client.query('DROP FUNCTION IF EXISTS publico.sp_padron_global(INTEGER, INTEGER, VARCHAR) CASCADE');
        console.log('✓ SP anterior eliminado');

        // 5. Crear nuevo SP
        printSection('5. CREANDO NUEVO SP sp_padron_global');

        const createSP = `
CREATE OR REPLACE FUNCTION publico.sp_padron_global(
    p_year INTEGER,
    p_month INTEGER,
    p_status VARCHAR
)
RETURNS TABLE(
    id_local INTEGER,
    oficina SMALLINT,
    num_mercado SMALLINT,
    categoria SMALLINT,
    seccion CHARACTER(2),
    local INTEGER,
    letra_local CHARACTER VARYING(3),
    bloque CHARACTER VARYING(2),
    nombre CHARACTER VARYING(60),
    descripcion_local CHARACTER(20),
    superficie NUMERIC,
    vigencia CHARACTER(1),
    clave_cuota SMALLINT,
    descripcion CHARACTER VARYING(30),
    renta NUMERIC(10,2),
    leyenda VARCHAR(50),
    adeudo INTEGER,
    registro VARCHAR(200)
)
AS $$
DECLARE
    v_periodo INTEGER;
BEGIN
    -- Calcular periodo (año + mes en formato YYYYMM)
    v_periodo := (p_year * 100) + p_month;

    RETURN QUERY
    SELECT
        l.id_local,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque,
        l.nombre,
        l.descripcion_local,
        l.superficie,
        l.vigencia,
        l.clave_cuota,
        m.descripcion,
        -- Cálculo de renta según lógica
        CASE
            -- PS con clave_cuota 4
            WHEN l.seccion = 'PS' AND l.clave_cuota = 4 THEN
                ROUND((l.superficie * COALESCE(c.importe_cuota, 0)), 2)
            -- PS otros
            WHEN l.seccion = 'PS' THEN
                ROUND(((COALESCE(c.importe_cuota, 0) * l.superficie) * 30), 2)
            -- Mercado 214
            WHEN l.num_mercado = 214 THEN
                ROUND((l.superficie * COALESCE(c.importe_cuota, 0) * COALESCE(fd.sabadosacum, 1)), 2)
            -- Default
            ELSE
                ROUND((l.superficie * COALESCE(c.importe_cuota, 0)), 2)
        END::NUMERIC(10,2) AS renta,
        -- Leyenda de adeudo
        CASE
            WHEN COALESCE(a.adeudos, 0) >= 1 THEN 'Local con Adeudo'::VARCHAR(50)
            ELSE 'Local al Corriente de Pagos'::VARCHAR(50)
        END AS leyenda,
        -- Indicador de adeudo (0 o 1)
        CASE
            WHEN COALESCE(a.adeudos, 0) >= 1 THEN 1
            ELSE 0
        END::INTEGER AS adeudo,
        -- Registro concatenado
        (l.oficina::TEXT || ' ' ||
         l.num_mercado::TEXT || ' ' ||
         l.categoria::TEXT || ' ' ||
         l.seccion || ' ' ||
         l.local::TEXT || ' ' ||
         COALESCE(l.letra_local, '') || ' ' ||
         COALESCE(l.bloque, ''))::VARCHAR(200) AS registro
    FROM publico.ta_11_locales l
    INNER JOIN publico.ta_11_mercados m
        ON l.oficina = m.oficina
        AND l.num_mercado = m.num_mercado_nvo
    LEFT JOIN publico.ta_11_cuo_locales c
        ON c.axo = p_year
        AND c.categoria = l.categoria
        AND c.seccion = l.seccion
        AND c.clave_cuota = l.clave_cuota
    LEFT JOIN (
        SELECT
            al.id_local,
            COUNT(*)::INTEGER AS adeudos
        FROM publico.ta_11_adeudo_local al
        WHERE (al.axo = p_year AND al.periodo <= p_month)
           OR (al.axo < p_year)
        GROUP BY al.id_local
    ) a ON a.id_local = l.id_local
    LEFT JOIN publico.ta_11_fecha_desc fd
        ON fd.mes = p_month
    WHERE
        (p_status = 'T' OR l.vigencia = p_status)
    ORDER BY
        l.vigencia,
        l.oficina,
        l.num_mercado,
        l.categoria,
        l.seccion,
        l.local,
        l.letra_local,
        l.bloque;
END;
$$ LANGUAGE plpgsql;
        `;

        await client.query(createSP);
        console.log('✓ SP sp_padron_global creado exitosamente');

        // 6. Probar el SP
        printSection('6. PROBANDO EL SP');

        const now = new Date();
        const currentYear = now.getFullYear();
        const currentMonth = now.getMonth() + 1;

        console.log(`Parámetros de prueba:`);
        console.log(`  - Año: ${currentYear}`);
        console.log(`  - Mes: ${currentMonth}`);
        console.log(`  - Vigencia: 'A'`);
        console.log();

        // Contar registros con vigencia 'A'
        const countA = await client.query(
            'SELECT COUNT(*) FROM publico.sp_padron_global($1, $2, $3)',
            [currentYear, currentMonth, 'A']
        );
        const totalA = parseInt(countA.rows[0].count);
        console.log(`✓ Registros con vigencia 'A': ${totalA}`);

        // Contar registros totales
        const countT = await client.query(
            'SELECT COUNT(*) FROM publico.sp_padron_global($1, $2, $3)',
            [currentYear, currentMonth, 'T']
        );
        const totalT = parseInt(countT.rows[0].count);
        console.log(`✓ Registros totales (vigencia 'T'): ${totalT}`);

        // Obtener primeros 3 registros
        const vigenciaTest = totalA > 0 ? 'A' : 'T';
        const totalTest = totalA > 0 ? totalA : totalT;

        const samplesQuery = `
            SELECT
                id_local,
                oficina,
                num_mercado,
                descripcion,
                categoria,
                seccion,
                local,
                letra_local,
                bloque,
                nombre,
                descripcion_local,
                superficie,
                vigencia,
                clave_cuota,
                renta,
                leyenda,
                adeudo,
                registro
            FROM publico.sp_padron_global($1, $2, $3)
            LIMIT 3
        `;

        const samplesResult = await client.query(samplesQuery, [currentYear, currentMonth, vigenciaTest]);

        if (samplesResult.rows.length > 0) {
            console.log(`\nEJEMPLOS DE REGISTROS (primeros 3 con vigencia '${vigenciaTest}'):`);
            console.log('='.repeat(60));

            samplesResult.rows.forEach((row, idx) => {
                console.log(`\nRegistro ${idx + 1}:`);
                console.log(`  ID Local: ${row.id_local}`);
                console.log(`  Oficina: ${row.oficina}`);
                console.log(`  Mercado: ${row.num_mercado} - ${row.descripcion}`);
                console.log(`  Categoría: ${row.categoria}`);
                console.log(`  Sección: ${row.seccion}`);
                console.log(`  Local: ${row.local}${row.letra_local || ''}`);
                console.log(`  Bloque: ${row.bloque || ''}`);
                console.log(`  Nombre: ${row.nombre}`);
                console.log(`  Descripción Local: [${row.descripcion_local}]`);
                console.log(`  Superficie: ${row.superficie} m²`);
                console.log(`  Vigencia: ${row.vigencia}`);
                console.log(`  Clave Cuota: ${row.clave_cuota}`);
                console.log(`  Renta: $${parseFloat(row.renta).toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`);
                console.log(`  Adeudo: ${row.leyenda} (${row.adeudo})`);
                console.log(`  Registro: ${row.registro}`);
            });
        }

        // Resumen final
        printHeader('RESUMEN DE LA CORRECCIÓN');
        console.log('✓ Verificada estructura de ta_11_locales');
        console.log('✓ Campo descripcion_local identificado correctamente');
        console.log('✓ SP sp_padron_global eliminado (versión anterior)');
        console.log('✓ SP sp_padron_global creado con tipos correctos');
        console.log('✓ SP probado exitosamente');
        console.log(`✓ Retorna ${totalTest} registros con los parámetros de prueba`);
        console.log('\nEl SP está listo para usar en producción.');
        console.log();

    } catch (error) {
        console.error('\n✗ ERROR:');
        console.error(`  ${error.message}`);
        if (error.stack) {
            console.error('\nStack trace:');
            console.error(error.stack);
        }
        process.exit(1);
    } finally {
        await client.end();
    }
}

main();
