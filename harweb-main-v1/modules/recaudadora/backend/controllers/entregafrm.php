<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class EntregaRequerimientosController extends Controller
{
    /**
     * Endpoint unificado para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Si hay autenticación
        $response = [
            'success' => false,
            'data' => null,
            'message' => ''
        ];

        try {
            switch ($action) {
                case 'buscar_ejecutor':
                    $response['data'] = $this->buscarEjecutor($params);
                    $response['success'] = true;
                    break;
                case 'listar_requerimientos':
                    $response['data'] = $this->listarRequerimientos($params);
                    $response['success'] = true;
                    break;
                case 'asignar_requerimiento':
                    $response['data'] = $this->asignarRequerimiento($params, $user);
                    $response['success'] = true;
                    break;
                case 'quitar_requerimiento':
                    $response['data'] = $this->quitarRequerimiento($params, $user);
                    $response['success'] = true;
                    break;
                case 'imprimir_entrega':
                    $response['data'] = $this->imprimirEntrega($params);
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

    private function buscarEjecutor($params)
    {
        $criterio = $params['criterio'] ?? null;
        $tipo = $params['tipo'] ?? 'numero'; // 'numero' o 'nombre'
        if ($tipo === 'numero') {
            return DB::select('SELECT *, TRIM(paterno)||' '||TRIM(materno)||' '||TRIM(nombres) as ncompleto FROM ejecutor WHERE cveejecutor = ?', [$criterio]);
        } else {
            return DB::select('SELECT *, TRIM(paterno)||' '||TRIM(materno)||' '||TRIM(nombres) as ncompleto FROM ejecutor WHERE (TRIM(paterno)||' '||TRIM(materno)||' '||TRIM(nombres)) ILIKE ?', ["%$criterio%"]);
        }
    }

    private function listarRequerimientos($params)
    {
        $cveejecutor = $params['cveejecutor'];
        $recaud = $params['recaud'];
        $fecha = $params['fecha'];
        return DB::select('SELECT * FROM reqpredial WHERE cveejecut = ? AND recaud = ? AND fecejec = ?', [$cveejecutor, $recaud, $fecha]);
    }

    private function asignarRequerimiento($params, $user)
    {
        $folio = $params['folio'];
        $recaud = $params['recaud'];
        $cveejecutor = $params['cveejecutor'];
        $fecha = $params['fecha'];
        // Llama al stored procedure para asignar
        $result = DB::select('CALL sp_asignar_requerimiento(?, ?, ?, ?, ?)', [$folio, $recaud, $cveejecutor, $fecha, $user->username]);
        return $result;
    }

    private function quitarRequerimiento($params, $user)
    {
        $folio = $params['folio'];
        $recaud = $params['recaud'];
        $cveejecutor = $params['cveejecutor'];
        // Llama al stored procedure para quitar
        $result = DB::select('CALL sp_quitar_requerimiento(?, ?, ?, ?)', [$folio, $recaud, $cveejecutor, $user->username]);
        return $result;
    }

    private function imprimirEntrega($params)
    {
        // Aquí se puede generar un PDF o devolver los datos para impresión
        // Por simplicidad, solo retorna los datos
        $cveejecutor = $params['cveejecutor'];
        $fecha = $params['fecha'];
        $recaud = $params['recaud'];
        $ejecutor = DB::selectOne('SELECT *, TRIM(paterno)||' '||TRIM(materno)||' '||TRIM(nombres) as ncompleto FROM ejecutor WHERE cveejecutor = ?', [$cveejecutor]);
        $requerimientos = DB::select('SELECT * FROM reqpredial WHERE cveejecut = ? AND recaud = ? AND fecejec = ?', [$cveejecutor, $recaud, $fecha]);
        return [
            'ejecutor' => $ejecutor,
            'requerimientos' => $requerimientos
        ];
    }
}
