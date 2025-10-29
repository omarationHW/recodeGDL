<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Crear función para alta de registro (equivalente al stored procedure)
        DB::statement("
            CREATE OR REPLACE FUNCTION pavimentacion.sp_99_altaregistro(
                p_contrato INTEGER,
                p_nombre VARCHAR(100),
                p_calle VARCHAR(100),
                p_metros DECIMAL(5,2),
                p_costomtr DECIMAL(18,2),
                p_tipo CHAR(1)
            )
            RETURNS TABLE(estado INTEGER, mensaje VARCHAR(100))
            LANGUAGE plpgsql
            AS $\$
            DECLARE
                v_idcontrol INTEGER;
                v_costototal DECIMAL(18,2);
                v_mensualidad DECIMAL(18,2);
                v_cont INTEGER;
            BEGIN
                -- Verificar si existe el contrato
                IF EXISTS (SELECT 1 FROM pavimentacion.ta_99_proyecto_obra_pavimiento WHERE contrato = p_contrato) THEN
                    RETURN QUERY SELECT -1, 'Ya existe el numero de contrato.. Verifica'::VARCHAR(100);
                    RETURN;
                END IF;
                
                -- Calcular costo total
                v_costototal := p_metros * p_costomtr;
                
                -- Insertar proyecto
                INSERT INTO pavimentacion.ta_99_proyecto_obra_pavimiento 
                    (contrato, nombre, calle, metros, costomtr, costototal, tipo_pavimento)
                VALUES 
                    (p_contrato, p_nombre, p_calle, p_metros, p_costomtr, v_costototal, p_tipo)
                RETURNING id_control INTO v_idcontrol;
                
                -- Calcular mensualidad
                v_mensualidad := v_costototal / 12;
                
                -- Insertar 12 mensualidades
                FOR v_cont IN 1..12 LOOP
                    INSERT INTO pavimentacion.ta_99_adeudos_obra 
                        (id_control, axo, mes, mensualidad, numero_recibo, estado)
                    VALUES 
                        (v_idcontrol, EXTRACT(YEAR FROM CURRENT_DATE), v_cont, v_mensualidad, NULL, 'V');
                END LOOP;
                
                RETURN QUERY SELECT 0, 'El contrato se registro correctamente'::VARCHAR(100);
            END;
            $\$;
        ");

        // Crear función para obtener resumen de adeudos
        DB::statement("
            CREATE OR REPLACE FUNCTION pavimentacion.obtener_resumen_adeudos(p_id_control INTEGER)
            RETURNS TABLE(
                total_mensualidades INTEGER,
                mensualidades_pagadas INTEGER,
                mensualidades_pendientes INTEGER,
                monto_pagado DECIMAL(18,2),
                monto_pendiente DECIMAL(18,2)
            )
            LANGUAGE plpgsql
            AS $\$
            BEGIN
                RETURN QUERY
                SELECT 
                    COUNT(*)::INTEGER AS total_mensualidades,
                    COUNT(*) FILTER (WHERE estado = 'P')::INTEGER AS mensualidades_pagadas,
                    COUNT(*) FILTER (WHERE estado = 'V')::INTEGER AS mensualidades_pendientes,
                    COALESCE(SUM(mensualidad) FILTER (WHERE estado = 'P'), 0) AS monto_pagado,
                    COALESCE(SUM(mensualidad) FILTER (WHERE estado = 'V'), 0) AS monto_pendiente
                FROM pavimentacion.ta_99_adeudos_obra
                WHERE id_control = p_id_control;
            END;
            $\$;
        ");

        // Crear función para registrar pago
        DB::statement("
            CREATE OR REPLACE FUNCTION pavimentacion.registrar_pago(
                p_id_adeudo INTEGER,
                p_numero_recibo VARCHAR(20)
            )
            RETURNS BOOLEAN
            LANGUAGE plpgsql
            AS $\$
            BEGIN
                UPDATE pavimentacion.ta_99_adeudos_obra
                SET estado = 'P', 
                    numero_recibo = p_numero_recibo,
                    updated_at = CURRENT_TIMESTAMP
                WHERE id_adeudo = p_id_adeudo AND estado = 'V';
                
                RETURN FOUND;
            END;
            $\$;
        ");
    }

    public function down(): void
    {
        DB::statement('DROP FUNCTION IF EXISTS pavimentacion.sp_99_altaregistro(INTEGER, VARCHAR(100), VARCHAR(100), DECIMAL(5,2), DECIMAL(18,2), CHAR(1))');
        DB::statement('DROP FUNCTION IF EXISTS pavimentacion.obtener_resumen_adeudos(INTEGER)');
        DB::statement('DROP FUNCTION IF EXISTS pavimentacion.registrar_pago(INTEGER, VARCHAR(20))');
    }
};