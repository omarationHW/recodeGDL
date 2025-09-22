<template>
  <div class="container-fluid mt-4">
    <!-- Header del Sistema -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #28a745 !important;">
      <div class="card-body p-4">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-success bg-opacity-10 rounded-3 p-3 me-3">
              <i class="fas fa-handshake fa-2x text-success"></i>
            </div>
            <div>
              <h1 class="h3 fw-bold text-dark mb-1">Sistema Integral de Convenios - Otras Obligaciones</h1>
              <p class="text-muted mb-0">Gestión moderna de convenios para otras obligaciones fiscales</p>
            </div>
          </div>
          <div>
            <span class="badge bg-success fs-6">NUEVO</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Navegación por Tabs -->
    <div class="card border-0 shadow-sm mb-4">
      <div class="card-header bg-white border-0">
        <ul class="nav nav-tabs card-header-tabs" id="conveniosTab" role="tablist">
          <li class="nav-item" role="presentation">
            <button class="nav-link active" id="intereses-tab" data-bs-toggle="tab" data-bs-target="#intereses" type="button" role="tab">
              <i class="fas fa-percentage me-2"></i>Catálogo de Intereses
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="convenios-tab" data-bs-toggle="tab" data-bs-target="#convenios" type="button" role="tab">
              <i class="fas fa-file-contract me-2"></i>Gestión de Convenios
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="pagos-tab" data-bs-toggle="tab" data-bs-target="#pagos" type="button" role="tab">
              <i class="fas fa-credit-card me-2"></i>Sistema de Pagos
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="reportes-tab" data-bs-toggle="tab" data-bs-target="#reportes" type="button" role="tab">
              <i class="fas fa-chart-bar me-2"></i>Reportes Avanzados
            </button>
          </li>
        </ul>
      </div>

      <div class="card-body">
        <div class="tab-content" id="conveniosTabContent">

          <!-- Tab: Catálogo de Intereses -->
          <div class="tab-pane fade show active" id="intereses" role="tabpanel">
            <div class="row g-4">
              <div class="col-md-6">
                <div class="card h-100 border-success border-opacity-25">
                  <div class="card-header bg-success bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-success">
                      <i class="fas fa-plus-circle me-2"></i>Gestión de Tipos de Interés
                    </h5>
                  </div>
                  <div class="card-body">
                    <p class="text-muted mb-3">Administración completa del catálogo de intereses para convenios</p>

                    <div class="list-group list-group-flush">
                      <div class="list-group-item border-0 px-0">
                        <div class="d-flex align-items-center">
                          <i class="fas fa-check-circle text-success me-2"></i>
                          <span class="small">Altas con validaciones automáticas</span>
                        </div>
                      </div>
                      <div class="list-group-item border-0 px-0">
                        <div class="d-flex align-items-center">
                          <i class="fas fa-check-circle text-success me-2"></i>
                          <span class="small">Bajas controladas con verificación</span>
                        </div>
                      </div>
                      <div class="list-group-item border-0 px-0">
                        <div class="d-flex align-items-center">
                          <i class="fas fa-check-circle text-success me-2"></i>
                          <span class="small">Cambios con historial completo</span>
                        </div>
                      </div>
                      <div class="list-group-item border-0 px-0">
                        <div class="d-flex align-items-center">
                          <i class="fas fa-check-circle text-success me-2"></i>
                          <span class="small">Configuración de tasas variables</span>
                        </div>
                      </div>
                    </div>

                    <div class="mt-3">
                      <button class="btn btn-success btn-sm me-2">
                        <i class="fas fa-plus me-1"></i>Nuevo Tipo
                      </button>
                      <button class="btn btn-outline-success btn-sm">
                        <i class="fas fa-list me-1"></i>Ver Catálogo
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-md-6">
                <div class="card h-100 border-info border-opacity-25">
                  <div class="card-header bg-info bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-info">
                      <i class="fas fa-cogs me-2"></i>Configuración Avanzada
                    </h5>
                  </div>
                  <div class="card-body">
                    <p class="text-muted mb-3">Parámetros especializados para tipos de interés</p>

                    <div class="row g-3">
                      <div class="col-12">
                        <div class="bg-light rounded p-3">
                          <div class="d-flex align-items-center mb-2">
                            <i class="fas fa-calculator text-primary me-2"></i>
                            <span class="fw-bold small">Tasas Variables</span>
                          </div>
                          <p class="text-muted small mb-0">Configuración de tasas que cambian según criterios específicos</p>
                        </div>
                      </div>
                      <div class="col-12">
                        <div class="bg-light rounded p-3">
                          <div class="d-flex align-items-center mb-2">
                            <i class="fas fa-calendar text-primary me-2"></i>
                            <span class="fw-bold small">Períodos Específicos</span>
                          </div>
                          <p class="text-muted small mb-0">Definición de períodos de aplicación para cada tipo de interés</p>
                        </div>
                      </div>
                      <div class="col-12">
                        <div class="bg-light rounded p-3">
                          <div class="d-flex align-items-center mb-2">
                            <i class="fas fa-gavel text-primary me-2"></i>
                            <span class="fw-bold small">Criterios Legales</span>
                          </div>
                          <p class="text-muted small mb-0">Validación automática según marco normativo vigente</p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tab: Gestión de Convenios -->
          <div class="tab-pane fade" id="convenios" role="tabpanel">
            <div class="row g-4">
              <div class="col-lg-8">
                <div class="card border-primary border-opacity-25">
                  <div class="card-header bg-primary bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-primary">
                      <i class="fas fa-file-contract me-2"></i>Gestión Integral de Convenios
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="row g-4">
                      <div class="col-md-6">
                        <h6 class="fw-bold text-dark">Datos Generales</h6>
                        <ul class="list-unstyled text-muted small">
                          <li><i class="fas fa-user me-2 text-primary"></i>Información completa del contribuyente</li>
                          <li><i class="fas fa-file-alt me-2 text-primary"></i>Detalles de la obligación fiscal</li>
                          <li><i class="fas fa-calendar me-2 text-primary"></i>Períodos y fechas relevantes</li>
                          <li><i class="fas fa-map-marker-alt me-2 text-primary"></i>Ubicación y referencias</li>
                        </ul>
                      </div>
                      <div class="col-md-6">
                        <h6 class="fw-bold text-dark">Importes Automatizados</h6>
                        <ul class="list-unstyled text-muted small">
                          <li><i class="fas fa-calculator me-2 text-success"></i>Cálculo automático de parcialidades</li>
                          <li><i class="fas fa-percentage me-2 text-success"></i>Aplicación automática de intereses</li>
                          <li><i class="fas fa-coins me-2 text-success"></i>Desglose por rubros específicos</li>
                          <li><i class="fas fa-check-circle me-2 text-success"></i>Validaciones de integridad</li>
                        </ul>
                      </div>
                    </div>

                    <div class="mt-4">
                      <div class="alert alert-info">
                        <div class="d-flex align-items-center">
                          <i class="fas fa-info-circle me-2"></i>
                          <div>
                            <strong>Desglose de Parcialidades</strong>
                            <p class="mb-0 small">Sistema automático de generación de parcialidades con rubros detallados para facilitar el cobro en caja y el seguimiento de pagos.</p>
                          </div>
                        </div>
                      </div>
                    </div>

                    <div class="d-flex gap-2 mt-3">
                      <button class="btn btn-primary btn-sm">
                        <i class="fas fa-plus me-1"></i>Nuevo Convenio
                      </button>
                      <button class="btn btn-outline-primary btn-sm">
                        <i class="fas fa-search me-1"></i>Buscar Convenio
                      </button>
                      <button class="btn btn-outline-primary btn-sm">
                        <i class="fas fa-print me-1"></i>Imprimir Convenio
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="card border-warning border-opacity-25">
                  <div class="card-header bg-warning bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-warning">
                      <i class="fas fa-print me-2"></i>Documentos Oficiales
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="text-center mb-3">
                      <div class="bg-warning bg-opacity-10 rounded-circle p-3 d-inline-flex">
                        <i class="fas fa-file-pdf fa-2x text-warning"></i>
                      </div>
                    </div>

                    <div class="list-group list-group-flush">
                      <div class="list-group-item border-0 px-0">
                        <div class="d-flex justify-content-between align-items-center">
                          <span class="small">Convenio Oficial</span>
                          <button class="btn btn-outline-warning btn-sm">
                            <i class="fas fa-download"></i>
                          </button>
                        </div>
                      </div>
                      <div class="list-group-item border-0 px-0">
                        <div class="d-flex justify-content-between align-items-center">
                          <span class="small">Pagaré</span>
                          <button class="btn btn-outline-warning btn-sm">
                            <i class="fas fa-download"></i>
                          </button>
                        </div>
                      </div>
                      <div class="list-group-item border-0 px-0">
                        <div class="d-flex justify-content-between align-items-center">
                          <span class="small">Estado de Cuenta</span>
                          <button class="btn btn-outline-warning btn-sm">
                            <i class="fas fa-download"></i>
                          </button>
                        </div>
                      </div>
                    </div>

                    <div class="mt-3 text-center">
                      <span class="badge bg-warning text-dark">Plantillas Personalizables</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tab: Sistema de Pagos -->
          <div class="tab-pane fade" id="pagos" role="tabpanel">
            <div class="row g-4">
              <div class="col-md-4">
                <div class="card text-center border-success border-opacity-25 h-100">
                  <div class="card-body">
                    <div class="bg-success bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-cash-register fa-2x text-success"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Registro de Pagos</h5>
                    <p class="text-muted small">Captura automática desde sistema de caja con conciliación en tiempo real</p>
                    <button class="btn btn-outline-success btn-sm">
                      <i class="fas fa-plus me-1"></i>Registrar Pago
                    </button>
                  </div>
                </div>
              </div>

              <div class="col-md-4">
                <div class="card text-center border-primary border-opacity-25 h-100">
                  <div class="card-body">
                    <div class="bg-primary bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-balance-scale fa-2x text-primary"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Conciliación</h5>
                    <p class="text-muted small">Verificación automática de importes y estados de cuenta actualizados</p>
                    <button class="btn btn-outline-primary btn-sm">
                      <i class="fas fa-sync me-1"></i>Conciliar
                    </button>
                  </div>
                </div>
              </div>

              <div class="col-md-4">
                <div class="card text-center border-warning border-opacity-25 h-100">
                  <div class="card-body">
                    <div class="bg-warning bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-bell fa-2x text-warning"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Alertas</h5>
                    <p class="text-muted small">Notificaciones automáticas de vencimientos y confirmación de pagos</p>
                    <button class="btn btn-outline-warning btn-sm">
                      <i class="fas fa-cog me-1"></i>Configurar
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <div class="mt-4">
              <div class="card border-info border-opacity-25">
                <div class="card-header bg-info bg-opacity-10">
                  <h5 class="fw-bold mb-0 text-info">
                    <i class="fas fa-chart-line me-2"></i>Control de Estados de Cuenta
                  </h5>
                </div>
                <div class="card-body">
                  <div class="row">
                    <div class="col-md-6">
                      <h6 class="fw-bold text-dark">Funcionalidades Automáticas</h6>
                      <ul class="list-unstyled text-muted small">
                        <li><i class="fas fa-robot me-2 text-info"></i>Generación automática de saldos</li>
                        <li><i class="fas fa-sync-alt me-2 text-info"></i>Actualización en tiempo real</li>
                        <li><i class="fas fa-history me-2 text-info"></i>Historial completo de movimientos</li>
                        <li><i class="fas fa-shield-alt me-2 text-info"></i>Verificación de integridad</li>
                      </ul>
                    </div>
                    <div class="col-md-6">
                      <h6 class="fw-bold text-dark">Controles de Calidad</h6>
                      <ul class="list-unstyled text-muted small">
                        <li><i class="fas fa-check-double me-2 text-success"></i>Validación de importes</li>
                        <li><i class="fas fa-calculator me-2 text-success"></i>Verificación de cálculos</li>
                        <li><i class="fas fa-flag me-2 text-success"></i>Detección de inconsistencias</li>
                        <li><i class="fas fa-user-shield me-2 text-success"></i>Trazabilidad de operaciones</li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tab: Reportes Avanzados -->
          <div class="tab-pane fade" id="reportes" role="tabpanel">
            <div class="row g-4">
              <div class="col-lg-8">
                <div class="card border-primary border-opacity-25">
                  <div class="card-header bg-primary bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-primary">
                      <i class="fas fa-chart-bar me-2"></i>Reportes Integrales
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-md-6">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center mb-2">
                              <i class="fas fa-users text-primary me-2"></i>
                              <span class="fw-bold small">Padrón de Convenios</span>
                            </div>
                            <p class="text-muted small mb-2">Listado completo con filtros avanzados por estado, fecha, tipo y monto</p>
                            <button class="btn btn-outline-primary btn-sm">
                              <i class="fas fa-external-link-alt me-1"></i>Generar
                            </button>
                          </div>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center mb-2">
                              <i class="fas fa-coins text-warning me-2"></i>
                              <span class="fw-bold small">Adeudos y Pagos</span>
                            </div>
                            <p class="text-muted small mb-2">Análisis financiero detallado con proyecciones y tendencias</p>
                            <button class="btn btn-outline-warning btn-sm">
                              <i class="fas fa-external-link-alt me-1"></i>Generar
                            </button>
                          </div>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center mb-2">
                              <i class="fas fa-file-excel text-success me-2"></i>
                              <span class="fw-bold small">Exportación Excel</span>
                            </div>
                            <p class="text-muted small mb-2">Datos listos para análisis con formato y fórmulas integradas</p>
                            <button class="btn btn-outline-success btn-sm">
                              <i class="fas fa-download me-1"></i>Exportar
                            </button>
                          </div>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center mb-2">
                              <i class="fas fa-clock text-info me-2"></i>
                              <span class="fw-bold small">Reportes Automáticos</span>
                            </div>
                            <p class="text-muted small mb-2">Generación programada con envío automático por correo</p>
                            <button class="btn btn-outline-info btn-sm">
                              <i class="fas fa-cog me-1"></i>Configurar
                            </button>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="card border-danger border-opacity-25">
                  <div class="card-header bg-danger bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-danger">
                      <i class="fas fa-trash-alt me-2"></i>Cancelación Masiva
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="text-center mb-3">
                      <div class="bg-danger bg-opacity-10 rounded-circle p-3 d-inline-flex">
                        <i class="fas fa-exclamation-triangle fa-2x text-danger"></i>
                      </div>
                    </div>

                    <h6 class="fw-bold text-dark">Control Inteligente</h6>
                    <ul class="list-unstyled text-muted small mb-3">
                      <li><i class="fas fa-robot me-2 text-danger"></i>Criterios automatizados</li>
                      <li><i class="fas fa-user-cog me-2 text-danger"></i>Selección manual</li>
                      <li><i class="fas fa-layer-group me-2 text-danger"></i>Procesamiento en lote</li>
                      <li><i class="fas fa-history me-2 text-danger"></i>Trazabilidad completa</li>
                    </ul>

                    <div class="alert alert-warning small">
                      <i class="fas fa-info-circle me-1"></i>
                      <strong>Criterio:</strong> Convenios con 2+ parcialidades vencidas
                    </div>

                    <button class="btn btn-danger btn-sm w-100">
                      <i class="fas fa-trash me-1"></i>Cancelación Masiva
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>

    <!-- Estadísticas Rápidas -->
    <div class="row g-3">
      <div class="col-md-3">
        <div class="card border-0 bg-primary text-white">
          <div class="card-body text-center">
            <i class="fas fa-file-contract fa-2x mb-2"></i>
            <h4 class="fw-bold">1,247</h4>
            <p class="mb-0 small">Convenios Activos</p>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-0 bg-success text-white">
          <div class="card-body text-center">
            <i class="fas fa-coins fa-2x mb-2"></i>
            <h4 class="fw-bold">$2.8M</h4>
            <p class="mb-0 small">Pagos del Mes</p>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-0 bg-warning text-white">
          <div class="card-body text-center">
            <i class="fas fa-clock fa-2x mb-2"></i>
            <h4 class="fw-bold">156</h4>
            <p class="mb-0 small">Próximos Vencimientos</p>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-0 bg-info text-white">
          <div class="card-body text-center">
            <i class="fas fa-percentage fa-2x mb-2"></i>
            <h4 class="fw-bold">94.2%</h4>
            <p class="mb-0 small">Cumplimiento</p>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
export default {
  name: 'SistemaConveniosOtrasOblig',
  data() {
    return {
      // Estado del componente
    }
  }
}
</script>

<style scoped>
.nav-tabs .nav-link {
  border: none;
  color: #6c757d;
  font-weight: 500;
}

.nav-tabs .nav-link.active {
  color: #495057;
  background-color: #fff;
  border-color: #dee2e6 #dee2e6 #fff;
  font-weight: 600;
}

.card {
  transition: transform 0.2s ease;
}

.card:hover {
  transform: translateY(-2px);
}
</style>