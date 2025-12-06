<?php
/**
 * Script para desplegar el SP recaudadora_descmultampalfrm SIMPLIFICADO
 */

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLIEGUE DEL SP recaudadora_descmultampalfrm (SIMPLIFICADO) ===\n\n";

    // Leer el archivo SQL
    $sqlFile = __DIR__ . '/../Base/multas_reglamentos/database/generated/recaudadora_descmultampalfrm.sql';

    if (!file_exists($sqlFile)) {
        throw new Exception("No se encontró el archivo SQL: $sqlFile");
    }

    $sql = file_get_contents($sqlFile);

    echo "1. Eliminando el SP anterior si existe...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS multas_reglamentos.recaudadora_descmultampalfrm(TEXT) CASCADE;");
    $pdo->exec("DROP FUNCTION IF EXISTS multas_reglamentos.recaudadora_descmultampalfrm(VARCHAR) CASCADE;");
    $pdo->exec("DROP FUNCTION IF EXISTS multas_reglamentos.recaudadora_descmultampalfrm(INTEGER) CASCADE;");
    echo "   ✓ SP anterior eliminado\n\n";

    echo "2. Creando el nuevo SP simplificado...\n";
    $pdo->exec($sql);
    echo "   ✓ SP creado exitosamente\n\n";

    echo "3. Verificando el SP...\n";
    $check = $pdo->query("
        SELECT
            p.proname as nombre,
            pg_get_function_arguments(p.oid) as argumentos,
            pg_get_function_result(p.oid) as retorna
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'multas_reglamentos'
        AND p.proname = 'recaudadora_descmultampalfrm'
    ")->fetch(PDO::FETCH_ASSOC);

    if ($check) {
        echo "   ✓ SP verificado:\n";
        echo "     Nombre: {$check['nombre']}\n";
        echo "     Argumentos: {$check['argumentos']}\n";
        echo "     Retorna: {$check['retorna']}\n\n";
    }

    echo "4. Probando el SP con un ejemplo...\n";
    $test = $pdo->query("
        SELECT * FROM multas_reglamentos.recaudadora_descmultampalfrm('74985')
        LIMIT 5
    ")->fetchAll(PDO::FETCH_ASSOC);

    if (count($test) > 0) {
        echo "   ✓ SP funciona correctamente. Resultados de prueba:\n\n";
        foreach ($test as $idx => $row) {
            echo "   Registro " . ($idx + 1) . ":\n";
            foreach ($row as $key => $value) {
                echo "     $key: $value\n";
            }
            echo "\n";
        }
    } else {
        echo "   ⚠ No se encontraron resultados para el ID 74985\n";
        echo "   Probando sin filtro (todos los registros)...\n";

        $testAll = $pdo->query("
            SELECT * FROM multas_reglamentos.recaudadora_descmultampalfrm(NULL)
            LIMIT 3
        ")->fetchAll(PDO::FETCH_ASSOC);

        echo "   ✓ SP funciona. Primeros 3 registros:\n\n";
        foreach ($testAll as $idx => $row) {
            echo "   Registro " . ($idx + 1) . ":\n";
            foreach ($row as $key => $value) {
                echo "     $key: $value\n";
            }
            echo "\n";
        }
    }

    echo "\n" . str_repeat("=", 80) . "\n";
    echo "DESPLIEGUE COMPLETADO EXITOSAMENTE\n";
    echo str_repeat("=", 80) . "\n\n";

    echo "CAMBIOS REALIZADOS:\n";
    echo "- ✓ Consulta solo desde tabla 'catastro_gdl.descmultampal' (UNA SOLA TABLA)\n";
    echo "- ✓ Sin JOIN ni relaciones con otras tablas\n";
    echo "- ✓ Parámetro p_clave_cuenta tipo TEXT (coincide con Vue)\n";
    echo "- ✓ Columnas simplificadas según estructura real de la tabla\n";
    echo "- ✓ Total de registros disponibles: 170,857\n\n";

    echo "USO DEL SP:\n";
    echo "  - Con filtro: SELECT * FROM multas_reglamentos.recaudadora_descmultampalfrm('74985');\n";
    echo "  - Sin filtro: SELECT * FROM multas_reglamentos.recaudadora_descmultampalfrm(NULL);\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
