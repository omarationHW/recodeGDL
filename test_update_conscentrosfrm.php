<?php
// Script para probar el stored procedure recaudadora_conscentrosfrm actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_conscentrosfrm...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_conscentrosfrm.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar con query vacío (todos los centros)
    echo "2. Probando con query vacío (todos los centros)...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_conscentrosfrm('')");
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Resultados: " . count($rows) . " centros encontrados\n";

    if (count($rows) > 0) {
        echo "\n   Primeros 5 centros:\n";
        foreach (array_slice($rows, 0, 5) as $i => $r) {
            echo "   ---\n";
            echo "   Centro " . ($i + 1) . ":\n";
            echo "     ID: " . $r["id_centro"] . "\n";
            echo "     Clave: " . $r["clave"] . "\n";
            echo "     Nombre: " . $r["nombre"] . "\n";
            echo "     Tipo: " . $r["tipo"] . "\n";
            echo "     Estado: " . $r["estado"] . "\n";
            echo "     Fecha Alta: " . $r["fecha_alta"] . "\n";
        }
    }

    // 3. Probar búsqueda por nombre
    echo "\n\n3. Probando búsqueda por 'ECOLOGIA'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_conscentrosfrm(?)");
    $stmt->execute(['ECOLOGIA']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " centros encontrados\n";

    if (count($rows) > 0) {
        echo "\n   Resultados:\n";
        foreach ($rows as $r) {
            echo "     - ID: {$r['id_centro']}, Nombre: {$r['nombre']}, Tipo: {$r['tipo']}\n";
        }
    }

    // 4. Probar búsqueda por tipo
    echo "\n\n4. Probando búsqueda por tipo 'Municipal'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_conscentrosfrm(?)");
    $stmt->execute(['Municipal']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " centros encontrados\n";

    if (count($rows) > 0) {
        echo "\n   Primeros 5 resultados:\n";
        foreach (array_slice($rows, 0, 5) as $r) {
            echo "     - {$r['nombre']} (Tipo: {$r['tipo']})\n";
        }
    }

    // 5. Probar búsqueda por ID
    echo "\n\n5. Probando búsqueda por ID '7'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_conscentrosfrm(?)");
    $stmt->execute(['7']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " centros encontrados\n";

    if (count($rows) > 0) {
        $r = $rows[0];
        echo "\n   Resultado:\n";
        echo "     ID: {$r['id_centro']}\n";
        echo "     Clave: {$r['clave']}\n";
        echo "     Nombre: {$r['nombre']}\n";
        echo "     Tipo: {$r['tipo']}\n";
        echo "     Estado: {$r['estado']}\n";
    }

    // 6. Probar búsqueda sin resultados
    echo "\n\n6. Probando búsqueda sin resultados...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_conscentrosfrm(?)");
    $stmt->execute(['ZZZZZ']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " centros encontrados\n";

    echo "\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
