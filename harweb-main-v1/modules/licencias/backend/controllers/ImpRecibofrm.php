<?php
namespace App\Http\Controllers\Api;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ImpReciboController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
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
                case 'getLicenciaRecibo':
                    $response['data'] = $this->getLicenciaRecibo($params);
                    $response['success'] = true;
                    break;
                case 'printRecibo':
                    $response['data'] = $this->printRecibo($params);
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
     * Consulta la información de la licencia para el recibo
     * @param array $params
     * @return array|null
     */
    private function getLicenciaRecibo($params)
    {
        $licencia = $params['licencia'] ?? null;
        if (!$licencia) {
            throw new \Exception('El número de licencia es requerido');
        }
        $result = DB::selectOne('SELECT *, (ubicacion || \' \' || numext_ubic || \'-\' || COALESCE(letraext_ubic, \'\') || \'-\' || COALESCE(numint_ubic, \'\') || \'-\' || COALESCE(letraint_ubic, \'\')) as dom_completo, (COALESCE(primer_ap, \'\') || \' \' || COALESCE(segundo_ap, \'\') || \' \' || COALESCE(propietario, \'\')) as propietarionvo FROM licencias WHERE licencia = ? AND vigente = \'V\'', [$licencia]);
        if (!$result) {
            throw new \Exception('No se encontró licencia con ese número');
        }
        return (array)$result;
    }

    /**
     * Genera los datos para imprimir el recibo (simula impresión)
     * @param array $params
     * @return array
     */
    private function printRecibo($params)
    {
        $licencia = $params['licencia'] ?? null;
        $tipo = $params['tipo'] ?? 'certificacion'; // 'constancia' o 'certificacion'
        if (!$licencia) {
            throw new \Exception('El número de licencia es requerido');
        }
        // Consulta licencia
        $licenciaData = $this->getLicenciaRecibo(['licencia' => $licencia]);
        // Consulta costo
        $costo = DB::selectOne('SELECT costo_certific, costo_constancia FROM parametros_lic LIMIT 1');
        $monto = ($tipo === 'constancia') ? $costo->costo_constancia : $costo->costo_certific;
        // Convertir a letra (puedes usar una función PHP o SP en PG)
        $monto_letra = $this->numeroALetras($monto);
        return [
            'licencia' => $licenciaData['licencia'],
            'nombre' => $licenciaData['propietarionvo'],
            'domicilio' => $licenciaData['dom_completo'],
            'concepto' => strtoupper($tipo),
            'cantidad' => $monto,
            'cantidad_letra' => $monto_letra . ' PESOS 00/100 M.N.'
        ];
    }

    /**
     * Convierte número a letras (simplificado)
     */
    private function numeroALetras($numero)
    {
        // Puedes usar una librería o SP en PG, aquí ejemplo simple
        $formatter = new \NumberFormatter('es', \NumberFormatter::SPELLOUT);
        return strtoupper($formatter->format($numero));
    }
}
