<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "=== BUSCANDO TABLAS DE DESCUENTOS EN MULTAS ===\n\n";

    // Buscar tablas con "desc" en el nombre solo en comun
    $sql = "
        SELECT
            schemaname,
            tablename,
            pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
        FROM pg_tables
        WHERE schemaname = 'comun'
        AND (tablename LIKE '%desc%' OR tablename LIKE '%multa%')
        ORDER BY tablename
    ";

    $stmt = $pdo->query($sql);
    $tables = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "TABLAS ENCONTRADAS:\n";
    echo "===================\n";
    foreach ($tables as $t) {
        echo "{$t['schemaname']}.{$t['tablename']} - {$t['size']}\n";
    }

    // Revisar la tabla descmultas (descuentos en multas)
    echo "\n\n=== EXPLORANDO comun.descmultas ===\n\n";

    $sqlDescMultas = "
        SELECT
            column_name,
            data_type,
            is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'descmultas'
        ORDER BY ordinal_position
    ";

    $stmt = $pdo->query($sqlDescMultas);
    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "Columnas de comun.descmultas:\n";
    foreach ($cols as $col) {
        echo "  - {$col['column_name']} ({$col['data_type']}) {$col['is_nullable']}\n";
    }

    // Contar registros
    $countSql = "SELECT COUNT(*) as total FROM comun.descmultas";
    $stmt = $pdo->query($countSql);
    $count = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "\nTotal de registros: {$count['total']}\n";

    // Obtener ejemplos de descuentos con cuenta y año
    echo "\n\n=== EJEMPLOS DE DESCUENTOS CON CUENTA Y AÑO ===\n\n";

    $sqlExamples = "
        SELECT
            d.*,
            m.contribuyente,
            m.num_acta as folio,
            m.total as total_multa
        FROM comun.descmultas d
        LEFT JOIN comun.multas m ON d.id_multa = m.id_multa
        WHERE d.cvepago IS NOT NULL AND d.cvepago != ''
        AND d.ejercicio IS NOT NULL
        LIMIT 10
    ";

    $stmt = $pdo->query($sqlExamples);
    $examples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($examples as $i => $ex) {
        $num = $i + 1;
        echo "EJEMPLO $num:\n";
        echo "  Cuenta: {$ex['cvepago']}\n";
        echo "  Ejercicio: {$ex['ejercicio']}\n";
        echo "  ID Multa: {$ex['id_multa']}\n";
        echo "  Contribuyente: {$ex['contribuyente']}\n";
        echo "  Folio: {$ex['folio']}\n";
        echo "  Total Multa: \${$ex['total_multa']}\n";
        echo "  Importe Desc: \${$ex['importe']}\n";
        echo "  Porcentaje: {$ex['porcentaje']}%\n";
        echo "  Autorizado: {$ex['autorizado']}\n";
        echo "\n";
    }

    // Buscar cuentas con múltiples descuentos
    echo "\n=== CUENTAS CON MÚLTIPLES DESCUENTOS ===\n\n";

    $sqlMultiple = "
        SELECT
            cvepago,
            ejercicio,
            COUNT(*) as total_descuentos,
            SUM(importe) as suma_descuentos
        FROM comun.descmultas
        WHERE cvepago IS NOT NULL AND cvepago != ''
        GROUP BY cvepago, ejercicio
        HAVING COUNT(*) > 1
        ORDER BY COUNT(*) DESC
        LIMIT 5
    ";

    $stmt = $pdo->query($sqlMultiple);
    $multiple = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($multiple as $m) {
        echo "Cuenta: {$m['cvepago']}, Año: {$m['ejercicio']}\n";
        echo "  Total descuentos: {$m['total_descuentos']}\n";
        echo "  Suma: \${$m['suma_descuentos']}\n\n";
    }

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
    exit(1);
}
