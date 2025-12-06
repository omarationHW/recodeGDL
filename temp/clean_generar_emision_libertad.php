<?php
$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== Limpiando versiones antiguas de generar_emision_libertad ===\n\n";

try {
    // Eliminar versión 1 (INTEGER)
    echo "Eliminando versión 1 (INTEGER)...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS public.generar_emision_libertad(p_oficina integer, p_mercados json, p_axo integer, p_periodo integer, p_usuario_id integer);");
    echo "✓ Versión 1 eliminada\n\n";

    // Eliminar versión 2 (SMALLINT)
    echo "Eliminando versión 2 (SMALLINT)...\n";
    $pdo->exec("DROP FUNCTION IF EXISTS public.generar_emision_libertad(p_oficina smallint, p_mercados json, p_axo smallint, p_periodo smallint, p_usuario_id integer);");
    echo "✓ Versión 2 eliminada\n\n";

    // Verificar que no quede ninguna
    $stmt = $pdo->query("SELECT COUNT(*) FROM pg_proc p JOIN pg_namespace n ON p.pronamespace = n.oid WHERE p.proname = 'generar_emision_libertad'");
    $count = $stmt->fetch(PDO::FETCH_COLUMN);

    if ($count == 0) {
        echo "✅ Todas las versiones eliminadas correctamente\n";
    } else {
        echo "⚠ Aún quedan {$count} versiones\n";
    }

} catch (PDOException $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
}
