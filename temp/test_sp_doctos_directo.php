<?php
// Probar llamada directa al SP

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== PRUEBA DIRECTA DE SP_DOCTOS_LIST ===\n\n";

    // 1. Verificar que el SP existe
    echo "1️⃣  Verificando existencia del SP...\n";
    $stmt = $db->query("
        SELECT
            routine_name,
            routine_schema,
            pg_get_function_arguments(p.oid) as argumentos,
            pg_get_function_identity_arguments(p.oid) as identity_args
        FROM information_schema.routines r
        JOIN pg_proc p ON p.proname = r.routine_name
        JOIN pg_namespace n ON n.oid = p.pronamespace AND n.nspname = r.routine_schema
        WHERE routine_schema = 'public'
          AND routine_name = 'sp_doctos_list'
    ");
    $spInfo = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($spInfo) {
        echo "✅ SP encontrado:\n";
        echo "   Schema: {$spInfo['routine_schema']}\n";
        echo "   Nombre: {$spInfo['routine_name']}\n";
        echo "   Argumentos: '{$spInfo['argumentos']}'\n";
        echo "   Identity Args: '{$spInfo['identity_args']}'\n\n";
    } else {
        echo "❌ SP NO encontrado\n";
        exit(1);
    }

    // 2. Llamar el SP SIN parámetros
    echo "2️⃣  Llamando SP sin parámetros: SELECT * FROM public.sp_doctos_list()\n";
    try {
        $stmt = $db->query('SELECT * FROM public.sp_doctos_list()');
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "✅ Éxito! Registros: " . count($results) . "\n";
        echo "   Primeros 3:\n";
        foreach (array_slice($results, 0, 3) as $i => $row) {
            echo "   " . ($i + 1) . ". Clave: {$row['cvedocto']} - {$row['documento']}\n";
        }
        echo "\n";
    } catch (PDOException $e) {
        echo "❌ Error: " . $e->getMessage() . "\n\n";
    }

    // 3. Intentar llamar CON un parámetro (simular el error)
    echo "3️⃣  Intentando llamar con parámetro (simular error): SELECT * FROM public.sp_doctos_list($1)\n";
    try {
        $stmt = $db->prepare('SELECT * FROM public.sp_doctos_list($1)');
        $stmt->execute(['test']);
        echo "✅ Éxito (no esperado)\n\n";
    } catch (PDOException $e) {
        echo "❌ Error (ESPERADO): " . $e->getMessage() . "\n\n";
    }

    // 4. Probar con array vacío de parámetros usando prepare/execute
    echo "4️⃣  Llamando con prepare/execute y array vacío:\n";
    try {
        $sql = 'SELECT * FROM public.sp_doctos_list()';
        echo "   SQL: $sql\n";
        $stmt = $db->prepare($sql);
        $stmt->execute([]); // Array vacío
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "✅ Éxito! Registros: " . count($results) . "\n\n";
    } catch (PDOException $e) {
        echo "❌ Error: " . $e->getMessage() . "\n\n";
    }

    // 5. Simular lo que hace el GenericController
    echo "5️⃣  Simulando GenericController (sin parámetros):\n";
    try {
        $parametros = []; // Array vacío como envía el frontend
        $spParametros = [];

        foreach ($parametros as $param) {
            if (isset($param['nombre'])) {
                $spParametros[] = $param['valor'];
            }
        }

        $placeholders = str_repeat('?,', count($spParametros));
        $placeholders = rtrim($placeholders, ',');
        $sql = "SELECT * FROM public.sp_doctos_list({$placeholders})";

        echo "   Parámetros recibidos: " . count($parametros) . "\n";
        echo "   SP Parámetros: " . count($spParametros) . "\n";
        echo "   Placeholders: '$placeholders'\n";
        echo "   SQL generado: $sql\n";

        $stmt = $db->prepare($sql);
        $stmt->execute($spParametros);
        $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo "✅ Éxito! Registros: " . count($results) . "\n";
    } catch (PDOException $e) {
        echo "❌ Error: " . $e->getMessage() . "\n";
    }

} catch (PDOException $e) {
    echo "❌ Error de conexión: " . $e->getMessage() . "\n";
}
