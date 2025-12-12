<?php
$pdo = new PDO("pgsql:host=192.168.6.146;dbname=multas_reglamentos", "refact", "FF)-BQk2");
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

echo "=== CREANDO TABLA catastro_dm ===\n\n";

// Crear tabla
$sql = "
CREATE TABLE IF NOT EXISTS public.catastro_dm (
    id SERIAL PRIMARY KEY,
    clave_cuenta VARCHAR(50) NOT NULL,
    propietario VARCHAR(200) NOT NULL,
    domicilio VARCHAR(300),
    colonia VARCHAR(100),
    ejercicio INTEGER NOT NULL,
    status VARCHAR(1) DEFAULT 'A',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_catastro_status CHECK (status IN ('A', 'I'))
);

CREATE INDEX IF NOT EXISTS idx_catastro_dm_cuenta ON public.catastro_dm(clave_cuenta);
CREATE INDEX IF NOT EXISTS idx_catastro_dm_ejercicio ON public.catastro_dm(ejercicio);
CREATE INDEX IF NOT EXISTS idx_catastro_dm_status ON public.catastro_dm(status);
CREATE INDEX IF NOT EXISTS idx_catastro_dm_propietario ON public.catastro_dm(propietario);
CREATE INDEX IF NOT EXISTS idx_catastro_dm_colonia ON public.catastro_dm(colonia);
";

try {
    $pdo->exec($sql);
    echo "✅ Tabla 'catastro_dm' creada exitosamente en esquema public\n\n";

    // Insertar datos de prueba realistas
    $colonias = [
        'Centro', 'Americana', 'Lafayette', 'Chapultepec', 'Providencia',
        'Santa Teresita', 'Mezquitán', 'Oblatos', 'Analco', 'El Retiro',
        'Moderna', 'Jardines del Bosque', 'Chapalita', 'Ciudad del Sol'
    ];

    $nombres = [
        'Juan Pérez García', 'María González López', 'Carlos Rodríguez Martínez',
        'Ana Hernández Sánchez', 'Luis Ramírez Torres', 'Patricia Flores Morales',
        'José Mendoza Cruz', 'Laura Vargas Ruiz', 'Miguel Castillo Jiménez',
        'Carmen Ortiz Gutiérrez', 'Francisco Díaz Medina', 'Rosa Rivera Domínguez',
        'Antonio Moreno Chávez', 'Isabel Romero Herrera', 'Pedro Soto Aguilar',
        'Gabriela Castro Vega', 'Roberto Reyes Márquez', 'Silvia Guerrero Campos',
        'Eduardo Torres Navarro', 'Verónica Luna Ríos', 'Alejandro Núñez Silva',
        'Mónica Ortega Ramos', 'Ricardo Delgado Sandoval', 'Diana Mendez Vargas'
    ];

    $calles = [
        'Av. Juárez', 'Calle Morelos', 'Av. Hidalgo', 'Calle Insurgentes',
        'Av. Chapultepec', 'Calle 8 de Julio', 'Av. América', 'Calle Libertad',
        'Av. Vallarta', 'Calle Maestranza', 'Av. México', 'Calle Pavo',
        'Av. Patria', 'Calle San Felipe', 'Av. López Mateos'
    ];

    echo "🏠 Generando 100 registros de catastro...\n";

    $insertedRecords = [];
    for ($i = 0; $i < 100; $i++) {
        $clave = str_pad(1000000 + $i, 7, '0', STR_PAD_LEFT);
        $nombre = $nombres[array_rand($nombres)];
        $calle = $calles[array_rand($calles)];
        $numero = rand(100, 9999);
        $domicilio = "$calle #$numero";
        $colonia = $colonias[array_rand($colonias)];

        // 80% de registros en 2024, 20% en 2025
        $ejercicio = (rand(1, 100) <= 80) ? 2024 : 2025;

        // 95% activos, 5% inactivos
        $status = (rand(1, 100) <= 95) ? 'A' : 'I';

        $insertedRecords[] = [
            'clave' => $clave,
            'nombre' => $nombre,
            'domicilio' => $domicilio,
            'colonia' => $colonia,
            'ejercicio' => $ejercicio,
            'status' => $status
        ];
    }

    // Insertar en lotes
    $pdo->beginTransaction();
    $stmt = $pdo->prepare("
        INSERT INTO public.catastro_dm (clave_cuenta, propietario, domicilio, colonia, ejercicio, status)
        VALUES (?, ?, ?, ?, ?, ?)
    ");

    foreach ($insertedRecords as $record) {
        $stmt->execute([
            $record['clave'],
            $record['nombre'],
            $record['domicilio'],
            $record['colonia'],
            $record['ejercicio'],
            $record['status']
        ]);
    }

    $pdo->commit();
    echo "✅ 100 registros insertados exitosamente\n\n";

    // Verificar datos
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM public.catastro_dm");
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "📊 Total de registros: {$result['total']}\n\n";

    // Estadísticas
    echo "📈 Estadísticas:\n\n";

    echo "Por Ejercicio:\n";
    $stmt = $pdo->query("
        SELECT
            ejercicio,
            COUNT(*) as cantidad,
            COUNT(CASE WHEN status = 'A' THEN 1 END) as activos,
            COUNT(CASE WHEN status = 'I' THEN 1 END) as inactivos
        FROM public.catastro_dm
        GROUP BY ejercicio
        ORDER BY ejercicio
    ");

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  Ejercicio {$row['ejercicio']}: {$row['cantidad']} registros ";
        echo "({$row['activos']} activos, {$row['inactivos']} inactivos)\n";
    }

    echo "\nPor Colonia (Top 5):\n";
    $stmt = $pdo->query("
        SELECT
            colonia,
            COUNT(*) as cantidad
        FROM public.catastro_dm
        WHERE status = 'A'
        GROUP BY colonia
        ORDER BY cantidad DESC
        LIMIT 5
    ");

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  {$row['colonia']}: {$row['cantidad']} cuentas\n";
    }

    echo "\n📋 Ejemplos de registros:\n";
    $stmt = $pdo->query("
        SELECT clave_cuenta, propietario, domicilio, colonia, ejercicio, status
        FROM public.catastro_dm
        ORDER BY id
        LIMIT 5
    ");

    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        echo "  Cuenta: {$row['clave_cuenta']} | {$row['propietario']}\n";
        echo "    {$row['domicilio']}, Col. {$row['colonia']}\n";
        echo "    Ejercicio: {$row['ejercicio']} | Status: {$row['status']}\n\n";
    }

} catch (Exception $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    echo "❌ Error: " . $e->getMessage() . "\n";
}
