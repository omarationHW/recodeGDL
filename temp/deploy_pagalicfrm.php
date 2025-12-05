<?php
// Script para desplegar el stored procedure pagalicfrm

$host = '192.168.6.146';
$port = '5432';
$dbname = 'padron_licencias';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);

    echo "=== DESPLEGANDO STORED PROCEDURE: recaudadora_pagalicfrm ===\n\n";

    // Eliminar función existente si existe
    echo "Eliminando funciones anteriores...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS public.recaudadora_pagalicfrm();");
    $pdo->exec("DROP FUNCTION IF EXISTS public.recaudadora_pagalicfrm(VARCHAR);");
    $pdo->exec("DROP FUNCTION IF EXISTS comun.recaudadora_pagalicfrm();");
    $pdo->exec("DROP FUNCTION IF EXISTS comun.recaudadora_pagalicfrm(VARCHAR);");
    echo "✓ Funciones anteriores eliminadas\n\n";

    // Leer el archivo SQL
    $sql = file_get_contents('RefactorX/Base/multas_reglamentos/database/generated/recaudadora_pagalicfrm.sql');

    // Ejecutar el SQL
    $pdo->exec($sql);

    echo "✓ Stored procedure creado exitosamente en schema 'comun'\n\n";

    // Verificar que el SP existe
    $stmt = $pdo->query("
        SELECT routine_schema, routine_name
        FROM information_schema.routines
        WHERE routine_name = 'recaudadora_pagalicfrm'
    ");

    echo "=== VERIFICACIÓN ===\n";
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "✓ SP encontrado: {$row['routine_schema']}.{$row['routine_name']}\n";
    }

    // Probar el SP con licencia 4
    echo "\n=== PRUEBA CON LICENCIA #4 ===\n";
    $stmt = $pdo->query("SELECT * FROM public.recaudadora_pagalicfrm('4') LIMIT 5");

    $count = 0;
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $count++;
        echo "\nRegistro $count:\n";
        echo "  ID Licencia: {$row['id_licencia']}\n";
        echo "  Número: {$row['licencia']}\n";
        echo "  Propietario: {$row['propietario']}\n";
        echo "  Año: {$row['axo']}\n";
        echo "  Saldo: \${$row['saldo']}\n";
        echo "  Total Adeudo: \${$row['total_adeudo']}\n";
    }

    echo "\n✓ Total de registros obtenidos: $count\n";

    // Guardar ejemplos
    echo "\n=== OBTENIENDO 3 EJEMPLOS DE LICENCIAS ===\n";
    $stmt = $pdo->query("
        SELECT DISTINCT licencia
        FROM public.recaudadora_pagalicfrm(NULL)
        LIMIT 3
    ");

    echo "\nEjemplos de licencias para probar:\n";
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  - Licencia: {$row['licencia']}\n";
    }

    echo "\n✓ Despliegue completado exitosamente!\n";

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    exit(1);
}
