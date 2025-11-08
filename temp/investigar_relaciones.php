<?php
$host = '192.168.6.146';
$database = 'padron_licencias';
$username = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;dbname=$database";
    $pdo = new PDO($dsn, $username, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== INVESTIGACIÓN DE RELACIONES ===\n\n";

    // 1. Ver estructura de c_giros
    echo "1. Estructura de comun.c_giros:\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_schema = 'comun' AND table_name = 'c_giros'
        ORDER BY ordinal_position
        LIMIT 20
    ");
    $cols = $stmt->fetchAll();
    foreach ($cols as $col) {
        echo "   {$col['column_name']} ({$col['data_type']})\n";
    }

    // 2. Sample de c_giros
    echo "\n2. Sample de c_giros (primeros 5):\n";
    $stmt = $pdo->query("SELECT * FROM comun.c_giros LIMIT 5");
    $samples = $stmt->fetchAll();
    if (count($samples) > 0) {
        $firstRow = $samples[0];
        echo "   Columnas disponibles: " . implode(', ', array_keys($firstRow)) . "\n\n";
        foreach ($samples as $idx => $row) {
            echo "   Giro " . ($idx+1) . ": ";
            // Mostrar solo las primeras columnas relevantes
            $display = [];
            $count = 0;
            foreach ($row as $key => $val) {
                if (!is_numeric($key) && $count < 3) {
                    $display[] = "$key=" . (is_string($val) ? trim($val) : $val);
                    $count++;
                }
            }
            echo implode(', ', $display) . "\n";
        }
    }

    // 3. Verificar relación licencias.cvecuenta
    echo "\n3. Explorando licencias.cvecuenta:\n";
    $stmt = $pdo->query("
        SELECT COUNT(*) as total,
               COUNT(DISTINCT cvecuenta) as distintas_cuentas,
               COUNT(DISTINCT id_giro) as distintos_giros
        FROM comun.licencias
        WHERE cvecuenta IS NOT NULL
    ");
    $stats = $stmt->fetch();
    echo "   Licencias con cvecuenta: " . number_format($stats['total']) . "\n";
    echo "   Cuentas distintas: " . number_format($stats['distintas_cuentas']) . "\n";
    echo "   Giros distintos: " . number_format($stats['distintos_giros']) . "\n";

    // 4. Ver si cve cuenta relaciona con adeudos.cuentas
    echo "\n4. Verificando relación adeudos.cuentas:\n";
    $stmt = $pdo->query("
        SELECT COUNT(*) as total,
               SUM(total) as suma_total
        FROM comun.adeudos
        WHERE total > 0
        LIMIT 1
    ");
    $adeudo_stats = $stmt->fetch();
    echo "   Registros de adeudos con total > 0: " . number_format($adeudo_stats['total']) . "\n";

    // 5. Intentar hacer un JOIN de prueba
    echo "\n5. Probando JOIN licencias-adeudos-giros:\n";
    $stmt = $pdo->query("
        SELECT
            g.id_giro,
            g.descripcion as giro_nombre,
            COUNT(DISTINCT l.licencia) as total_licencias,
            COUNT(DISTINCT CASE WHEN a.total > 0 THEN l.licencia END) as lic_con_adeudo,
            SUM(CASE WHEN a.total > 0 THEN a.total ELSE 0 END) as monto_adeudo
        FROM comun.licencias l
        LEFT JOIN comun.c_giros g ON l.id_giro = g.id_giro
        LEFT JOIN comun.adeudos a ON l.cvecuenta = a.cuentas
        WHERE g.id_giro IS NOT NULL
        GROUP BY g.id_giro, g.descripcion
        ORDER BY monto_adeudo DESC
        LIMIT 5
    ");
    $results = $stmt->fetchAll();

    if (count($results) > 0) {
        echo "   ✓ JOIN EXITOSO! Primeros 5 giros con adeudo:\n\n";
        foreach ($results as $idx => $row) {
            echo "   " . ($idx+1) . ". {$row['giro_nombre']}\n";
            echo "      Total Licencias: {$row['total_licencias']}\n";
            echo "      Con Adeudo: {$row['lic_con_adeudo']}\n";
            echo "      Monto: $" . number_format($row['monto_adeudo'], 2) . "\n\n";
        }

        echo "   ✅ MODELO IDENTIFICADO:\n";
        echo "   licencias.cvecuenta -> adeudos.cuentas\n";
        echo "   licencias.id_giro -> c_giros.id_giro\n";
    }

} catch (PDOException $e) {
    echo "\nError: " . $e->getMessage() . "\n";
}
