<?php
// Script para probar el stored procedure recaudadora_empresas actualizado

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente.\n\n";

    // 1. Actualizar el stored procedure
    echo "1. Actualizando stored procedure recaudadora_empresas...\n";
    $sql = file_get_contents(__DIR__ . '/update_sp_recaudadora_empresas.sql');
    $pdo->exec($sql);
    echo "   ✓ Stored procedure actualizado exitosamente.\n\n";

    // 2. Probar sin parámetros (listar primeras empresas)
    echo "2. Probando sin parámetros (primeras empresas)...\n";
    $stmt = $pdo->query("SELECT * FROM publico.recaudadora_empresas('', 0, 10)");
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($rows) > 0) {
        echo "   Total de empresas en BD: " . number_format($rows[0]['total_count']) . "\n";
        echo "   Resultados mostrados: " . count($rows) . "\n\n";

        echo "   Primeras 5 empresas:\n";
        for ($i = 0; $i < min(5, count($rows)); $i++) {
            $r = $rows[$i];
            echo "\n   " . ($i + 1) . ". {$r['nombre']}\n";
            echo "      Folio: {$r['folio']}\n";
            echo "      RFC: {$r['rfc']}\n";
            echo "      Tipo: {$r['tipo']}\n";
            if ($r['telefono']) {
                echo "      Teléfono: {$r['telefono']}\n";
            }
            if ($r['email']) {
                echo "      Email: {$r['email']}\n";
            }
            if ($r['contacto'] && trim($r['contacto']) != '') {
                echo "      Contacto: {$r['contacto']}\n";
            }
        }
    }

    // 3. Buscar empresas con razón social que contenga "SA"
    echo "\n\n3. Probando búsqueda por razón social 'SA'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_empresas(?, 0, 10)");
    $stmt->execute(['SA']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($rows) > 0) {
        echo "   Total encontrados: " . number_format($rows[0]['total_count']) . "\n";
        echo "   Mostrando primeros " . count($rows) . ":\n";
        foreach ($rows as $i => $r) {
            echo "     " . ($i + 1) . ". {$r['nombre']} (RFC: {$r['rfc']})\n";
        }
    }

    // 4. Buscar por RFC
    echo "\n\n4. Probando búsqueda por RFC 'HME'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_empresas(?, 0, 5)");
    $stmt->execute(['HME']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($rows) > 0) {
        echo "   Empresas encontradas: " . count($rows) . "\n";
        foreach ($rows as $r) {
            echo "\n   Empresa:\n";
            echo "     Nombre: {$r['nombre']}\n";
            echo "     RFC: {$r['rfc']}\n";
            echo "     Teléfono: {$r['telefono']}\n";
            echo "     Email: {$r['email']}\n";
            echo "     Dirección: {$r['direccion']}\n";
            echo "     Colonia: {$r['colonia']}\n";
            echo "     CP: {$r['codigo_postal']}\n";
        }
    }

    // 5. Buscar por folio
    echo "\n\n5. Probando búsqueda por folio '232100'...\n";
    $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_empresas(?, 0, 5)");
    $stmt->execute(['232100']);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($rows) > 0) {
        echo "   Encontrado:\n";
        $r = $rows[0];
        echo "     Folio: {$r['folio']}\n";
        echo "     Nombre: {$r['nombre']}\n";
        echo "     RFC: {$r['rfc']}\n";
        echo "     Tipo: {$r['tipo']}\n";
    }

    // 6. Estadísticas
    echo "\n\n6. Estadísticas generales...\n";

    // Total de empresas (tipo M)
    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM public.receptcontrib
        WHERE tipo = 'M'
    ");
    $total_m = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Total Personas Morales (Empresas): " . number_format($total_m['total']) . "\n";

    // Total de personas físicas con razón social
    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM public.receptcontrib
        WHERE tipo = 'F' AND TRIM(razonsocial) != ''
    ");
    $total_f = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Total Personas Físicas con Razón Social: " . number_format($total_f['total']) . "\n";

    // Total general
    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM public.receptcontrib
        WHERE tipo = 'M' OR (tipo = 'F' AND TRIM(razonsocial) != '')
    ");
    $total_all = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Total disponible en el sistema: " . number_format($total_all['total']) . "\n";

    // Con email
    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM public.receptcontrib
        WHERE (tipo = 'M' OR (tipo = 'F' AND TRIM(razonsocial) != ''))
        AND correo IS NOT NULL AND TRIM(correo) != ''
    ");
    $with_email = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Con email registrado: " . number_format($with_email['total']) . "\n";

    // Con teléfono
    $stmt = $pdo->query("
        SELECT COUNT(*) as total
        FROM public.receptcontrib
        WHERE (tipo = 'M' OR (tipo = 'F' AND TRIM(razonsocial) != ''))
        AND telefono IS NOT NULL AND TRIM(telefono) != ''
    ");
    $with_phone = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Con teléfono registrado: " . number_format($with_phone['total']) . "\n";

    echo "\n\n✅ Todas las pruebas completadas exitosamente!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
