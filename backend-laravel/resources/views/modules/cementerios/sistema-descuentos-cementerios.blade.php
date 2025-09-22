@extends('layouts.app')

@section('title', '🆕 Sistema de Descuentos Automatizados - Cementerios')

@section('content')
<div class="container-fluid mt-4">
    <!-- Header del Sistema -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #28a745 !important;">
        <div class="card-body p-4">
            <div class="d-flex align-items-center mb-3">
                <div class="bg-success bg-opacity-10 rounded-3 p-3 me-3">
                    <i class="fas fa-percentage fa-2x text-success"></i>
                </div>
                <div>
                    <h1 class="h3 fw-bold text-dark mb-1">
                        <span class="badge bg-danger me-2" style="font-size: 0.6em;">NUEVO</span>
                        Sistema de Descuentos Automatizados
                    </h1>
                    <p class="text-muted mb-0">Gestión inteligente de descuentos en recargos con validación legal automática</p>
                </div>
            </div>

            <div class="alert alert-success" role="alert">
                <div class="d-flex align-items-center">
                    <i class="fas fa-check-circle me-2"></i>
                    <div>
                        <strong>🆕 Sistema Moderno Implementado</strong>
                        <p class="mb-0 small">
                            Automatización completa de descuentos con cálculos inteligentes y control por niveles de autorización.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Funcionalidades Principales -->
    <div class="row g-4 mb-5">
        <div class="col-lg-4">
            <div class="card border-success border-opacity-25 h-100">
                <div class="card-header bg-success bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-success">
                        <i class="fas fa-calculator me-2"></i>Cálculo Automático
                    </h5>
                </div>
                <div class="card-body">
                    <ul class="list-unstyled">
                        <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Aplicación automática de descuentos</li>
                        <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Criterios variables por servicio</li>
                        <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Validación legal automática</li>
                        <li class="mb-2"><i class="fas fa-check text-success me-2"></i>Trazabilidad completa</li>
                    </ul>
                </div>
            </div>
        </div>

        <div class="col-lg-4">
            <div class="card border-warning border-opacity-25 h-100">
                <div class="card-header bg-warning bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-warning">
                        <i class="fas fa-shield-alt me-2"></i>Control de Autorización
                    </h5>
                </div>
                <div class="card-body">
                    <ul class="list-unstyled">
                        <li class="mb-2"><i class="fas fa-check text-warning me-2"></i>Autorización por niveles</li>
                        <li class="mb-2"><i class="fas fa-check text-warning me-2"></i>Montos límite configurables</li>
                        <li class="mb-2"><i class="fas fa-check text-warning me-2"></i>Períodos de aplicación</li>
                        <li class="mb-2"><i class="fas fa-check text-warning me-2"></i>Historial de cambios</li>
                    </ul>
                </div>
            </div>
        </div>

        <div class="col-lg-4">
            <div class="card border-info border-opacity-25 h-100">
                <div class="card-header bg-info bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-info">
                        <i class="fas fa-chart-line me-2"></i>Reportes Especializados
                    </h5>
                </div>
                <div class="card-body">
                    <ul class="list-unstyled">
                        <li class="mb-2"><i class="fas fa-check text-info me-2"></i>Análisis de impacto</li>
                        <li class="mb-2"><i class="fas fa-check text-info me-2"></i>Descuentos otorgados</li>
                        <li class="mb-2"><i class="fas fa-check text-info me-2"></i>Tendencias y proyecciones</li>
                        <li class="mb-2"><i class="fas fa-check text-info me-2"></i>Exportación avanzada</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <!-- Tipos de Descuento -->
    <div class="card border-0 shadow-sm mb-5">
        <div class="card-header bg-light">
            <h5 class="fw-bold mb-0">
                <i class="fas fa-tags me-2"></i>Tipos de Descuento Configurables
            </h5>
        </div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-md-3">
                    <div class="text-center p-3 bg-primary bg-opacity-10 rounded-3">
                        <i class="fas fa-clock fa-2x text-primary mb-2"></i>
                        <h6 class="fw-semibold">Pronto Pago</h6>
                        <small class="text-muted">Descuentos por pago anticipado</small>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="text-center p-3 bg-success bg-opacity-10 rounded-3">
                        <i class="fas fa-heart fa-2x text-success mb-2"></i>
                        <h6 class="fw-semibold">Situación Vulnerable</h6>
                        <small class="text-muted">Apoyo social automático</small>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="text-center p-3 bg-warning bg-opacity-10 rounded-3">
                        <i class="fas fa-handshake fa-2x text-warning mb-2"></i>
                        <h6 class="fw-semibold">Convenios Especiales</h6>
                        <small class="text-muted">Acuerdos institucionales</small>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="text-center p-3 bg-info bg-opacity-10 rounded-3">
                        <i class="fas fa-star fa-2x text-info mb-2"></i>
                        <h6 class="fw-semibold">Casos Especiales</h6>
                        <small class="text-muted">Situaciones extraordinarias</small>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Indicadores de Rendimiento -->
    <div class="card border-0 shadow-sm">
        <div class="card-header bg-light">
            <h5 class="fw-bold mb-0">
                <i class="fas fa-chart-bar me-2"></i>Indicadores de Rendimiento
            </h5>
        </div>
        <div class="card-body">
            <div class="row g-4 text-center">
                <div class="col-md-3">
                    <div class="bg-success bg-opacity-10 rounded-3 p-4">
                        <h3 class="text-success fw-bold mb-1">100%</h3>
                        <p class="text-muted mb-0">Automatización de descuentos</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="bg-primary bg-opacity-10 rounded-3 p-4">
                        <h3 class="text-primary fw-bold mb-1">85%</h3>
                        <p class="text-muted mb-0">Reducción de tiempo</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="bg-warning bg-opacity-10 rounded-3 p-4">
                        <h3 class="text-warning fw-bold mb-1">99.5%</h3>
                        <p class="text-muted mb-0">Precisión en cálculos</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="bg-info bg-opacity-10 rounded-3 p-4">
                        <h3 class="text-info fw-bold mb-1">95%</h3>
                        <p class="text-muted mb-0">Reducción de errores</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script>
    // Scripts específicos para el sistema de descuentos si es necesario
    document.addEventListener('DOMContentLoaded', function() {
        console.log('Sistema de Descuentos Automatizados - Cementerios cargado');
    });
</script>
@endsection