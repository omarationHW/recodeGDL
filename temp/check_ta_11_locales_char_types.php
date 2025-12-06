<?php
echo "==============================================\n";
echo "ESTRUCTURA: publico.ta_11_locales\n";
echo "Campos con restricción de longitud\n";
echo "==============================================\n\n";

$pdo = new PDO('pgsql:host=192.168.6.146;port=5432;dbname=mercados', 'refact', 'FF)-BQk2', [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
]);

$query = "
    SELECT
        column_name,
        data_type,
        character_maximum_length,
        CASE
            WHEN data_type = 'character' THEN 'char(' || character_maximum_length || ')'
            WHEN data_type = 'character varying' THEN 'varchar(' || COALESCE(character_maximum_length::text, 'unlimited') || ')'
            ELSE data_type
        END as full_type
    FROM information_schema.columns
    WHERE table_schema = 'publico'
      AND table_name = 'ta_11_locales'
    ORDER BY ordinal_position
";

$result = $pdo->query($query)->fetchAll(PDO::FETCH_ASSOC);

echo "Campos que estamos actualizando en el SP:\n\n";

$fieldsInUpdate = [
    'nombre', 'domicilio', 'sector', 'zona', 'descripcion_local',
    'superficie', 'giro', 'fecha_alta', 'fecha_baja', 'vigencia',
    'clave_cuota', 'bloqueo', 'observacion'
];

foreach ($result as $col) {
    if (in_array($col['column_name'], $fieldsInUpdate)) {
        $warning = '';
        if ($col['data_type'] === 'character' && $col['character_maximum_length'] <= 2) {
            $warning = ' ⚠️ RESTRICCIÓN ESTRICTA';
        }
        echo str_pad($col['column_name'], 25) . " => " . str_pad($col['full_type'], 20) . $warning . "\n";
    }
}

echo "\n==============================================\n";
echo "IMPORTANTE\n";
echo "==============================================\n";
echo "Los campos char(1) y char(2) tienen longitud fija.\n";
echo "Si enviamos un valor más largo, PostgreSQL lo rechaza.\n";
