<template>
  <div class="container-fluid mt-4">
    <!-- Header del Sistema -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #6f42c1 !important;">
      <div class="card-body p-4">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-primary bg-opacity-10 rounded-3 p-3 me-3">
              <i class="fas fa-percentage fa-2x text-primary"></i>
            </div>
            <div>
              <h1 class="h3 fw-bold text-dark mb-1">Sistema de Descuentos y Conversión - Otras Obligaciones</h1>
              <p class="text-muted mb-0">Conversión automática de procedimientos y descuentos especializados</p>
            </div>
          </div>
          <div>
            <span class="badge bg-primary fs-6">NUEVO</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Navegación por Tabs -->
    <div class="card border-0 shadow-sm mb-4">
      <div class="card-header bg-white border-0">
        <ul class="nav nav-tabs card-header-tabs" id="descuentosTab" role="tablist">
          <li class="nav-item" role="presentation">
            <button class="nav-link active" id="recargos-tab" data-bs-toggle="tab" data-bs-target="#recargos" type="button" role="tab">
              <i class="fas fa-percent me-2"></i>Descuentos en Recargos
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="multas-tab" data-bs-toggle="tab" data-bs-target="#multas" type="button" role="tab">
              <i class="fas fa-file-invoice-dollar me-2"></i>Descuentos en Multas
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="conversion-tab" data-bs-toggle="tab" data-bs-target="#conversion" type="button" role="tab">
              <i class="fas fa-exchange-alt me-2"></i>Conversión de Procedimientos
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="criterios-tab" data-bs-toggle="tab" data-bs-target="#criterios" type="button" role="tab">
              <i class="fas fa-gavel me-2"></i>Criterios Legales
            </button>
          </li>
        </ul>
      </div>

      <div class="card-body">
        <div class="tab-content" id="descuentosTabContent">

          <!-- Tab: Descuentos en Recargos -->
          <div class="tab-pane fade show active" id="recargos" role="tabpanel">
            <div class="row g-4">
              <div class="col-lg-6">
                <div class="card border-success border-opacity-25">
                  <div class="card-header bg-success bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-success">
                      <i class="fas fa-calculator me-2"></i>Cálculo Automático de Descuentos
                    </h5>
                  </div>
                  <div class="card-body">
                    <p class="text-muted mb-4">Sistema automatizado para aplicación de descuentos en recargos según criterios fiscales vigentes</p>

                    <div class="row g-3">
                      <div class="col-md-6">
                        <div class="bg-light rounded p-3">
                          <div class="d-flex align-items-center mb-2">
                            <i class="fas fa-magic text-success me-2"></i>
                            <span class="fw-bold small">Automatización</span>
                          </div>
                          <ul class="list-unstyled text-muted small mb-0">
                            <li>• Cálculo automático de porcentajes</li>
                            <li>• Aplicación según criterios legales</li>
                            <li>• Validación de requisitos</li>
                            <li>• Registro de trazabilidad</li>
                          </ul>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <div class="bg-light rounded p-3">
                          <div class="d-flex align-items-center mb-2">
                            <i class="fas fa-chart-pie text-primary me-2"></i>
                            <span class="fw-bold small">Criterios Variables</span>
                          </div>
                          <ul class="list-unstyled text-muted small mb-0">
                            <li>• Descuentos por pronto pago</li>
                            <li>• Regularización voluntaria</li>
                            <li>• Situación socioeconómica</li>
                            <li>• Convenios especiales</li>
                          </ul>
                        </div>
                      </div>
                    </div>

                    <div class="mt-4">
                      <div class="alert alert-success">
                        <div class="d-flex align-items-center">
                          <i class="fas fa-info-circle me-2"></i>
                          <div>
                            <strong>Descuentos Inteligentes</strong>
                            <p class="mb-0 small">El sistema calcula automáticamente el porcentaje de descuento aplicable según las condiciones específicas de cada caso y la normatividad vigente.</p>
                          </div>
                        </div>
                      </div>
                    </div>

                    <div class="d-flex gap-2">
                      <button class="btn btn-success btn-sm">
                        <i class="fas fa-calculator me-1"></i>Calcular Descuento
                      </button>
                      <button class="btn btn-outline-success btn-sm">
                        <i class="fas fa-history me-1"></i>Ver Historial
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-lg-6">
                <div class="card border-info border-opacity-25">
                  <div class="card-header bg-info bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-info">
                      <i class="fas fa-cogs me-2"></i>Configuración de Parámetros
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-12">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center justify-content-between mb-2">
                              <span class="fw-bold small">Porcentajes por Categoría</span>
                              <span class="badge bg-info">Configurable</span>
                            </div>
                            <div class="row g-2">
                              <div class="col-6">
                                <small class="text-muted">Pronto Pago:</small>
                                <div class="progress" style="height: 8px;">
                                  <div class="progress-bar bg-success" style="width: 100%"></div>
                                </div>
                                <small class="text-success">100%</small>
                              </div>
                              <div class="col-6">
                                <small class="text-muted">Regularización:</small>
                                <div class="progress" style="height: 8px;">
                                  <div class="progress-bar bg-warning" style="width: 50%"></div>
                                </div>
                                <small class="text-warning">50%</small>
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                      <div class="col-12">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center justify-content-between mb-2">
                              <span class="fw-bold small">Períodos de Aplicación</span>
                              <span class="badge bg-primary">Automático</span>
                            </div>
                            <p class="text-muted small mb-2">Control temporal para la aplicación de descuentos según fechas específicas</p>
                            <div class="d-flex gap-1">
                              <span class="badge bg-success">Vigente</span>
                              <span class="badge bg-warning text-dark">Próximo</span>
                              <span class="badge bg-secondary">Vencido</span>
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

          <!-- Tab: Descuentos en Multas -->
          <div class="tab-pane fade" id="multas" role="tabpanel">
            <div class="row g-4">
              <div class="col-lg-8">
                <div class="card border-warning border-opacity-25">
                  <div class="card-header bg-warning bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-warning">
                      <i class="fas fa-file-invoice-dollar me-2"></i>Gestión de Descuentos en Multas Fiscales
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="row g-4">
                      <div class="col-md-6">
                        <h6 class="fw-bold text-dark">Tipos de Multas</h6>
                        <div class="list-group list-group-flush">
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center justify-content-between">
                              <div>
                                <i class="fas fa-exclamation-triangle text-warning me-2"></i>
                                <span class="small">Multas por Incumplimiento</span>
                              </div>
                              <span class="badge bg-warning text-dark">25%</span>
                            </div>
                          </div>
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center justify-content-between">
                              <div>
                                <i class="fas fa-calendar-times text-danger me-2"></i>
                                <span class="small">Multas por Retraso</span>
                              </div>
                              <span class="badge bg-danger">50%</span>
                            </div>
                          </div>
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center justify-content-between">
                              <div>
                                <i class="fas fa-file-alt text-info me-2"></i>
                                <span class="small">Multas Administrativas</span>
                              </div>
                              <span class="badge bg-info">30%</span>
                            </div>
                          </div>
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center justify-content-between">
                              <div>
                                <i class="fas fa-ban text-dark me-2"></i>
                                <span class="small">Multas por Omisión</span>
                              </div>
                              <span class="badge bg-dark">75%</span>
                            </div>
                          </div>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <h6 class="fw-bold text-dark">Condiciones Especiales</h6>
                        <div class="list-group list-group-flush">
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center">
                              <i class="fas fa-user-friends text-primary me-2"></i>
                              <span class="small">Primera vez infractor</span>
                            </div>
                          </div>
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center">
                              <i class="fas fa-heart text-danger me-2"></i>
                              <span class="small">Situación vulnerable</span>
                            </div>
                          </div>
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center">
                              <i class="fas fa-handshake text-success me-2"></i>
                              <span class="small">Voluntad de pago</span>
                            </div>
                          </div>
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center">
                              <i class="fas fa-graduation-cap text-info me-2"></i>
                              <span class="small">Programas educativos</span>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>

                    <div class="mt-4">
                      <div class="alert alert-warning">
                        <div class="d-flex align-items-center">
                          <i class="fas fa-balance-scale me-2"></i>
                          <div>
                            <strong>Aplicación Proporcional</strong>
                            <p class="mb-0 small">Los descuentos se aplicarán de manera proporcional según la gravedad de la infracción y las circunstancias específicas del contribuyente.</p>
                          </div>
                        </div>
                      </div>
                    </div>

                    <div class="d-flex gap-2">
                      <button class="btn btn-warning btn-sm">
                        <i class="fas fa-percent me-1"></i>Aplicar Descuento
                      </button>
                      <button class="btn btn-outline-warning btn-sm">
                        <i class="fas fa-chart-bar me-1"></i>Ver Estadísticas
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="card border-primary border-opacity-25">
                  <div class="card-header bg-primary bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-primary">
                      <i class="fas fa-shield-alt me-2"></i>Autorización
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="text-center mb-3">
                      <div class="bg-primary bg-opacity-10 rounded-circle p-3 d-inline-flex">
                        <i class="fas fa-user-shield fa-2x text-primary"></i>
                      </div>
                    </div>

                    <h6 class="fw-bold text-dark">Control de Niveles</h6>
                    <ul class="list-unstyled text-muted small mb-3">
                      <li><i class="fas fa-user me-2 text-primary"></i>Operador: Hasta 25%</li>
                      <li><i class="fas fa-user-tie me-2 text-primary"></i>Supervisor: Hasta 50%</li>
                      <li><i class="fas fa-crown me-2 text-primary"></i>Director: Hasta 75%</li>
                      <li><i class="fas fa-star me-2 text-primary"></i>Especial: Hasta 100%</li>
                    </ul>

                    <div class="alert alert-primary small">
                      <i class="fas fa-key me-1"></i>
                      <strong>Autorización:</strong> Requerida según nivel de descuento
                    </div>

                    <button class="btn btn-primary btn-sm w-100">
                      <i class="fas fa-key me-1"></i>Solicitar Autorización
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tab: Conversión de Procedimientos -->
          <div class="tab-pane fade" id="conversion" role="tabpanel">
            <div class="row g-4">
              <div class="col-md-4">
                <div class="card text-center border-success border-opacity-25 h-100">
                  <div class="card-body">
                    <div class="bg-success bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-sync-alt fa-2x text-success"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Migración Automática</h5>
                    <p class="text-muted small">Conversión automática de procesos obsoletos al nuevo sistema integrado</p>
                    <div class="progress mb-3" style="height: 10px;">
                      <div class="progress-bar bg-success" style="width: 87%"></div>
                    </div>
                    <small class="text-success">87% Completado</small>
                    <div class="mt-3">
                      <button class="btn btn-outline-success btn-sm">
                        <i class="fas fa-play me-1"></i>Iniciar Conversión
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-md-4">
                <div class="card text-center border-primary border-opacity-25 h-100">
                  <div class="card-body">
                    <div class="bg-primary bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-sitemap fa-2x text-primary"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Mapeo de Datos</h5>
                    <p class="text-muted small">Transformación inteligente de información del sistema anterior al nuevo</p>
                    <div class="list-group list-group-flush">
                      <div class="list-group-item border-0 px-0 py-1">
                        <small><i class="fas fa-check text-success me-1"></i>Contribuyentes</small>
                      </div>
                      <div class="list-group-item border-0 px-0 py-1">
                        <small><i class="fas fa-check text-success me-1"></i>Obligaciones</small>
                      </div>
                      <div class="list-group-item border-0 px-0 py-1">
                        <small><i class="fas fa-check text-success me-1"></i>Pagos</small>
                      </div>
                    </div>
                    <div class="mt-3">
                      <button class="btn btn-outline-primary btn-sm">
                        <i class="fas fa-cog me-1"></i>Configurar Mapeo
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-md-4">
                <div class="card text-center border-warning border-opacity-25 h-100">
                  <div class="card-body">
                    <div class="bg-warning bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-check-double fa-2x text-warning"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Validación</h5>
                    <p class="text-muted small">Verificación automática de integridad durante el proceso de conversión</p>
                    <div class="row g-2">
                      <div class="col-6">
                        <div class="bg-light rounded p-2">
                          <small class="fw-bold">2,341</small>
                          <br>
                          <small class="text-muted">Registros</small>
                        </div>
                      </div>
                      <div class="col-6">
                        <div class="bg-light rounded p-2">
                          <small class="fw-bold">0</small>
                          <br>
                          <small class="text-muted">Errores</small>
                        </div>
                      </div>
                    </div>
                    <div class="mt-3">
                      <button class="btn btn-outline-warning btn-sm">
                        <i class="fas fa-shield-alt me-1"></i>Validar Datos
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
                    <i class="fas fa-chart-line me-2"></i>Seguimiento del Proceso de Migración
                  </h5>
                </div>
                <div class="card-body">
                  <div class="row">
                    <div class="col-md-6">
                      <h6 class="fw-bold text-dark">Estado Actual</h6>
                      <ul class="list-unstyled text-muted small">
                        <li><i class="fas fa-check-circle text-success me-2"></i>Análisis de datos completado</li>
                        <li><i class="fas fa-check-circle text-success me-2"></i>Mapeo de estructuras validado</li>
                        <li><i class="fas fa-spinner text-primary me-2"></i>Conversión en progreso</li>
                        <li><i class="fas fa-clock text-secondary me-2"></i>Validación pendiente</li>
                      </ul>
                    </div>
                    <div class="col-md-6">
                      <h6 class="fw-bold text-dark">Reportes de Migración</h6>
                      <ul class="list-unstyled text-muted small">
                        <li><i class="fas fa-file-alt text-info me-2"></i>Registro detallado de transformaciones</li>
                        <li><i class="fas fa-exclamation-triangle text-warning me-2"></i>Log de excepciones y resoluciones</li>
                        <li><i class="fas fa-chart-bar text-primary me-2"></i>Estadísticas de conversión</li>
                        <li><i class="fas fa-history text-secondary me-2"></i>Historial completo del proceso</li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tab: Criterios Legales -->
          <div class="tab-pane fade" id="criterios" role="tabpanel">
            <div class="row g-4">
              <div class="col-lg-8">
                <div class="card border-dark border-opacity-25">
                  <div class="card-header bg-dark bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-dark">
                      <i class="fas fa-gavel me-2"></i>Marco Normativo y Validaciones
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="row g-4">
                      <div class="col-md-6">
                        <h6 class="fw-bold text-dark">Validación Automática</h6>
                        <div class="list-group list-group-flush">
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center">
                              <i class="fas fa-book text-primary me-2"></i>
                              <span class="small">Código Fiscal vigente</span>
                            </div>
                          </div>
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center">
                              <i class="fas fa-file-contract text-success me-2"></i>
                              <span class="small">Reglamentos municipales</span>
                            </div>
                          </div>
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center">
                              <i class="fas fa-clipboard-list text-info me-2"></i>
                              <span class="small">Criterios administrativos</span>
                            </div>
                          </div>
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center">
                              <i class="fas fa-scale-balanced text-warning me-2"></i>
                              <span class="small">Jurisprudencias aplicables</span>
                            </div>
                          </div>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <h6 class="fw-bold text-dark">Requisitos Específicos</h6>
                        <div class="list-group list-group-flush">
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center">
                              <i class="fas fa-user-check text-primary me-2"></i>
                              <span class="small">Perfil del contribuyente</span>
                            </div>
                          </div>
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center">
                              <i class="fas fa-calendar-check text-success me-2"></i>
                              <span class="small">Temporalidad de la obligación</span>
                            </div>
                          </div>
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center">
                              <i class="fas fa-coins text-info me-2"></i>
                              <span class="small">Montos y límites establecidos</span>
                            </div>
                          </div>
                          <div class="list-group-item border-0 px-0">
                            <div class="d-flex align-items-center">
                              <i class="fas fa-file-signature text-warning me-2"></i>
                              <span class="small">Documentación requerida</span>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>

                    <div class="mt-4">
                      <div class="alert alert-dark">
                        <div class="d-flex align-items-center">
                          <i class="fas fa-shield-alt me-2"></i>
                          <div>
                            <strong>Cumplimiento Normativo</strong>
                            <p class="mb-0 small">El sistema valida automáticamente que todos los descuentos y conversiones cumplan con el marco legal vigente, garantizando la legalidad de cada operación.</p>
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
                      <i class="fas fa-exclamation-triangle me-2"></i>Alertas Legales
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="text-center mb-3">
                      <div class="bg-danger bg-opacity-10 rounded-circle p-3 d-inline-flex">
                        <i class="fas fa-bell fa-2x text-danger"></i>
                      </div>
                    </div>

                    <h6 class="fw-bold text-dark">Sistema de Avisos</h6>
                    <ul class="list-unstyled text-muted small mb-3">
                      <li><i class="fas fa-clock me-2 text-danger"></i>Cambios normativos</li>
                      <li><i class="fas fa-calendar-times me-2 text-danger"></i>Vencimientos legales</li>
                      <li><i class="fas fa-file-alt me-2 text-danger"></i>Actualizaciones requeridas</li>
                      <li><i class="fas fa-warning me-2 text-danger"></i>Inconsistencias detectadas</li>
                    </ul>

                    <div class="alert alert-danger small">
                      <i class="fas fa-info-circle me-1"></i>
                      <strong>3 Alertas</strong> requieren atención inmediata
                    </div>

                    <button class="btn btn-danger btn-sm w-100">
                      <i class="fas fa-eye me-1"></i>Ver Alertas
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>

    <!-- Métricas de Rendimiento -->
    <div class="row g-3">
      <div class="col-md-3">
        <div class="card border-0 bg-success text-white">
          <div class="card-body text-center">
            <i class="fas fa-percentage fa-2x mb-2"></i>
            <h4 class="fw-bold">$1.2M</h4>
            <p class="mb-0 small">Descuentos Aplicados</p>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-0 bg-primary text-white">
          <div class="card-body text-center">
            <i class="fas fa-exchange-alt fa-2x mb-2"></i>
            <h4 class="fw-bold">1,847</h4>
            <p class="mb-0 small">Conversiones Realizadas</p>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-0 bg-warning text-white">
          <div class="card-body text-center">
            <i class="fas fa-check-circle fa-2x mb-2"></i>
            <h4 class="fw-bold">99.2%</h4>
            <p class="mb-0 small">Cumplimiento Legal</p>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-0 bg-info text-white">
          <div class="card-body text-center">
            <i class="fas fa-clock fa-2x mb-2"></i>
            <h4 class="fw-bold">-82%</h4>
            <p class="mb-0 small">Tiempo de Proceso</p>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
export default {
  name: 'SistemaDescuentosOtrasOblig',
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