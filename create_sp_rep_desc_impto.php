<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== CREANDO STORED PROCEDURE recaudadora_rep_desc_impto ===\n\n";

$sql = "
CREATE OR REPLACE FUNCTION publico.recaudadora_rep_desc_impto(
    p_ejercicio INTEGER
)
RETURNS TABLE (
    dependencia INTEGER,
    nombre_dependencia VARCHAR,
    cantidad_multas BIGINT,
    total_multas NUMERIC,
    total_gastos NUMERIC,
    total_general NUMERIC
)
LANGUAGE plpgsql AS \$\$
BEGIN
    RETURN QUERY
    SELECT
        r.dependencia,
        MAX(r.nombre_dependencia)::VARCHAR as nombre_dependencia,
        SUM(r.cantidad_multas)::BIGINT as cantidad_multas,
        SUM(r.total_multas) as total_multas,
        SUM(r.total_gastos) as total_gastos,
        SUM(r.total_general) as total_general
    FROM publico.relacion_mensual r
    WHERE r.anio = p_ejercicio
    GROUP BY r.dependencia
    ORDER BY r.dependencia;
END; \$\$;
";

try {
    $pdo->exec($sql);
    echo "✅ Stored Procedure 'recaudadora_rep_desc_impto' creado exitosamente\n\n";

    // Verificar que el SP existe
    $check = $pdo->query("
        SELECT routine_name, routine_type
        FROM information_schema.routines
        WHERE routine_schema = 'publico'
        AND routine_name = 'recaudadora_rep_desc_impto'
    ")->fetch(PDO::FETCH_ASSOC);

    if ($check) {
        echo "✅ Verificación: SP existe en el esquema publico\n";
        echo "   Nombre: {$check['routine_name']}\n";
        echo "   Tipo: {$check['routine_type']}\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
