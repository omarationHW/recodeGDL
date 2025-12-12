<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== CREANDO TABLA relacion_mensual ===\n\n";

// Crear tabla
$sql = "
DROP TABLE IF EXISTS publico.relacion_mensual CASCADE;

CREATE TABLE publico.relacion_mensual (
    id SERIAL PRIMARY KEY,
    dependencia INTEGER NOT NULL,
    nombre_dependencia VARCHAR(200) NOT NULL,
    mes INTEGER NOT NULL CHECK (mes BETWEEN 1 AND 12),
    anio INTEGER NOT NULL,
    cantidad_multas INTEGER DEFAULT 0,
    total_multas NUMERIC(12,2) DEFAULT 0,
    total_gastos NUMERIC(12,2) DEFAULT 0,
    total_general NUMERIC(12,2) DEFAULT 0,
    fecha_registro DATE DEFAULT CURRENT_DATE
);

CREATE INDEX idx_relmes_dependencia ON publico.relacion_mensual(dependencia);
CREATE INDEX idx_relmes_periodo ON publico.relacion_mensual(mes, anio);
CREATE INDEX idx_relmes_anio ON publico.relacion_mensual(anio);
";

$pdo->exec($sql);
echo "✅ Tabla relacion_mensual creada\n\n";

// Generar datos de prueba para 2024 y 2025
$dependencias = [
    ['id' => 3, 'nombre' => 'Tránsito y Vialidad'],
    ['id' => 7, 'nombre' => 'Reglamentos Municipales'],
    ['id' => 5, 'nombre' => 'Protección Civil'],
    ['id' => 8, 'nombre' => 'Ecología'],
    ['id' => 10, 'nombre' => 'Obras Públicas']
];

$stmt = $pdo->prepare("
    INSERT INTO publico.relacion_mensual
    (dependencia, nombre_dependencia, mes, anio, cantidad_multas, total_multas, total_gastos, total_general)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
");

$count = 0;

// Generar datos para 2024 (año completo)
foreach ([2024, 2025] as $anio) {
    foreach (range(1, 12) as $mes) {
        foreach ($dependencias as $dep) {
            // Solo generar datos hasta el mes actual en 2025
            if ($anio == 2025 && $mes > 12) continue;

            // Variar la cantidad según la dependencia y mes
            $base_multas = match($dep['id']) {
                3 => rand(80, 150),   // Tránsito - más multas
                7 => rand(50, 100),   // Reglamentos
                5 => rand(20, 50),    // Protección Civil
                8 => rand(30, 60),    // Ecología
                10 => rand(15, 40),   // Obras Públicas
                default => rand(20, 50)
            };

            // Variación por temporada (más multas en vacaciones)
            $factor_temporada = in_array($mes, [7, 8, 12]) ? 1.3 : 1.0;

            $cantidad = round($base_multas * $factor_temporada);
            $promedio_multa = rand(1200, 3500);
            $total_multas = $cantidad * $promedio_multa;
            $total_gastos = $total_multas * (rand(5, 15) / 100); // 5-15% de gastos
            $total_general = $total_multas + $total_gastos;

            $stmt->execute([
                $dep['id'],
                $dep['nombre'],
                $mes,
                $anio,
                $cantidad,
                $total_multas,
                $total_gastos,
                $total_general
            ]);
            $count++;
        }
    }
}

echo "✅ Insertados $count registros de multas mensuales\n\n";

// Estadísticas por año
foreach ([2024, 2025] as $anio) {
    echo "=== ESTADÍSTICAS $anio ===\n";
    $stats = $pdo->query("
        SELECT
            dependencia,
            nombre_dependencia,
            SUM(cantidad_multas) as total_cantidad,
            SUM(total_multas) as total_multas_año,
            SUM(total_gastos) as total_gastos_año,
            SUM(total_general) as total_general_año
        FROM publico.relacion_mensual
        WHERE anio = $anio
        GROUP BY dependencia, nombre_dependencia
        ORDER BY dependencia
    ")->fetchAll(PDO::FETCH_ASSOC);

    foreach ($stats as $stat) {
        echo "  Dep {$stat['dependencia']} ({$stat['nombre_dependencia']}):\n";
        echo "    - Multas: {$stat['total_cantidad']}\n";
        echo "    - Total Multas: $" . number_format($stat['total_multas_año'], 2) . "\n";
        echo "    - Total Gastos: $" . number_format($stat['total_gastos_año'], 2) . "\n";
        echo "    - Total General: $" . number_format($stat['total_general_año'], 2) . "\n\n";
    }
}

echo "✅ Tabla relacion_mensual lista!\n";
