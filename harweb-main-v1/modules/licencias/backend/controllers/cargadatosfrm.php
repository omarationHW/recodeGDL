<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class CargaDatosController extends Controller
{
    /**
     * Endpoint unificado para ejecutar acciones (eRequest/eResponse)
     * Ruta: POST /api/execute
     */
    public function execute(Request $request)
    {
        $input = $request->all();
        $action = $input['action'] ?? null;
        $params = $input['params'] ?? [];
        $response = [
            'success' => false,
            'message' => '',
            'data' => null
        ];

        try {
            switch ($action) {
                case 'getCargadatos':
                    $response['data'] = $this->getCargadatos($params);
                    $response['success'] = true;
                    break;
                case 'saveCargadatos':
                    $response['data'] = $this->saveCargadatos($params);
                    $response['success'] = true;
                    break;
                case 'getAvaluos':
                    $response['data'] = $this->getAvaluos($params);
                    $response['success'] = true;
                    break;
                case 'getConstrucciones':
                    $response['data'] = $this->getConstrucciones($params);
                    $response['success'] = true;
                    break;
                case 'getAreaCarto':
                    $response['data'] = $this->getAreaCarto($params);
                    $response['success'] = true;
                    break;
                case 'closeCargadatos':
                    $response['data'] = $this->closeCargadatos($params);
                    $response['success'] = true;
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    /**
     * Obtener datos principales del formulario cargadatosfrm
     */
    private function getCargadatos($params)
    {
        $cvecatnva = $params['cvecatnva'] ?? null;
        if (!$cvecatnva) {
            throw new \Exception('Falta parámetro cvecatnva');
        }
        $result = DB::select('SELECT * FROM get_cargadatos(:cvecatnva)', [
            'cvecatnva' => $cvecatnva
        ]);
        return $result[0] ?? null;
    }

    /**
     * Guardar/actualizar datos del formulario
     */
    private function saveCargadatos($params)
    {
        $validator = Validator::make($params, [
            'cvecatnva' => 'required',
            // ... otros campos requeridos
        ]);
        if ($validator->fails()) {
            throw new \Exception($validator->errors()->first());
        }
        $result = DB::select('SELECT * FROM save_cargadatos(:cvecatnva, :data)', [
            'cvecatnva' => $params['cvecatnva'],
            'data' => json_encode($params)
        ]);
        return $result[0] ?? null;
    }

    /**
     * Obtener avaluos (tab avaluos)
     */
    private function getAvaluos($params)
    {
        $cvecatnva = $params['cvecatnva'] ?? null;
        $subpredio = $params['subpredio'] ?? 0;
        $result = DB::select('SELECT * FROM get_avaluos(:cvecatnva, :subpredio)', [
            'cvecatnva' => $cvecatnva,
            'subpredio' => $subpredio
        ]);
        return $result;
    }

    /**
     * Obtener construcciones
     */
    private function getConstrucciones($params)
    {
        $cveavaluo = $params['cveavaluo'] ?? null;
        $result = DB::select('SELECT * FROM get_construcciones(:cveavaluo)', [
            'cveavaluo' => $cveavaluo
        ]);
        return $result;
    }

    /**
     * Obtener área cartográfica
     */
    private function getAreaCarto($params)
    {
        $cvecatnva = $params['cvecatnva'] ?? null;
        $result = DB::select('SELECT * FROM get_area_carto(:cvecatnva)', [
            'cvecatnva' => $cvecatnva
        ]);
        return $result[0] ?? null;
    }

    /**
     * Cerrar recursos (simulación de cierre de queries)
     */
    private function closeCargadatos($params)
    {
        // En Laravel, no es necesario cerrar queries, pero se puede simular para compatibilidad
        return ['closed' => true];
    }
}
