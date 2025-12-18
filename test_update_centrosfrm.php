<?php
// Script para probar el stored procedure recaudadora_centrosfrm actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_centrosfrm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_centrosfrm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar con query vacío (todos los centros)
    echo "2. Probando con query vacío (todos los centros activos)...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_centrosfrm('')");
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Resultados: " . count($rows) . " centros encontrados\n";

    if (count($rows) > 0) {
        echo "\n   Primeros 5 centros:\n";
        foreach (array_slice($rows, 0, 5) as $i => $r) {
            echo "   ---\n";
            echo "   Centro " . ($i + 1) . ":\n";
            echo "     ID: " . $r["id_centro"] . "\n";
            echo "     Clave: " . $r["clave_centro"] . "\n";
            echo "     Nombre: " . $r["nombre_centro"] . "\n";
            echo "     Tipo: " . $r["tipo_centro"] . "\n";
            echo "     Status: " . $r["status"] . "\n";
        }
    }

    // 3. Probar búsqueda por nombre
    echo "\n\n3. Probando búsqueda por 'ECOLOGIA'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_centrosfrm(?)");
    $stmt->execute(['ECOLOGIA']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " centros encontrados\n";

    if (count($rows) > 0) {
        $r = $rows[0];
        echo "\n   Primer resultado:\n";
        echo "     ID: " . $r["id_centro"] . "\n";
        echo "     Nombre: " . $r["nombre_centro"] . "\n";
        echo "     Tipo: " . $r["tipo_centro"] . "\n";
    }

    // 4. Probar búsqueda por abreviatura
    echo "\n\n4. Probando búsqueda por abreviatura 'R'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_centrosfrm(?)");
    $stmt->execute(['R']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " centros encontrados\n";

    if (count($rows) > 0) {
        foreach ($rows as $r) {
            echo "     - {$r['clave_centro']}: {$r['nombre_centro']}\n";
        }
    }

    // 5. Probar búsqueda sin resultados
    echo "\n\n5. Probando búsqueda sin resultados...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_centrosfrm(?)");
    $stmt->execute(['ZZZZZ']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " centros encontrados\n";

    echo "\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
