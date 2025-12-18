<?php
// Verificar estructura y datos de diferencias_glosa

$host = '192.168.6.146';
$dbname = 'multas_reglamentos';
$user = 'refact';
$password = 'FF)-BQk2';

try {
    $pdo = new PDO("pgsql:host=$host;dbname=$dbname", $user, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== VERIFICACIÓN DE diferencias_glosa ===\n\n";

    // 1. Ver todas las columnas
    echo "1. Estructura completa de public.diferencias_glosa:\n";
    $stmt = $pdo->query("
        SELECT column_name, data_type, is_nullable
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = 'diferencias_glosa'
        ORDER BY ordinal_position
    ");
    $cols = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($cols as $col) {
        echo "   - {$col['column_name']} ({$col['data_type']}) - NULL: {$col['is_nullable']}\n";
    }

    // 2. Ejemplos de registros completos
    echo "\n2. Ejemplos de registros completos (primeros 5):\n";
    $stmt = $pdo->query("
        SELECT *
        FROM public.diferencias_glosa
        ORDER BY fecha_alta DESC
        LIMIT 5
    ");
    $ejemplos = $stmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($ejemplos as $i => $ej) {
        echo "\n   === DIFERENCIA " . ($i + 1) . " ===\n";
        foreach ($ej as $key => $value) {
            if ($value !== null && $value !== '') {
                echo "   {$key}: {$value}\n";
            }
        }
    }

    // 3. Verificar valores de tipo_dif
    echo "\n\n3. Valores distintos de tipo_dif:\n";
    $stmt = $pdo->query("
        SELECT tipo_dif, COUNT(*) as total
        FROM public.diferencias_glosa
        GROUP BY tipo_dif
        ORDER BY total DESC
    ");
    $tipos = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($tipos as $tipo) {
        $tipo_val = $tipo['tipo_dif'] ?: '(NULL)';
        echo "   {$tipo_val}: " . number_format($tipo['total']) . "\n";
    }

    // 4. Verificar valores de diferen
    echo "\n4. Valores distintos de diferen:\n";
    $stmt = $pdo->query("
        SELECT diferen, COUNT(*) as total
        FROM public.diferencias_glosa
        GROUP BY diferen
        ORDER BY total DESC
        LIMIT 10
    ");
    $difs = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($difs as $dif) {
        $dif_val = $dif['diferen'] ?: '(NULL)';
        echo "   {$dif_val}: " . number_format($dif['total']) . "\n";
    }

    // 5. Verificar estados (vigencia)
    echo "\n5. Estados de vigencia:\n";
    $stmt = $pdo->query("
        SELECT vigencia, COUNT(*) as total
        FROM public.diferencias_glosa
        GROUP BY vigencia
        ORDER BY total DESC
    ");
    $estados = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($estados as $est) {
        $est_val = $est['vigencia'] ?: '(NULL)';
        $est_nombre = $est_val == 'P' ? 'Pendiente' :
                     ($est_val == 'C' ? 'Cancelado' :
                     ($est_val == 'V' ? 'Vigente' : $est_val));
        echo "   {$est_nombre} ({$est_val}): " . number_format($est['total']) . "\n";
    }

    // 6. Rango de fechas
    echo "\n6. Rango de fechas:\n";
    $stmt = $pdo->query("
        SELECT
            MIN(fecha_alta) as fecha_min,
            MAX(fecha_alta) as fecha_max,
            COUNT(*) as total
        FROM public.diferencias_glosa
    ");
    $rango = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "   Fecha mínima: {$rango['fecha_min']}\n";
    echo "   Fecha máxima: {$rango['fecha_max']}\n";
    echo "   Total registros: " . number_format($rango['total']) . "\n";

    // 7. Ver usuarios más activos
    echo "\n7. Usuarios que registran diferencias:\n";
    $stmt = $pdo->query("
        SELECT usu_alta, COUNT(*) as total
        FROM public.diferencias_glosa
        GROUP BY usu_alta
        ORDER BY total DESC
        LIMIT 10
    ");
    $usuarios = $stmt->fetchAll(PDO::FETCH_ASSOC);
    foreach ($usuarios as $usr) {
        echo "   {$usr['usu_alta']}: " . number_format($usr['total']) . "\n";
    }

    echo "\n✅ Verificación completada!\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
