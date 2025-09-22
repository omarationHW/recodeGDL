<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Crear vista para proyectos con adeudos
        DB::statement("
            CREATE OR REPLACE VIEW pavimentacion.v_proyectos_con_adeudos AS
            SELECT 
                o.id_control,
                o.contrato,
                o.nombre,
                o.calle,
                o.metros,
                o.costomtr,
                o.costototal,
                o.tipo_pavimento,
                CASE 
                    WHEN o.tipo_pavimento = 'A' THEN 'ASFALTO'
                    ELSE 'CONCRETO HIDRAULICO'
                END AS pavimento_descripcion,
                COALESCE(SUM(a.mensualidad) FILTER (WHERE a.estado = 'V'), 0) AS adeudo_total,
                COUNT(a.id_adeudo) AS total_mensualidades,
                COUNT(a.id_adeudo) FILTER (WHERE a.estado = 'P') AS mensualidades_pagadas,
                COUNT(a.id_adeudo) FILTER (WHERE a.estado = 'V') AS mensualidades_pendientes,
                o.created_at,
                o.updated_at
            FROM 
                pavimentacion.ta_99_proyecto_obra_pavimiento o
                LEFT JOIN pavimentacion.ta_99_adeudos_obra a ON a.id_control = o.id_control
            GROUP BY 
                o.id_control, o.contrato, o.nombre, o.calle, o.metros, 
                o.costomtr, o.costototal, o.tipo_pavimento, o.created_at, o.updated_at
            ORDER BY 
                o.contrato;
        ");

        // Crear vista para estadísticas generales
        DB::statement("
            CREATE OR REPLACE VIEW pavimentacion.v_estadisticas_generales AS
            SELECT 
                COUNT(DISTINCT o.id_control) AS total_contratos,
                SUM(o.costototal) AS inversion_total,
                SUM(COALESCE(a.adeudo_pendiente, 0)) AS adeudo_total,
                SUM(COALESCE(a.monto_pagado, 0)) AS monto_pagado_total,
                COUNT(DISTINCT CASE WHEN o.tipo_pavimento = 'A' THEN o.id_control END) AS contratos_asfalto,
                COUNT(DISTINCT CASE WHEN o.tipo_pavimento = 'H' THEN o.id_control END) AS contratos_concreto
            FROM 
                pavimentacion.ta_99_proyecto_obra_pavimiento o
                LEFT JOIN (
                    SELECT 
                        id_control,
                        SUM(CASE WHEN estado = 'V' THEN mensualidad ELSE 0 END) AS adeudo_pendiente,
                        SUM(CASE WHEN estado = 'P' THEN mensualidad ELSE 0 END) AS monto_pagado
                    FROM pavimentacion.ta_99_adeudos_obra
                    GROUP BY id_control
                ) a ON a.id_control = o.id_control;
        ");
    }

    public function down(): void
    {
        DB::statement('DROP VIEW IF EXISTS pavimentacion.v_proyectos_con_adeudos');
        DB::statement('DROP VIEW IF EXISTS pavimentacion.v_estadisticas_generales');
    }
};