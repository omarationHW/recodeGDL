<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== CREANDO STORED PROCEDURE recaudadora_catastro_dm ===\n\n";

$sql = "
CREATE OR REPLACE FUNCTION public.recaudadora_catastro_dm(
    p_query TEXT,
    p_year INTEGER,
    p_offset INTEGER,
    p_limit INTEGER
)
RETURNS TABLE (
    id INTEGER,
    clave_cuenta VARCHAR,
    propietario VARCHAR,
    domicilio VARCHAR,
    colonia VARCHAR,
    ejercicio INTEGER,
    status VARCHAR,
    total_count BIGINT
)
LANGUAGE plpgsql AS \$\$
DECLARE
    v_total_count BIGINT;
BEGIN
    -- Primero calcular el total de registros que cumplen los filtros
    SELECT COUNT(*)
    INTO v_total_count
    FROM public.catastro_dm c
    WHERE c.status = 'A'
      AND (p_year = 0 OR c.ejercicio = p_year)
      AND (p_query = '' OR
           c.clave_cuenta ILIKE '%' || p_query || '%' OR
           c.propietario ILIKE '%' || p_query || '%' OR
           c.domicilio ILIKE '%' || p_query || '%' OR
           c.colonia ILIKE '%' || p_query || '%');

    -- Retornar los resultados paginados con el total_count
    RETURN QUERY
    SELECT
        c.id,
        c.clave_cuenta,
        c.propietario,
        c.domicilio,
        c.colonia,
        c.ejercicio,
        c.status,
        v_total_count as total_count
    FROM public.catastro_dm c
    WHERE c.status = 'A'
      AND (p_year = 0 OR c.ejercicio = p_year)
      AND (p_query = '' OR
           c.clave_cuenta ILIKE '%' || p_query || '%' OR
           c.propietario ILIKE '%' || p_query || '%' OR
           c.domicilio ILIKE '%' || p_query || '%' OR
           c.colonia ILIKE '%' || p_query || '%')
    ORDER BY c.id
    LIMIT p_limit
    OFFSET p_offset;
END; \$\$;
";

try {
    $pdo->exec($sql);
    echo "✅ Stored Procedure 'recaudadora_catastro_dm' creado exitosamente\n\n";

    // Verificar que el SP existe
    $check = $pdo->query("
        SELECT routine_name, routine_type
        FROM information_schema.routines
        WHERE routine_schema = 'public'
        AND routine_name = 'recaudadora_catastro_dm'
    ")->fetch(PDO::FETCH_ASSOC);

    if ($check) {
        echo "✅ Verificación: SP existe en el esquema public\n";
        echo "   Nombre: {$check['routine_name']}\n";
        echo "   Tipo: {$check['routine_type']}\n\n";
    }

    // Pruebas del SP
    echo "=== PRUEBAS DEL STORED PROCEDURE ===\n\n";

    // Prueba 1: Consulta sin filtros, primera página
    echo "Prueba 1: Sin filtros, página 1 (10 registros)\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('', 0, 0, 10)");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $totalCount = $results[0]['total_count'] ?? 0;

    echo "  📊 Total de registros activos: $totalCount\n";
    echo "  📄 Registros en página: " . count($results) . "\n";
    if (count($results) > 0) {
        echo "  📝 Primer registro: {$results[0]['clave_cuenta']} - {$results[0]['propietario']}\n";
    }
    echo "\n";

    // Prueba 2: Filtrar por año 2024
    echo "Prueba 2: Filtrar por ejercicio 2024\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('', 2024, 0, 10)");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $totalCount = $results[0]['total_count'] ?? 0;

    echo "  📊 Total en 2024: $totalCount\n";
    echo "  📄 Registros en página: " . count($results) . "\n";
    echo "\n";

    // Prueba 3: Filtrar por año 2025
    echo "Prueba 3: Filtrar por ejercicio 2025\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('', 2025, 0, 10)");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $totalCount = $results[0]['total_count'] ?? 0;

    echo "  📊 Total en 2025: $totalCount\n";
    echo "  📄 Registros en página: " . count($results) . "\n";
    echo "\n";

    // Prueba 4: Búsqueda por texto (cuenta)
    echo "Prueba 4: Buscar cuentas que contengan '100000'\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('100000', 0, 0, 10)");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $totalCount = $results[0]['total_count'] ?? 0;

    echo "  📊 Total encontrado: $totalCount\n";
    echo "  📄 Registros en página: " . count($results) . "\n";
    if (count($results) > 0) {
        foreach ($results as $r) {
            echo "    - {$r['clave_cuenta']}\n";
        }
    }
    echo "\n";

    // Prueba 5: Búsqueda por colonia
    echo "Prueba 5: Buscar por colonia 'Centro'\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('Centro', 0, 0, 10)");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $totalCount = $results[0]['total_count'] ?? 0;

    echo "  📊 Total encontrado: $totalCount\n";
    echo "  📄 Registros en página: " . count($results) . "\n";
    if (count($results) > 0) {
        echo "  📝 Ejemplos:\n";
        for ($i = 0; $i < min(3, count($results)); $i++) {
            $r = $results[$i];
            echo "    - {$r['clave_cuenta']}: {$r['propietario']} (Col. {$r['colonia']})\n";
        }
    }
    echo "\n";

    // Prueba 6: Paginación - Segunda página
    echo "Prueba 6: Segunda página (offset 10, limit 10)\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('', 0, 10, 10)");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "  📄 Registros en página: " . count($results) . "\n";
    if (count($results) > 0) {
        echo "  📝 Primer registro de la página: {$results[0]['clave_cuenta']}\n";
        echo "  📝 Último registro de la página: {$results[count($results)-1]['clave_cuenta']}\n";
    }
    echo "\n";

    // Prueba 7: Cambiar tamaño de página
    echo "Prueba 7: Página con 25 registros\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('', 0, 0, 25)");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "  📄 Registros obtenidos: " . count($results) . "\n";
    echo "\n";

    // Prueba 8: Búsqueda combinada (año + texto)
    echo "Prueba 8: Búsqueda combinada - Ejercicio 2024 + colonia 'Americana'\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('Americana', 2024, 0, 10)");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $totalCount = $results[0]['total_count'] ?? 0;

    echo "  📊 Total encontrado: $totalCount\n";
    echo "  📄 Registros en página: " . count($results) . "\n";
    echo "\n";

    // Prueba 9: Búsqueda sin resultados
    echo "Prueba 9: Búsqueda sin resultados (texto inexistente)\n";
    $stmt = $pdo->prepare("SELECT * FROM public.recaudadora_catastro_dm('XXXXXXXX', 0, 0, 10)");
    $stmt->execute();
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "  📊 Total encontrado: " . (count($results) > 0 ? $results[0]['total_count'] : 0) . "\n";
    echo "  📄 Registros en página: " . count($results) . "\n";
    echo "\n";

    // Resumen de capacidades
    echo "=== CAPACIDADES DEL STORED PROCEDURE ===\n\n";
    echo "✅ Paginación server-side (offset + limit)\n";
    echo "✅ Filtro por ejercicio (año)\n";
    echo "✅ Búsqueda de texto en múltiples campos:\n";
    echo "   - Clave de cuenta\n";
    echo "   - Propietario\n";
    echo "   - Domicilio\n";
    echo "   - Colonia\n";
    echo "✅ Solo registros activos (status = 'A')\n";
    echo "✅ Retorna total_count para paginación en frontend\n";
    echo "✅ Ordenamiento por ID\n\n";

    echo "✅ Todas las pruebas completadas!\n";

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
