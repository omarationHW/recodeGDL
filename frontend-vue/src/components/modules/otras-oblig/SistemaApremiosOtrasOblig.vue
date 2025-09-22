<template>
  <div class="container-fluid mt-4">
    <!-- Header del Sistema -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #dc3545 !important;">
      <div class="card-body p-4">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-danger bg-opacity-10 rounded-3 p-3 me-3">
              <i class="fas fa-gavel fa-2x text-danger"></i>
            </div>
            <div>
              <h1 class="h3 fw-bold text-dark mb-1">Sistema Integral de Apremios - Otras Obligaciones</h1>
              <p class="text-muted mb-0">Gestión avanzada de apremios para otras obligaciones fiscales</p>
            </div>
          </div>
          <div>
            <span class="badge bg-danger fs-6">NUEVO</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Navegación por Tabs -->
    <div class="card border-0 shadow-sm mb-4">
      <div class="card-header bg-white border-0">
        <ul class="nav nav-tabs card-header-tabs" id="apremiosTab" role="tablist">
          <li class="nav-item" role="presentation">
            <button class="nav-link active" id="ejecutores-tab" data-bs-toggle="tab" data-bs-target="#ejecutores" type="button" role="tab">
              <i class="fas fa-users me-2"></i>Catálogo Ejecutores
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="folios-tab" data-bs-toggle="tab" data-bs-target="#folios" type="button" role="tab">
              <i class="fas fa-file-signature me-2"></i>Gestión de Folios
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="impresion-tab" data-bs-toggle="tab" data-bs-target="#impresion" type="button" role="tab">
              <i class="fas fa-print me-2"></i>Impresión Legal
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="reportes-apremios-tab" data-bs-toggle="tab" data-bs-target="#reportes-apremios" type="button" role="tab">
              <i class="fas fa-chart-line me-2"></i>Reportes Especializados
            </button>
          </li>
        </ul>
      </div>

      <div class="card-body">
        <div class="tab-content" id="apremiosTabContent">

          <!-- Tab: Catálogo de Ejecutores -->
          <div class="tab-pane fade show active" id="ejecutores" role="tabpanel">
            <div class="row g-4">
              <div class="col-lg-6">
                <div class="card border-primary border-opacity-25">
                  <div class="card-header bg-primary bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-primary">
                      <i class="fas fa-user-tie me-2"></i>Gestión de Personal Ejecutor
                    </h5>
                  </div>
                  <div class="card-body">
                    <p class="text-muted mb-4">Administración completa del personal especializado en procedimientos de apremio</p>

                    <div class="row g-3">
                      <div class="col-md-6">
                        <div class="bg-light rounded p-3">
                          <div class="d-flex align-items-center mb-2">
                            <i class="fas fa-id-badge text-primary me-2"></i>
                            <span class="fw-bold small">Registro Completo</span>
                          </div>
                          <ul class="list-unstyled text-muted small mb-0">
                            <li>• Datos personales completos</li>
                            <li>• Certificaciones profesionales</li>
                            <li>• Historial de desempeño</li>
                            <li>• Contacto y disponibilidad</li>
                          </ul>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <div class="bg-light rounded p-3">
                          <div class="d-flex align-items-center mb-2">
                            <i class="fas fa-map-marked-alt text-success me-2"></i>
                            <span class="fw-bold small">Control Territorial</span>
                          </div>
                          <ul class="list-unstyled text-muted small mb-0">
                            <li>• Asignación automática de zonas</li>
                            <li>• Optimización de rutas</li>
                            <li>• Control de cargas de trabajo</li>
                            <li>• Seguimiento GPS integrado</li>
                          </ul>
                        </div>
                      </div>
                    </div>

                    <div class="mt-4">
                      <div class="d-flex gap-2">
                        <button class="btn btn-primary btn-sm">
                          <i class="fas fa-user-plus me-1"></i>Nuevo Ejecutor
                        </button>
                        <button class="btn btn-outline-primary btn-sm">
                          <i class="fas fa-search me-1"></i>Buscar
                        </button>
                        <button class="btn btn-outline-success btn-sm">
                          <i class="fas fa-map me-1"></i>Ver Asignaciones
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-lg-6">
                <div class="card border-info border-opacity-25">
                  <div class="card-header bg-info bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-info">
                      <i class="fas fa-cogs me-2"></i>Capacidades y Especialidades
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-12">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center justify-content-between mb-2">
                              <span class="fw-bold small">Perfil Detallado</span>
                              <span class="badge bg-info">Activo</span>
                            </div>
                            <p class="text-muted small mb-2">Registro especializado de competencias y áreas de experticia</p>
                            <div class="progress mb-2" style="height: 8px;">
                              <div class="progress-bar bg-info" style="width: 85%"></div>
                            </div>
                            <small class="text-muted">Eficiencia: 85%</small>
                          </div>
                        </div>
                      </div>
                      <div class="col-12">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center justify-content-between mb-2">
                              <span class="fw-bold small">Disponibilidad</span>
                              <span class="badge bg-success">En Línea</span>
                            </div>
                            <p class="text-muted small mb-2">Estado en tiempo real con sistema de seguimiento integrado</p>
                            <div class="d-flex gap-1">
                              <span class="badge bg-success">Disponible</span>
                              <span class="badge bg-warning text-dark">En Campo</span>
                              <span class="badge bg-danger">Ocupado</span>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tab: Gestión de Folios -->
          <div class="tab-pane fade" id="folios" role="tabpanel">
            <div class="row g-4">
              <div class="col-lg-8">
                <div class="card border-warning border-opacity-25">
                  <div class="card-header bg-warning bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-warning">
                      <i class="fas fa-file-signature me-2"></i>Generación Inteligente de Folios
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="row g-4">
                      <div class="col-md-6">
                        <h6 class="fw-bold text-dark">Criterios Automatizados</h6>
                        <div class="list-group list-group-flush">
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center">
                              <i class="fas fa-robot text-primary me-2"></i>
                              <span class="small">Selección automática basada en reglas</span>
                            </div>
                          </div>
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center">
                              <i class="fas fa-bell text-success me-2"></i>
                              <span class="small">Notificaciones automáticas</span>
                            </div>
                          </div>
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center">
                              <i class="fas fa-sort-numeric-up text-info me-2"></i>
                              <span class="small">Control de secuencia automático</span>
                            </div>
                          </div>
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center">
                              <i class="fas fa-shield-alt text-warning me-2"></i>
                              <span class="small">Validaciones legales</span>
                            </div>
                          </div>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <h6 class="fw-bold text-dark">Gestión Masiva</h6>
                        <div class="list-group list-group-flush">
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center justify-content-between">
                              <span class="small">Asignación Masiva</span>
                              <button class="btn btn-outline-primary btn-sm">
                                <i class="fas fa-users"></i>
                              </button>
                            </div>
                          </div>
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center justify-content-between">
                              <span class="small">Cancelación en Lote</span>
                              <button class="btn btn-outline-danger btn-sm">
                                <i class="fas fa-times-circle"></i>
                              </button>
                            </div>
                          </div>
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center justify-content-between">
                              <span class="small">Practicar Folios</span>
                              <button class="btn btn-outline-success btn-sm">
                                <i class="fas fa-play-circle"></i>
                              </button>
                            </div>
                          </div>
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center justify-content-between">
                              <span class="small">Control de Estados</span>
                              <button class="btn btn-outline-info btn-sm">
                                <i class="fas fa-eye"></i>
                              </button>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>

                    <div class="mt-4">
                      <div class="alert alert-info">
                        <div class="d-flex align-items-center">
                          <i class="fas fa-lightbulb me-2"></i>
                          <div>
                            <strong>Generación Masiva de Requerimientos</strong>
                            <p class="mb-0 small">Sistema automatizado para la generación masiva de folios de notificación y/o requerimientos basado en criterios predefinidos y validaciones legales.</p>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="card border-success border-opacity-25">
                  <div class="card-header bg-success bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-success">
                      <i class="fas fa-edit me-2"></i>Modificación de Folios
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="text-center mb-3">
                      <div class="bg-success bg-opacity-10 rounded-circle p-3 d-inline-flex">
                        <i class="fas fa-history fa-2x text-success"></i>
                      </div>
                    </div>

                    <h6 class="fw-bold text-dark">Edición Controlada</h6>
                    <ul class="list-unstyled text-muted small mb-3">
                      <li><i class="fas fa-lock me-2 text-success"></i>Cambios con autorización</li>
                      <li><i class="fas fa-history me-2 text-success"></i>Historial de versiones</li>
                      <li><i class="fas fa-check-circle me-2 text-success"></i>Validaciones de integridad</li>
                      <li><i class="fas fa-user-shield me-2 text-success"></i>Sistema de permisos</li>
                    </ul>

                    <div class="alert alert-warning small">
                      <i class="fas fa-exclamation-triangle me-1"></i>
                      <strong>Trazabilidad:</strong> Registro completo de modificaciones
                    </div>

                    <button class="btn btn-success btn-sm w-100">
                      <i class="fas fa-edit me-1"></i>Modificar Folio
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tab: Impresión Legal -->
          <div class="tab-pane fade" id="impresion" role="tabpanel">
            <div class="row g-4">
              <div class="col-md-4">
                <div class="card text-center border-primary border-opacity-25 h-100">
                  <div class="card-body">
                    <div class="bg-primary bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-file-alt fa-2x text-primary"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Formatos Oficiales</h5>
                    <p class="text-muted small">Plantillas aprobadas por la Dirección de Política Fiscal y Mejora Hacendaria</p>
                    <div class="d-flex flex-column gap-2">
                      <button class="btn btn-outline-primary btn-sm">
                        <i class="fas fa-file-pdf me-1"></i>Notificación
                      </button>
                      <button class="btn btn-outline-primary btn-sm">
                        <i class="fas fa-file-pdf me-1"></i>Requerimiento
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-md-4">
                <div class="card text-center border-warning border-opacity-25 h-100">
                  <div class="card-body">
                    <div class="bg-warning bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-gavel fa-2x text-warning"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Fundamentos Legales</h5>
                    <p class="text-muted small">Inclusión automática del marco jurídico vigente según el tipo de procedimiento</p>
                    <div class="d-flex flex-column gap-2">
                      <button class="btn btn-outline-warning btn-sm">
                        <i class="fas fa-book me-1"></i>Marco Legal
                      </button>
                      <button class="btn btn-outline-warning btn-sm">
                        <i class="fas fa-cog me-1"></i>Configurar
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-md-4">
                <div class="card text-center border-success border-opacity-25 h-100">
                  <div class="card-body">
                    <div class="bg-success bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-check-double fa-2x text-success"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Control de Calidad</h5>
                    <p class="text-muted small">Validación automática antes de impresión con verificación de datos y formato</p>
                    <div class="d-flex flex-column gap-2">
                      <button class="btn btn-outline-success btn-sm">
                        <i class="fas fa-search me-1"></i>Validar
                      </button>
                      <button class="btn btn-outline-success btn-sm">
                        <i class="fas fa-print me-1"></i>Imprimir
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div class="mt-4">
              <div class="card border-info border-opacity-25">
                <div class="card-header bg-info bg-opacity-10">
                  <h5 class="fw-bold mb-0 text-info">
                    <i class="fas fa-paint-brush me-2"></i>Personalización Avanzada
                  </h5>
                </div>
                <div class="card-body">
                  <div class="row">
                    <div class="col-md-6">
                      <h6 class="fw-bold text-dark">Adaptación por Tipo</h6>
                      <ul class="list-unstyled text-muted small">
                        <li><i class="fas fa-file-signature me-2 text-info"></i>Notificaciones de requerimiento</li>
                        <li><i class="fas fa-exclamation-triangle me-2 text-info"></i>Avisos de embargo</li>
                        <li><i class="fas fa-gavel me-2 text-info"></i>Actas de notificación</li>
                        <li><i class="fas fa-file-contract me-2 text-info"></i>Documentos de diligencia</li>
                      </ul>
                    </div>
                    <div class="col-md-6">
                      <h6 class="fw-bold text-dark">Elementos Dinámicos</h6>
                      <ul class="list-unstyled text-muted small">
                        <li><i class="fas fa-calendar me-2 text-success"></i>Fechas automáticas</li>
                        <li><i class="fas fa-user me-2 text-success"></i>Datos del contribuyente</li>
                        <li><i class="fas fa-coins me-2 text-success"></i>Importes actualizados</li>
                        <li><i class="fas fa-map-marker-alt me-2 text-success"></i>Direcciones verificadas</li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tab: Reportes Especializados -->
          <div class="tab-pane fade" id="reportes-apremios" role="tabpanel">
            <div class="row g-4">
              <div class="col-lg-8">
                <div class="card border-primary border-opacity-25">
                  <div class="card-header bg-primary bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-primary">
                      <i class="fas fa-chart-bar me-2"></i>Reportes de Gestión
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-md-6">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center mb-2">
                              <i class="fas fa-users text-primary me-2"></i>
                              <span class="fw-bold small">Catálogo de Ejecutores</span>
                            </div>
                            <p class="text-muted small mb-2">Listado completo con estadísticas de desempeño y eficiencia</p>
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
                              <i class="fas fa-percentage text-success me-2"></i>
                              <span class="fw-bold small">Listado de Descuentos</span>
                            </div>
                            <p class="text-muted small mb-2">Análisis detallado de descuentos aplicados y su impacto fiscal</p>
                            <button class="btn btn-outline-success btn-sm">
                              <i class="fas fa-external-link-alt me-1"></i>Generar
                            </button>
                          </div>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center mb-2">
                              <i class="fas fa-money-check text-warning me-2"></i>
                              <span class="fw-bold small">Nómina de Ejecutores</span>
                            </div>
                            <p class="text-muted small mb-2">Cálculo automático de pagos basado en folios asignados</p>
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
                              <i class="fas fa-file-signature text-info me-2"></i>
                              <span class="fw-bold small">Estados de Folios</span>
                            </div>
                            <p class="text-muted small mb-2">Seguimiento detallado por ejecutor con criterios específicos</p>
                            <button class="btn btn-outline-info btn-sm">
                              <i class="fas fa-external-link-alt me-1"></i>Generar
                            </button>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="card border-success border-opacity-25">
                  <div class="card-header bg-success bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-success">
                      <i class="fas fa-search me-2"></i>Consulta Avanzada
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="text-center mb-3">
                      <div class="bg-success bg-opacity-10 rounded-circle p-3 d-inline-flex">
                        <i class="fas fa-filter fa-2x text-success"></i>
                      </div>
                    </div>

                    <h6 class="fw-bold text-dark">Búsqueda Múltiple</h6>
                    <ul class="list-unstyled text-muted small mb-3">
                      <li><i class="fas fa-hashtag me-2 text-success"></i>Por número de folio</li>
                      <li><i class="fas fa-user me-2 text-success"></i>Por ejecutor asignado</li>
                      <li><i class="fas fa-calendar me-2 text-success"></i>Por rango de fechas</li>
                      <li><i class="fas fa-flag me-2 text-success"></i>Por estado del proceso</li>
                    </ul>

                    <div class="alert alert-info small">
                      <i class="fas fa-clock me-1"></i>
                      <strong>Tiempo Real:</strong> Información actualizada automáticamente
                    </div>

                    <button class="btn btn-success btn-sm w-100">
                      <i class="fas fa-search me-1"></i>Buscar Folios
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>

    <!-- Estadísticas de Rendimiento -->
    <div class="row g-3">
      <div class="col-md-3">
        <div class="card border-0 bg-danger text-white">
          <div class="card-body text-center">
            <i class="fas fa-file-signature fa-2x mb-2"></i>
            <h4 class="fw-bold">2,341</h4>
            <p class="mb-0 small">Folios Activos</p>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-0 bg-warning text-white">
          <div class="card-body text-center">
            <i class="fas fa-users fa-2x mb-2"></i>
            <h4 class="fw-bold">24</h4>
            <p class="mb-0 small">Ejecutores Activos</p>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-0 bg-success text-white">
          <div class="card-body text-center">
            <i class="fas fa-check-circle fa-2x mb-2"></i>
            <h4 class="fw-bold">1,856</h4>
            <p class="mb-0 small">Folios Practicados</p>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-0 bg-info text-white">
          <div class="card-body text-center">
            <i class="fas fa-chart-line fa-2x mb-2"></i>
            <h4 class="fw-bold">79.3%</h4>
            <p class="mb-0 small">Eficiencia</p>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
export default {
  name: 'SistemaApremiosOtrasOblig',
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