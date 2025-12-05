<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLEGANDO SP ULTRA OPTIMIZADO ===\n\n";

    $sql = file_get_contents(__DIR__ . '/recaudadora_propuestatab_ultra.sql');
    $pdo->exec($sql);

    echo "✓ SP ultra optimizado creado\n\n";

    echo "=== PROBANDO VELOCIDAD ===\n\n";

    $ejemplos = [
        ['filtro' => '', 'descripcion' => 'Sin filtro (últimos 2 años)'],
        ['filtro' => '260676', 'descripcion' => 'Cuenta 260676'],
        ['filtro' => '7530946', 'descripcion' => 'Folio 7530946'],
        ['filtro' => 'ODOO', 'descripcion' => 'Cajero ODOO']
    ];

    foreach ($ejemplos as $idx => $ejemplo) {
        echo "PRUEBA " . ($idx + 1) . ": {$ejemplo['descripcion']}\n";

        $start = microtime(true);
        $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_propuestatab(:filtro)");
        $stmt->execute(['filtro' => $ejemplo['filtro']]);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        $end = microtime(true);

        $tiempo = round(($end - $start) * 1000, 2);

        echo "⏱️  Tiempo: {$tiempo}ms\n";
        echo "📊 Registros: " . count($results) . "\n";

        if (!empty($results)) {
            $r = $results[0];
            echo "📌 Primer resultado: Pago#{$r['cvepago']} - Cuenta:{$r['cvecuenta']} - Folio:{$r['folio']} - Fecha:{$r['fecha']}\n";
        }

        echo "\n";
    }

} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
