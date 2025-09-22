@extends('layouts.app')

@section('title', '🆕 Sistema de Conversión y Revaluación - Cementerios')

@section('content')
<div class="container-fluid mt-4">
    <!-- Header del Sistema -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #007bff !important;">
        <div class="card-body p-4">
            <div class="d-flex align-items-center mb-3">
                <div class="bg-primary bg-opacity-10 rounded-3 p-3 me-3">
                    <i class="fas fa-exchange-alt fa-2x text-primary"></i>
                </div>
                <div>
                    <h1 class="h3 fw-bold text-dark mb-1">
                        <span class="badge bg-danger me-2" style="font-size: 0.6em;">NUEVO</span>
                        Sistema de Conversión y Revaluación
                    </h1>
                    <p class="text-muted mb-0">Migración automática de procedimientos con revaluación inteligente de costos</p>
                </div>
            </div>

            <div class="alert alert-primary" role="alert">
                <div class="d-flex align-items-center">
                    <i class="fas fa-sync-alt me-2"></i>
                    <div>
                        <strong>🆕 Modernización de Procesos</strong>
                        <p class="mb-0 small">
                            Conversión automática de procedimientos manuales a digitales con revaluación dinámica de costos.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Funcionalidades Principales -->
    <div class="row g-4 mb-5">
        <div class="col-lg-6">
            <div class="card border-primary border-opacity-25 h-100">
                <div class="card-header bg-primary bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-primary">
                        <i class="fas fa-arrow-right me-2"></i>Conversión de Procedimientos
                    </h5>
                </div>
                <div class="card-body">
                    <ul class="list-unstyled">
                        <li class="mb-2"><i class="fas fa-check text-primary me-2"></i>Migración automática a digital</li>
                        <li class="mb-2"><i class="fas fa-check text-primary me-2"></i>Integración con sistema de caja</li>
                        <li class="mb-2"><i class="fas fa-check text-primary me-2"></i>Validación cruzada de importes</li>
                        <li class="mb-2"><i class="fas fa-check text-primary me-2"></i>Estados en tiempo real</li>
                        <li class="mb-2"><i class="fas fa-check text-primary me-2"></i>Conciliación automática</li>
                        <li class="mb-2"><i class="fas fa-check text-primary me-2"></i>Alertas inteligentes</li>
                    </ul>
                </div>
            </div>
        </div>

        <div class="col-lg-6">
            <div class="card border-warning border-opacity-25 h-100">
                <div class="card-header bg-warning bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-warning">
                        <i class="fas fa-calculator me-2"></i>Revaluación de Costos
                    </h5>
                </div>
                <div class="card-body">
                    <ul class="list-unstyled">
                        <li class="mb-2"><i class="fas fa-check text-warning me-2"></i>Actualización automática periódica</li>
                        <li class="mb-2"><i class="fas fa-check text-warning me-2"></i>Integración con UMA e inflación</li>
                        <li class="mb-2"><i class="fas fa-check text-warning me-2"></i>Proyecciones de costos futuros</li>
                        <li class="mb-2"><i class="fas fa-check text-warning me-2"></i>Comparativo histórico</li>
                        <li class="mb-2"><i class="fas fa-check text-warning me-2"></i>Evaluación de impacto financiero</li>
                        <li class="mb-2"><i class="fas fa-check text-warning me-2"></i>Reportes ejecutivos</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <!-- Optimización de Procesos -->
    <div class="card border-0 shadow-sm mb-5">
        <div class="card-header bg-light">
            <h5 class="fw-bold mb-0">
                <i class="fas fa-cogs me-2"></i>Optimización de Procesos
            </h5>
        </div>
        <div class="card-body">
            <div class="row g-4">
                <div class="col-md-6">
                    <div class="d-flex align-items-start">
                        <div class="bg-success bg-opacity-10 rounded-3 p-3 me-3">
                            <i class="fas fa-robot fa-lg text-success"></i>
                        </div>
                        <div>
                            <h6 class="fw-semibold">Flujos Automatizados</h6>
                            <p class="text-muted small mb-0">Eliminación de procesos manuales repetitivos con validaciones inteligentes automáticas.</p>
                        </div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="d-flex align-items-start">
                        <div class="bg-info bg-opacity-10 rounded-3 p-3 me-3">
                            <i class="fas fa-shield-alt fa-lg text-info"></i>
                        </div>
                        <div>
                            <h6 class="fw-semibold">Validaciones Inteligentes</h6>
                            <p class="text-muted small mb-0">Control automático de consistencia de datos con verificación en tiempo real.</p>
                        </div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="d-flex align-items-start">
                        <div class="bg-warning bg-opacity-10 rounded-3 p-3 me-3">
                            <i class="fas fa-database fa-lg text-warning"></i>
                        </div>
                        <div>
                            <h6 class="fw-semibold">Backup Automático</h6>
                            <p class="text-muted small mb-0">Respaldo automático de transacciones críticas con sistema de rollback.</p>
                        </div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="d-flex align-items-start">
                        <div class="bg-danger bg-opacity-10 rounded-3 p-3 me-3">
                            <i class="fas fa-undo fa-lg text-danger"></i>
                        </div>
                        <div>
                            <h6 class="fw-semibold">Recuperación de Errores</h6>
                            <p class="text-muted small mb-0">Sistema inteligente de rollback para corrección automática de errores.</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Índices Económicos -->
    <div class="card border-0 shadow-sm mb-5">
        <div class="card-header bg-light">
            <h5 class="fw-bold mb-0">
                <i class="fas fa-chart-line me-2"></i>Índices Económicos Integrados
            </h5>
        </div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-4">
                    <div class="text-center p-4 bg-primary bg-opacity-10 rounded-3">
                        <i class="fas fa-peso-sign fa-2x text-primary mb-3"></i>
                        <h6 class="fw-semibold">UMA</h6>
                        <p class="h4 fw-bold text-primary mb-1">$108.57</p>
                        <small class="text-muted">Unidad de Medida y Actualización</small>
                        <div class="mt-2">
                            <span class="badge bg-success"><i class="fas fa-arrow-up"></i> 2.3%</span>
                        </div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="text-center p-4 bg-warning bg-opacity-10 rounded-3">
                        <i class="fas fa-percentage fa-2x text-warning mb-3"></i>
                        <h6 class="fw-semibold">Inflación</h6>
                        <p class="h4 fw-bold text-warning mb-1">4.66%</p>
                        <small class="text-muted">Índice Nacional de Precios</small>
                        <div class="mt-2">
                            <span class="badge bg-info"><i class="fas fa-arrow-down"></i> 0.5%</span>
                        </div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="text-center p-4 bg-success bg-opacity-10 rounded-3">
                        <i class="fas fa-chart-bar fa-2x text-success mb-3"></i>
                        <h6 class="fw-semibold">Proyección</h6>
                        <p class="h4 fw-bold text-success mb-1">+15.2%</p>
                        <small class="text-muted">Incremento estimado anual</small>
                        <div class="mt-2">
                            <span class="badge bg-primary">Automático</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Métricas de Rendimiento -->
    <div class="card border-0 shadow-sm">
        <div class="card-header bg-light">
            <h5 class="fw-bold mb-0">
                <i class="fas fa-tachometer-alt me-2"></i>Métricas de Rendimiento
            </h5>
        </div>
        <div class="card-body">
            <div class="row g-4">
                <div class="col-md-3">
                    <div class="text-center">
                        <div class="bg-primary bg-opacity-10 rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 80px; height: 80px;">
                            <i class="fas fa-sync-alt fa-2x text-primary"></i>
                        </div>
                        <h5 class="fw-bold text-primary mb-1">95%</h5>
                        <p class="text-muted small mb-0">Automatización de procesos</p>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="text-center">
                        <div class="bg-success bg-opacity-10 rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 80px; height: 80px;">
                            <i class="fas fa-clock fa-2x text-success"></i>
                        </div>
                        <h5 class="fw-bold text-success mb-1">70%</h5>
                        <p class="text-muted small mb-0">Reducción de tiempo</p>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="text-center">
                        <div class="bg-warning bg-opacity-10 rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 80px; height: 80px;">
                            <i class="fas fa-target fa-2x text-warning"></i>
                        </div>
                        <h5 class="fw-bold text-warning mb-1">99.8%</h5>
                        <p class="text-muted small mb-0">Precisión en cálculos</p>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="text-center">
                        <div class="bg-info bg-opacity-10 rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 80px; height: 80px;">
                            <i class="fas fa-money-bill-wave fa-2x text-info"></i>
                        </div>
                        <h5 class="fw-bold text-info mb-1">15%</h5>
                        <p class="text-muted small mb-0">Mejora en ingresos</p>
                    </div>
                </div>
            </div>

            <hr class="my-4">

            <div class="row g-3">
                <div class="col-md-6">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <span class="text-muted">Conciliación automática</span>
                        <span class="fw-semibold">98.5%</span>
                    </div>
                    <div class="progress" style="height: 8px;">
                        <div class="progress-bar bg-success" style="width: 98.5%"></div>
                    </div>
                </div>

                <div class="col-md-6">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <span class="text-muted">Validación cruzada</span>
                        <span class="fw-semibold">99.2%</span>
                    </div>
                    <div class="progress" style="height: 8px;">
                        <div class="progress-bar bg-primary" style="width: 99.2%"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script>
    // Scripts específicos para el sistema de conversión y revaluación
    document.addEventListener('DOMContentLoaded', function() {
        console.log('Sistema de Conversión y Revaluación - Cementerios cargado');

        // Simular actualización de índices económicos
        setInterval(function() {
            // Actualización automática cada 30 segundos (solo para demo)
            console.log('Actualizando índices económicos...');
        }, 30000);
    });
</script>
@endsection