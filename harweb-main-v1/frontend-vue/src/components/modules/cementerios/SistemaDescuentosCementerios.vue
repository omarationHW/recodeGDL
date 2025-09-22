<template>
  <div class="container-fluid mt-4">
    <!-- Header del Sistema -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #28a745 !important;">
      <div class="card-body p-4">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-success bg-opacity-10 rounded-3 p-3 me-3">
              <i class="fas fa-percentage fa-2x text-success"></i>
            </div>
            <div>
              <h1 class="h3 fw-bold text-dark mb-1">Sistema de Descuentos Automatizados - Cementerios</h1>
              <p class="text-muted mb-0">Gestión inteligente de descuentos en recargos con criterios legales</p>
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
        <ul class="nav nav-tabs card-header-tabs" id="descuentosTab" role="tablist">
          <li class="nav-item" role="presentation">
            <button class="nav-link active" id="recargos-tab" data-bs-toggle="tab" data-bs-target="#recargos" type="button" role="tab">
              <i class="fas fa-calculator me-2"></i>Descuentos en Recargos
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="criterios-tab" data-bs-toggle="tab" data-bs-target="#criterios" type="button" role="tab">
              <i class="fas fa-cogs me-2"></i>Criterios Variables
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="autorizacion-tab" data-bs-toggle="tab" data-bs-target="#autorizacion" type="button" role="tab">
              <i class="fas fa-shield-alt me-2"></i>Control de Autorización
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="reportes-tab" data-bs-toggle="tab" data-bs-target="#reportes" type="button" role="tab">
              <i class="fas fa-chart-line me-2"></i>Reportes Especializados
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
                      <i class="fas fa-robot me-2"></i>Cálculo Automático Inteligente
                    </h5>
                  </div>
                  <div class="card-body">
                    <p class="text-muted mb-4">Sistema automatizado para aplicación de descuentos en recargos de servicios funerarios</p>

                    <div class="row g-3">
                      <div class="col-md-6">
                        <div class="bg-light rounded p-3">
                          <div class="d-flex align-items-center mb-2">
                            <i class="fas fa-magic text-success me-2"></i>
                            <span class="fw-bold small">Automatización</span>
                          </div>
                          <ul class="list-unstyled text-muted small mb-0">
                            <li>• Aplicación automática según criterios</li>
                            <li>• Cálculo preciso de porcentajes</li>
                            <li>• Validación de requisitos legales</li>
                            <li>• Registro de trazabilidad completa</li>
                          </ul>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <div class="bg-light rounded p-3">
                          <div class="d-flex align-items-center mb-2">
                            <i class="fas fa-gavel text-primary me-2"></i>
                            <span class="fw-bold small">Validación Legal</span>
                          </div>
                          <ul class="list-unstyled text-muted small mb-0">
                            <li>• Verificación automática de requisitos</li>
                            <li>• Cumplimiento normativo vigente</li>
                            <li>• Control de límites legales</li>
                            <li>• Documentación justificativa</li>
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
                            <p class="mb-0 small">El sistema calcula automáticamente el porcentaje de descuento aplicable según las condiciones específicas del servicio funerario y la normatividad vigente.</p>
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
                      <i class="fas fa-chart-pie me-2"></i>Análisis de Impacto
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-12">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center justify-content-between mb-2">
                              <span class="fw-bold small">Descuentos Aplicados Hoy</span>
                              <span class="badge bg-info">+24</span>
                            </div>
                            <div class="progress mb-2" style="height: 8px;">
                              <div class="progress-bar bg-info" style="width: 65%"></div>
                            </div>
                            <div class="row g-2">
                              <div class="col-6">
                                <small class="text-muted">Total:</small>
                                <div class="fw-bold">$156,750</div>
                              </div>
                              <div class="col-6">
                                <small class="text-muted">Promedio:</small>
                                <div class="fw-bold">$6,531</div>
                              </div>
                            </div>
                          </div>
                        </div>
                      </div>
                      <div class="col-12">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center justify-content-between mb-2">
                              <span class="fw-bold small">Distribución por Tipo</span>
                              <span class="badge bg-success">Activo</span>
                            </div>
                            <div class="d-flex gap-1 mb-2">
                              <span class="badge bg-primary">Pronto Pago 45%</span>
                              <span class="badge bg-warning text-dark">Vulnerable 35%</span>
                              <span class="badge bg-secondary">Otros 20%</span>
                            </div>
                            <small class="text-muted">Actualizado en tiempo real</small>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tab: Criterios Variables -->
          <div class="tab-pane fade" id="criterios" role="tabpanel">
            <div class="row g-4">
              <div class="col-md-4">
                <div class="card text-center border-primary border-opacity-25 h-100">
                  <div class="card-body">
                    <div class="bg-primary bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-clock fa-2x text-primary"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Pronto Pago</h5>
                    <p class="text-muted small mb-3">Descuentos por pago inmediato de servicios funerarios</p>
                    <div class="progress mb-2" style="height: 10px;">
                      <div class="progress-bar bg-primary" style="width: 100%"></div>
                    </div>
                    <small class="text-primary fw-bold">Hasta 100% en recargos</small>
                    <div class="mt-3">
                      <button class="btn btn-outline-primary btn-sm">
                        <i class="fas fa-cog me-1"></i>Configurar
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-md-4">
                <div class="card text-center border-warning border-opacity-25 h-100">
                  <div class="card-body">
                    <div class="bg-warning bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-heart fa-2x text-warning"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Situación Vulnerable</h5>
                    <p class="text-muted small mb-3">Descuentos especiales por condición socioeconómica</p>
                    <div class="progress mb-2" style="height: 10px;">
                      <div class="progress-bar bg-warning" style="width: 75%"></div>
                    </div>
                    <small class="text-warning fw-bold">Hasta 75% en recargos</small>
                    <div class="mt-3">
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
                      <i class="fas fa-handshake fa-2x text-success"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Convenios Especiales</h5>
                    <p class="text-muted small mb-3">Descuentos por convenios institucionales</p>
                    <div class="progress mb-2" style="height: 10px;">
                      <div class="progress-bar bg-success" style="width: 50%"></div>
                    </div>
                    <small class="text-success fw-bold">Hasta 50% en recargos</small>
                    <div class="mt-3">
                      <button class="btn btn-outline-success btn-sm">
                        <i class="fas fa-cog me-1"></i>Configurar
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
                    <i class="fas fa-calendar me-2"></i>Períodos de Aplicación
                  </h5>
                </div>
                <div class="card-body">
                  <div class="row">
                    <div class="col-md-6">
                      <h6 class="fw-bold text-dark">Control Temporal</h6>
                      <ul class="list-unstyled text-muted small">
                        <li><i class="fas fa-calendar-check me-2 text-info"></i>Fechas de inicio y fin automáticas</li>
                        <li><i class="fas fa-clock me-2 text-info"></i>Horarios específicos de aplicación</li>
                        <li><i class="fas fa-calendar-alt me-2 text-info"></i>Excepciones por días especiales</li>
                        <li><i class="fas fa-bell me-2 text-info"></i>Notificaciones de vencimiento</li>
                      </ul>
                    </div>
                    <div class="col-md-6">
                      <h6 class="fw-bold text-dark">Configuración Avanzada</h6>
                      <ul class="list-unstyled text-muted small">
                        <li><i class="fas fa-coins me-2 text-success"></i>Montos límite por tipo de servicio</li>
                        <li><i class="fas fa-percentage me-2 text-success"></i>Porcentajes escalonados</li>
                        <li><i class="fas fa-shield-alt me-2 text-success"></i>Validaciones de seguridad</li>
                        <li><i class="fas fa-history me-2 text-success"></i>Historial de modificaciones</li>
                      </ul>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tab: Control de Autorización -->
          <div class="tab-pane fade" id="autorizacion" role="tabpanel">
            <div class="row g-4">
              <div class="col-lg-8">
                <div class="card border-danger border-opacity-25">
                  <div class="card-header bg-danger bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-danger">
                      <i class="fas fa-shield-alt me-2"></i>Niveles de Autorización
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-md-6">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center justify-content-between mb-2">
                              <span class="fw-bold small">Operador</span>
                              <span class="badge bg-primary">Nivel 1</span>
                            </div>
                            <p class="text-muted small mb-2">Descuentos básicos hasta 25% en recargos</p>
                            <div class="progress mb-2" style="height: 6px;">
                              <div class="progress-bar bg-primary" style="width: 25%"></div>
                            </div>
                            <small class="text-primary">Autorización automática</small>
                          </div>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center justify-content-between mb-2">
                              <span class="fw-bold small">Supervisor</span>
                              <span class="badge bg-warning text-dark">Nivel 2</span>
                            </div>
                            <p class="text-muted small mb-2">Descuentos intermedios hasta 50% en recargos</p>
                            <div class="progress mb-2" style="height: 6px;">
                              <div class="progress-bar bg-warning" style="width: 50%"></div>
                            </div>
                            <small class="text-warning">Requiere justificación</small>
                          </div>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center justify-content-between mb-2">
                              <span class="fw-bold small">Director</span>
                              <span class="badge bg-danger">Nivel 3</span>
                            </div>
                            <p class="text-muted small mb-2">Descuentos altos hasta 75% en recargos</p>
                            <div class="progress mb-2" style="height: 6px;">
                              <div class="progress-bar bg-danger" style="width: 75%"></div>
                            </div>
                            <small class="text-danger">Autorización manual</small>
                          </div>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center justify-content-between mb-2">
                              <span class="fw-bold small">Especial</span>
                              <span class="badge bg-dark">Nivel 4</span>
                            </div>
                            <p class="text-muted small mb-2">Descuentos excepcionales hasta 100% en recargos</p>
                            <div class="progress mb-2" style="height: 6px;">
                              <div class="progress-bar bg-dark" style="width: 100%"></div>
                            </div>
                            <small class="text-dark">Casos extraordinarios</small>
                          </div>
                        </div>
                      </div>
                    </div>

                    <div class="mt-4">
                      <div class="alert alert-warning">
                        <div class="d-flex align-items-center">
                          <i class="fas fa-shield-alt me-2"></i>
                          <div>
                            <strong>Control de Seguridad</strong>
                            <p class="mb-0 small">Todos los descuentos quedan registrados con trazabilidad completa, incluyendo usuario, fecha, hora y justificación del descuento aplicado.</p>
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
                      <i class="fas fa-history me-2"></i>Trazabilidad
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="text-center mb-3">
                      <div class="bg-info bg-opacity-10 rounded-circle p-3 d-inline-flex">
                        <i class="fas fa-file-alt fa-2x text-info"></i>
                      </div>
                    </div>

                    <h6 class="fw-bold text-dark">Registro Completo</h6>
                    <ul class="list-unstyled text-muted small mb-3">
                      <li><i class="fas fa-user me-2 text-info"></i>Usuario que autoriza</li>
                      <li><i class="fas fa-calendar me-2 text-info"></i>Fecha y hora exacta</li>
                      <li><i class="fas fa-comment me-2 text-info"></i>Justificación detallada</li>
                      <li><i class="fas fa-dollar-sign me-2 text-info"></i>Monto y porcentaje</li>
                    </ul>

                    <div class="alert alert-info small">
                      <i class="fas fa-lock me-1"></i>
                      <strong>Inmutable:</strong> Los registros no pueden ser modificados
                    </div>

                    <button class="btn btn-info btn-sm w-100">
                      <i class="fas fa-search me-1"></i>Consultar Historial
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tab: Reportes Especializados -->
          <div class="tab-pane fade" id="reportes" role="tabpanel">
            <div class="row g-4">
              <div class="col-lg-8">
                <div class="card border-primary border-opacity-25">
                  <div class="card-header bg-primary bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-primary">
                      <i class="fas fa-chart-bar me-2"></i>Análisis de Impacto
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-md-6">
                        <div class="card border-0 bg-light">
                          <div class="card-body p-3">
                            <div class="d-flex align-items-center mb-2">
                              <i class="fas fa-chart-pie text-primary me-2"></i>
                              <span class="fw-bold small">Distribución de Descuentos</span>
                            </div>
                            <p class="text-muted small mb-2">Análisis por tipo de descuento aplicado en el período</p>
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
                              <i class="fas fa-coins text-success me-2"></i>
                              <span class="fw-bold small">Impacto Financiero</span>
                            </div>
                            <p class="text-muted small mb-2">Evaluación del impacto económico de descuentos otorgados</p>
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
                              <i class="fas fa-users text-warning me-2"></i>
                              <span class="fw-bold small">Beneficiarios</span>
                            </div>
                            <p class="text-muted small mb-2">Reporte de familias beneficiadas por descuentos</p>
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
                              <i class="fas fa-file-excel text-info me-2"></i>
                              <span class="fw-bold small">Exportación Excel</span>
                            </div>
                            <p class="text-muted small mb-2">Datos detallados para análisis externo</p>
                            <button class="btn btn-outline-info btn-sm">
                              <i class="fas fa-download me-1"></i>Exportar
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
                      <i class="fas fa-clock me-2"></i>Tendencias
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="text-center mb-3">
                      <div class="bg-success bg-opacity-10 rounded-circle p-3 d-inline-flex">
                        <i class="fas fa-trending-up fa-2x text-success"></i>
                      </div>
                    </div>

                    <h6 class="fw-bold text-dark">Análisis Temporal</h6>
                    <ul class="list-unstyled text-muted small mb-3">
                      <li><i class="fas fa-calendar-week me-2 text-success"></i>Tendencias semanales</li>
                      <li><i class="fas fa-calendar-alt me-2 text-success"></i>Patrones mensuales</li>
                      <li><i class="fas fa-chart-line me-2 text-success"></i>Proyecciones futuras</li>
                      <li><i class="fas fa-balance-scale me-2 text-success"></i>Comparativos anuales</li>
                    </ul>

                    <div class="alert alert-success small">
                      <i class="fas fa-lightbulb me-1"></i>
                      <strong>Insights:</strong> Identificación automática de patrones
                    </div>

                    <button class="btn btn-success btn-sm w-100">
                      <i class="fas fa-chart-line me-1"></i>Ver Tendencias
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
        <div class="card border-0 bg-success text-white">
          <div class="card-body text-center">
            <i class="fas fa-percentage fa-2x mb-2"></i>
            <h4 class="fw-bold">$847K</h4>
            <p class="mb-0 small">Descuentos Aplicados</p>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-0 bg-primary text-white">
          <div class="card-body text-center">
            <i class="fas fa-users fa-2x mb-2"></i>
            <h4 class="fw-bold">324</h4>
            <p class="mb-0 small">Familias Beneficiadas</p>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-0 bg-warning text-white">
          <div class="card-body text-center">
            <i class="fas fa-check-circle fa-2x mb-2"></i>
            <h4 class="fw-bold">99.8%</h4>
            <p class="mb-0 small">Precisión Automática</p>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-0 bg-info text-white">
          <div class="card-body text-center">
            <i class="fas fa-clock fa-2x mb-2"></i>
            <h4 class="fw-bold">-85%</h4>
            <p class="mb-0 small">Tiempo de Proceso</p>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
export default {
  name: 'SistemaDescuentosCementerios',
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