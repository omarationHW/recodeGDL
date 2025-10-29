<?php

namespace App\Services;

use App\Models\ProyectoObra;
use App\Models\AdeudoObra;
use Illuminate\Support\Facades\DB;

class ProyectoObraService
{
    public function crearProyecto(array $datos): array
    {
        // Usar la función stored procedure de PostgreSQL para crear el proyecto
        // Esto garantiza consistencia con la lógica de negocio implementada en la BD
        $resultado = DB::select('SELECT * FROM pavimentacion.sp_99_altaregistro(?, ?, ?, ?, ?, ?)', [
            $datos['contrato'],
            $datos['nombre'],
            $datos['calle'],
            $datos['metros'],
            $datos['costomtr'],
            $datos['tipo_pavimento']
        ]);

        $respuesta = $resultado[0];

        if ($respuesta->estado === -1) {
            throw new \Exception($respuesta->mensaje);
        }

        // Obtener el proyecto creado con sus adeudos
        $proyecto = ProyectoObra::with('adeudos')
            ->where('contrato', $datos['contrato'])
            ->first();

        return [
            'proyecto' => $proyecto,
            'mensaje' => $respuesta->mensaje
        ];
    }

    public function actualizarProyecto(int $id, array $datos): array
    {
        // Buscar el proyecto por ID
        $proyecto = ProyectoObra::findOrFail($id);
        
        // Verificar si el número de contrato ya existe en otro proyecto
        $contratoExistente = ProyectoObra::where('contrato', $datos['contrato'])
            ->where('id_control', '!=', $id)
            ->first();
        
        if ($contratoExistente) {
            throw new \Exception('El número de contrato ya existe en otro proyecto');
        }

        DB::beginTransaction();
        
        try {
            // Calcular el nuevo costo total
            $costoTotal = $datos['metros'] * $datos['costomtr'];
            
            // Actualizar el proyecto
            $proyecto->update([
                'contrato' => $datos['contrato'],
                'nombre' => $datos['nombre'],
                'calle' => $datos['calle'],
                'metros' => $datos['metros'],
                'costomtr' => $datos['costomtr'],
                'costototal' => $costoTotal,
                'tipo_pavimento' => $datos['tipo_pavimento']
            ]);

            // Si el costo total cambió, necesitamos recalcular los adeudos
            if ($proyecto->wasChanged('costototal')) {
                // Eliminar adeudos existentes que no han sido pagados
                AdeudoObra::where('id_control', $id)
                    ->where('estado', 'V') // Solo los pendientes
                    ->delete();
                
                // Crear nuevos adeudos basados en el nuevo costo total
                $mensualidad = $costoTotal / 12; // Dividir en 12 mensualidades
                
                for ($mes = 1; $mes <= 12; $mes++) {
                    AdeudoObra::create([
                        'id_control' => $id,
                        'mes' => $mes,
                        'axo' => 2025,
                        'mensualidad' => $mensualidad,
                        'estado' => 'V' // Vencido/Pendiente
                    ]);
                }
            }
            
            DB::commit();
            
            // Obtener el proyecto actualizado con sus adeudos
            $proyectoActualizado = ProyectoObra::with('adeudos')->find($id);
            
            return [
                'proyecto' => $proyectoActualizado,
                'mensaje' => 'Proyecto actualizado exitosamente'
            ];
            
        } catch (\Exception $e) {
            DB::rollback();
            throw $e;
        }
    }

    public function obtenerEstadisticas(): array
    {
        // Usar la vista de estadísticas generales
        $estadisticas = DB::select('SELECT * FROM pavimentacion.v_estadisticas_generales')[0];

        return [
            'total_contratos' => $estadisticas->total_contratos,
            'inversion_total' => floatval($estadisticas->inversion_total),
            'adeudo_total' => floatval($estadisticas->adeudo_total),
            'monto_pagado_total' => floatval($estadisticas->monto_pagado_total),
            'contratos_asfalto' => $estadisticas->contratos_asfalto,
            'contratos_concreto' => $estadisticas->contratos_concreto
        ];
    }

    public function obtenerResumenAdeudos(int $idControl): array
    {
        $resumen = DB::select('SELECT * FROM pavimentacion.obtener_resumen_adeudos(?)', [$idControl]);
        
        if (empty($resumen)) {
            return [
                'total_mensualidades' => 0,
                'mensualidades_pagadas' => 0,
                'mensualidades_pendientes' => 0,
                'monto_pagado' => 0,
                'monto_pendiente' => 0
            ];
        }

        $data = $resumen[0];
        return [
            'total_mensualidades' => $data->total_mensualidades,
            'mensualidades_pagadas' => $data->mensualidades_pagadas,
            'mensualidades_pendientes' => $data->mensualidades_pendientes,
            'monto_pagado' => floatval($data->monto_pagado),
            'monto_pendiente' => floatval($data->monto_pendiente)
        ];
    }

    public function registrarPago(int $idAdeudo, string $numeroRecibo): bool
    {
        $resultado = DB::select('SELECT pavimentacion.registrar_pago(?, ?) as success', [
            $idAdeudo, $numeroRecibo
        ]);

        return $resultado[0]->success;
    }

    public function obtenerProyectosOptimizado(): array
    {
        // Usar la vista optimizada en lugar de hacer múltiples queries
        $proyectos = DB::select('SELECT * FROM pavimentacion.v_proyectos_con_adeudos');
        
        return array_map(function($proyecto) {
            return [
                'id_control' => $proyecto->id_control,
                'contrato' => $proyecto->contrato,
                'nombre' => $proyecto->nombre,
                'calle' => $proyecto->calle,
                'metros' => floatval($proyecto->metros),
                'costomtr' => floatval($proyecto->costomtr),
                'costototal' => floatval($proyecto->costototal),
                'tipo_pavimento' => $proyecto->tipo_pavimento,
                'pavimento_descripcion' => $proyecto->pavimento_descripcion,
                'adeudo_total' => floatval($proyecto->adeudo_total),
                'total_mensualidades' => $proyecto->total_mensualidades,
                'mensualidades_pagadas' => $proyecto->mensualidades_pagadas,
                'mensualidades_pendientes' => $proyecto->mensualidades_pendientes,
                'created_at' => $proyecto->created_at,
                'updated_at' => $proyecto->updated_at
            ];
        }, $proyectos);
    }
}