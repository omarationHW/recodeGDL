<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class DeudaGrupoController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'getDeudaGrupo':
                    $response['data'] = $this->getDeudaGrupo($params);
                    $response['success'] = true;
                    break;
                case 'exportDeudaGrupo':
                    $response['data'] = $this->exportDeudaGrupo($params);
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
     * Consulta principal de deuda de grupo
     * @param array $params
     * @return array
     */
    private function getDeudaGrupo($params)
    {
        $axo = isset($params['axo']) ? (int)$params['axo'] : date('Y');
        $fechaRecargo = isset($params['fecha_recargo']) ? $params['fecha_recargo'] : date('Y-m-d');
        $result = DB::select('SELECT * FROM sp_deuda_grupo(:axo, :fecha_recargo)', [
            'axo' => $axo,
            'fecha_recargo' => $fechaRecargo
        ]);
        return $result;
    }

    /**
     * Exporta la consulta a Excel (devuelve base64 o URL de descarga)
     * @param array $params
     * @return array
     */
    private function exportDeudaGrupo($params)
    {
        // Lógica de exportación, puede ser base64 o generar archivo temporal
        $data = $this->getDeudaGrupo($params);
        // Aquí se debe usar una librería como PhpSpreadsheet para generar el archivo
        // Por simplicidad, retornamos los datos crudos
        return [
            'exported' => true,
            'data' => $data
        ];
    }
}
