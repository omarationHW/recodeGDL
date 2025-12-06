<?php
/**
 * Script para desplegar SPs de PasoMdos y PasoAdeudos
 * Base de datos: padron_licencias
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';  // Los SPs van a esta BD
$user = 'refact';
$password = 'FF)-BQk2';

echo "\n=============================================================\n";
echo "DESPLIEGUE DE SPs - MÓDULO TIANGUIS (MERCADOS)\n";
echo "=============================================================\n\n";

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "✓ Conectado a $dbname en $host:$port\n\n";

    // =========================================================
    // 1. DESPLEGAR SPs de PasoMdos
    // =========================================================
    echo "1. DESPLEGANDO SPs DE PASOMDOS (Paso de Tianguis)...\n";
    echo str_repeat('-', 70) . "\n";

    $sqlPasoMdos = file_get_contents(__DIR__ . '/../RefactorX/Base/mercados/database/database/PasoMdos_sp_insert_tianguis_padron_corregido.sql');

    if (!$sqlPasoMdos) {
        die("✗ Error: No se pudo leer PasoMdos_sp_insert_tianguis_padron_corregido.sql\n");
    }

    // Remover comando \c y SET search_path que pueden causar problemas
    $sqlPasoMdos = preg_replace('/\\\\c\s+\w+;?/', '', $sqlPasoMdos);
    $sqlPasoMdos = preg_replace('/SET\s+search_path\s+TO\s+\w+;?/', '', $sqlPasoMdos);

    try {
        $pdo->exec($sqlPasoMdos);
        echo "  ✓ sp_pasomdos_insert_tianguis desplegado\n";
        echo "  ✓ sp_pasomdos_verificar_local desplegado\n";
    } catch (PDOException $e) {
        echo "  ✗ Error en PasoMdos: " . $e->getMessage() . "\n";
    }

    echo "\n";

    // =========================================================
    // 2. DESPLEGAR SPs de PasoAdeudos
    // =========================================================
    echo "2. DESPLEGANDO SPs DE PASOADEUDOS (Generación Adeudos)...\n";
    echo str_repeat('-', 70) . "\n";

    $sqlPasoAdeudos = file_get_contents(__DIR__ . '/PasoAdeudos_SPs_corregidos.sql');

    if (!$sqlPasoAdeudos) {
        die("✗ Error: No se pudo leer PasoAdeudos_SPs_corregidos.sql\n");
    }

    // Remover comando \c y SET search_path
    $sqlPasoAdeudos = preg_replace('/\\\\c\s+\w+;?/', '', $sqlPasoAdeudos);
    $sqlPasoAdeudos = preg_replace('/SET\s+search_path\s+TO\s+\w+;?/', '', $sqlPasoAdeudos);

    try {
        $pdo->exec($sqlPasoAdeudos);
        echo "  ✓ sp_get_tianguis_locales desplegado\n";
        echo "  ✓ sp_insertar_adeudo_local desplegado\n";
    } catch (PDOException $e) {
        echo "  ✗ Error en PasoAdeudos: " . $e->getMessage() . "\n";
    }

    echo "\n";

    // =========================================================
    // 3. VERIFICAR SPs DESPLEGADOS
    // =========================================================
    echo "3. VERIFICANDO SPs DESPLEGADOS...\n";
    echo str_repeat('-', 70) . "\n";

    $stmt = $pdo->query("
        SELECT routine_name, routine_type
        FROM information_schema.routines
        WHERE routine_schema = 'public'
        AND (
            routine_name LIKE 'sp_pasomdos%' OR
            routine_name LIKE 'sp_%tianguis%' OR
            routine_name LIKE 'sp_insertar_adeudo%'
        )
        ORDER BY routine_name
    ");

    $routines = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (count($routines) > 0) {
        echo "\nSPs encontrados en padron_licencias.public:\n";
        foreach ($routines as $routine) {
            echo "  ✓ {$routine['routine_name']} ({$routine['routine_type']})\n";
        }
    } else {
        echo "  ⚠ No se encontraron SPs (puede que estén en otro schema)\n";
    }

    echo "\n";
    echo str_repeat('=', 70) . "\n";
    echo "✓ DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
    echo str_repeat('=', 70) . "\n\n";

    echo "SPs desplegados:\n";
    echo "  1. sp_pasomdos_insert_tianguis\n";
    echo "  2. sp_pasomdos_verificar_local\n";
    echo "  3. sp_get_tianguis_locales\n";
    echo "  4. sp_insertar_adeudo_local\n\n";

    echo "Base de datos: padron_licencias\n";
    echo "Esquema: public\n\n";

} catch (PDOException $e) {
    echo "\n✗ ERROR DE CONEXIÓN: " . $e->getMessage() . "\n";
    echo "Verificar:\n";
    echo "  - Host: $host\n";
    echo "  - Puerto: $port\n";
    echo "  - Base de datos: $dbname\n";
    echo "  - Usuario: $user\n";
    exit(1);
}
