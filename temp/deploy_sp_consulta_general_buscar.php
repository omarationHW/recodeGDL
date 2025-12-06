<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'mercados';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "✓ Conectado a base de datos mercados\n\n";

    // Leer y desplegar el archivo SQL
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/ConsultaGeneral_sp_consulta_general_buscar.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando sp_consulta_general_buscar...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Probar el SP
    echo "=== Probando SP ===\n";

    // Buscar un local válido para probar
    $stmt = $pdo->query("
        SELECT oficina, num_mercado, categoria, seccion, local, letra_local, bloque
        FROM publico.ta_11_locales
        WHERE vigencia = 'A'
        LIMIT 1
    ");
    $local = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$local) {
        echo "No se encontraron locales para probar\n";
        exit(0);
    }

    echo "Buscando local con:\n";
    echo "  Oficina: {$local['oficina']}\n";
    echo "  Mercado: {$local['num_mercado']}\n";
    echo "  Categoría: {$local['categoria']}\n";
    echo "  Sección: {$local['seccion']}\n";
    echo "  Local: {$local['local']}\n";
    echo "  Letra: {$local['letra_local']}\n";
    echo "  Bloque: {$local['bloque']}\n\n";

    try {
        $stmt2 = $pdo->prepare("SELECT * FROM sp_consulta_general_buscar(?, ?, ?, ?, ?, ?, ?)");
        $stmt2->execute([
            $local['oficina'],
            $local['num_mercado'],
            $local['categoria'],
            $local['seccion'],
            $local['local'],
            $local['letra_local'],
            $local['bloque']
        ]);
        $results = $stmt2->fetchAll(PDO::FETCH_ASSOC);

        if (count($results) > 0) {
            echo "✓ SP ejecutado correctamente\n";
            echo "  Registros encontrados: " . count($results) . "\n";

            foreach ($results as $i => $row) {
                echo "\n  Local #" . ($i + 1) . ":\n";
                echo "    ID Local: {$row['id_local']}\n";
                echo "    Ubicación: {$row['oficina']}-{$row['num_mercado']}-{$row['local']}{$row['letra_local']}\n";
                echo "    Nombre: {$row['nombre']}\n";
                echo "    Arrendatario: {$row['arrendatario']}\n";
                echo "    Domicilio: {$row['domicilio']}\n";
                echo "    Sector: {$row['sector']}\n";
                echo "    Zona: {$row['zona']}\n";
            }
        } else {
            echo "✓ SP ejecutado pero no retornó resultados\n";
        }
    } catch (PDOException $e) {
        echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
    }

    // Probar sin letra y bloque (parámetros opcionales)
    echo "\n\n=== Probando búsqueda sin letra y bloque ===\n";
    try {
        $stmt3 = $pdo->prepare("SELECT * FROM sp_consulta_general_buscar(?, ?, ?, ?, ?, NULL, NULL)");
        $stmt3->execute([
            $local['oficina'],
            $local['num_mercado'],
            $local['categoria'],
            $local['seccion'],
            $local['local']
        ]);
        $results2 = $stmt3->fetchAll(PDO::FETCH_ASSOC);

        echo "Registros encontrados sin filtrar letra/bloque: " . count($results2) . "\n";
    } catch (PDOException $e) {
        echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
    }

    echo "\n✅ SP desplegado correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
