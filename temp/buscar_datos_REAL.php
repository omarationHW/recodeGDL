<?php
$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

echo "========================================\n";
echo "BUSCANDO DATOS REALES PARA PRUEBAS\n";
echo "Host: $host | DB: $dbname\n";
echo "========================================\n\n";

try {
    echo "Conectando...\n";
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✓ Conexión exitosa\n\n";

    // BUSCAR REQUERIMIENTO VINCULADO A LOCAL
    echo "========================================\n";
    echo "BUSCANDO REQUERIMIENTO VINCULADO\n";
    echo "========================================\n\n";

    $stmt = $pdo->query("
        SELECT
            l.id_local,
            l.oficina,
            l.num_mercado,
            l.categoria,
            l.seccion,
            l.letra_local,
            l.bloque,
            l.nombre,
            a.modulo,
            a.folio,
            a.control_otr,
            a.diligencia,
            a.importe_global,
            a.fecha_emision
        FROM comun.ta_11_locales l
        INNER JOIN comun.ta_15_apremios a ON l.id_local = a.control_otr
        LIMIT 3
    ");

    $resultados = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($resultados) > 0) {
        echo "✓ DATOS ENCONTRADOS: " . count($resultados) . " registros\n\n";

        foreach ($resultados as $i => $r) {
            echo "========================================\n";
            echo "OPCIÓN " . ($i + 1) . " PARA PRUEBA\n";
            echo "========================================\n";
            echo "📋 VALORES PARA EL FORMULARIO:\n";
            echo "   ID Local: {$r['id_local']}\n";
            echo "   Módulo: {$r['modulo']}\n";
            echo "   Folio: {$r['folio']}\n\n";

            echo "📍 DATOS DEL LOCAL:\n";
            echo "   Nombre: {$r['nombre']}\n";
            echo "   Oficina: {$r['oficina']}, Mercado: {$r['num_mercado']}\n";
            echo "   Categoría: {$r['categoria']}, Sección: {$r['seccion']}\n\n";

            echo "📄 DATOS DEL REQUERIMIENTO:\n";
            echo "   Diligencia: {$r['diligencia']}\n";
            echo "   Importe: \${$r['importe_global']}\n";
            echo "   Fecha: {$r['fecha_emision']}\n\n";

            if ($i === 0) {
                echo "🎯 JSON PARA API:\n";
                echo json_encode([
                    'id_local' => $r['id_local'],
                    'modulo' => $r['modulo'],
                    'folio' => $r['folio']
                ], JSON_PRETTY_PRINT);
                echo "\n\n";
            }
        }

        // Usar el primero para probar los SPs
        $primero = $resultados[0];

        echo "========================================\n";
        echo "PROBANDO SPs CON DATOS REALES\n";
        echo "========================================\n\n";

        // Probar sp_get_locales
        echo "1. Probando sp_get_locales({$primero['id_local']})...\n";
        try {
            $stmt = $pdo->prepare("SELECT * FROM sp_get_locales(?)");
            $stmt->execute([$primero['id_local']]);
            $local = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($local) {
                echo "   ✓ SP funciona correctamente\n";
                echo "   Local: {$local['nombre']}\n";
            } else {
                echo "   ✗ No se encontró el local\n";
            }
        } catch (PDOException $e) {
            echo "   ✗ ERROR: " . $e->getMessage() . "\n";
        }

        // Probar sp_get_mercado
        echo "\n2. Probando sp_get_mercado({$primero['oficina']}, {$primero['num_mercado']})...\n";
        try {
            $stmt = $pdo->prepare("SELECT * FROM sp_get_mercado(?, ?)");
            $stmt->execute([$primero['oficina'], $primero['num_mercado']]);
            $mercado = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($mercado) {
                echo "   ✓ SP funciona correctamente\n";
                echo "   Mercado: {$mercado['descripcion']}\n";
            } else {
                echo "   ✗ No se encontró el mercado\n";
            }
        } catch (PDOException $e) {
            echo "   ✗ ERROR: " . $e->getMessage() . "\n";
        }

        // Probar sp_get_requerimientos
        echo "\n3. Probando sp_get_requerimientos({$primero['modulo']}, {$primero['folio']}, {$primero['control_otr']})...\n";
        try {
            $stmt = $pdo->prepare("SELECT * FROM sp_get_requerimientos(?, ?, ?)");
            $stmt->execute([$primero['modulo'], $primero['folio'], $primero['control_otr']]);
            $req = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($req) {
                echo "   ✓ SP funciona correctamente\n";
                echo "   Diligencia: {$req['diligencia']}\n";
                echo "   Importe: \${$req['importe_global']}\n";
            } else {
                echo "   ✗ No se encontró el requerimiento\n";
            }
        } catch (PDOException $e) {
            echo "   ✗ ERROR: " . $e->getMessage() . "\n";
        }

        // Probar sp_get_periodos
        echo "\n4. Probando sp_get_periodos({$primero['control_otr']})...\n";
        try {
            $stmt = $pdo->prepare("SELECT * FROM sp_get_periodos(?)");
            $stmt->execute([$primero['control_otr']]);
            $periodos = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (count($periodos) > 0) {
                echo "   ✓ SP funciona correctamente\n";
                echo "   Periodos encontrados: " . count($periodos) . "\n";
            } else {
                echo "   ⚠ No hay periodos para este requerimiento\n";
            }
        } catch (PDOException $e) {
            echo "   ✗ ERROR: " . $e->getMessage() . "\n";
        }

    } else {
        echo "✗ No se encontraron requerimientos vinculados a locales\n";
        echo "\nBuscando datos por separado...\n\n";

        // Buscar locales
        $stmt = $pdo->query("SELECT * FROM comun.ta_11_locales LIMIT 1");
        $local = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($local) {
            echo "✓ Hay locales en la BD\n";
            echo "  Ejemplo: ID {$local['id_local']} - {$local['nombre']}\n";
        }

        // Buscar requerimientos
        $stmt = $pdo->query("SELECT * FROM comun.ta_15_apremios LIMIT 1");
        $apremio = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($apremio) {
            echo "✓ Hay requerimientos en la BD\n";
            echo "  Ejemplo: Modulo {$apremio['modulo']}, Folio {$apremio['folio']}\n";
        }
    }

    echo "\n========================================\n";
    echo "BÚSQUEDA COMPLETADA\n";
    echo "========================================\n";

} catch (PDOException $e) {
    echo "\n✗ ERROR DE CONEXIÓN: " . $e->getMessage() . "\n";
    exit(1);
}
