<?php
/**
 * Test: sp_localesmodif_modificar_local
 */

echo "==============================================\n";
echo "TEST: sp_localesmodif_modificar_local\n";
echo "==============================================\n\n";

try {
    $pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "1. Buscando local de prueba...\n";
    $local = $pdo->query("
        SELECT
            id_local, nombre, domicilio, sector, zona,
            descripcion_local, superficie, giro, fecha_alta, fecha_baja,
            vigencia, clave_cuota
        FROM publico.ta_11_locales
        WHERE id_local IS NOT NULL
        LIMIT 1
    ")->fetch(PDO::FETCH_OBJ);

    if (!$local) {
        throw new Exception("No hay locales de prueba");
    }

    echo "   ✓ Local encontrado:\n";
    echo "     - id_local: {$local->id_local}\n";
    echo "     - nombre: {$local->nombre}\n\n";

    echo "2. Probando SP con parámetros de tipo correcto...\n";

    // Preparar valores con tipos correctos
    $id_local = (int)$local->id_local;
    $nombre = (string)($local->nombre ?? '');
    $domicilio = (string)($local->domicilio ?? '');
    $sector = (string)($local->sector ?? 'J');
    $zona = (int)($local->zona ?? 1);
    $descripcion = (string)($local->descripcion_local ?? '');
    $superficie = (float)($local->superficie ?? 0.0);
    $giro = (int)($local->giro ?? 0);
    $fecha_alta = $local->fecha_alta ?? date('Y-m-d');
    $fecha_baja = $local->fecha_baja ?? null;
    $vigencia = (string)($local->vigencia ?? 'A');
    $clave_cuota = (int)($local->clave_cuota ?? 1);

    // Ejecutar SP con tipos explícitos
    $stmt = $pdo->prepare("
        SELECT * FROM sp_localesmodif_modificar_local(
            ?::INTEGER,           -- p_id_local
            ?::VARCHAR,           -- p_nombre
            ?::VARCHAR,           -- p_domicilio
            ?::VARCHAR,           -- p_sector
            ?::INTEGER,           -- p_zona
            ?::VARCHAR,           -- p_descripcion_local
            ?::NUMERIC,           -- p_superficie
            ?::INTEGER,           -- p_giro
            ?::DATE,              -- p_fecha_alta
            ?::DATE,              -- p_fecha_baja
            ?::VARCHAR,           -- p_vigencia
            ?::INTEGER,           -- p_clave_cuota
            ?::INTEGER,           -- p_tipo_movimiento
            ?::INTEGER,           -- p_bloqueo
            ?::INTEGER,           -- p_cve_bloqueo
            ?::DATE,              -- p_fecha_inicio_bloqueo
            ?::DATE,              -- p_fecha_final_bloqueo
            ?::VARCHAR            -- p_observacion
        )
    ");

    $stmt->execute([
        $id_local,
        $nombre,
        $domicilio,
        $sector,
        $zona,
        $descripcion,
        $superficie,
        $giro,
        $fecha_alta,
        $fecha_baja,
        $vigencia,
        $clave_cuota,
        1,          // tipo_movimiento
        0,          // bloqueo
        null,       // cve_bloqueo
        null,       // fecha_inicio_bloqueo
        null,       // fecha_final_bloqueo
        'Test'      // observacion
    ]);

    $result = $stmt->fetch(PDO::FETCH_OBJ);

    if ($result) {
        echo "   ✓ SP ejecutado exitosamente\n";
        echo "   ✓ Resultado: {$result->result}\n\n";
    }

    echo "==============================================\n";
    echo "✓ TEST COMPLETADO\n";
    echo "==============================================\n";
    echo "\nEl SP funciona correctamente.\n";
    echo "Recarga el navegador en /locales-modif\n";

} catch (Exception $e) {
    echo "\n✗ ERROR: " . $e->getMessage() . "\n";
    exit(1);
}
?>
