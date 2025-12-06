<?php
$host = '192.168.20.31';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'postgres';
$password = 'F3rnand0';

echo "========================================\n";
echo "BUSCANDO DATOS REALES PARA PRUEBAS\n";
echo "========================================\n\n";

try {
    echo "Conectando a padron_licencias...\n";
    $pdo = new PDO("pgsql:host=$host;port=$port;dbname=$dbname;connect_timeout=10", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✓ Conexión exitosa\n\n";

    // 1. Buscar locales que existen
    echo "========================================\n";
    echo "1. BUSCANDO LOCALES EN comun.ta_11_locales\n";
    echo "========================================\n";

    $stmt = $pdo->query("
        SELECT id_local, oficina, num_mercado, categoria, seccion,
               letra_local, bloque, nombre
        FROM comun.ta_11_locales
        LIMIT 5
    ");

    $locales = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($locales) > 0) {
        echo "✓ Locales encontrados: " . count($locales) . "\n\n";
        foreach ($locales as $local) {
            echo "Local ID: {$local['id_local']}\n";
            echo "  Oficina: {$local['oficina']}, Mercado: {$local['num_mercado']}\n";
            echo "  Categoria: {$local['categoria']}, Seccion: {$local['seccion']}\n";
            echo "  Nombre: {$local['nombre']}\n\n";
        }
    } else {
        echo "✗ No se encontraron locales\n";
    }

    // 2. Buscar requerimientos (apremios)
    echo "========================================\n";
    echo "2. BUSCANDO REQUERIMIENTOS (ta_15_apremios)\n";
    echo "========================================\n";

    $stmt = $pdo->query("
        SELECT a.modulo, a.folio, a.control_otr, a.id_control,
               a.diligencia, a.importe_global, a.fecha_emision
        FROM comun.ta_15_apremios a
        WHERE a.control_otr IS NOT NULL
        LIMIT 10
    ");

    $apremios = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($apremios) > 0) {
        echo "✓ Requerimientos encontrados: " . count($apremios) . "\n\n";
        foreach ($apremios as $apremio) {
            echo "Modulo: {$apremio['modulo']}, Folio: {$apremio['folio']}, Control: {$apremio['control_otr']}\n";
            echo "  ID Control: {$apremio['id_control']}\n";
            echo "  Diligencia: {$apremio['diligencia']}\n";
            echo "  Importe: \${$apremio['importe_global']}\n";
            echo "  Fecha: {$apremio['fecha_emision']}\n\n";
        }
    } else {
        echo "✗ No se encontraron requerimientos\n";
    }

    // 3. Buscar requerimientos que coincidan con locales existentes
    echo "========================================\n";
    echo "3. REQUERIMIENTOS VINCULADOS A LOCALES\n";
    echo "========================================\n";

    $stmt = $pdo->query("
        SELECT
            l.id_local,
            l.oficina,
            l.num_mercado,
            l.nombre,
            a.modulo,
            a.folio,
            a.control_otr,
            a.importe_global,
            a.fecha_emision
        FROM comun.ta_11_locales l
        INNER JOIN comun.ta_15_apremios a ON l.id_local = a.control_otr
        LIMIT 5
    ");

    $vinculados = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($vinculados) > 0) {
        echo "✓ Requerimientos vinculados encontrados: " . count($vinculados) . "\n\n";

        echo "DATOS PARA PRUEBA:\n";
        echo "========================================\n";

        $primero = $vinculados[0];
        echo "📋 DATOS PARA PROBAR DatosRequerimientos:\n\n";
        echo "ID Local: {$primero['id_local']}\n";
        echo "Módulo: {$primero['modulo']}\n";
        echo "Folio: {$primero['folio']}\n";
        echo "Control OTR: {$primero['control_otr']}\n";
        echo "\nLocal:\n";
        echo "  Nombre: {$primero['nombre']}\n";
        echo "  Oficina: {$primero['oficina']}\n";
        echo "  Mercado: {$primero['num_mercado']}\n";
        echo "\nRequerimiento:\n";
        echo "  Importe: \${$primero['importe_global']}\n";
        echo "  Fecha: {$primero['fecha_emision']}\n";

        echo "\n========================================\n";
        echo "JSON PARA PRUEBA EN FRONTEND:\n";
        echo "========================================\n";
        echo json_encode([
            'id_local' => $primero['id_local'],
            'modulo' => $primero['modulo'],
            'folio' => $primero['folio']
        ], JSON_PRETTY_PRINT);

        echo "\n\n========================================\n";
        echo "TODOS LOS DATOS VINCULADOS:\n";
        echo "========================================\n";

        foreach ($vinculados as $v) {
            echo "Local {$v['id_local']} - Modulo:{$v['modulo']}, Folio:{$v['folio']} - {$v['nombre']}\n";
        }

    } else {
        echo "✗ No se encontraron requerimientos vinculados a locales\n";
        echo "\nPROBANDO CON DATOS SEPARADOS:\n";

        if (count($locales) > 0 && count($apremios) > 0) {
            echo "\nLocal de prueba:\n";
            echo "  ID: {$locales[0]['id_local']}\n";
            echo "\nRequerimiento de prueba:\n";
            echo "  Modulo: {$apremios[0]['modulo']}\n";
            echo "  Folio: {$apremios[0]['folio']}\n";
        }
    }

    // 4. Buscar periodos
    echo "\n========================================\n";
    echo "4. BUSCANDO PERIODOS (ta_15_periodos)\n";
    echo "========================================\n";

    $stmt = $pdo->query("
        SELECT control_otr, ayo, periodo, importe, recargos
        FROM comun.ta_15_periodos
        LIMIT 5
    ");

    $periodos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($periodos) > 0) {
        echo "✓ Periodos encontrados: " . count($periodos) . "\n\n";
        foreach ($periodos as $p) {
            echo "Control: {$p['control_otr']}, Año: {$p['ayo']}, Periodo: {$p['periodo']}\n";
            echo "  Importe: \${$p['importe']}, Recargos: \${$p['recargos']}\n";
        }
    } else {
        echo "✗ No se encontraron periodos\n";
    }

    echo "\n========================================\n";
    echo "BÚSQUEDA COMPLETADA\n";
    echo "========================================\n";

} catch (PDOException $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
