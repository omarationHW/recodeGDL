<?php
// Script para probar el stored procedure recaudadora_descderechos_merc actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_descderechos_merc...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_descderechos_merc.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Buscar locales de ejemplo
    echo "2. Buscando descuentos de ejemplo...\n";
    $stmt = $pdo->query("
        SELECT DISTINCT id_local, axoini, porcentaje, estado
        FROM public.ta_11_descderechos
        WHERE id_local IS NOT NULL
        ORDER BY axoini DESC
        LIMIT 5
    ");
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "   Descuentos encontrados:\n";
    foreach ($ejemplos as $ej) {
        echo "     - Local: {$ej['id_local']}, Año: {$ej['axoini']}, Descuento: {$ej['porcentaje']}%, Estado: {$ej['estado']}\n";
    }

    if (count($ejemplos) > 0) {
        $localEjemplo = $ejemplos[0]['id_local'];
        $axoEjemplo = $ejemplos[0]['axoini'];

        // 3. Probar sin filtros (listar todos)
        echo "\n\n3. Probando sin filtros (primeros 10 descuentos)...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_descderechos_merc('', 0) LIMIT 10");
        $stmt->execute();
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " descuento(s) encontrado(s)\n";

        if (count($rows) > 0) {
            echo "\n   Primeros 3 descuentos:\n";
            foreach (array_slice($rows, 0, 3) as $i => $r) {
                echo "   " . ($i + 1) . ". Local: {$r['clave_cuenta']}, Descuento: {$r['descuento']}%, ";
                echo "Periodo: {$r['desde']} a {$r['hasta']}, Estatus: {$r['estatus']}\n";
            }
        }

        // 4. Probar con local específico
        echo "\n\n4. Probando con local específico '$localEjemplo'...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_descderechos_merc(?, 0)");
        $stmt->execute([$localEjemplo]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " descuento(s) encontrado(s)\n";

        if (count($rows) > 0) {
            echo "\n   Descuentos del local $localEjemplo:\n";
            foreach ($rows as $i => $r) {
                echo "\n   " . ($i + 1) . ". Descuento ID: {$r['id']}\n";
                echo "      Porcentaje: {$r['descuento']}%\n";
                echo "      Periodo: {$r['desde']} hasta {$r['hasta']}\n";
                echo "      Estatus: {$r['estatus']}\n";
                echo "      Ejercicio: {$r['ejercicio']}\n";
                echo "      Observaciones: " . substr($r['observaciones'], 0, 80) . "\n";
                echo "      Fecha Registro: {$r['fecha_registro']}\n";
            }
        }

        // 5. Probar con filtro por ejercicio
        echo "\n\n5. Probando con filtro por ejercicio '$axoEjemplo'...\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_descderechos_merc('', ?)");
        $stmt->execute([$axoEjemplo]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

        echo "   Resultados: " . count($rows) . " descuento(s) del ejercicio $axoEjemplo\n";

        if (count($rows) > 0) {
            echo "   Primeros 3 descuentos de $axoEjemplo:\n";
            foreach (array_slice($rows, 0, 3) as $i => $r) {
                echo "   " . ($i + 1) . ". Local: {$r['clave_cuenta']}, Descuento: {$r['descuento']}%, Estatus: {$r['estatus']}\n";
            }
        }

        // 6. Probar con local y ejercicio específicos
        if (count($ejemplos) > 1) {
            $localEjemplo2 = $ejemplos[1]['id_local'];
            $axoEjemplo2 = $ejemplos[1]['axoini'];

            echo "\n\n6. Probando con local '$localEjemplo2' y ejercicio '$axoEjemplo2'...\n";
            $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_descderechos_merc(?, ?)");
            $stmt->execute([$localEjemplo2, $axoEjemplo2]);
            $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

            echo "   Resultados: " . count($rows) . " descuento(s) encontrado(s)\n";
            if (count($rows) > 0) {
                $r = $rows[0];
                echo "   - Descuento: {$r['descuento']}%, Periodo: {$r['desde']} a {$r['hasta']}\n";
            }
        }

        // 7. Contar total de descuentos
        echo "\n\n7. Contando total de descuentos...\n";
        $stmt = $pdo->query("SELECT COUNT(*) as total FROM publico.recaudadora_descderechos_merc('', 0)");
        $total = $stmt->fetch(PDO::FETCH_ASSOC);
        echo "   Total de descuentos en el sistema: " . number_format($total['total']) . "\n";
    }

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
