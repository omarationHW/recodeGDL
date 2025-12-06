<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "Verificando estructura de ta_11_locales...\n\n";

    // Verificar secuencia para id_local
    $stmt = $pdo->query("
        SELECT column_default
        FROM information_schema.columns
        WHERE table_schema = 'comun'
        AND table_name = 'ta_11_locales'
        AND column_name = 'id_local'
    ");
    $default = $stmt->fetchColumn();

    echo "Default para id_local: $default\n\n";

    // Buscar registros con folio 9000 en mercado 214
    echo "Buscando registros con folio 9000 en mercado 214...\n";
    $stmt = $pdo->query("
        SELECT id_local, oficina, num_mercado, local, nombre
        FROM comun.ta_11_locales
        WHERE oficina = 1
        AND num_mercado = 214
        AND local = 9000
    ");

    $registros = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "Registros encontrados: " . count($registros) . "\n";
    foreach ($registros as $reg) {
        echo "  ID: {$reg['id_local']}, Local: {$reg['local']}, Nombre: {$reg['nombre']}\n";
    }

    // Ver último ID insertado
    echo "\nÚltimos 5 registros en la tabla:\n";
    $stmt = $pdo->query("
        SELECT id_local, oficina, num_mercado, local, nombre
        FROM comun.ta_11_locales
        ORDER BY id_local DESC
        LIMIT 5
    ");

    while ($reg = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  ID: {$reg['id_local']}, Ofi: {$reg['oficina']}, Mdo: {$reg['num_mercado']}, Local: {$reg['local']}, Nombre: " . substr($reg['nombre'], 0, 30) . "\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
