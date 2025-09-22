@extends('layouts.app')

@section('title', '🆕 Sistema de Consultas Unificadas - Cementerios')

@section('content')
<div class="container-fluid mt-4">
    <!-- Header del Sistema -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #007bff !important;">
        <div class="card-body p-4">
            <div class="d-flex align-items-center mb-3">
                <div class="bg-primary bg-opacity-10 rounded-3 p-3 me-3">
                    <i class="fas fa-search fa-2x text-primary"></i>
                </div>
                <div>
                    <h1 class="h3 fw-bold text-dark mb-1">
                        <span class="badge bg-danger me-2" style="font-size: 0.6em;">NUEVO</span>
                        Sistema de Consultas Unificadas
                    </h1>
                    <p class="text-muted mb-0">Búsqueda inteligente multifiltro para servicios de cementerios</p>
                </div>
            </div>

            <div class="alert alert-primary" role="alert">
                <div class="d-flex align-items-center">
                    <i class="fas fa-magic me-2"></i>
                    <div>
                        <strong>🆕 Sistema Moderno de Búsquedas</strong>
                        <p class="mb-0 small">
                            Reemplaza múltiples sistemas obsoletos con algoritmos avanzados de búsqueda fonética y filtros combinados.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Búsqueda Inteligente -->
    <div class="card border-0 shadow-sm mb-5">
        <div class="card-header bg-light">
            <h5 class="fw-bold mb-0">
                <i class="fas fa-search me-2"></i>Búsqueda Inteligente Multifiltro
            </h5>
        </div>
        <div class="card-body">
            <div class="row g-4">
                <div class="col-lg-8">
                    <div class="mb-3">
                        <label class="form-label fw-semibold">Buscar por cualquier criterio:</label>
                        <div class="input-group input-group-lg">
                            <span class="input-group-text bg-primary text-white">
                                <i class="fas fa-search"></i>
                            </span>
                            <input type="text" class="form-control" placeholder="RCM, nombre completo, folio, ubicación...">
                            <button class="btn btn-primary" type="button">
                                <i class="fas fa-search me-1"></i>Buscar
                            </button>
                        </div>
                        <div class="form-text">
                            <i class="fas fa-info-circle me-1"></i>
                            Búsqueda fonética activada - encuentra nombres similares automáticamente
                        </div>
                    </div>

                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="form-label">Tipo de búsqueda:</label>
                            <select class="form-select">
                                <option>🔍 Universal (Todos los campos)</option>
                                <option>📋 Registro Civil Municipal</option>
                                <option>👤 Por Nombre</option>
                                <option>📄 Por Folio</option>
                                <option>📍 Por Ubicación</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Algoritmo:</label>
                            <select class="form-select">
                                <option>Inteligente (combinado)</option>
                                <option>Coincidencia exacta</option>
                                <option>Búsqueda fonética</option>
                                <option>Nombres similares</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">Resultados por página:</label>
                            <select class="form-select">
                                <option>25 resultados</option>
                                <option>10 resultados</option>
                                <option>50 resultados</option>
                                <option>100 resultados</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="card border-info border-opacity-25">
                        <div class="card-header bg-info bg-opacity-10">
                            <h6 class="fw-bold mb-0 text-info">
                                <i class="fas fa-bookmark me-2"></i>Búsquedas Guardadas
                            </h6>
                        </div>
                        <div class="card-body">
                            <div class="d-grid gap-2">
                                <button class="btn btn-outline-info btn-sm d-flex justify-content-between align-items-center">
                                    <span>Servicios vencidos</span>
                                    <i class="fas fa-play"></i>
                                </button>
                                <button class="btn btn-outline-info btn-sm d-flex justify-content-between align-items-center">
                                    <span>Panteón Municipal</span>
                                    <i class="fas fa-play"></i>
                                </button>
                                <button class="btn btn-outline-info btn-sm d-flex justify-content-between align-items-center">
                                    <span>Pagos pendientes</span>
                                    <i class="fas fa-play"></i>
                                </button>
                                <hr class="my-2">
                                <button class="btn btn-info btn-sm">
                                    <i class="fas fa-save me-1"></i>Guardar búsqueda actual
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Filtros Avanzados -->
    <div class="card border-0 shadow-sm mb-5">
        <div class="card-header bg-light">
            <h5 class="fw-bold mb-0">
                <i class="fas fa-filter me-2"></i>Filtros Avanzados
            </h5>
        </div>
        <div class="card-body">
            <div class="row g-4">
                <div class="col-md-6">
                    <div class="card border-warning border-opacity-25">
                        <div class="card-header bg-warning bg-opacity-10">
                            <h6 class="fw-bold mb-0 text-warning">
                                <i class="fas fa-sliders-h me-2"></i>Filtros de Servicios
                            </h6>
                        </div>
                        <div class="card-body">
                            <div class="row g-3">
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Tipo de Servicio:</label>
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" id="inhumacion" checked>
                                        <label class="form-check-label" for="inhumacion">Inhumación</label>
                                    </div>
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" id="exhumacion">
                                        <label class="form-check-label" for="exhumacion">Exhumación</label>
                                    </div>
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" id="cremacion">
                                        <label class="form-check-label" for="cremacion">Cremación</label>
                                    </div>
                                    <div class="form-check">
                                        <input class="form-check-input" type="checkbox" id="mantenimiento">
                                        <label class="form-check-label" for="mantenimiento">Mantenimiento</label>
                                    </div>
                                </div>
                                <div class="col-6">
                                    <label class="form-label">Fecha desde:</label>
                                    <input type="date" class="form-control">
                                </div>
                                <div class="col-6">
                                    <label class="form-label">Fecha hasta:</label>
                                    <input type="date" class="form-control">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="card border-success border-opacity-25">
                        <div class="card-header bg-success bg-opacity-10">
                            <h6 class="fw-bold mb-0 text-success">
                                <i class="fas fa-map-marker-alt me-2"></i>Filtros de Ubicación
                            </h6>
                        </div>
                        <div class="card-body">
                            <div class="row g-3">
                                <div class="col-12">
                                    <label class="form-label">Panteón:</label>
                                    <select class="form-select">
                                        <option>Todos los panteones</option>
                                        <option>Panteón Municipal</option>
                                        <option>Panteón Belén</option>
                                        <option>Panteón Reforma</option>
                                        <option>Panteón Americana</option>
                                    </select>
                                </div>
                                <div class="col-6">
                                    <label class="form-label">Sección:</label>
                                    <input type="text" class="form-control" placeholder="A, B, C...">
                                </div>
                                <div class="col-6">
                                    <label class="form-label">Lote:</label>
                                    <input type="text" class="form-control" placeholder="Número de lote">
                                </div>
                                <div class="col-12">
                                    <label class="form-label">Estado del servicio:</label>
                                    <select class="form-select">
                                        <option>Todos los estados</option>
                                        <option>Activo</option>
                                        <option>Vencido</option>
                                        <option>Pagado</option>
                                        <option>Pendiente</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mt-4 text-center">
                <button class="btn btn-primary btn-lg me-2">
                    <i class="fas fa-filter me-1"></i>Aplicar Filtros
                </button>
                <button class="btn btn-outline-secondary btn-lg">
                    <i class="fas fa-eraser me-1"></i>Limpiar Filtros
                </button>
            </div>
        </div>
    </div>

    <!-- Resultados y Estadísticas -->
    <div class="row g-4 mb-5">
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm">
                <div class="card-header bg-light">
                    <h5 class="fw-bold mb-0">
                        <i class="fas fa-table me-2"></i>Resultados de Búsqueda
                    </h5>
                </div>
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-hover table-striped">
                            <thead class="table-dark">
                                <tr>
                                    <th>Folio</th>
                                    <th>RCM</th>
                                    <th>Nombre Completo</th>
                                    <th>Servicio</th>
                                    <th>Ubicación</th>
                                    <th>Estado</th>
                                    <th>Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td><span class="badge bg-primary">CEM-2024-001</span></td>
                                    <td>RC123456789</td>
                                    <td>
                                        <strong>Juan Pérez García</strong>
                                        <br><small class="text-muted">15/03/1945</small>
                                    </td>
                                    <td><span class="badge bg-dark">Inhumación</span></td>
                                    <td>
                                        <small>Municipal<br>Sec: A Lote: 15</small>
                                    </td>
                                    <td><span class="badge bg-success">Activo</span></td>
                                    <td>
                                        <div class="btn-group btn-group-sm">
                                            <button class="btn btn-outline-primary" title="Ver detalles">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <button class="btn btn-outline-success" title="Historial">
                                                <i class="fas fa-history"></i>
                                            </button>
                                            <button class="btn btn-outline-info" title="Documentos">
                                                <i class="fas fa-file-alt"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td><span class="badge bg-primary">CEM-2024-002</span></td>
                                    <td>RC987654321</td>
                                    <td>
                                        <strong>María Rodríguez López</strong>
                                        <br><small class="text-muted">22/07/1952</small>
                                    </td>
                                    <td><span class="badge bg-info">Mantenimiento</span></td>
                                    <td>
                                        <small>Belén<br>Sec: B Lote: 32</small>
                                    </td>
                                    <td><span class="badge bg-warning">Pendiente</span></td>
                                    <td>
                                        <div class="btn-group btn-group-sm">
                                            <button class="btn btn-outline-primary" title="Ver detalles">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                            <button class="btn btn-outline-success" title="Historial">
                                                <i class="fas fa-history"></i>
                                            </button>
                                            <button class="btn btn-outline-info" title="Documentos">
                                                <i class="fas fa-file-alt"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Paginación -->
                    <nav aria-label="Navegación de resultados" class="mt-3">
                        <ul class="pagination justify-content-center">
                            <li class="page-item">
                                <a class="page-link" href="#" aria-label="Anterior">
                                    <span aria-hidden="true">&laquo;</span>
                                </a>
                            </li>
                            <li class="page-item active"><a class="page-link" href="#">1</a></li>
                            <li class="page-item"><a class="page-link" href="#">2</a></li>
                            <li class="page-item"><a class="page-link" href="#">3</a></li>
                            <li class="page-item">
                                <a class="page-link" href="#" aria-label="Siguiente">
                                    <span aria-hidden="true">&raquo;</span>
                                </a>
                            </li>
                        </ul>
                    </nav>
                </div>
            </div>
        </div>

        <div class="col-lg-4">
            <div class="card border-info border-opacity-25">
                <div class="card-header bg-info bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-info">
                        <i class="fas fa-chart-bar me-2"></i>Estadísticas
                    </h5>
                </div>
                <div class="card-body">
                    <div class="row g-3 text-center">
                        <div class="col-6">
                            <div class="border rounded p-3">
                                <h3 class="text-primary mb-1">1,247</h3>
                                <small class="text-muted">Total encontrados</small>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="border rounded p-3">
                                <h3 class="text-success mb-1">892</h3>
                                <small class="text-muted">Servicios activos</small>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="border rounded p-3">
                                <h3 class="text-warning mb-1">156</h3>
                                <small class="text-muted">Pagos pendientes</small>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="border rounded p-3">
                                <h3 class="text-info mb-1">245ms</h3>
                                <small class="text-muted">Tiempo búsqueda</small>
                            </div>
                        </div>
                    </div>

                    <div class="mt-4">
                        <h6 class="fw-semibold mb-2">Distribución por panteón:</h6>
                        <div class="progress mb-1" style="height: 6px;">
                            <div class="progress-bar bg-primary" style="width: 45%"></div>
                            <div class="progress-bar bg-success" style="width: 25%"></div>
                            <div class="progress-bar bg-warning" style="width: 20%"></div>
                            <div class="progress-bar bg-info" style="width: 10%"></div>
                        </div>
                        <small class="text-muted">
                            Municipal (45%) • Belén (25%) • Reforma (20%) • Americana (10%)
                        </small>
                    </div>
                </div>
            </div>

            <!-- Exportación -->
            <div class="card border-success border-opacity-25 mt-4">
                <div class="card-header bg-success bg-opacity-10">
                    <h6 class="fw-bold mb-0 text-success">
                        <i class="fas fa-file-export me-2"></i>Exportación
                    </h6>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <select class="form-select">
                            <option>📊 Excel (.xlsx)</option>
                            <option>📄 PDF</option>
                            <option>📋 CSV</option>
                            <option>🔧 JSON</option>
                        </select>
                    </div>
                    <button class="btn btn-success w-100">
                        <i class="fas fa-download me-1"></i>Exportar Resultados
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Capacidades del Sistema -->
    <div class="card border-0 shadow-sm">
        <div class="card-header bg-light">
            <h5 class="fw-bold mb-0">
                <i class="fas fa-star me-2"></i>Capacidades del Sistema
            </h5>
        </div>
        <div class="card-body">
            <div class="row g-4">
                <div class="col-md-3">
                    <div class="text-center">
                        <div class="bg-primary bg-opacity-10 rounded-3 p-3 mb-3">
                            <i class="fas fa-search-plus fa-2x text-primary"></i>
                        </div>
                        <h6 class="fw-semibold">Búsqueda Universal</h6>
                        <p class="text-muted small">RCM, nombre, folio en una sola interface</p>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="text-center">
                        <div class="bg-success bg-opacity-10 rounded-3 p-3 mb-3">
                            <i class="fas fa-brain fa-2x text-success"></i>
                        </div>
                        <h6 class="fw-semibold">Algoritmos Avanzados</h6>
                        <p class="text-muted small">Búsqueda fonética y por similitud</p>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="text-center">
                        <div class="bg-warning bg-opacity-10 rounded-3 p-3 mb-3">
                            <i class="fas fa-filter fa-2x text-warning"></i>
                        </div>
                        <h6 class="fw-semibold">Filtros Combinados</h6>
                        <p class="text-muted small">Múltiples criterios simultáneos</p>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="text-center">
                        <div class="bg-info bg-opacity-10 rounded-3 p-3 mb-3">
                            <i class="fas fa-eye fa-2x text-info"></i>
                        </div>
                        <h6 class="fw-semibold">Vista Integral</h6>
                        <p class="text-muted small">Historial completo de servicios</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script>
    // Scripts específicos para el sistema de consultas unificadas
    document.addEventListener('DOMContentLoaded', function() {
        console.log('Sistema de Consultas Unificadas - Cementerios cargado');

        // Simular búsqueda en tiempo real
        const searchInput = document.querySelector('input[placeholder*="RCM"]');
        if (searchInput) {
            searchInput.addEventListener('input', function() {
                // Simular búsqueda en tiempo real
                console.log('Búsqueda:', this.value);
            });
        }
    });
</script>
@endsection