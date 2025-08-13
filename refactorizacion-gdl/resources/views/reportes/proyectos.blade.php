<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Reporte de Pavimentación</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            font-size: 12px;
            margin: 20px;
        }
        .header { 
            text-align: center; 
            margin-bottom: 30px; 
        }
        .logos { 
            display: flex; 
            justify-content: space-between; 
            margin-bottom: 20px; 
        }
        table { 
            width: 100%; 
            border-collapse: collapse; 
            margin-top: 20px;
        }
        th, td { 
            border: 1px solid #333; 
            padding: 8px; 
            text-align: left; 
        }
        th { 
            background-color: #f2f2f2; 
            font-weight: bold;
        }
        .total { 
            font-weight: bold; 
            text-align: right; 
            background-color: #f9f9f9;
        }
        .footer { 
            margin-top: 30px; 
            text-align: center; 
            font-size: 10px;
        }
        .currency {
            text-align: right;
        }
        .center {
            text-align: center;
        }
        h1, h2 {
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>MUNICIPIO DE GUADALAJARA</h1>
        <h2>LISTADO DE PAVIMENTACIÓN</h2>
        <p>Reporte generado el {{ $fecha }} a las {{ $hora }}</p>
    </div>
    
    <table>
        <thead>
            <tr>
                <th class="center">Contrato</th>
                <th>Nombre</th>
                <th>Calle</th>
                <th class="center">Metros</th>
                <th>Tipo Pavimento</th>
                <th class="currency">Adeudo</th>
            </tr>
        </thead>
        <tbody>
            @foreach($proyectos as $proyecto)
            <tr>
                <td class="center">{{ $proyecto->contrato }}</td>
                <td>{{ $proyecto->nombre }}</td>
                <td>{{ $proyecto->calle }}</td>
                <td class="center">{{ number_format($proyecto->metros, 2) }}</td>
                <td class="center">{{ $proyecto->pavimento_descripcion }}</td>
                <td class="currency">${{ number_format($proyecto->adeudo_total, 2) }}</td>
            </tr>
            @endforeach
        </tbody>
        <tfoot>
            <tr class="total">
                <td colspan="5">TOTAL DE REGISTROS: {{ count($proyectos) }}</td>
                <td class="currency">${{ number_format($totalGeneral, 2) }}</td>
            </tr>
        </tfoot>
    </table>
    
    <div class="footer">
        <p>Sistema de Pavimentación - Municipio de Guadalajara</p>
        <p>Fecha de generación: {{ $fecha }} - Hora: {{ $hora }}</p>
    </div>
</body>
</html>