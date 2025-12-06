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

    echo "Buscando registro insertado con folio 9000, mercado 214...\n\n";

    $stmt = $pdo->query("
        SELECT id_local, oficina, num_mercado, categoria, seccion, local, nombre, domicilio, superficie, vigencia, clave_cuota
        FROM comun.ta_11_locales
        WHERE oficina = 1
        AND num_mercado = 214
        AND local = 9000
        ORDER BY id_local DESC
    ");

    $registros = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($registros) > 0) {
        echo "Registros encontrados: " . count($registros) . "\n\n";
        foreach ($registros as $reg) {
            echo "ID: {$reg['id_local']}\n";
            echo "  Oficina: {$reg['oficina']}\n";
            echo "  Mercado: {$reg['num_mercado']}\n";
            echo "  Categoría: {$reg['categoria']}\n";
            echo "  Sección: {$reg['seccion']}\n";
            echo "  Local/Folio: {$reg['local']}\n";
            echo "  Nombre: {$reg['nombre']}\n";
            echo "  Domicilio: {$reg['domicilio']}\n";
            echo "  Superficie: {$reg['superficie']}\n";
            echo "  Vigencia: {$reg['vigencia']}\n";
            echo "  Clave Cuota: {$reg['clave_cuota']}\n\n";
        }
    } else {
        echo "✗ No se encontró ningún registro con folio 9000 en mercado 214\n";
    }

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
    exit(1);
}
