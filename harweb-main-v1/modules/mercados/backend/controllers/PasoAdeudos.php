<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PasoAdeudosController extends Controller
{
    /**
     * Ejecuta acciones según el eRequest recibido.
     * Endpoint único: /api/execute
     */
    public function execute(Request $request)
    {
        $action = $request->input('eRequest.action');
        $params = $request->input('eRequest.params', []);
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'getTianguisLocales':
                    $response['data'] = $this->getTianguisLocales($params);
                    $response['success'] = true;
                    break;
                case 'generarAdeudos':
                    $response['data'] = $this->generarAdeudos($params);
                    $response['success'] = true;
                    break;
                case 'insertarAdeudos':
                    $response['data'] = $this->insertarAdeudos($params);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }

        return response()->json(['eResponse' => $response]);
    }

    /**
     * Obtiene los locales del tianguis para un año dado
     */
    private function getTianguisLocales($params)
    {
        $ano = $params['ano'] ?? date('Y');
        $locales = DB::select('SELECT b.clave_cuota, b.importe_cuota, a.* FROM ta_11_locales a, ta_11_cuo_locales b WHERE a.num_mercado=214 AND b.axo=? AND b.clave_cuota=a.clave_cuota', [$ano]);
        return $locales;
    }

    /**
     * Genera la matriz de adeudos para los locales del tianguis
     */
    private function generarAdeudos($params)
    {
        $ano = $params['ano'] ?? date('Y');
        $trimestre = $params['trimestre'] ?? 1;
        $usuario_id = $params['usuario_id'] ?? 1;
        $fecha_actual = now();
        $locales = $this->getTianguisLocales(['ano' => $ano]);
        $adeudos = [];
        $i = 1;
        foreach ($locales as $local) {
            $adeudo = (
                floatval($local->superficie) * floatval($local->importe_cuota)
            ) * 13;
            $adeudos[] = [
                'registro' => $i,
                'id_local' => $local->id_local,
                'ano' => $ano,
                'periodo' => $trimestre,
                'importe' => $adeudo,
                'actualizacion' => $fecha_actual,
                'id_usuario' => $usuario_id
            ];
            $i++;
        }
        return $adeudos;
    }

    /**
     * Inserta los adeudos generados en la base de datos
     */
    private function insertarAdeudos($params)
    {
        $adeudos = $params['adeudos'] ?? [];
        $insertados = 0;
        DB::beginTransaction();
        try {
            foreach ($adeudos as $adeudo) {
                DB::statement('CALL sp_insertar_adeudo_local(?, ?, ?, ?, ?, ?)', [
                    $adeudo['id_local'],
                    $adeudo['ano'],
                    $adeudo['periodo'],
                    $adeudo['importe'],
                    $adeudo['actualizacion'],
                    $adeudo['id_usuario']
                ]);
                $insertados++;
            }
            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            throw $e;
        }
        return ['insertados' => $insertados];
    }
}
