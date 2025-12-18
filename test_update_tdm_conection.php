<?php
// Script para probar el stored procedure recaudadora_tdm_conection actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_tdm_conection...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_tdm_conection.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar con query vacío (todos los usuarios)
    echo "2. Probando con query vacío (primeros 10 usuarios)...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_tdm_conection('') LIMIT 10");
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Resultados: " . count($rows) . " usuarios\n";

    if (count($rows) > 0) {
        echo "\n   Primeros 5 usuarios:\n";
        foreach (array_slice($rows, 0, 5) as $i => $r) {
            echo "   ---\n";
            echo "   Usuario " . ($i + 1) . ":\n";
            echo "     ID: " . $r["id_usuario"] . "\n";
            echo "     Usuario: " . $r["usuario"] . "\n";
            echo "     Nombre: " . $r["nombre"] . "\n";
            echo "     Estado: " . $r["estado"] . " (" . ($r["estado"] == 'A' ? 'Activo' : 'Inactivo') . ")\n";
            echo "     Departamento: " . $r["id_rec"] . "\n";
            echo "     Nivel: " . $r["nivel"] . "\n";
            echo "     Clave: " . ($r["clave"] ?? 'NULL') . "\n";
        }
    }

    // 3. Probar búsqueda por nombre
    echo "\n\n3. Probando búsqueda por 'GARCIA'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_tdm_conection(?)");
    $stmt->execute(['GARCIA']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " usuarios encontrados\n";

    if (count($rows) > 0) {
        echo "\n   Primeros 3 resultados:\n";
        foreach (array_slice($rows, 0, 3) as $r) {
            echo "     - {$r['usuario']}: {$r['nombre']} (Estado: {$r['estado']})\n";
        }
    }

    // 4. Probar usuarios activos
    echo "\n\n4. Contando usuarios activos (estado='A')...\n";
    $stmt = $pdo->prepare("SELECT COUNT(*) as total FROM publico.recaudadora_tdm_conection('') WHERE estado = 'A'");
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Total de usuarios activos: {$result['total']}\n";

    // 5. Probar usuarios inactivos
    echo "\n5. Contando usuarios inactivos (estado='I')...\n";
    $stmt = $pdo->prepare("SELECT COUNT(*) as total FROM publico.recaudadora_tdm_conection('') WHERE estado = 'I'");
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Total de usuarios inactivos: {$result['total']}\n";

    // 6. Probar búsqueda por nivel
    echo "\n6. Probando búsqueda por nivel '9'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_tdm_conection('9') LIMIT 5");
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo "   Resultados: " . count($rows) . " usuarios con nivel 9\n";

    if (count($rows) > 0) {
        foreach ($rows as $r) {
            echo "     - {$r['usuario']}: {$r['nombre']} (Nivel: {$r['nivel']})\n";
        }
    }

    echo "\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
