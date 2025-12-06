<?php
// Probar el SP sp_localesmodif_buscar_local

$dbConfig = [
    'host' => '192.168.6.146',
    'port' => '5432',
    'dbname' => 'mercados',
    'user' => 'refact',
    'password' => 'FF)-BQk2'
];

try {
    $dsn = "pgsql:host={$dbConfig['host']};port={$dbConfig['port']};dbname={$dbConfig['dbname']}";
    $pdo = new PDO($dsn, $dbConfig['user'], $dbConfig['password']);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conectado a la base de datos\n\n";

    // Primero verificar qué datos hay en la tabla
    echo "Verificando datos disponibles en ta_11_localpaso...\n";
    echo str_repeat('=', 80) . "\n";

    $stmt = $pdo->query("
        SELECT oficina, num_mercado, categoria, seccion, local, letra_local, bloque
        FROM public.ta_11_localpaso
        LIMIT 3
    ");

    $samples = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($samples) > 0) {
        echo "Datos de ejemplo:\n";
        foreach ($samples as $i => $row) {
            echo ($i + 1) . ". " . json_encode($row, JSON_UNESCAPED_UNICODE) . "\n";
        }

        // Probar el SP con el primer registro
        $sample = $samples[0];

        echo "\n\nProbando SP con primer registro...\n";
        echo str_repeat('=', 80) . "\n";

        $stmt = $pdo->prepare("
            SELECT * FROM sp_localesmodif_buscar_local(
                :oficina,
                :num_mercado,
                :categoria,
                :seccion,
                :local,
                :letra_local,
                :bloque
            )
        ");

        $stmt->execute([
            'oficina' => $sample['oficina'],
            'num_mercado' => $sample['num_mercado'],
            'categoria' => $sample['categoria'],
            'seccion' => $sample['seccion'],
            'local' => $sample['local'],
            'letra_local' => $sample['letra_local'],
            'bloque' => $sample['bloque']
        ]);

        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($result) {
            echo "✓ SP ejecutado correctamente\n";
            echo "Resultado:\n";
            echo json_encode($result, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT) . "\n";
        } else {
            echo "⚠ SP no encontró resultados\n";
        }

    } else {
        echo "⚠ No hay datos en la tabla ta_11_localpaso\n";
    }

} catch (Exception $e) {
    echo "✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
