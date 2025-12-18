<?php
// Script para probar el stored procedure recaudadora_listchq actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_listchq...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_listchq.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar sin parámetros (todo el histórico)
    echo "2. Probando sin parámetros (todo el histórico)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listchq(?::TEXT)");
    $stmt->execute(['']);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Pagos con cheque encontrados: " . count($results) . "\n\n";

    if (count($results) > 0) {
        echo "   === PRIMEROS 5 PAGOS CON CHEQUE ===\n";
        for ($i = 0; $i < min(5, count($results)); $i++) {
            $pago = $results[$i];
            echo "\n   PAGO " . ($i + 1) . ":\n";
            echo "   Fecha: {$pago['fecha']}\n";
            echo "   Banco: {$pago['banco']}\n";
            echo "   Cheque: {$pago['cheque']}\n";
            echo "   Cuenta: {$pago['cuenta']}\n";
            echo "   Importe: $" . number_format($pago['importe'], 2) . "\n";
            echo "   Tipo Pago: {$pago['tipo_pag']}\n";
            echo "   Folio: {$pago['folio_completo']}\n";
            echo "   Recaudadora: {$pago['id_rec']}\n";
            echo "   Caja: {$pago['caja']}\n";
            echo "   Operación: {$pago['operacion']}\n";
        }
    }

    // 3. Contar total de pagos con cheque
    echo "\n\n3. Estadísticas generales...\n";

    $stmt_total = $pdo->query("
        SELECT COUNT(*) as total
        FROM publico.pagos p
        INNER JOIN public.cheqpag c ON p.cvepago = c.cvepago
        WHERE p.cvecanc IS NULL
    ");
    $total = $stmt_total->fetch(PDO::FETCH_ASSOC);
    echo "   Total de pagos con cheque (no cancelados): " . number_format($total['total']) . "\n";

    // 6. Ver distribución por banco
    echo "\n   Distribución por banco:\n";
    $stmt_bancos = $pdo->query("
        SELECT
            c.cvebanco,
            CASE
                WHEN c.cvebanco = 1 THEN 'BANAMEX'
                WHEN c.cvebanco = 2 THEN 'BANCOMER'
                WHEN c.cvebanco = 3 THEN 'SANTANDER'
                WHEN c.cvebanco = 4 THEN 'HSBC'
                WHEN c.cvebanco = 5 THEN 'BANORTE'
                WHEN c.cvebanco = 6 THEN 'SCOTIABANK'
                WHEN c.cvebanco = 7 THEN 'INBURSA'
                ELSE 'BANCO ' || c.cvebanco::TEXT
            END AS banco,
            COUNT(*) as total
        FROM public.cheqpag c
        GROUP BY c.cvebanco
        ORDER BY total DESC
        LIMIT 10
    ");
    $bancos = $stmt_bancos->fetchAll(PDO::FETCH_ASSOC);
    foreach ($bancos as $banco) {
        echo "   - {$banco['banco']}: " . number_format($banco['total']) . " cheques\n";
    }

    // 4. Probar con filtro de texto (búsqueda por número de cheque)
    echo "\n\n4. Probando con filtro de texto (búsqueda: '5908')...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listchq(?::TEXT)");
    $stmt->execute(['5908']);
    $results_filtro = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Pagos encontrados con '5908': " . count($results_filtro) . "\n";

    if (count($results_filtro) > 0) {
        $pago = $results_filtro[0];
        echo "\n   Ejemplo:\n";
        echo "   Fecha: {$pago['fecha']}\n";
        echo "   Banco: {$pago['banco']}\n";
        echo "   Cheque: {$pago['cheque']}\n";
        echo "   Cuenta: {$pago['cuenta']}\n";
        echo "   Importe: $" . number_format($pago['importe'], 2) . "\n";
    }

    // 5. Probar con filtro de banco
    echo "\n\n5. Probando con filtro de banco (búsqueda: 'SANTANDER')...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listchq(?::TEXT)");
    $stmt->execute(['SANTANDER']);
    $results_banco = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Pagos encontrados con 'SANTANDER': " . count($results_banco) . "\n";

    // 6. Probar sin filtro (texto vacío)
    echo "\n\n6. Probando sin filtro (texto vacío, debe traer primeros 100)...\n";

    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listchq(?::TEXT)");
    $stmt->execute(['']);
    $results_sin_filtro = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Pagos encontrados (sin filtro): " . count($results_sin_filtro) . "\n";

    // 7. Ver formato JSON
    echo "\n\n7. Formato JSON para el frontend (primeros 2 registros):\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listchq(?::TEXT) LIMIT 2");
    $stmt->execute(['']);
    $result_json = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($result_json, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
