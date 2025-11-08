<?php
// Actualizar SP_FECHASEG_LIST sin límite de registros

try {
    $db = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=padron_licencias', 'refact', 'FF)-BQk2');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "=== ACTUALIZAR SP_FECHASEG_LIST SIN LÍMITE ===\n\n";

    // DROP función existente
    echo "🗑️  Eliminando función existente...\n";
    $db->exec("DROP FUNCTION IF EXISTS comun.sp_fechaseg_list(TIMESTAMP, TIMESTAMP)");
    echo "✅ Función eliminada\n\n";

    // Crear SP sin límite
    echo "1️⃣  Creando sp_fechaseg_list SIN LÍMITE...\n";
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
            ORDER BY s.fec_seg DESC NULLS LAST, s.id DESC;
        END;
        \$\$ LANGUAGE plpgsql;
    ");
    echo "✅ sp_fechaseg_list actualizado SIN LÍMITE\n\n";

    // Probar SP sin filtro para traer todos
    echo "🧪 Probando sp_fechaseg_list SIN filtro de fechas:\n";
    echo str_repeat("-", 80) . "\n";

    $stmt = $db->query("SELECT * FROM comun.sp_fechaseg_list(NULL, NULL) LIMIT 5");
    $results = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo "✅ SP ejecutado correctamente\n";
    echo "📊 Total registros obtenidos (muestra): " . count($results) . "\n";

    if (count($results) > 0) {
        echo "\nPrimeros 3 registros:\n";
        foreach ($results as $i => $row) {
            if ($i < 3) {
                $fecha = $row['fec_seg'] ?? 'NULL';
                $obs = substr($row['observacion'] ?? '', 0, 40);
                echo ($i + 1) . ". ID: {$row['id']} - Fecha: {$fecha} - Obs: {$obs}\n";
            }
        }
    }
    echo str_repeat("-", 80) . "\n\n";

    // Contar total de registros en la tabla
    $stmt2 = $db->query("SELECT COUNT(*) as total FROM comun.t42_seguimiento");
    $total = $stmt2->fetch(PDO::FETCH_ASSOC)['total'];
    echo "📊 Total registros en tabla t42_seguimiento: " . number_format($total) . "\n\n";

    echo "✅ SP ACTUALIZADO EXITOSAMENTE (SIN LÍMITE)\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
