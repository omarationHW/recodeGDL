<?php

namespace App\Exports;

use App\Models\ProyectoObra;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;
use Maatwebsite\Excel\Concerns\WithStyles;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;
use PhpOffice\PhpSpreadsheet\Style\Alignment;

class ProyectosExport implements FromCollection, WithHeadings, WithMapping, WithStyles
{
    public function collection()
    {
        return ProyectoObra::with('adeudos')->get();
    }

    public function headings(): array
    {
        return [
            'Contrato',
            'Nombre',
            'Calle',
            'Metros',
            'Costo por Metro',
            'Costo Total',
            'Tipo Pavimento',
            'Adeudo Total',
            'Mensualidades Pendientes',
            'Mensualidades Pagadas'
        ];
    }

    public function map($proyecto): array
    {
        $adeudosPendientes = $proyecto->adeudos->where('estado', 'V')->count();
        $adeudosPagados = $proyecto->adeudos->where('estado', 'P')->count();
        
        return [
            $proyecto->contrato,
            $proyecto->nombre,
            $proyecto->calle,
            $proyecto->metros,
            '$' . number_format($proyecto->costomtr, 2),
            '$' . number_format($proyecto->costototal, 2),
            $proyecto->tipo_pavimento == 'A' ? 'Asfalto' : 'Concreto Hidráulico',
            '$' . number_format($proyecto->adeudo_total, 2),
            $adeudosPendientes,
            $adeudosPagados
        ];
    }

    public function styles(Worksheet $sheet)
    {
        return [
            1 => [
                'font' => ['bold' => true],
                'alignment' => ['horizontal' => Alignment::HORIZONTAL_CENTER]
            ]
        ];
    }
}