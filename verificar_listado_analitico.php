<?php
// Verificar estructura para listado analítico

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICACIÓN PARA LISTADO ANALÍTICO ===\n\n";

    // 1. Verificar reqbfpredial
    echo "1. Tabla principal: public.reqbfpredial\n";
    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM public.reqbfpredial
    ");
    $total = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Registros: " . number_format($total['total']) . "\n\n";

    // 2. Ver estructura de la tabla
    echo "2. Campos disponibles:\n";
    $cols = $pdo->query("
        SELECT column_name
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'reqbfpredial'
        ORDER BY ordinal_position
    ");
    foreach ($cols->fetchAll(PDO::FETCH_ASSOC) as $col) {
        echo "   - {$col['column_name']}\n";
    }

    // 3. JOIN con detreqbfpredial para desglose
    echo "\n3. Ejemplo de listado analítico (JOIN reqbfpredial + detreqbfpredial):\n\n";

    $stmt = $pdo->query("
        SELECT
            r.cvecuenta,
            r.vigencia,
            r.fecemi,
            r.total as total_req,
            d.axo,
            d.bimini,
            d.bimfin,
            d.impuesto,
            d.recargos
        FROM public.reqbfpredial r
        LEFT JOIN public.detreqbfpredial d ON r.cvecuenta = d.cvecuenta
        WHERE r.vigencia IS NOT NULL
        ORDER BY r.cvecuenta, d.axo
        LIMIT 10
    ");

    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($results as $i => $row) {
        echo "   Registro " . ($i + 1) . ":\n";
        echo "     Cuenta: {$row['cvecuenta']}\n";
        echo "     Vigencia: {$row['vigencia']}\n";
        echo "     Fecha Emisión: {$row['fecemi']}\n";
        echo "     Total Req: $" . number_format($row['total_req'], 2) . "\n";
        echo "     Año: {$row['axo']}, Bimestres: {$row['bimini']}-{$row['bimfin']}\n";
        echo "     Impuesto: $" . number_format($row['impuesto'], 2) . "\n";
        echo "     Recargos: $" . number_format($row['recargos'], 2) . "\n\n";
    }

    // 4. Buscar tabla con nombres de contribuyentes
    echo "\n4. Buscando tablas con cvecuenta y nombre de propietario...\n\n";

    $stmt = $pdo->query("
        SELECT DISTINCT c.table_schema, c.table_name
        FROM information_schema.columns c
        WHERE c.table_schema IN ('public', 'publico')
        AND c.column_name = 'cvecuenta'
        AND EXISTS (
            SELECT 1 FROM information_schema.columns c2
            WHERE c2.table_schema = c.table_schema
            AND c2.table_name = c.table_name
            AND (c2.column_name ILIKE '%propietario%'
                 OR c2.column_name ILIKE '%nombre%'
                 OR c2.column_name ILIKE '%titular%')
        )
        ORDER BY c.table_schema, c.table_name
    ");

    $tablas_nombres = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($tablas_nombres) > 0) {
        foreach ($tablas_nombres as $tabla) {
            echo "   Tabla encontrada: {$tabla['table_schema']}.{$tabla['table_name']}\n";

            $count = $pdo->query("SELECT COUNT(*) as total FROM {$tabla['table_schema']}.{$tabla['table_name']}");
            $total = $count->fetch(PDO::FETCH_ASSOC);
            echo "     Registros: " . number_format($total['total']) . "\n";

            // Ver columnas
            $cols = $pdo->query("
                SELECT column_name
                FROM information_schema.columns
                WHERE table_schema = '{$tabla['table_schema']}'
                AND table_name = '{$tabla['table_name']}'
                AND (column_name ILIKE '%cuenta%'
                     OR column_name ILIKE '%propietario%'
                     OR column_name ILIKE '%nombre%'
                     OR column_name ILIKE '%titular%')
            ");

            $col_names = [];
            foreach ($cols->fetchAll(PDO::FETCH_ASSOC) as $col) {
                $col_names[] = $col['column_name'];
            }
            echo "     Columnas: " . implode(', ', $col_names) . "\n\n";
        }
    } else {
        echo "   No se encontraron tablas con cvecuenta + nombre\n\n";
    }

    echo "✅ Verificación completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
