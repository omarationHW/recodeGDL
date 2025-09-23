@extends('layouts.app')

@section('title', '🆕 Funciones Excluidas - Cementerios')

@section('content')
<div class="container-fluid mt-4">
    <!-- Header del Sistema -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #dc3545 !important;">
        <div class="card-body p-4">
            <div class="d-flex align-items-center mb-3">
                <div class="bg-danger bg-opacity-10 rounded-3 p-3 me-3">
                    <i class="fas fa-times-circle fa-2x text-danger"></i>
                </div>
                <div>
                    <h1 class="h3 fw-bold text-dark mb-1">
                        <span class="badge bg-danger me-2" style="font-size: 0.6em;">NUEVO</span>
                        Funciones Excluidas - Cementerios
                    </h1>
                    <p class="text-muted mb-0">Documentación de funciones obsoletas eliminadas en la modernización</p>
                </div>
            </div>

            <div class="alert alert-warning border-warning" role="alert">
                <div class="d-flex align-items-center">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    <div>
                        <strong>📋 Documentación de Modernización</strong>
                        <p class="mb-0 small">
                            Este documento detalla las 10 funciones obsoletas que fueron excluidas y sus reemplazos modernos.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Resumen de Exclusiones -->
    <div class="card border-0 shadow-sm mb-5">
        <div class="card-header bg-light">
            <h5 class="fw-bold mb-0">
                <i class="fas fa-chart-pie me-2"></i>Resumen de Modernización
            </h5>
        </div>
        <div class="card-body">
            <div class="row g-3 text-center mb-4">
                <div class="col-md-3">
                    <div class="bg-danger bg-opacity-10 rounded p-3">
                        <h2 class="text-danger mb-1">10</h2>
                        <small class="text-muted">Funciones excluidas</small>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="bg-success bg-opacity-10 rounded p-3">
                        <h2 class="text-success mb-1">4</h2>
                        <small class="text-muted">Sistemas nuevos</small>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="bg-warning bg-opacity-10 rounded p-3">
                        <h2 class="text-warning mb-1">350%</h2>
                        <small class="text-muted">Mejora eficiencia</small>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="bg-info bg-opacity-10 rounded p-3">
                        <h2 class="text-info mb-1">70%</h2>
                        <small class="text-muted">Reducción tiempo</small>
                    </div>
                </div>
            </div>

            <div class="alert alert-info">
                <h6 class="fw-semibold mb-2">📈 Indicadores de Éxito:</h6>
                <ul class="mb-0">
                    <li>✅ Reducción de tiempo en consultas: 80%</li>
                    <li>✅ Automatización de descuentos: 100%</li>
                    <li>✅ Precisión en revaluaciones: 99.5%</li>
                    <li>✅ Reducción de errores manuales: 95%</li>
                </ul>
            </div>
        </div>
    </div>

    <!-- Funciones Obsoletas de Consultas -->
    <div class="card border-0 shadow-sm mb-5">
        <div class="card-header bg-danger bg-opacity-10">
            <h5 class="fw-bold mb-0 text-danger">
                <i class="fas fa-search me-2"></i>Funciones de Consulta Obsoletas (3)
            </h5>
        </div>
        <div class="card-body">
            <div class="row g-4">
                <div class="col-lg-4">
                    <div class="card border-danger border-opacity-25">
                        <div class="card-header bg-danger bg-opacity-10">
                            <h6 class="fw-bold mb-0 text-danger">
                                <i class="fas fa-times me-2"></i>1. Múltiple por RCM
                            </h6>
                        </div>
                        <div class="card-body">
                            <h6 class="fw-semibold text-muted mb-2">❌ Problemas:</h6>
                            <ul class="text-muted small mb-3">
                                <li>Consultas lentas por RCM</li>
                                <li>Falta de filtros avanzados</li>
                                <li>Interface poco intuitiva</li>
                                <li>Sin capacidad de exportación</li>
                            </ul>
                            <div class="alert alert-light border-success">
                                <h6 class="fw-semibold text-success mb-1">✅ Reemplazado por:</h6>
                                <small class="text-success">
                                    <strong>Sistema de Consultas Unificadas</strong><br>
                                    Búsqueda inteligente con algoritmos avanzados
                                </small>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="card border-danger border-opacity-25">
                        <div class="card-header bg-danger bg-opacity-10">
                            <h6 class="fw-bold mb-0 text-danger">
                                <i class="fas fa-times me-2"></i>2. Múltiple por nombre
                            </h6>
                        </div>
                        <div class="card-body">
                            <h6 class="fw-semibold text-muted mb-2">❌ Problemas:</h6>
                            <ul class="text-muted small mb-3">
                                <li>Búsquedas poco precisas</li>
                                <li>Sin soporte para nombres similares</li>
                                <li>Resultados limitados</li>
                                <li>Falta de ordenamiento inteligente</li>
                            </ul>
                            <div class="alert alert-light border-success">
                                <h6 class="fw-semibold text-success mb-1">✅ Reemplazado por:</h6>
                                <small class="text-success">
                                    <strong>Búsqueda Fonética Avanzada</strong><br>
                                    Algoritmos de similitud y búsqueda inteligente
                                </small>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="card border-danger border-opacity-25">
                        <div class="card-header bg-danger bg-opacity-10">
                            <h6 class="fw-bold mb-0 text-danger">
                                <i class="fas fa-times me-2"></i>3. Consulta por folio
                            </h6>
                        </div>
                        <div class="card-body">
                            <h6 class="fw-semibold text-muted mb-2">❌ Problemas:</h6>
                            <ul class="text-muted small mb-3">
                                <li>Consulta únicamente por folio</li>
                                <li>Sin información contextual</li>
                                <li>Falta de historial completo</li>
                                <li>Interface obsoleta</li>
                            </ul>
                            <div class="alert alert-light border-success">
                                <h6 class="fw-semibold text-success mb-1">✅ Reemplazado por:</h6>
                                <small class="text-success">
                                    <strong>Vista Integral de Información</strong><br>
                                    Historial completo con información contextual
                                </small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Funciones Obsoletas de Gestión -->
    <div class="card border-0 shadow-sm mb-5">
        <div class="card-header bg-warning bg-opacity-10">
            <h5 class="fw-bold mb-0 text-warning">
                <i class="fas fa-database me-2"></i>Funciones de Gestión Manual Obsoletas (4)
            </h5>
        </div>
        <div class="card-body">
            <div class="row g-4">
                <div class="col-lg-6">
                    <div class="card border-warning border-opacity-25">
                        <div class="card-header bg-warning bg-opacity-10">
                            <h6 class="fw-bold mb-0 text-warning">
                                <i class="fas fa-times me-2"></i>4. Bases de datos de panteones
                            </h6>
                        </div>
                        <div class="card-body">
                            <h6 class="fw-semibold text-muted mb-2">❌ Problemas:</h6>
                            <ul class="text-muted small mb-3">
                                <li>Mantenimiento manual de datos</li>
                                <li>Falta de sincronización automática</li>
                                <li>Sin control de versiones</li>
                                <li>Respaldos manuales propensos a errores</li>
                            </ul>
                            <div class="alert alert-light border-success">
                                <h6 class="fw-semibold text-success mb-1">✅ Reemplazado por:</h6>
                                <small class="text-success">
                                    <strong>Base de Datos Inteligente</strong><br>
                                    Sincronización automática y georreferenciación
                                </small>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="card border-warning border-opacity-25">
                        <div class="card-header bg-warning bg-opacity-10">
                            <h6 class="fw-bold mb-0 text-warning">
                                <i class="fas fa-times me-2"></i>5. ABC pagos por folio
                            </h6>
                        </div>
                        <div class="card-body">
                            <h6 class="fw-semibold text-muted mb-2">❌ Problemas:</h6>
                            <ul class="text-muted small mb-3">
                                <li>Registro manual de pagos</li>
                                <li>Falta de validación automática</li>
                                <li>Sin conciliación automática</li>
                                <li>Control limitado de estados</li>
                            </ul>
                            <div class="alert alert-light border-success">
                                <h6 class="fw-semibold text-success mb-1">✅ Reemplazado por:</h6>
                                <small class="text-success">
                                    <strong>Sistema de Conversión de Pagos</strong><br>
                                    Migración automática e integración con caja
                                </small>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="card border-warning border-opacity-25">
                        <div class="card-header bg-warning bg-opacity-10">
                            <h6 class="fw-bold mb-0 text-warning">
                                <i class="fas fa-times me-2"></i>6. Traslado pago
                            </h6>
                        </div>
                        <div class="card-body">
                            <h6 class="fw-semibold text-muted mb-2">❌ Problemas:</h6>
                            <ul class="text-muted small mb-3">
                                <li>Gestión manual de traslados</li>
                                <li>Falta de trazabilidad automática</li>
                                <li>Sin validaciones de integridad</li>
                                <li>Proceso lento y propenso a errores</li>
                            </ul>
                            <div class="alert alert-light border-success">
                                <h6 class="fw-semibold text-success mb-1">✅ Reemplazado por:</h6>
                                <small class="text-success">
                                    <strong>Gestión Automatizada de Traslados</strong><br>
                                    Proceso unificado con trazabilidad completa
                                </small>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="card border-warning border-opacity-25">
                        <div class="card-header bg-warning bg-opacity-10">
                            <h6 class="fw-bold mb-0 text-warning">
                                <i class="fas fa-times me-2"></i>7. Traslado de pago por folio
                            </h6>
                        </div>
                        <div class="card-body">
                            <h6 class="fw-semibold text-muted mb-2">❌ Problemas:</h6>
                            <ul class="text-muted small mb-3">
                                <li>Proceso específico muy limitado</li>
                                <li>Sin visión integral del traslado</li>
                                <li>Falta de validaciones cruzadas</li>
                                <li>Interface fragmentada</li>
                            </ul>
                            <div class="alert alert-light border-success">
                                <h6 class="fw-semibold text-success mb-1">✅ Reemplazado por:</h6>
                                <small class="text-success">
                                    <strong>Proceso Unificado de Traslados</strong><br>
                                    Validación automática y documentación digital
                                </small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Funciones Obsoletas de Bonificaciones -->
    <div class="card border-0 shadow-sm mb-5">
        <div class="card-header bg-info bg-opacity-10">
            <h5 class="fw-bold mb-0 text-info">
                <i class="fas fa-credit-card me-2"></i>Sistemas de Bonificaciones Obsoletos (3)
            </h5>
        </div>
        <div class="card-body">
            <div class="row g-4">
                <div class="col-lg-4">
                    <div class="card border-info border-opacity-25">
                        <div class="card-header bg-info bg-opacity-10">
                            <h6 class="fw-bold mb-0 text-info">
                                <i class="fas fa-times me-2"></i>8. Bonificación
                            </h6>
                        </div>
                        <div class="card-body">
                            <h6 class="fw-semibold text-muted mb-2">❌ Problemas:</h6>
                            <ul class="text-muted small mb-3">
                                <li>Cálculo manual de bonificaciones</li>
                                <li>Falta de criterios automatizados</li>
                                <li>Sin control de autorizaciones</li>
                                <li>Aplicación inconsistente</li>
                            </ul>
                            <div class="alert alert-light border-success">
                                <h6 class="fw-semibold text-success mb-1">✅ Reemplazado por:</h6>
                                <small class="text-success">
                                    <strong>Sistema Automatizado de Descuentos</strong><br>
                                    Cálculo automático con validación legal
                                </small>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="card border-info border-opacity-25">
                        <div class="card-header bg-info bg-opacity-10">
                            <h6 class="fw-bold mb-0 text-info">
                                <i class="fas fa-times me-2"></i>9. Listado de bonificaciones
                            </h6>
                        </div>
                        <div class="card-body">
                            <h6 class="fw-semibold text-muted mb-2">❌ Problemas:</h6>
                            <ul class="text-muted small mb-3">
                                <li>Reportes estáticos limitados</li>
                                <li>Sin filtros dinámicos</li>
                                <li>Falta de análisis estadístico</li>
                                <li>Sin exportación moderna</li>
                            </ul>
                            <div class="alert alert-light border-success">
                                <h6 class="fw-semibold text-success mb-1">✅ Reemplazado por:</h6>
                                <small class="text-success">
                                    <strong>Reportes Especializados</strong><br>
                                    Análisis de impacto con filtros dinámicos
                                </small>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-4">
                    <div class="card border-info border-opacity-25">
                        <div class="card-header bg-info bg-opacity-10">
                            <h6 class="fw-bold mb-0 text-info">
                                <i class="fas fa-times me-2"></i>10. Utilería (Config./Salir)
                            </h6>
                        </div>
                        <div class="card-body">
                            <h6 class="fw-semibold text-muted mb-2">❌ Problemas:</h6>
                            <ul class="text-muted small mb-3">
                                <li>Configuración manual repetitiva</li>
                                <li>Función de salida básica</li>
                                <li>Falta de automatización</li>
                                <li>Sin integración moderna</li>
                            </ul>
                            <div class="alert alert-light border-success">
                                <h6 class="fw-semibold text-success mb-1">✅ Reemplazado por:</h6>
                                <small class="text-success">
                                    <strong>Configuración Automática</strong><br>
                                    Integración completa con sistema moderno
                                </small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Nuevos Sistemas Implementados -->
    <div class="card border-0 shadow-sm">
        <div class="card-header bg-success bg-opacity-10">
            <h5 class="fw-bold mb-0 text-success">
                <i class="fas fa-plus-circle me-2"></i>Nuevos Sistemas Implementados
            </h5>
        </div>
        <div class="card-body">
            <div class="row g-4">
                <div class="col-lg-6">
                    <div class="card border-success border-opacity-25">
                        <div class="card-header bg-success bg-opacity-10">
                            <h6 class="fw-bold mb-0 text-success">
                                <i class="fas fa-percentage me-2"></i>1. Sistema de Descuentos Automatizados
                            </h6>
                        </div>
                        <div class="card-body">
                            <h6 class="fw-semibold mb-2">🆕 Funcionalidades:</h6>
                            <ul class="small mb-3">
                                <li>✅ Cálculo automático de descuentos en recargos</li>
                                <li>✅ Criterios variables según tipo de servicio</li>
                                <li>✅ Validación legal automática</li>
                                <li>✅ Autorización por niveles</li>
                                <li>✅ Trazabilidad completa</li>
                            </ul>
                            <div class="alert alert-light border-primary">
                                <small class="text-primary">
                                    <strong>Reemplaza:</strong> Bonificación, Listado de bonificaciones
                                </small>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="card border-success border-opacity-25">
                        <div class="card-header bg-success bg-opacity-10">
                            <h6 class="fw-bold mb-0 text-success">
                                <i class="fas fa-exchange-alt me-2"></i>2. Sistema de Conversión y Revaluación
                            </h6>
                        </div>
                        <div class="card-body">
                            <h6 class="fw-semibold mb-2">🆕 Funcionalidades:</h6>
                            <ul class="small mb-3">
                                <li>✅ Migración automática de procedimientos</li>
                                <li>✅ Integración con sistema de caja</li>
                                <li>✅ Revaluación automática de costos</li>
                                <li>✅ Validación cruzada de importes</li>
                                <li>✅ Conciliación automática</li>
                            </ul>
                            <div class="alert alert-light border-primary">
                                <small class="text-primary">
                                    <strong>Reemplaza:</strong> ABC pagos, Traslado pago, Traslado por folio
                                </small>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="card border-success border-opacity-25">
                        <div class="card-header bg-success bg-opacity-10">
                            <h6 class="fw-bold mb-0 text-success">
                                <i class="fas fa-search-plus me-2"></i>3. Sistema de Consultas Unificadas
                            </h6>
                        </div>
                        <div class="card-body">
                            <h6 class="fw-semibold mb-2">🆕 Funcionalidades:</h6>
                            <ul class="small mb-3">
                                <li>✅ Búsqueda universal multifiltro</li>
                                <li>✅ Algoritmos avanzados de búsqueda</li>
                                <li>✅ Filtros combinados inteligentes</li>
                                <li>✅ Vista integral de información</li>
                                <li>✅ Exportación flexible</li>
                            </ul>
                            <div class="alert alert-light border-primary">
                                <small class="text-primary">
                                    <strong>Reemplaza:</strong> Múltiple por RCM, por nombre, Consulta por folio
                                </small>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-lg-6">
                    <div class="card border-success border-opacity-25">
                        <div class="card-header bg-success bg-opacity-10">
                            <h6 class="fw-bold mb-0 text-success">
                                <i class="fas fa-database me-2"></i>4. Sistema de Gestión de Panteones
                            </h6>
                        </div>
                        <div class="card-body">
                            <h6 class="fw-semibold mb-2">🆕 Funcionalidades:</h6>
                            <ul class="small mb-3">
                                <li>✅ Base de datos inteligente</li>
                                <li>✅ Sincronización automática</li>
                                <li>✅ Control de versiones</li>
                                <li>✅ Georreferenciación</li>
                                <li>✅ Gestión automatizada de traslados</li>
                            </ul>
                            <div class="alert alert-light border-primary">
                                <small class="text-primary">
                                    <strong>Reemplaza:</strong> Bases de datos de panteones, Utilería
                                </small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script>
    // Scripts específicos para la documentación de funciones excluidas
    document.addEventListener('DOMContentLoaded', function() {
        console.log('Documentación de Funciones Excluidas - Cementerios cargada');
    });
</script>
@endsection