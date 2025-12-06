<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "📡 Conectado a mercados @ 192.168.6.146\n\n";

    $sqlFile = __DIR__ . '/sp_get_pagos_loc_grl_FINAL.sql';
    $sql = file_get_contents($sqlFile);

    echo "📦 Desplegando sp_get_pagos_loc_grl FINAL...\n\n";

    $pdo->exec($sql);

    echo "✅ SP desplegado exitosamente\n\n";

    // Verificar
    $check = $pdo->query("SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'public' AND routine_name = 'sp_get_pagos_loc_grl'")->fetch();

    if ($check) {
        echo "✅ Verificación: SP existe\n\n";

        // Probar
        echo "🧪 Probando SP con mercado=1, año 2024...\n";
        $stmt = $pdo->prepare("SELECT * FROM sp_get_pagos_loc_grl(?, ?, ?)");
        $stmt->execute([1, '2024-01-01', '2024-12-31']);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "✅ Registros: " . count($rows) . "\n";

        if (count($rows) > 0) {
            echo "\n📊 Primer registro:\n";
            $r = $rows[0];
            echo "   Mercado: {$r['num_mercado']} | Secc: {$r['seccion']} | Local: {$r['local']}\n";
            echo "   Importe: \${$r['importe_pago']} | Fecha: {$r['fecha_pago']}\n";
        } else {
            echo "\n⚠️  No hay datos de prueba para mercado=1 en 2024\n";
        }
        echo "\n✅ SP FUNCIONANDO CORRECTAMENTE\n";
    } else {
        echo "❌ ERROR: SP no encontrado\n";
    }

} catch (PDOException $e) {
    echo "❌ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
