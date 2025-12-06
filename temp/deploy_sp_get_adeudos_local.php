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
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/DatosIndividuales_sp_get_adeudos_local.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando sp_get_adeudos_local...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Probar el SP con un id_local válido
    echo "=== Probando SP ===\n";

    // Obtener un id_local válido que tenga adeudos
    $stmt = $pdo->query("SELECT DISTINCT id_local FROM publico.ta_11_adeudo_local LIMIT 1");
    $local = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($local) {
        $id_local = $local['id_local'];
        echo "Probando con id_local: {$id_local}\n";

        try {
            $stmt2 = $pdo->prepare("SELECT * FROM sp_get_adeudos_local(?)");
            $stmt2->execute([$id_local]);
            $results = $stmt2->fetchAll(PDO::FETCH_ASSOC);

            if (count($results) > 0) {
                echo "✓ SP ejecutado correctamente\n";
                echo "  Adeudos encontrados: " . count($results) . "\n";
                foreach ($results as $i => $adeudo) {
                    echo "\n  Adeudo #" . ($i + 1) . ":\n";
                    echo "    ID Local: {$adeudo['id_local']}\n";
                    echo "    Año: {$adeudo['axo']}\n";
                    echo "    Período: {$adeudo['periodo']}\n";
                    echo "    Importe: \${$adeudo['importe']}\n";
                    echo "    Recargos: \${$adeudo['recargos']}\n";
                }
            } else {
                echo "✓ SP ejecutado pero no retornó resultados (el local no tiene adeudos)\n";
            }
        } catch (PDOException $e) {
            echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
        }
    } else {
        echo "No hay adeudos en la tabla para probar\n";
    }

    echo "\n✅ SP desplegado correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
