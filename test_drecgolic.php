<?php
// Script para probar el stored procedure recaudadora_drecgolic actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_drecgolic...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_drecgolic.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Buscar licencias de ejemplo
    echo "2. Buscando licencias de ejemplo...\n";
    $stmt = $pdo->query("
        SELECT id_licencia, licencia, propietario, rfc, id_giro
        FROM publico.licencias
        WHERE id_licencia IS NOT NULL
        ORDER BY id_licencia DESC
        LIMIT 5
    ");
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Licencias encontradas:\n";
    foreach ($ejemplos as $ej) {
        $nombre = substr($ej['propietario'], 0, 30);
        echo "     - ID: {$ej['id_licencia']}, Licencia: {$ej['licencia']}, ";
        echo "Propietario: $nombre, RFC: {$ej['rfc']}\n";
    }

    if (count($ejemplos) > 0) {
        $licenciaEjemplo = $ejemplos[0]['id_licencia'];

        // 3. Probar sin filtro (listar todas)
        echo "\n\n3. Probando sin filtro (primeras 10 licencias)...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_drecgolic('') LIMIT 10");
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " licencia(s) encontrada(s)\n";

        if (count($rows) > 0) {
            echo "\n   Primeras 3 licencias:\n";
            foreach (array_slice($rows, 0, 3) as $i => $r) {
                echo "   " . ($i + 1) . ". ID: {$r['id_licencia']}, Licencia: {$r['licencia']}, ";
                echo "Propietario: " . substr($r['propietario'], 0, 30) . "\n";
            }
        }

        // 4. Probar con ID específico
        echo "\n\n4. Probando con ID específico '$licenciaEjemplo'...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_drecgolic(?)");
        $stmt->execute([$licenciaEjemplo]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " licencia(s) encontrada(s)\n";

        if (count($rows) > 0) {
            echo "\n   Detalles de la licencia:\n";
            $r = $rows[0];
            echo "      ID Licencia: {$r['id_licencia']}\n";
            echo "      Licencia: {$r['licencia']}\n";
            echo "      Propietario: {$r['propietario']}\n";
            echo "      RFC: {$r['rfc']}\n";
            echo "      Domicilio: {$r['domicilio']}\n";
            echo "      ID Giro: {$r['id_giro']}\n";
            echo "      Zona: {$r['zona']}, Subzona: {$r['subzona']}\n";
            echo "      Cuenta: {$r['cvecuenta']}\n";
            echo "      Fecha Otorgamiento: {$r['fecha_otorgamiento']}\n";
            echo "      Coordenadas: {$r['coordenadas']}\n";
        }

        // 5. Buscar por nombre
        echo "\n\n5. Buscando por nombre 'GARCIA'...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_drecgolic('GARCIA') LIMIT 5");
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " licencia(s) con 'GARCIA'\n";
        if (count($rows) > 0) {
            foreach ($rows as $i => $r) {
                echo "   " . ($i + 1) . ". ID: {$r['id_licencia']}, Propietario: " . substr($r['propietario'], 0, 40) . "\n";
            }
        }

        // 6. Buscar por RFC
        $stmt = $pdo->query("
            SELECT rfc FROM publico.licencias
            WHERE rfc IS NOT NULL AND TRIM(rfc) != ''
            LIMIT 1
        ");
        $rfcTest = $stmt->fetchColumn();

        if ($rfcTest) {
            echo "\n\n6. Buscando por RFC '$rfcTest'...\n";
            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_drecgolic(?)");
            $stmt->execute([$rfcTest]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "   Resultados: " . count($rows) . " licencia(s) con este RFC\n";
            if (count($rows) > 0) {
                $r = $rows[0];
                echo "   - Propietario: {$r['propietario']}, Licencia: {$r['licencia']}\n";
            }
        }

        // 7. Estadísticas
        echo "\n\n7. Estadísticas generales...\n";
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM publico.licencias");
        $total = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "   Total de licencias en el sistema: " . number_format($total['total']) . "\n";

        // Ver distribución por zona
        $stmt = $pdo->query("
            SELECT zona, COUNT(*) as cantidad
            FROM publico.licencias
            WHERE zona IS NOT NULL
            GROUP BY zona
            ORDER BY cantidad DESC
            LIMIT 5
        ");
        $zonas = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Distribución por zonas (top 5):\n";
        foreach ($zonas as $z) {
            echo "     - Zona {$z['zona']}: " . number_format($z['cantidad']) . " licencias\n";
        }
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
