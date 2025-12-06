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
    $sqlFile = __DIR__ . '/../RefactorX/Base/mercados/database/database/DatosIndividuales_sp_get_requerimientos_local.sql';
    $sql = file_get_contents($sqlFile);

    echo "Desplegando sp_get_requerimientos_local...\n";
    $pdo->exec($sql);
    echo "✓ SP desplegado exitosamente\n\n";

    // Probar el SP con un id_local válido
    echo "=== Probando SP ===\n";

    // Buscar un id_local que tenga requerimientos
    $stmt = $pdo->query("
        SELECT DISTINCT control_otr
        FROM publico.ta_15_apremios
        WHERE vigencia = '1' AND clave_practicado = 'P'
        LIMIT 1
    ");
    $local = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($local) {
        $id_local = $local['control_otr'];
        echo "Probando con id_local: {$id_local}\n";

        try {
            $stmt2 = $pdo->prepare("SELECT * FROM sp_get_requerimientos_local(?)");
            $stmt2->execute([$id_local]);
            $results = $stmt2->fetchAll(PDO::FETCH_ASSOC);

            if (count($results) > 0) {
                echo "✓ SP ejecutado correctamente\n";
                echo "  Requerimientos encontrados: " . count($results) . "\n";
                foreach ($results as $i => $req) {
                    echo "\n  Requerimiento #" . ($i + 1) . ":\n";
                    echo "    ID Control: {$req['id_control']}\n";
                    echo "    Módulo: {$req['modulo']}\n";
                    echo "    Control OTR: {$req['control_otr']}\n";
                    echo "    Folio: {$req['folio']}\n";
                    echo "    Diligencia: {$req['diligencia']}\n";
                    echo "    Importe Global: \${$req['importe_global']}\n";
                    echo "    Importe Multa: \${$req['importe_multa']}\n";
                    echo "    Importe Recargo: \${$req['importe_recargo']}\n";
                    echo "    Importe Gastos: \${$req['importe_gastos']}\n";
                    echo "    Fecha Emisión: {$req['fecha_emision']}\n";
                    echo "    Clave Practicado: {$req['clave_practicado']}\n";
                    echo "    Vigencia: {$req['vigencia']}\n";
                }
            } else {
                echo "✓ SP ejecutado pero no retornó resultados (el local no tiene requerimientos)\n";
            }
        } catch (PDOException $e) {
            echo "✗ Error al ejecutar: " . $e->getMessage() . "\n";
        }
    } else {
        echo "No hay requerimientos en la tabla para probar\n";
    }

    echo "\n✅ SP desplegado correctamente\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
