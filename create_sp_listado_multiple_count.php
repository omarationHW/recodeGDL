<?php
// Script enfocado en crear SOLO el SP recaudadora_listado_multiple_count

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Conectado exitosamente a la base de datos.\n\n";

    // 1. Verificar si existe el SP antes de eliminarlo
    echo "1. Verificando si el SP existe...\n";
    $stmt = $pdo->prepare("
        SELECT COUNT(*) as existe
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'publico'
        AND p.proname = 'recaudadora_listado_multiple_count'
    ");
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   SP existe: " . ($result['existe'] > 0 ? "SI" : "NO") . "\n\n";

    // 2. Eliminar función si existe
    echo "2. Eliminando función existente si existe...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS publico.recaudadora_listado_multiple_count(VARCHAR) CASCADE");
    echo "   ✓ Función eliminada (si existía).\n\n";

    // 3. Crear el stored procedure de conteo
    echo "3. Creando stored procedure publico.recaudadora_listado_multiple_count...\n";
    $sql = "
    CREATE FUNCTION publico.recaudadora_listado_multiple_count(
        p_filtro VARCHAR
    )
    RETURNS TABLE (
        total BIGINT
    )
    LANGUAGE plpgsql
    AS \$\$
    BEGIN
        RETURN QUERY
        SELECT COUNT(*)::BIGINT AS total
        FROM publico.listado_multiple l
        WHERE
            CASE
                WHEN p_filtro = '' OR p_filtro IS NULL THEN TRUE
                ELSE (
                    l.folio ILIKE '%' || p_filtro || '%'
                    OR l.clave_cuenta ILIKE '%' || p_filtro || '%'
                    OR l.contribuyente ILIKE '%' || p_filtro || '%'
                    OR l.concepto ILIKE '%' || p_filtro || '%'
                    OR l.tipo_movimiento ILIKE '%' || p_filtro || '%'
                    OR l.estado ILIKE '%' || p_filtro || '%'
                )
            END;
    END;
    \$\$;
    ";
    $pdo->exec($sql);
    echo "   ✓ Stored procedure creado exitosamente.\n\n";

    // 4. Verificar que fue creado correctamente
    echo "4. Verificando creación del SP...\n";
    $stmt = $pdo->prepare("
        SELECT
            n.nspname as schema,
            p.proname as nombre,
            pg_get_function_arguments(p.oid) as argumentos,
            pg_get_functiondef(p.oid) as definicion
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'publico'
        AND p.proname = 'recaudadora_listado_multiple_count'
    ");
    $stmt->execute();
    $sp_info = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($sp_info) {
        echo "   ✓ SP encontrado en schema: " . $sp_info['schema'] . "\n";
        echo "   ✓ Nombre: " . $sp_info['nombre'] . "\n";
        echo "   ✓ Argumentos: " . $sp_info['argumentos'] . "\n\n";
    } else {
        echo "   ❌ ERROR: SP no fue encontrado después de crearlo!\n\n";
        exit(1);
    }

    // 5. Probar el SP con datos reales
    echo "5. Probando el stored procedure:\n\n";

    $tests = [
        [
            'nombre' => 'Contar todos los registros (sin filtro)',
            'filtro' => ''
        ],
        [
            'nombre' => 'Contar registros con filtro "PAGO"',
            'filtro' => 'PAGO'
        ],
        [
            'nombre' => 'Contar registros con filtro "ACTIVO"',
            'filtro' => 'ACTIVO'
        ]
    ];

    foreach ($tests as $idx => $test) {
        echo "   Prueba " . ($idx + 1) . ": " . $test['nombre'] . "\n";
        $stmt = $pdo->prepare("SELECT * FROM publico.recaudadora_listado_multiple_count(?)");
        $stmt->execute([$test['filtro']]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($row) {
            echo "   Total encontrado: " . $row['total'] . " registro(s)\n";
        } else {
            echo "   ❌ ERROR: No se pudo ejecutar el SP\n";
        }
        echo "\n";
    }

    // 6. Verificar también el SP de datos
    echo "6. Verificando que el SP recaudadora_listado_multiple también existe...\n";
    $stmt = $pdo->prepare("
        SELECT COUNT(*) as existe
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'publico'
        AND p.proname = 'recaudadora_listado_multiple'
    ");
    $stmt->execute();
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   SP recaudadora_listado_multiple existe: " . ($result['existe'] > 0 ? "SI" : "NO") . "\n\n";

    echo "✅ Script completado exitosamente!\n";
    echo "\n📝 RESUMEN:\n";
    echo "   - SP recaudadora_listado_multiple_count creado en esquema 'publico'\n";
    echo "   - Parámetro: p_filtro (VARCHAR)\n";
    echo "   - Retorna: TABLE (total BIGINT)\n";
    echo "   - Búsqueda por: folio, cuenta, contribuyente, concepto, tipo_movimiento, estado\n";
    echo "   - SP verificado y probado exitosamente\n";
    echo "   - Ahora ListadoMultiple.vue debería poder usarlo correctamente\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Detalle: " . $e->getTraceAsString() . "\n";
    exit(1);
}
