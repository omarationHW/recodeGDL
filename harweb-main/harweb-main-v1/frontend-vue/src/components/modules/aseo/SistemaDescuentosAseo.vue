<template>
  <div class="container-fluid mt-4">
    <!-- Header del Sistema -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #6f42c1 !important;">
      <div class="card-body p-4">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-secondary bg-opacity-10 rounded-3 p-3 me-3">
              <i class="fas fa-percentage fa-2x text-secondary"></i>
            </div>
            <div>
              <h1 class="h3 fw-bold text-dark mb-1">Sistema de Descuentos - Aseo</h1>
              <p class="text-muted mb-0">Descuentos automatizados y conversión de procedimientos para aseo</p>
            </div>
          </div>
          <div>
            <span class="badge bg-danger fs-6">NUEVO</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Navegación por Pestañas -->
    <div class="card border-0 shadow-sm">
      <div class="card-header bg-white border-bottom">
        <ul class="nav nav-tabs card-header-tabs" id="descuentosTab" role="tablist">
          <li class="nav-item" role="presentation">
            <button class="nav-link active" id="descuentos-tab" data-bs-toggle="tab" data-bs-target="#descuentos" type="button" role="tab">
              <i class="fas fa-percentage me-2"></i>Descuentos
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="conversion-tab" data-bs-toggle="tab" data-bs-target="#conversion" type="button" role="tab">
              <i class="fas fa-sync-alt me-2"></i>Conversión
            </button>
          </li>
        </ul>
      </div>

      <div class="card-body p-4">
        <div class="tab-content" id="descuentosTabContent">

          <!-- Pestaña 1: Descuentos de Recargos y Multas -->
          <div class="tab-pane fade show active" id="descuentos" role="tabpanel">
            <div class="row">
              <div class="col-lg-8">
                <h4 class="fw-bold text-secondary mb-3">
                  <i class="fas fa-percentage me-2"></i>Descuentos para Servicios de Aseo
                </h4>
                <p class="text-muted mb-4">Sistema automatizado de descuentos específicos para servicios de aseo urbano</p>

                <!-- Configuración de Descuentos -->
                <div class="card border border-secondary border-opacity-25 mb-4">
                  <div class="card-header bg-secondary bg-opacity-10">
                    <h6 class="fw-bold mb-0 text-secondary">
                      <i class="fas fa-cog me-2"></i>Configuración de Descuentos para Aseo
                    </h6>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Tipo de Descuento</label>
                        <select class="form-select">
                          <option>Descuento por Pronto Pago</option>
                          <option>Descuento por Convenio</option>
                          <option>Descuento por Regularización</option>
                          <option>Descuento por Usuario Responsable</option>
                          <option>Descuento por Zona Vulnerable</option>
                        </select>
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Porcentaje (%)</label>
                        <input type="number" class="form-control" placeholder="0" min="0" max="100" step="1">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Aplicable a</label>
                        <div class="form-check">
                          <input class="form-check-input" type="checkbox" id="recargos">
                          <label class="form-check-label" for="recargos">Recargos por Servicio</label>
                        </div>
                        <div class="form-check">
                          <input class="form-check-input" type="checkbox" id="multas">
                          <label class="form-check-label" for="multas">Multas por Incumplimiento</label>
                        </div>
                        <div class="form-check">
                          <input class="form-check-input" type="checkbox" id="intereses">
                          <label class="form-check-label" for="intereses">Intereses Moratorios</label>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Zona de Aplicación</label>
                        <select class="form-select">
                          <option>Todas las zonas</option>
                          <option>Zona 1 - Centro</option>
                          <option>Zona 2 - Norte</option>
                          <option>Zona 3 - Sur</option>
                          <option>Zona 4 - Oriente</option>
                          <option>Zona 5 - Poniente</option>
                        </select>
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Tipo de Usuario</label>
                        <select class="form-select">
                          <option>Todos los tipos</option>
                          <option>Domiciliario</option>
                          <option>Comercial</option>
                          <option>Industrial</option>
                          <option>Servicio Especial</option>
                        </select>
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Vigencia</label>
                        <div class="row g-2">
                          <div class="col-6">
                            <input type="date" class="form-control" placeholder="Desde">
                          </div>
                          <div class="col-6">
                            <input type="date" class="form-control" placeholder="Hasta">
                          </div>
                        </div>
                      </div>
                    </div>

                    <div class="mt-3 d-flex gap-2">
                      <button class="btn btn-secondary">
                        <i class="fas fa-save me-2"></i>Guardar Configuración
                      </button>
                      <button class="btn btn-outline-secondary">
                        <i class="fas fa-list me-2"></i>Ver Configuraciones
                      </button>
                    </div>
                  </div>
                </div>

                <!-- Aplicación de Descuentos -->
                <div class="card border border-info border-opacity-25">
                  <div class="card-header bg-info bg-opacity-10">
                    <h6 class="fw-bold mb-0 text-info">
                      <i class="fas fa-play me-2"></i>Aplicación de Descuentos
                    </h6>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-md-4">
                        <label class="form-label fw-medium">Cuenta de Servicio</label>
                        <input type="text" class="form-control" placeholder="ASE-12345">
                      </div>
                      <div class="col-md-4">
                        <label class="form-label fw-medium">Zona de Servicio</label>
                        <select class="form-select">
                          <option>Zona 1 - Centro</option>
                          <option>Zona 2 - Norte</option>
                          <option>Zona 3 - Sur</option>
                        </select>
                      </div>
                      <div class="col-md-4">
                        <label class="form-label fw-medium">Tipo de Descuento</label>
                        <select class="form-select">
                          <option>Seleccionar...</option>
                          <option>Pronto Pago (15%)</option>
                          <option>Convenio (10%)</option>
                          <option>Regularización (20%)</option>
                        </select>
                      </div>
                    </div>

                    <div class="mt-4 row">
                      <div class="col-md-6">
                        <h6 class="fw-bold text-dark">Cálculo Original</h6>
                        <div class="bg-light p-3 rounded">
                          <p class="mb-1">Servicio Base: <strong>$800.00</strong></p>
                          <p class="mb-1">Recargos: <strong>$160.00</strong></p>
                          <p class="mb-1">Multas: <strong>$80.00</strong></p>
                          <p class="mb-0">Total: <strong>$1,040.00</strong></p>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <h6 class="fw-bold text-success">Con Descuento</h6>
                        <div class="bg-success bg-opacity-10 p-3 rounded border border-success border-opacity-25">
                          <p class="mb-1">Servicio Base: <strong>$800.00</strong></p>
                          <p class="mb-1">Recargos: <strong class="text-success">$136.00</strong> <small class="text-muted">(-15%)</small></p>
                          <p class="mb-1">Multas: <strong class="text-success">$68.00</strong> <small class="text-muted">(-15%)</small></p>
                          <p class="mb-0">Total: <strong class="text-success">$1,004.00</strong></p>
                        </div>
                      </div>
                    </div>

                    <div class="mt-3 d-flex gap-2">
                      <button class="btn btn-success">
                        <i class="fas fa-check me-2"></i>Aplicar Descuento
                      </button>
                      <button class="btn btn-outline-info">
                        <i class="fas fa-calculator me-2"></i>Recalcular
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="bg-secondary bg-opacity-10 rounded-3 p-3 mb-3">
                  <h6 class="fw-bold text-secondary mb-2">
                    <i class="fas fa-recycle me-2"></i>Información de Aseo
                  </h6>
                  <p class="small text-muted mb-2">• Descuentos específicos por zona</p>
                  <p class="small text-muted mb-2">• Consideración de tipo de usuario</p>
                  <p class="small text-muted mb-0">• Aplicación automática por servicio</p>
                </div>

                <div class="bg-primary bg-opacity-10 rounded-3 p-3">
                  <h6 class="fw-bold text-primary mb-2">
                    <i class="fas fa-chart-pie me-2"></i>Estadísticas del Mes
                  </h6>
                  <p class="small mb-1">Descuentos Aplicados: <strong>156</strong></p>
                  <p class="small mb-1">Monto Descontado: <strong>$124,800</strong></p>
                  <p class="small mb-0">Promedio por Usuario: <strong>$800</strong></p>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 2: Conversión de Procedimientos -->
          <div class="tab-pane fade" id="conversion" role="tabpanel">
            <div class="row">
              <div class="col-lg-8">
                <h4 class="fw-bold text-info mb-3">
                  <i class="fas fa-sync-alt me-2"></i>Conversión de Procedimientos de Aseo
                </h4>
                <p class="text-muted mb-4">Sistema de conversión específico para servicios de aseo urbano</p>

                <!-- Selección de Procedimiento -->
                <div class="card border border-info border-opacity-25 mb-4">
                  <div class="card-header bg-info bg-opacity-10">
                    <h6 class="fw-bold mb-0 text-info">
                      <i class="fas fa-file-alt me-2"></i>Procedimiento de Aseo a Convertir
                    </h6>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Tipo de Procedimiento</label>
                        <select class="form-select">
                          <option>Procedimiento de Cobranza de Aseo</option>
                          <option>Embargo por Servicio de Aseo</option>
                          <option>Suspensión de Servicio</option>
                          <option>Multa por Incumplimiento</option>
                        </select>
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Cuenta de Servicio</label>
                        <input type="text" class="form-control" placeholder="ASE-12345">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Zona de Servicio</label>
                        <select class="form-select">
                          <option>Zona 1 - Centro</option>
                          <option>Zona 2 - Norte</option>
                          <option>Zona 3 - Sur</option>
                          <option>Zona 4 - Oriente</option>
                          <option>Zona 5 - Poniente</option>
                        </select>
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Convertir a</label>
                        <select class="form-select">
                          <option>Pago Directo en Caja</option>
                          <option>Convenio de Pago</option>
                          <option>Pago en Parcialidades</option>
                          <option>Servicio Regularizado</option>
                        </select>
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Motivo de Conversión</label>
                        <select class="form-select">
                          <option>Solicitud del Usuario</option>
                          <option>Programa de Regularización</option>
                          <option>Beneficio Social</option>
                          <option>Política Municipal</option>
                        </select>
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Ruta de Recolección</label>
                        <select class="form-select">
                          <option>Ruta A - Matutina</option>
                          <option>Ruta B - Vespertina</option>
                          <option>Ruta C - Especial</option>
                        </select>
                      </div>
                    </div>

                    <div class="mt-3 d-flex gap-2">
                      <button class="btn btn-info">
                        <i class="fas fa-search me-2"></i>Buscar Cuenta
                      </button>
                      <button class="btn btn-outline-info">
                        <i class="fas fa-eye me-2"></i>Ver Detalles
                      </button>
                    </div>
                  </div>
                </div>

                <!-- Datos del Servicio -->
                <div class="card border border-secondary border-opacity-25">
                  <div class="card-header bg-secondary bg-opacity-10">
                    <h6 class="fw-bold mb-0">Datos del Servicio de Aseo</h6>
                  </div>
                  <div class="card-body">
                    <div class="row">
                      <div class="col-md-6">
                        <p><strong>Usuario:</strong> Juan Pérez García</p>
                        <p><strong>Cuenta:</strong> ASE-12345</p>
                        <p><strong>Zona:</strong> Zona 1 - Centro</p>
                        <p><strong>Tipo de Servicio:</strong> Domiciliario</p>
                      </div>
                      <div class="col-md-6">
                        <p><strong>Adeudo del Servicio:</strong> $2,500.00</p>
                        <p><strong>Recargos:</strong> $500.00</p>
                        <p><strong>Estado Actual:</strong> <span class="badge bg-warning">En Cobranza</span></p>
                        <p><strong>Total Adeudo:</strong> <strong>$3,000.00</strong></p>
                      </div>
                    </div>

                    <div class="mt-3 alert alert-info">
                      <h6 class="fw-bold">
                        <i class="fas fa-recycle me-2"></i>Nueva Modalidad de Pago para Servicio de Aseo
                      </h6>
                      <p class="mb-2">El procedimiento se convertirá a <strong>Pago Directo en Caja</strong></p>
                      <p class="mb-0">Se aplicarán descuentos por conversión voluntaria y regularización del servicio</p>
                    </div>

                    <div class="d-flex gap-2">
                      <button class="btn btn-success">
                        <i class="fas fa-check me-2"></i>Confirmar Conversión
                      </button>
                      <button class="btn btn-outline-secondary">
                        <i class="fas fa-times me-2"></i>Cancelar
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="bg-info bg-opacity-10 rounded-3 p-3 mb-3">
                  <h6 class="fw-bold text-info mb-2">
                    <i class="fas fa-recycle me-2"></i>Beneficios para Aseo
                  </h6>
                  <p class="small text-muted mb-2">• Regularización del servicio</p>
                  <p class="small text-muted mb-2">• Continuidad en recolección</p>
                  <p class="small text-muted mb-2">• Facilidades de pago</p>
                  <p class="small text-muted mb-0">• Descuentos por pronto pago</p>
                </div>

                <div class="bg-warning bg-opacity-10 rounded-3 p-3">
                  <h6 class="fw-bold text-warning mb-2">
                    <i class="fas fa-route me-2"></i>Consideraciones Especiales
                  </h6>
                  <p class="small text-muted mb-2">• Continuidad del servicio durante conversión</p>
                  <p class="small text-muted mb-0">• Ruta de recolección asignada</p>
                </div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SistemaDescuentosAseo',
  data() {
    return {
      // Estado del componente
    }
  },
  methods: {
    // Métodos del componente
  }
}
</script>

<style scoped>
.nav-tabs .nav-link {
  border-bottom: 2px solid transparent;
  color: #6c757d;
}

.nav-tabs .nav-link.active {
  border-bottom-color: #6c757d;
  color: #6c757d;
  font-weight: 600;
}

.nav-tabs .nav-link:hover {
  border-bottom-color: #6c757d;
  color: #6c757d;
}
</style>