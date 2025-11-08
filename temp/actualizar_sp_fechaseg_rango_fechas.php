<?php
// Actualizar SP_FECHASEG_LIST para incluir filtro de rango de fechas

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== ACTUALIZAR SP_FECHASEG_LIST CON RANGO DE FECHAS ===\n\n";

    // DROP función existente
    echo "🗑️  Eliminando función existente...\n";
    $db->exec("DROP FUNCTION IF EXISTS comun.sp_fechaseg_list(TIMESTAMP, TIMESTAMP)");
    $db->exec("DROP FUNCTION IF EXISTS comun.sp_fechaseg_list()");
    echo "✅ Función eliminada\n\n";

    // Crear SP con parámetros de fecha
    echo "1️⃣  Creando sp_fechaseg_list con parámetros de fecha...\n";
    $db->exec("
        CREATE OR REPLACE FUNCTION comun.sp_fechaseg_list(
            p_fecha_inicio TIMESTAMP DEFAULT NULL,
            p_fecha_fin TIMESTAMP DEFAULT NULL
        )
        RETURNS TABLE (
            id INTEGER,
            t42_doctos_id INTEGER,
            t42_centros_id INTEGER,
            usuario_seg INTEGER,
            fec_seg TIMESTAMP,
            t42_statusseg_id INTEGER,
            observacion VARCHAR,
            usuario_mov CHAR(10)
        ) AS \$\$
        BEGIN
            RETURN QUERY
            SELECT
                s.id,
                s.t42_doctos_id,
                s.t42_centros_id,
                s.usuario_seg,
                s.fec_seg,
                s.t42_statusseg_id,
                s.observacion,
                s.usuario_mov
            FROM comun.t42_seguimiento s
            WHERE 1=1
                AND (p_fecha_inicio IS NULL OR s.fec_seg >= p_fecha_inicio)
                AND (p_fecha_fin IS NULL OR s.fec_seg <= p_fecha_fin)
            ORDER BY s.fec_seg DESC NULLS LAST, s.id DESC
            LIMIT 10000;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_fechaseg_list actualizado con parámetros de fecha\n\n";

    // Probar SP con rango de 6 meses
    echo "🧪 Probando sp_fechaseg_list con rango de 6 meses:\n";
    echo str_repeat("-", 80) . "\n";

    // Calcular fechas (hoy y hace 6 meses)
    $fechaFin = date('Y-m-d 23:59:59');
    $fechaInicio = date('Y-m-d 00:00:00', strtotime('-6 months'));

    echo "📅 Fecha inicio: $fechaInicio\n";
    echo "📅 Fecha fin: $fechaFin\n\n";

    $stmt = $db->prepare("SELECT * FROM comun.sp_fechaseg_list(:fecha_inicio, :fecha_fin) LIMIT 5");
    $stmt->execute([
        'fecha_inicio' => $fechaInicio,
        'fecha_fin' => $fechaFin
    ]);
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "✅ SP ejecutado correctamente\n";
    echo "📊 Total registros obtenidos: " . count($results) . "\n";

    if (count($results) > 0) {
        echo "\nPrimeros 3 registros:\n";
        foreach ($results as $i => $row) {
            if ($i < 3) {
                $fecha = $row['fec_seg'] ?? 'NULL';
                $obs = substr($row['observacion'] ?? '', 0, 40);
                echo ($i + 1) . ". ID: {$row['id']} - Fecha: {$fecha} - Obs: {$obs}\n";
            }
        }
    } else {
        echo "\n⚠️  No se encontraron registros en el rango de fechas especificado\n";
        echo "Probando sin filtro de fechas...\n";

        $stmt2 = $db->query("SELECT * FROM comun.sp_fechaseg_list(NULL, NULL) LIMIT 3");
        $results2 = $stmt2->fetchAll(PDO::FETCH_ASSOC);
        echo "📊 Total sin filtro: " . count($results2) . " registros\n";
    }

    echo str_repeat("-", 80) . "\n\n";

    echo "✅ SP ACTUALIZADO EXITOSAMENTE\n";
    echo "\nUso del SP:\n";
    echo "  - sp_fechaseg_list(NULL, NULL) - Sin filtro de fechas\n";
    echo "  - sp_fechaseg_list('2024-01-01', '2024-12-31') - Con rango de fechas\n";
    echo "  - sp_fechaseg_list('2024-06-01', NULL) - Desde fecha específica\n";
    echo "  - sp_fechaseg_list(NULL, '2024-12-31') - Hasta fecha específica\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
