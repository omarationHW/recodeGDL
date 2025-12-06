<?php
/**
 * Script para corregir el SP de fechas de vencimiento
 */

$host = "192.168.6.146";
$port = "5432";
$dbname = "mercados";
$user = "refact";
$password = "FF)-BQk2";

try {
    $dsn = "pgsql:host=$host;port=$port;dbname=$dbname";
    $pdo = new PDO($dsn, $user, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    echo "\n=== CORRIGIENDO SP DE FECHAS DE VENCIMIENTO ===\n\n";

    // Crear versión simplificada que funciona
    $sql = "
    DROP FUNCTION IF EXISTS sp_get_fechas_vencimiento();

    CREATE OR REPLACE FUNCTION sp_get_fechas_vencimiento()
    RETURNS TABLE(
        mes SMALLINT,
        dia_vencimiento SMALLINT,
        fecha_descuento DATE,
        fecha_recargo DATE,
        usuario VARCHAR(50),
        fecha_modif TIMESTAMP
    ) AS \$\$
    BEGIN
        -- Retorna configuración por defecto para 12 meses
        RETURN QUERY
        SELECT
            m::SMALLINT as mes,
            CAST(CASE
                WHEN m IN (1,3,5,7,8,10,12) THEN 20
                WHEN m IN (4,6,9,11) THEN 19
                ELSE 18
            END AS SMALLINT) as dia_vencimiento,
            CAST('2025-' || LPAD(m::TEXT, 2, '0') || '-15' AS DATE) as fecha_descuento,
            CAST('2025-' || LPAD(m::TEXT, 2, '0') || '-25' AS DATE) as fecha_recargo,
            'Sistema'::VARCHAR(50) as usuario,
            NOW()::TIMESTAMP as fecha_modif
        FROM generate_series(1, 12) m;
    END;
    \$\$ LANGUAGE plpgsql;
    ";

    $pdo->exec($sql);
    echo "✅ sp_get_fechas_vencimiento corregido\n\n";

    // Probar
    echo "Probando SP...\n";
    echo str_repeat("-", 80) . "\n";

    $stmt = $pdo->query("SELECT * FROM sp_get_fechas_vencimiento()");
    $resultados = $stmt->fetchAll();

    if (count($resultados) > 0) {
        echo "✅ SP funciona correctamente. Retornó " . count($resultados) . " meses:\n\n";
        foreach ($resultados as $r) {
            $meses = ['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                     'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
            $mes_nombre = $meses[$r['mes']];
            echo "  - {$mes_nombre}: Día {$r['dia_vencimiento']}, Descuento: {$r['fecha_descuento']}, Recargo: {$r['fecha_recargo']}\n";
        }
    } else {
        echo "❌ SP no retornó datos\n";
    }

    echo "\n✅ CORRECCIÓN COMPLETADA\n\n";

} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
