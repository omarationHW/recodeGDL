<?php
/**
 * Script para verificar y probar sp_consulta_general_buscar
 */

$host = "192.168.6.146";
$port = "5432";
$dbname = "mercados";
$user = "refact";
$password = "FF)-BQk2";

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
    ]);

    echo "\n=== VERIFICACIÓN DE sp_consulta_general_buscar ===\n\n";

    // 1. Verificar si existe el SP
    echo "1. Verificando existencia del SP...\n";
    $sql = "
        SELECT
            n.nspname as schema,
            p.proname as nombre,
            pg_get_function_arguments(p.oid) as argumentos
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE p.proname = 'sp_consulta_general_buscar'
    ";

    $stmt = $pdo->query($sql);
    $sp = $stmt->fetch();

    if ($sp) {
        echo "✅ SP encontrado en schema: " . $sp['schema'] . "\n";
        echo "   Argumentos: " . $sp['argumentos'] . "\n\n";
    } else {
        echo "❌ SP NO ENCONTRADO - necesita ser desplegado\n\n";
        exit(1);
    }

    // 2. Probar el SP con datos reales
    echo "2. Probando SP con datos reales...\n";
    echo str_repeat("-", 80) . "\n";

    // Test 1: Local completo con letra
    echo "\nTEST 1: Local con letra (Oficina:1, Mercado:2, Cat:1, Sec:SS, Local:1, Letra:A)\n";
    $sql = "SELECT * FROM sp_consulta_general_buscar(1::SMALLINT, 2::SMALLINT, 1::SMALLINT, 'SS'::CHAR(2), 1::INTEGER, 'A'::VARCHAR, NULL::VARCHAR)";
    $stmt = $pdo->query($sql);
    $resultados = $stmt->fetchAll();

    if (count($resultados) > 0) {
        echo "✅ Encontrados " . count($resultados) . " resultados\n";
        foreach ($resultados as $row) {
            echo "   - ID: {$row['id_local']}, Nombre: {$row['nombre']}\n";
        }
    } else {
        echo "⚠️  No se encontraron resultados\n";
    }

    // Test 2: Local sin letra
    echo "\nTEST 2: Local sin letra (Oficina:1, Mercado:2, Cat:1, Sec:SS, Local:2)\n";
    $sql = "SELECT * FROM sp_consulta_general_buscar(1::SMALLINT, 2::SMALLINT, 1::SMALLINT, 'SS'::CHAR(2), 2::INTEGER, NULL::VARCHAR, NULL::VARCHAR)";
    $stmt = $pdo->query($sql);
    $resultados = $stmt->fetchAll();

    if (count($resultados) > 0) {
        echo "✅ Encontrados " . count($resultados) . " resultados\n";
        foreach ($resultados as $row) {
            echo "   - ID: {$row['id_local']}, Nombre: {$row['nombre']}\n";
        }
    } else {
        echo "⚠️  No se encontraron resultados\n";
    }

    // Test 3: Otro local
    echo "\nTEST 3: Otro local (Oficina:1, Mercado:2, Cat:1, Sec:SS, Local:3)\n";
    $sql = "SELECT * FROM sp_consulta_general_buscar(1::SMALLINT, 2::SMALLINT, 1::SMALLINT, 'SS'::CHAR(2), 3::INTEGER, NULL::VARCHAR, NULL::VARCHAR)";
    $stmt = $pdo->query($sql);
    $resultados = $stmt->fetchAll();

    if (count($resultados) > 0) {
        echo "✅ Encontrados " . count($resultados) . " resultados\n";
        foreach ($resultados as $row) {
            echo "   - ID: {$row['id_local']}, Nombre: {$row['nombre']}, Domicilio: {$row['domicilio']}\n";
        }
    } else {
        echo "⚠️  No se encontraron resultados\n";
    }

    echo "\n" . str_repeat("=", 80) . "\n";
    echo "✅ VERIFICACIÓN COMPLETADA\n\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
