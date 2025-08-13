<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $configuracion['titulo'] }}</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: Arial, sans-serif;
            font-size: 12px;
            line-height: 1.4;
            color: #333;
        }
        
        .header {
            border-bottom: 3px solid #dc2626;
            padding-bottom: 15px;
            margin-bottom: 20px;
        }
        
        .header-content {
            display: table;
            width: 100%;
        }
        
        .logo-section {
            display: table-cell;
            vertical-align: middle;
            width: 80px;
        }
        
        .logo {
            width: 60px;
            height: 60px;
            object-fit: contain;
        }
        
        .title-section {
            display: table-cell;
            vertical-align: middle;
            padding-left: 15px;
        }
        
        .main-title {
            font-size: 18px;
            font-weight: bold;
            color: #dc2626;
            margin-bottom: 5px;
        }
        
        .subtitle {
            font-size: 14px;
            color: #666;
            margin-bottom: 3px;
        }
        
        .date-info {
            font-size: 10px;
            color: #888;
        }
        
        .info-section {
            display: table-cell;
            vertical-align: middle;
            text-align: right;
            width: 120px;
        }
        
        .section {
            margin-bottom: 25px;
            page-break-inside: avoid;
        }
        
        .section-title {
            font-size: 16px;
            font-weight: bold;
            color: #dc2626;
            margin-bottom: 10px;
            padding-bottom: 5px;
            border-bottom: 2px solid #dc2626;
        }
        
        .stats-grid {
            display: table;
            width: 100%;
            margin-bottom: 15px;
        }
        
        .stat-item {
            display: table-cell;
            text-align: center;
            padding: 15px;
            background-color: #f8fafc;
            border: 1px solid #e5e7eb;
            vertical-align: top;
        }
        
        .stat-value {
            font-size: 20px;
            font-weight: bold;
            color: #1f2937;
            margin-bottom: 5px;
        }
        
        .stat-label {
            font-size: 10px;
            color: #6b7280;
            text-transform: uppercase;
        }
        
        .table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 15px;
        }
        
        .table th,
        .table td {
            padding: 8px;
            text-align: left;
            border-bottom: 1px solid #e5e7eb;
            font-size: 10px;
        }
        
        .table th {
            background-color: #f8fafc;
            font-weight: bold;
            color: #374151;
            border-bottom: 2px solid #dc2626;
        }
        
        .table tr:nth-child(even) {
            background-color: #f9fafb;
        }
        
        .text-right {
            text-align: right;
        }
        
        .text-center {
            text-align: center;
        }
        
        .currency {
            font-weight: bold;
        }
        
        .status-badge {
            padding: 2px 6px;
            border-radius: 3px;
            font-size: 9px;
            font-weight: bold;
        }
        
        .status-pagado {
            background-color: #d1fae5;
            color: #065f46;
        }
        
        .status-pendiente {
            background-color: #fee2e2;
            color: #991b1b;
        }
        
        .footer {
            position: fixed;
            bottom: 20px;
            left: 0;
            right: 0;
            text-align: center;
            font-size: 9px;
            color: #666;
            border-top: 1px solid #e5e7eb;
            padding-top: 10px;
        }
        
        .page-number:before {
            content: "Página " counter(page) " de " counter(pages);
        }
        
        @page {
            margin: 2cm;
        }
        
        .chart-placeholder {
            background: linear-gradient(135deg, #3b82f6 0%, #10b981 100%);
            height: 150px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: bold;
            margin: 15px 0;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <!-- Header -->
    <div class="header">
        <div class="header-content">
            <div class="logo-section">
                <img src="data:image/png;base64,{{ base64_encode(file_get_contents(public_path('images/logo1.png'))) }}" 
                     alt="Gobierno de Guadalajara" class="logo">
            </div>
            <div class="title-section">
                <div class="main-title">{{ $configuracion['titulo'] }}</div>
                <div class="subtitle">Gobierno Municipal de Guadalajara</div>
                <div class="subtitle">Secretaría de Obras Públicas</div>
                <div class="date-info">
                    Período: {{ $configuracion['periodo'] === '2025' ? 'Ejercicio Fiscal 2025' : 
                               ($configuracion['periodo'] === '2025-actual' ? 'Enero - Agosto 2025' : 'Período personalizado') }}
                </div>
            </div>
            <div class="info-section">
                <div style="font-size: 10px; color: #666;">Generado el:</div>
                <div style="font-size: 11px; font-weight: bold;">{{ $fecha_generacion }}</div>
                <div style="margin-top: 10px; font-size: 9px; color: #888;">
                    Formato: {{ strtoupper($configuracion['formato']) }}<br>
                    Orientación: {{ ucfirst($configuracion['orientacion']) }}
                </div>
            </div>
        </div>
    </div>

    <!-- Estadísticas Generales -->
    @if($configuracion['incluir_estadisticas'] && isset($datos['estadisticas']))
    <div class="section">
        <div class="section-title">Resumen Ejecutivo</div>
        <div class="stats-grid">
            <div class="stat-item">
                <div class="stat-value">{{ $datos['estadisticas']['total_contratos'] }}</div>
                <div class="stat-label">Total Contratos</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">${{ number_format($datos['estadisticas']['inversion_total'], 2) }}</div>
                <div class="stat-label">Inversión Total</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">${{ number_format($datos['estadisticas']['adeudo_total'], 2) }}</div>
                <div class="stat-label">Adeudos Pendientes</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">${{ number_format($datos['estadisticas']['monto_pagado_total'], 2) }}</div>
                <div class="stat-label">Monto Pagado</div>
            </div>
        </div>
        
        <div class="stats-grid">
            <div class="stat-item">
                <div class="stat-value">{{ $datos['estadisticas']['contratos_asfalto'] }}</div>
                <div class="stat-label">Contratos Asfalto</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">{{ $datos['estadisticas']['contratos_concreto'] }}</div>
                <div class="stat-label">Contratos Concreto</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">{{ round(($datos['estadisticas']['monto_pagado_total'] / $datos['estadisticas']['inversion_total']) * 100, 1) }}%</div>
                <div class="stat-label">Porcentaje Pagado</div>
            </div>
            <div class="stat-item">
                <div class="stat-value">{{ round(($datos['estadisticas']['adeudo_total'] / $datos['estadisticas']['inversion_total']) * 100, 1) }}%</div>
                <div class="stat-label">Porcentaje Pendiente</div>
            </div>
        </div>
    </div>
    @endif

    <!-- Detalle de Proyectos -->
    @if($configuracion['incluir_detalles'] && isset($datos['proyectos']))
    <div class="section">
        <div class="section-title">Detalle de Contratos</div>
        <table class="table">
            <thead>
                <tr>
                    <th>Contrato</th>
                    <th>Contratista</th>
                    <th>Ubicación</th>
                    <th>Tipo</th>
                    <th class="text-right">Metros²</th>
                    <th class="text-right">Costo/m²</th>
                    <th class="text-right">Inversión Total</th>
                    <th class="text-right">Adeudo</th>
                </tr>
            </thead>
            <tbody>
                @foreach($datos['proyectos'] as $proyecto)
                <tr>
                    <td><strong>{{ $proyecto['contrato'] }}</strong></td>
                    <td>{{ $proyecto['nombre'] }}</td>
                    <td>{{ $proyecto['calle'] }}</td>
                    <td>{{ $proyecto['tipo_pavimento'] === 'A' ? 'Asfalto' : 'Concreto' }}</td>
                    <td class="text-right">{{ number_format($proyecto['metros'], 2) }}</td>
                    <td class="text-right currency">${{ number_format($proyecto['costomtr'], 2) }}</td>
                    <td class="text-right currency">${{ number_format($proyecto['costototal'], 2) }}</td>
                    <td class="text-right currency">${{ number_format($proyecto['adeudo_total'], 2) }}</td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
    @endif

    <!-- Control de Adeudos -->
    @if($configuracion['incluir_adeudos'] && isset($datos['adeudos']))
    <div class="section">
        <div class="section-title">Control de Adeudos por Contrato</div>
        <table class="table">
            <thead>
                <tr>
                    <th>Contrato</th>
                    <th>Contratista</th>
                    <th class="text-right">Costo Total</th>
                    <th class="text-right">Monto Pagado</th>
                    <th class="text-right">Monto Pendiente</th>
                    <th class="text-center">Mensualidades Pagadas</th>
                    <th class="text-center">Mensualidades Pendientes</th>
                    <th class="text-center">% Avance</th>
                </tr>
            </thead>
            <tbody>
                @foreach($datos['adeudos'] as $adeudo)
                <tr>
                    <td><strong>{{ $adeudo['contrato'] }}</strong></td>
                    <td>{{ $adeudo['nombre'] }}</td>
                    <td class="text-right currency">${{ number_format($adeudo['costototal'], 2) }}</td>
                    <td class="text-right currency">${{ number_format($adeudo['monto_pagado'], 2) }}</td>
                    <td class="text-right currency">${{ number_format($adeudo['monto_pendiente'], 2) }}</td>
                    <td class="text-center">{{ $adeudo['mensualidades_pagadas'] }}</td>
                    <td class="text-center">{{ $adeudo['mensualidades_pendientes'] }}</td>
                    <td class="text-center">{{ $adeudo['porcentaje_avance'] }}%</td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
    @endif


    <!-- Footer -->
    <div class="footer">
        <div>Sistema de Pavimentación - Gobierno Municipal de Guadalajara</div>
        <div>Generado el {{ $fecha_generacion }} - Documento oficial con validez legal</div>
        <div style="margin-top: 5px;">
            <strong>Confidencial:</strong> Este documento contiene información financiera sensible del gobierno municipal
        </div>
    </div>
</body>
</html>