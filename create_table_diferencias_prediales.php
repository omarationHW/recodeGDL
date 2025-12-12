<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== CREANDO TABLA diferencias_prediales ===\n\n";

// Crear tabla
$sql = "
CREATE TABLE IF NOT EXISTS public.diferencias_prediales (
    id SERIAL PRIMARY KEY,
    axo INTEGER NOT NULL,
    cvecuenta INTEGER NOT NULL,
    monto NUMERIC(12, 2) NOT NULL,
    status VARCHAR(1) DEFAULT 'A',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_status CHECK (status IN ('A', 'I'))
);

CREATE INDEX IF NOT EXISTS idx_dif_prediales_axo ON public.diferencias_prediales(axo);
CREATE INDEX IF NOT EXISTS idx_dif_prediales_cuenta ON public.diferencias_prediales(cvecuenta);
CREATE INDEX IF NOT EXISTS idx_dif_prediales_status ON public.diferencias_prediales(status);
";

try {
    $pdo->exec($sql);
    echo "✅ Tabla 'diferencias_prediales' creada exitosamente en esquema public\n\n";

    // Insertar datos de prueba
    $insertSql = "
    INSERT INTO public.diferencias_prediales (axo, cvecuenta, monto, status)
    VALUES
        (2024, 100001, 1500.00, 'A'),
        (2024, 100002, 2300.50, 'A'),
        (2024, 100003, 980.75, 'A'),
        (2025, 100004, 1750.00, 'A'),
        (2025, 100005, 3200.25, 'A'),
        (2024, 100006, 1200.00, 'I'),
        (2025, 100007, 890.50, 'A'),
        (2025, 100008, 2100.00, 'A')
    ON CONFLICT DO NOTHING;
    ";

    $pdo->exec($insertSql);
    echo "✅ Datos de prueba insertados\n\n";

    // Verificar datos
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.diferencias_prediales");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "📊 Total de registros: {$result['total']}\n\n";

    // Mostrar ejemplos
    echo "📋 Ejemplos de registros:\n";
    $stmt = $pdo->query("
        SELECT id, axo, cvecuenta, monto, status,
               TO_CHAR(fecha_registro, 'YYYY-MM-DD HH24:MI:SS') as fecha_registro
        FROM public.diferencias_prediales
        ORDER BY id
        LIMIT 5
    ");

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  ID: {$row['id']} | Año: {$row['axo']} | Cuenta: {$row['cvecuenta']} | ";
        echo "Monto: $" . number_format($row['monto'], 2) . " | Status: {$row['status']} | ";
        echo "Fecha: {$row['fecha_registro']}\n";
    }

    // Estadísticas
    echo "\n📈 Estadísticas:\n";
    $stmt = $pdo->query("
        SELECT
            axo,
            COUNT(*) as cantidad,
            SUM(monto) as total_monto,
            COUNT(CASE WHEN status = 'A' THEN 1 END) as activos,
            COUNT(CASE WHEN status = 'I' THEN 1 END) as inactivos
        FROM public.diferencias_prediales
        GROUP BY axo
        ORDER BY axo
    ");

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  Año {$row['axo']}: {$row['cantidad']} registros | ";
        echo "Total: $" . number_format($row['total_monto'], 2) . " | ";
        echo "Activos: {$row['activos']} | Inactivos: {$row['inactivos']}\n";
    }

} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
