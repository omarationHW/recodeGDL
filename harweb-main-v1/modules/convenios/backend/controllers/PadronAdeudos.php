<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PadronAdeudosController extends Controller
{
    /**
     * Endpoint único para eRequest/eResponse
     */
    public function execute(Request $request)
    {
        $action = $request->input('action');
        $params = $request->input('params', []);
        $user = $request->user(); // Si hay autenticación

        switch ($action) {
            case 'getRecaudadoras':
                return $this->getRecaudadoras();
            case 'getPadronAdeudos':
                return $this->getPadronAdeudos($params);
            case 'exportPadronAdeudosExcel':
                return $this->exportPadronAdeudosExcel($params);
            default:
                return response()->json([
                    'success' => false,
                    'message' => 'Acción no soportada',
                    'data' => null
                ], 400);
        }
    }

    /**
     * Obtener lista de recaudadoras
     */
    public function getRecaudadoras()
    {
        $recs = DB::select('SELECT id_rec, recaudadora FROM ta_12_recaudadoras WHERE id_rec NOT IN (6,8,9) ORDER BY id_rec');
        return response()->json([
            'success' => true,
            'data' => $recs
        ]);
    }

    /**
     * Obtener el padrón de adeudos por recaudadora
     * @param array $params ['rec_id' => int]
     */
    public function getPadronAdeudos($params)
    {
        $validator = Validator::make($params, [
            'rec_id' => 'required|integer|min:1'
        ]);
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Parámetros inválidos',
                'errors' => $validator->errors()
            ], 422);
        }
        $rec_id = $params['rec_id'];
        $result = DB::select('SELECT * FROM spd_17_padronconv(?)', [$rec_id]);
        return response()->json([
            'success' => true,
            'data' => $result
        ]);
    }

    /**
     * Exportar el padrón de adeudos a Excel (devuelve base64)
     * @param array $params ['rec_id' => int]
     */
    public function exportPadronAdeudosExcel($params)
    {
        // Reutiliza getPadronAdeudos
        $response = $this->getPadronAdeudos($params);
        $data = $response->getData(true);
        if (!$data['success']) {
            return $response;
        }
        $rows = $data['data'];
        // Usar PhpSpreadsheet para generar Excel
        $spreadsheet = new \PhpOffice\PhpSpreadsheet\Spreadsheet();
        $sheet = $spreadsheet->getActiveSheet();
        // Encabezados
        $headers = [
            'Tipo', 'Subtipo', 'Convenio', 'Nombre', 'Vigencia', 'Fecha Inicio', 'Plazo', 'Tipo Plazo',
            'Cantidad Total', '1er. Pago', 'Importe 1er. Pago', 'Total Pagos', 'Importe Pagado',
            'Parc. Adeudos', 'Importe Adeudo'
        ];
        $sheet->fromArray($headers, null, 'A1');
        $rowNum = 2;
        foreach ($rows as $row) {
            $sheet->fromArray([
                $row['tipo'], $row['subtipo'], $row['convenio'], $row['nombre'], $row['vigencia'],
                $row['fecha_otorg'], $row['plazo'], $row['tipo_plazo'], $row['cantidad'],
                $row['primer_pago'], $row['importe_primerpago'], $row['pagos_realizados'],
                $row['importe_pagado'], $row['parc_adeudo'], $row['importe_adeudo']
            ], null, 'A'.$rowNum);
            $rowNum++;
        }
        $writer = new \PhpOffice\PhpSpreadsheet\Writer\Xlsx($spreadsheet);
        ob_start();
        $writer->save('php://output');
        $excelContent = ob_get_clean();
        $base64 = base64_encode($excelContent);
        return response()->json([
            'success' => true,
            'file' => $base64,
            'filename' => 'padron_adeudos.xlsx'
        ]);
    }
}
