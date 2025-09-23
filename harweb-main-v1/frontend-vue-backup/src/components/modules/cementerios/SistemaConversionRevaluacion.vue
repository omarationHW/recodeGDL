<template>
  <div class="container-fluid mt-4">
    <!-- Header del Sistema -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #6f42c1 !important;">
      <div class="card-body p-4">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-primary bg-opacity-10 rounded-3 p-3 me-3">
              <i class="fas fa-exchange-alt fa-2x text-primary"></i>
            </div>
            <div>
              <h1 class="h3 fw-bold text-dark mb-1">Sistema de Conversión y Revaluación - Cementerios</h1>
              <p class="text-muted mb-0">Conversión automática de procedimientos y revaluación de costos</p>
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
        <ul class="nav nav-tabs card-header-tabs" id="conversionTab" role="tablist">
          <li class="nav-item" role="presentation">
            <button class="nav-link active" id="conversion-tab" data-bs-toggle="tab" data-bs-target="#conversion" type="button" role="tab">
              <i class="fas fa-sync-alt me-2"></i>Conversión de Procedimientos
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="revaluacion-tab" data-bs-toggle="tab" data-bs-target="#revaluacion" type="button" role="tab">
              <i class="fas fa-calculator me-2"></i>Revaluación de Costos
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="optimizacion-tab" data-bs-toggle="tab" data-bs-target="#optimizacion" type="button" role="tab">
              <i class="fas fa-rocket me-2"></i>Optimización de Procesos
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="monitoreo-tab" data-bs-toggle="tab" data-bs-target="#monitoreo" type="button" role="tab">
              <i class="fas fa-chart-line me-2"></i>Monitoreo en Tiempo Real
            </button>
          </li>
        </ul>
      </div>

      <div class="card-body">
        <div class="tab-content" id="conversionTabContent">

          <!-- Tab: Conversión de Procedimientos -->
          <div class="tab-pane fade show active" id="conversion" role="tabpanel">
            <div class="row g-4">
              <div class="col-lg-6">
                <div class="card border-success border-opacity-25">
                  <div class="card-header bg-success bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-success">
                      <i class="fas fa-robot me-2"></i>Migración Automática a Digital
                    </h5>
                  </div>
                  <div class="card-body">
                    <p class="text-muted mb-4">Conversión inteligente de procedimientos manuales de pago a formato digital</p>

                    <div class="row g-3">
                      <div class="col-md-6">
                        <div class="bg-light rounded p-3">
                          <div class="d-flex align-items-center mb-2">
                            <i class="fas fa-magic text-success me-2"></i>
                            <span class="fw-bold small">Migración Inteligente</span>
                          </div>
                          <ul class="list-unstyled text-muted small mb-0">
                            <li>• Conversión automática de formatos</li>
                            <li>• Validación de datos en tiempo real</li>
                            <li>• Mapeo inteligente de campos</li>
                            <li>• Preservación de integridad</li>
                          </ul>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <div class="bg-light rounded p-3">
                          <div class="d-flex align-items-center mb-2">
                            <i class="fas fa-shield-alt text-primary me-2"></i>
                            <span class="fw-bold small">Validación Cruzada</span>
                          </div>
                          <ul class="list-unstyled text-muted small mb-0">
                            <li>• Verificación automática de importes</li>
                            <li>• Control de conceptos y rubros</li>
                            <li>• Detección de inconsistencias</li>
                            <li>• Corrección automática de errores</li>
                          </ul>
                        </div>
                      </div>
                    </div>

                    <div class="mt-4">
                      <div class="progress mb-2" style="height: 12px;">
                        <div class="progress-bar bg-success" style="width: 87%">
                          <small class="fw-bold">87% Migración Completada</small>
                        </div>
                      </div>
                      <div class="row g-2 text-center">
                        <div class="col-4">
                          <small class="text-muted">Procesados</small>
                          <div class="fw-bold text-success">2,847</div>
                        </div>
                        <div class="col-4">
                          <small class="text-muted">En Cola</small>
                          <div class="fw-bold text-warning">423</div>
                        </div>
                        <div class="col-4">
                          <small class="text-muted">Errores</small>
                          <div class="fw-bold text-danger">12</div>
                        </div>
                      </div>
                    </div>

                    <div class="mt-3 d-flex gap-2">
                      <button class="btn btn-success btn-sm">
                        <i class="fas fa-play me-1"></i>Iniciar Conversión
                      </button>
                      <button class="btn btn-outline-success btn-sm">
                        <i class="fas fa-pause me-1"></i>Pausar
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-lg-6">
                <div class="card border-info border-opacity-25">
                  <div class="card-header bg-info bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-info">
                      <i class="fas fa-plug me-2"></i>Integración con Caja Municipal
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="text-center mb-3">
                      <div class="bg-info bg-opacity-10 rounded-circle p-3 d-inline-flex">
                        <i class="fas fa-link fa-2x text-info"></i>
                      </div>
                    </div>

                    <h6 class="fw-bold text-dark">Conexión Directa</h6>
                    <ul class="list-unstyled text-muted small mb-3">
                      <li><i class="fas fa-check-circle text-success me-2"></i>Sistema de cobros municipal</li>
                      <li><i class="fas fa-check-circle text-success me-2"></i>Actualización en tiempo real</li>
                      <li><i class="fas fa-check-circle text-success me-2"></i>Conciliación automática</li>
                      <li><i class="fas fa-check-circle text-success me-2"></i>Estados sincronizados</li>
                    </ul>

                    <div class="alert alert-info small">
                      <i class="fas fa-info-circle me-1"></i>
                      <strong>Estado:</strong> Conectado y funcionando
                    </div>

                    <div class="row g-2">
                      <div class="col-6">
                        <div class="bg-light rounded p-2 text-center">
                          <small class="text-muted d-block">Transacciones Hoy</small>
                          <span class="fw-bold text-info">1,247</span>
                        </div>
                      </div>
                      <div class="col-6">
                        <div class="bg-light rounded p-2 text-center">
                          <small class="text-muted d-block">Sincronización</small>
                          <span class="fw-bold text-success">99.8%</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div class="mt-4">
              <div class="card border-warning border-opacity-25">
                <div class="card-header bg-warning bg-opacity-10">
                  <h5 class="fw-bold mb-0 text-warning">
                    <i class="fas fa-bell me-2"></i>Alertas Inteligentes
                  </h5>
                </div>
                <div class="card-body">
                  <div class="row">
                    <div class="col-md-6">
                      <h6 class="fw-bold text-dark">Notificaciones Automáticas</h6>
                      <ul class="list-unstyled text-muted small">
                        <li><i class="fas fa-exclamation-triangle me-2 text-warning"></i>Discrepancias en importes</li>
                        <li><i class="fas fa-times-circle me-2 text-danger"></i>Errores de conversión</li>
                        <li><i class="fas fa-clock me-2 text-info"></i>Demoras en procesamiento</li>
                        <li><i class="fas fa-sync-alt me-2 text-primary"></i>Fallos de sincronización</li>
                      </ul>
                    </div>
                    <div class="col-md-6">
                      <h6 class="fw-bold text-dark">Sistema de Escalamiento</h6>
                      <ul class="list-unstyled text-muted small">
                        <li><i class="fas fa-user me-2 text-success"></i>Notificación a operador</li>
                        <li><i class="fas fa-user-tie me-2 text-warning"></i>Escalamiento a supervisor</li>
                        <li><i class="fas fa-crown me-2 text-danger"></i>Alerta a dirección</li>
                        <li><i class="fas fa-envelope me-2 text-info"></i>Notificación por email/SMS</li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tab: Revaluación de Costos -->
          <div class="tab-pane fade" id="revaluacion" role="tabpanel">
            <div class="row g-4">
              <div class="col-md-4">
                <div class="card text-center border-primary border-opacity-25 h-100">
                  <div class="card-body">
                    <div class="bg-primary bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-chart-line fa-2x text-primary"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Actualización Automática</h5>
                    <p class="text-muted small mb-3">Revaluación periódica basada en indicadores oficiales</p>
                    <div class="progress mb-2" style="height: 8px;">
                      <div class="progress-bar bg-primary" style="width: 92%"></div>
                    </div>
                    <small class="text-primary">Última actualización: Hoy</small>
                    <div class="mt-3">
                      <button class="btn btn-outline-primary btn-sm">
                        <i class="fas fa-sync me-1"></i>Actualizar
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-md-4">
                <div class="card text-center border-success border-opacity-25 h-100">
                  <div class="card-body">
                    <div class="bg-success bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-chart-bar fa-2x text-success"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Índices Económicos</h5>
                    <p class="text-muted small mb-3">Integración con UMA, inflación e indicadores oficiales</p>
                    <div class="row g-1 text-center">
                      <div class="col-6">
                        <small class="text-muted">UMA</small>
                        <div class="fw-bold text-success">$108.57</div>
                      </div>
                      <div class="col-6">
                        <small class="text-muted">Inflación</small>
                        <div class="fw-bold text-warning">4.2%</div>
                      </div>
                    </div>
                    <div class="mt-3">
                      <button class="btn btn-outline-success btn-sm">
                        <i class="fas fa-chart-line me-1"></i>Ver Indicadores
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-md-4">
                <div class="card text-center border-warning border-opacity-25 h-100">
                  <div class="card-body">
                    <div class="bg-warning bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-crystal-ball fa-2x text-warning"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Proyecciones</h5>
                    <p class="text-muted small mb-3">Cálculo de costos futuros basado en tendencias</p>
                    <div class="row g-1 text-center">
                      <div class="col-6">
                        <small class="text-muted">3 meses</small>
                        <div class="fw-bold text-info">+2.1%</div>
                      </div>
                      <div class="col-6">
                        <small class="text-muted">6 meses</small>
                        <div class="fw-bold text-warning">+4.8%</div>
                      </div>
                    </div>
                    <div class="mt-3">
                      <button class="btn btn-outline-warning btn-sm">
                        <i class="fas fa-eye me-1"></i>Ver Proyección
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
                    <i class="fas fa-history me-2"></i>Comparativo Histórico
                  </h5>
                </div>
                <div class="card-body">
                  <div class="row">
                    <div class="col-md-8">
                      <h6 class="fw-bold text-dark">Evolución de Precios (Últimos 12 meses)</h6>
                      <div class="table-responsive">
                        <table class="table table-sm">
                          <thead>
                            <tr>
                              <th>Servicio</th>
                              <th>Ene 2025</th>
                              <th>Jun 2025</th>
                              <th>Sep 2025</th>
                              <th>Variación</th>
                            </tr>
                          </thead>
                          <tbody>
                            <tr>
                              <td>Inhumación</td>
                              <td>$2,850</td>
                              <td>$2,970</td>
                              <td>$3,120</td>
                              <td><span class="badge bg-success">+9.5%</span></td>
                            </tr>
                            <tr>
                              <td>Exhumación</td>
                              <td>$1,420</td>
                              <td>$1,480</td>
                              <td>$1,550</td>
                              <td><span class="badge bg-success">+9.2%</span></td>
                            </tr>
                            <tr>
                              <td>Renovación</td>
                              <td>$890</td>
                              <td>$925</td>
                              <td>$970</td>
                              <td><span class="badge bg-success">+9.0%</span></td>
                            </tr>
                          </tbody>
                        </table>
                      </div>
                    </div>
                    <div class="col-md-4">
                      <h6 class="fw-bold text-dark">Impacto Financiero</h6>
                      <div class="card border-0 bg-light">
                        <div class="card-body p-3">
                          <div class="text-center">
                            <div class="h4 fw-bold text-success">+15.2%</div>
                            <small class="text-muted">Incremento en ingresos</small>
                          </div>
                          <hr>
                          <div class="d-flex justify-content-between">
                            <small class="text-muted">Proyección anual:</small>
                            <small class="fw-bold">$24.8M</small>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tab: Optimización de Procesos -->
          <div class="tab-pane fade" id="optimizacion" role="tabpanel">
            <div class="row g-4">
              <div class="col-md-6">
                <div class="card border-success border-opacity-25">
                  <div class="card-header bg-success bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-success">
                      <i class="fas fa-cogs me-2"></i>Flujos Automatizados
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="list-group list-group-flush">
                      <div class="list-group-item border-0 px-0">
                        <div class="d-flex align-items-center justify-content-between">
                          <div class="d-flex align-items-center">
                            <i class="fas fa-robot text-success me-2"></i>
                            <span class="small">Eliminación de procesos manuales</span>
                          </div>
                          <span class="badge bg-success">95%</span>
                        </div>
                      </div>
                      <div class="list-group-item border-0 px-0">
                        <div class="d-flex align-items-center justify-content-between">
                          <div class="d-flex align-items-center">
                            <i class="fas fa-sync-alt text-info me-2"></i>
                            <span class="small">Procesos repetitivos automatizados</span>
                          </div>
                          <span class="badge bg-info">87%</span>
                        </div>
                      </div>
                      <div class="list-group-item border-0 px-0">
                        <div class="d-flex align-items-center justify-content-between">
                          <div class="d-flex align-items-center">
                            <i class="fas fa-check-double text-primary me-2"></i>
                            <span class="small">Validaciones inteligentes</span>
                          </div>
                          <span class="badge bg-primary">100%</span>
                        </div>
                      </div>
                      <div class="list-group-item border-0 px-0">
                        <div class="d-flex align-items-center justify-content-between">
                          <div class="d-flex align-items-center">
                            <i class="fas fa-shield-alt text-warning me-2"></i>
                            <span class="small">Control de consistencia de datos</span>
                          </div>
                          <span class="badge bg-warning text-dark">99.2%</span>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-md-6">
                <div class="card border-primary border-opacity-25">
                  <div class="card-header bg-primary bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-primary">
                      <i class="fas fa-shield-alt me-2"></i>Sistema de Respaldo
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="text-center mb-3">
                      <div class="bg-primary bg-opacity-10 rounded-circle p-3 d-inline-flex">
                        <i class="fas fa-database fa-2x text-primary"></i>
                      </div>
                    </div>

                    <h6 class="fw-bold text-dark">Backup Automático</h6>
                    <ul class="list-unstyled text-muted small mb-3">
                      <li><i class="fas fa-clock me-2 text-primary"></i>Respaldo cada 15 minutos</li>
                      <li><i class="fas fa-history me-2 text-primary"></i>30 días de retención</li>
                      <li><i class="fas fa-cloud me-2 text-primary"></i>Almacenamiento en la nube</li>
                      <li><i class="fas fa-lock me-2 text-primary"></i>Encriptación avanzada</li>
                    </ul>

                    <div class="alert alert-primary small">
                      <i class="fas fa-check-circle me-1"></i>
                      <strong>Último backup:</strong> hace 8 minutos
                    </div>

                    <div class="row g-2">
                      <div class="col-6">
                        <button class="btn btn-outline-primary btn-sm w-100">
                          <i class="fas fa-download me-1"></i>Restaurar
                        </button>
                      </div>
                      <div class="col-6">
                        <button class="btn btn-primary btn-sm w-100">
                          <i class="fas fa-save me-1"></i>Backup Manual
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div class="mt-4">
              <div class="card border-danger border-opacity-25">
                <div class="card-header bg-danger bg-opacity-10">
                  <h5 class="fw-bold mb-0 text-danger">
                    <i class="fas fa-undo me-2"></i>Recuperación de Errores
                  </h5>
                </div>
                <div class="card-body">
                  <div class="row">
                    <div class="col-md-6">
                      <h6 class="fw-bold text-dark">Sistema de Rollback</h6>
                      <ul class="list-unstyled text-muted small">
                        <li><i class="fas fa-history me-2 text-danger"></i>Reversión automática de errores</li>
                        <li><i class="fas fa-checkpoint me-2 text-danger"></i>Puntos de control cada operación</li>
                        <li><i class="fas fa-shield-alt me-2 text-danger"></i>Preservación de integridad</li>
                        <li><i class="fas fa-bell me-2 text-danger"></i>Notificación de recuperaciones</li>
                      </ul>
                    </div>
                    <div class="col-md-6">
                      <h6 class="fw-bold text-dark">Estadísticas de Recuperación</h6>
                      <div class="row g-2 text-center">
                        <div class="col-6">
                          <div class="bg-light rounded p-2">
                            <small class="text-muted d-block">Errores Detectados</small>
                            <span class="fw-bold text-warning">23</span>
                          </div>
                        </div>
                        <div class="col-6">
                          <div class="bg-light rounded p-2">
                            <small class="text-muted d-block">Recuperaciones</small>
                            <span class="fw-bold text-success">23</span>
                          </div>
                        </div>
                        <div class="col-12">
                          <div class="bg-light rounded p-2">
                            <small class="text-muted d-block">Éxito en Recuperación</small>
                            <span class="fw-bold text-success">100%</span>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tab: Monitoreo en Tiempo Real -->
          <div class="tab-pane fade" id="monitoreo" role="tabpanel">
            <div class="row g-4">
              <div class="col-lg-8">
                <div class="card border-primary border-opacity-25">
                  <div class="card-header bg-primary bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-primary">
                      <i class="fas fa-tachometer-alt me-2"></i>Panel de Control en Tiempo Real
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-md-6">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center mb-2">
                              <i class="fas fa-sync-alt text-primary me-2"></i>
                              <span class="fw-bold small">Conversiones en Progreso</span>
                            </div>
                            <div class="h4 fw-bold text-primary">127</div>
                            <div class="progress" style="height: 4px;">
                              <div class="progress-bar bg-primary" style="width: 67%"></div>
                            </div>
                            <small class="text-muted">67% completado</small>
                          </div>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center mb-2">
                              <i class="fas fa-calculator text-success me-2"></i>
                              <span class="fw-bold small">Revaluaciones Completadas</span>
                            </div>
                            <div class="h4 fw-bold text-success">1,847</div>
                            <div class="progress" style="height: 4px;">
                              <div class="progress-bar bg-success" style="width: 100%"></div>
                            </div>
                            <small class="text-muted">Actualizado hace 2 min</small>
                          </div>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center mb-2">
                              <i class="fas fa-coins text-warning me-2"></i>
                              <span class="fw-bold small">Ingresos del Día</span>
                            </div>
                            <div class="h4 fw-bold text-warning">$847,350</div>
                            <div class="progress" style="height: 4px;">
                              <div class="progress-bar bg-warning" style="width: 84%"></div>
                            </div>
                            <small class="text-muted">84% de la meta diaria</small>
                          </div>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center mb-2">
                              <i class="fas fa-exclamation-triangle text-danger me-2"></i>
                              <span class="fw-bold small">Alertas Activas</span>
                            </div>
                            <div class="h4 fw-bold text-danger">3</div>
                            <div class="progress" style="height: 4px;">
                              <div class="progress-bar bg-danger" style="width: 15%"></div>
                            </div>
                            <small class="text-muted">Requieren atención</small>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="card border-info border-opacity-25">
                  <div class="card-header bg-info bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-info">
                      <i class="fas fa-chart-line me-2"></i>Rendimiento del Sistema
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="text-center mb-3">
                      <div class="bg-info bg-opacity-10 rounded-circle p-3 d-inline-flex">
                        <i class="fas fa-rocket fa-2x text-info"></i>
                      </div>
                    </div>

                    <div class="row g-2 text-center">
                      <div class="col-12">
                        <div class="bg-light rounded p-2">
                          <small class="text-muted d-block">Tiempo de Respuesta</small>
                          <span class="fw-bold text-success">0.2s</span>
                        </div>
                      </div>
                      <div class="col-6">
                        <div class="bg-light rounded p-2">
                          <small class="text-muted d-block">CPU</small>
                          <span class="fw-bold text-info">23%</span>
                        </div>
                      </div>
                      <div class="col-6">
                        <div class="bg-light rounded p-2">
                          <small class="text-muted d-block">Memoria</small>
                          <span class="fw-bold text-warning">67%</span>
                        </div>
                      </div>
                      <div class="col-12">
                        <div class="bg-light rounded p-2">
                          <small class="text-muted d-block">Disponibilidad</small>
                          <span class="fw-bold text-success">99.97%</span>
                        </div>
                      </div>
                    </div>

                    <div class="mt-3">
                      <button class="btn btn-info btn-sm w-100">
                        <i class="fas fa-chart-bar me-1"></i>Ver Detalles
                      </button>
                    </div>
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
        <div class="card border-0 bg-primary text-white">
          <div class="card-body text-center">
            <i class="fas fa-sync-alt fa-2x mb-2"></i>
            <h4 class="fw-bold">3,247</h4>
            <p class="mb-0 small">Procedimientos Convertidos</p>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-0 bg-success text-white">
          <div class="card-body text-center">
            <i class="fas fa-chart-line fa-2x mb-2"></i>
            <h4 class="fw-bold">+15.2%</h4>
            <p class="mb-0 small">Incremento en Ingresos</p>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-0 bg-warning text-white">
          <div class="card-body text-center">
            <i class="fas fa-clock fa-2x mb-2"></i>
            <h4 class="fw-bold">-78%</h4>
            <p class="mb-0 small">Reducción de Tiempo</p>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-0 bg-info text-white">
          <div class="card-body text-center">
            <i class="fas fa-check-circle fa-2x mb-2"></i>
            <h4 class="fw-bold">99.8%</h4>
            <p class="mb-0 small">Precisión Automática</p>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
export default {
  name: 'SistemaConversionRevaluacion',
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