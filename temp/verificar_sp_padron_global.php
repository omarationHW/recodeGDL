<?php
$host = "192.168.6.146";
$port = "5432";
$dbname = "mercados";
$user = "refact";
$password = "FF)-BQk2";

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "\n=== VERIFICANDO sp_padron_global ===\n\n";

    // 1. Verificar si existe
    $sql = "SELECT proname, pg_get_function_arguments(oid) as args FROM pg_proc WHERE proname = 'sp_padron_global'";
    $stmt = $pdo->query($sql);
    $sp = $stmt->fetch();

    if ($sp) {
        echo "✅ SP existe: {$sp['proname']}({$sp['args']})\n\n";
    } else {
        echo "❌ SP NO EXISTE\n\n";
        exit(1);
    }

    // 2. Probar con datos actuales
    $axo = date('Y');
    $mes = date('n');
    $vig = 'A';

    echo "Probando con: axo=$axo, mes=$mes, vig=$vig\n";
    echo str_repeat("-", 80) . "\n";

    $sql = "SELECT * FROM sp_padron_global(?, ?, ?) LIMIT 10";
    $stmt = $pdo->prepare($sql);
    $stmt->execute([$axo, $mes, $vig]);
    $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($result) > 0) {
        echo "✅ SP retorna datos: " . count($result) . " registros\n\n";
        echo "Primeros 3 registros:\n";
        foreach (array_slice($result, 0, 3) as $row) {
            echo "  - Local {$row['local']}: {$row['nombre']}\n";
        }
        echo "\n";
    } else {
        echo "⚠️  SP no retorna datos con estos parámetros\n\n";
    }

    echo "✅ VERIFICACIÓN COMPLETADA\n\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
