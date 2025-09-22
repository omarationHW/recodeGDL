<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class ExecuteController extends Controller
{
    /**
     * Endpoint único para ejecutar acciones del sistema (eRequest/eResponse)
     * Entrada: {
     *   "action": "GAdeudos.buscar", // o "GAdeudos.imprimir", etc
     *   "params": { ... }
     * }
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
                case 'GAdeudos.buscar':
                    $response = $this->buscarAdeudo($params);
                    break;
                case 'GAdeudos.detalle':
                    $response = $this->detalleAdeudo($params);
                    break;
                case 'GAdeudos.imprimir':
                    $response = $this->imprimirAdeudo($params);
                    break;
                case 'GAdeudos.tabla':
                    $response = $this->getTablas($params);
                    break;
                case 'GAdeudos.etiquetas':
                    $response = $this->getEtiquetas($params);
                    break;
                default:
                    $response['message'] = 'Acción no soportada';
            }
        } catch (\Exception $e) {
            $response['success'] = false;
            $response['message'] = $e->getMessage();
        }
        return response()->json($response);
    }

    private function buscarAdeudo($params)
    {
        // params: par_tab, par_control
        $result = DB::select('SELECT * FROM sp_gadeudos_busca(:par_tab, :par_control)', [
            'par_tab' => $params['par_tab'],
            'par_control' => $params['par_control']
        ]);
        return [
            'success' => true,
            'data' => $result,
            'message' => count($result) ? 'Registro encontrado' : 'No existe registro'
        ];
    }

    private function detalleAdeudo($params)
    {
        // params: par_tab, par_control, par_rep, par_fecha
        $result = DB::select('SELECT * FROM sp_gadeudos_detalle(:par_tab, :par_control, :par_rep, :par_fecha)', [
            'par_tab' => $params['par_tab'],
            'par_control' => $params['par_control'],
            'par_rep' => $params['par_rep'],
            'par_fecha' => $params['par_fecha']
        ]);
        return [
            'success' => true,
            'data' => $result,
            'message' => 'Detalle de adeudos recuperado'
        ];
    }

    private function imprimirAdeudo($params)
    {
        // params: par_tab, par_control, par_rep, par_fecha, tipo (concentrado|detalle)
        // Lógica: obtiene datos y retorna JSON para renderizado PDF en frontend
        $detalle = DB::select('SELECT * FROM sp_gadeudos_detalle(:par_tab, :par_control, :par_rep, :par_fecha)', [
            'par_tab' => $params['par_tab'],
            'par_control' => $params['par_control'],
            'par_rep' => $params['par_rep'],
            'par_fecha' => $params['par_fecha']
        ]);
        $cabecera = DB::select('SELECT * FROM sp_gadeudos_busca(:par_tab, :par_control)', [
            'par_tab' => $params['par_tab'],
            'par_control' => $params['par_control']
        ]);
        return [
            'success' => true,
            'data' => [
                'cabecera' => $cabecera,
                'detalle' => $detalle
            ],
            'message' => 'Datos para impresión recuperados'
        ];
    }

    private function getTablas($params)
    {
        $result = DB::select('SELECT * FROM sp_gadeudos_tablas(:par_tab)', [
            'par_tab' => $params['par_tab']
        ]);
        return [
            'success' => true,
            'data' => $result,
            'message' => 'Tablas recuperadas'
        ];
    }

    private function getEtiquetas($params)
    {
        $result = DB::select('SELECT * FROM sp_gadeudos_etiquetas(:par_tab)', [
            'par_tab' => $params['par_tab']
        ]);
        return [
            'success' => true,
            'data' => $result,
            'message' => 'Etiquetas recuperadas'
        ];
    }
}
