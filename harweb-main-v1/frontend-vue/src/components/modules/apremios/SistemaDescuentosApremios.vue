<template>
  <div class="container-fluid mt-4">
    <!-- Header del Sistema -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #fd7e14 !important;">
      <div class="card-body p-4">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-warning bg-opacity-10 rounded-3 p-3 me-3">
              <i class="fas fa-percentage fa-2x text-warning"></i>
            </div>
            <div>
              <h1 class="h3 fw-bold text-dark mb-1">Sistema de Descuentos y Conversión</h1>
              <p class="text-muted mb-0">Descuentos automatizados y conversión de procedimientos de pago</p>
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
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="revaluacion-tab" data-bs-toggle="tab" data-bs-target="#revaluacion" type="button" role="tab">
              <i class="fas fa-calculator me-2"></i>Revaluación
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
                <h4 class="fw-bold text-warning mb-3">
                  <i class="fas fa-percentage me-2"></i>Descuentos de Recargos y Multas
                </h4>
                <p class="text-muted mb-4">Sistema automatizado de aplicación de descuentos según criterios establecidos</p>

                <!-- Configuración de Descuentos -->
                <div class="card border border-warning border-opacity-25 mb-4">
                  <div class="card-header bg-warning bg-opacity-10">
                    <h6 class="fw-bold mb-0 text-warning">
                      <i class="fas fa-cog me-2"></i>Configuración de Descuentos
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
                          <option>Descuento Especial</option>
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
                          <label class="form-check-label" for="recargos">Recargos</label>
                        </div>
                        <div class="form-check">
                          <input class="form-check-input" type="checkbox" id="multas">
                          <label class="form-check-label" for="multas">Multas</label>
                        </div>
                        <div class="form-check">
                          <input class="form-check-input" type="checkbox" id="intereses">
                          <label class="form-check-label" for="intereses">Intereses</label>
                        </div>
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
                      <button class="btn btn-warning">
                        <i class="fas fa-save me-2"></i>Guardar Configuración
                      </button>
                      <button class="btn btn-outline-warning">
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
                        <label class="form-label fw-medium">RFC del Contribuyente</label>
                        <input type="text" class="form-control" placeholder="PEGJ800101ABC">
                      </div>
                      <div class="col-md-4">
                        <label class="form-label fw-medium">Tipo de Descuento</label>
                        <select class="form-select">
                          <option>Seleccionar...</option>
                          <option>Pronto Pago (20%)</option>
                          <option>Convenio (15%)</option>
                          <option>Regularización (10%)</option>
                        </select>
                      </div>
                      <div class="col-md-4">
                        <label class="form-label fw-medium">Autorización</label>
                        <input type="text" class="form-control" placeholder="No. Autorización">
                      </div>
                    </div>

                    <div class="mt-4 row">
                      <div class="col-md-6">
                        <h6 class="fw-bold text-dark">Cálculo Original</h6>
                        <div class="bg-light p-3 rounded">
                          <p class="mb-1">Capital: <strong>$15,000.00</strong></p>
                          <p class="mb-1">Recargos: <strong>$3,000.00</strong></p>
                          <p class="mb-1">Multas: <strong>$1,500.00</strong></p>
                          <p class="mb-0">Total: <strong>$19,500.00</strong></p>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <h6 class="fw-bold text-success">Con Descuento</h6>
                        <div class="bg-success bg-opacity-10 p-3 rounded border border-success border-opacity-25">
                          <p class="mb-1">Capital: <strong>$15,000.00</strong></p>
                          <p class="mb-1">Recargos: <strong class="text-success">$2,400.00</strong> <small class="text-muted">(-20%)</small></p>
                          <p class="mb-1">Multas: <strong class="text-success">$1,200.00</strong> <small class="text-muted">(-20%)</small></p>
                          <p class="mb-0">Total: <strong class="text-success">$18,600.00</strong></p>
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
                <div class="bg-warning bg-opacity-10 rounded-3 p-3 mb-3">
                  <h6 class="fw-bold text-warning mb-2">
                    <i class="fas fa-info-circle me-2"></i>Información
                  </h6>
                  <p class="small text-muted mb-2">• Aplicación automática según criterios</p>
                  <p class="small text-muted mb-2">• Control de autorizaciones requeridas</p>
                  <p class="small text-muted mb-0">• Historial completo de aplicaciones</p>
                </div>

                <div class="bg-primary bg-opacity-10 rounded-3 p-3">
                  <h6 class="fw-bold text-primary mb-2">
                    <i class="fas fa-chart-pie me-2"></i>Estadísticas del Mes
                  </h6>
                  <p class="small mb-1">Descuentos Aplicados: <strong>245</strong></p>
                  <p class="small mb-1">Monto Descontado: <strong>$2,450,000</strong></p>
                  <p class="small mb-0">Promedio: <strong>$10,000</strong></p>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 2: Conversión de Procedimientos -->
          <div class="tab-pane fade" id="conversion" role="tabpanel">
            <div class="row">
              <div class="col-lg-8">
                <h4 class="fw-bold text-info mb-3">
                  <i class="fas fa-sync-alt me-2"></i>Conversión de Procedimientos de Pago
                </h4>
                <p class="text-muted mb-4">Sistema de conversión de procedimientos de pago en caja</p>

                <!-- Selección de Procedimiento -->
                <div class="card border border-info border-opacity-25 mb-4">
                  <div class="card-header bg-info bg-opacity-10">
                    <h6 class="fw-bold mb-0 text-info">
                      <i class="fas fa-file-alt me-2"></i>Procedimiento a Convertir
                    </h6>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Tipo de Procedimiento Original</label>
                        <select class="form-select">
                          <option>Procedimiento Administrativo</option>
                          <option>Procedimiento Económico Coactivo</option>
                          <option>Embargo Precautorio</option>
                          <option>Mandamiento de Ejecución</option>
                        </select>
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Número de Expediente</label>
                        <input type="text" class="form-control" placeholder="EXP-2024-001">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Convertir a</label>
                        <select class="form-select">
                          <option>Pago Directo en Caja</option>
                          <option>Convenio de Pago</option>
                          <option>Pago en Parcialidades</option>
                        </select>
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Motivo de Conversión</label>
                        <select class="form-select">
                          <option>Solicitud del Contribuyente</option>
                          <option>Criterios de Eficiencia</option>
                          <option>Política Fiscal</option>
                          <option>Regularización Voluntaria</option>
                        </select>
                      </div>
                    </div>

                    <div class="mt-3 d-flex gap-2">
                      <button class="btn btn-info">
                        <i class="fas fa-search me-2"></i>Buscar Expediente
                      </button>
                      <button class="btn btn-outline-info">
                        <i class="fas fa-eye me-2"></i>Ver Detalles
                      </button>
                    </div>
                  </div>
                </div>

                <!-- Datos del Expediente -->
                <div class="card border border-secondary border-opacity-25">
                  <div class="card-header bg-secondary bg-opacity-10">
                    <h6 class="fw-bold mb-0">Datos del Expediente</h6>
                  </div>
                  <div class="card-body">
                    <div class="row">
                      <div class="col-md-6">
                        <p><strong>Contribuyente:</strong> Juan Pérez García</p>
                        <p><strong>RFC:</strong> PEGJ800101ABC</p>
                        <p><strong>Adeudo Original:</strong> $25,000.00</p>
                        <p><strong>Recargos:</strong> $5,000.00</p>
                      </div>
                      <div class="col-md-6">
                        <p><strong>Estado Actual:</strong> <span class="badge bg-warning">En Proceso</span></p>
                        <p><strong>Fecha Inicio:</strong> 15/08/2024</p>
                        <p><strong>Ejecutor:</strong> Lic. Juan Pérez</p>
                        <p><strong>Total Adeudo:</strong> <strong>$30,000.00</strong></p>
                      </div>
                    </div>

                    <div class="mt-3 alert alert-info">
                      <h6 class="fw-bold">
                        <i class="fas fa-info-circle me-2"></i>Nueva Modalidad de Pago
                      </h6>
                      <p class="mb-2">El procedimiento se convertirá a <strong>Pago Directo en Caja</strong></p>
                      <p class="mb-0">Se aplicarán los descuentos correspondientes por conversión voluntaria</p>
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
                <div class="bg-info bg-opacity-10 rounded-3 p-3">
                  <h6 class="fw-bold text-info mb-2">
                    <i class="fas fa-lightbulb me-2"></i>Beneficios
                  </h6>
                  <p class="small text-muted mb-2">• Agilización del proceso de cobro</p>
                  <p class="small text-muted mb-2">• Reducción de costos administrativos</p>
                  <p class="small text-muted mb-2">• Mayor satisfacción del contribuyente</p>
                  <p class="small text-muted mb-0">• Optimización de recursos</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 3: Revaluación de Costos -->
          <div class="tab-pane fade" id="revaluacion" role="tabpanel">
            <div class="row">
              <div class="col-lg-8">
                <h4 class="fw-bold text-primary mb-3">
                  <i class="fas fa-calculator me-2"></i>Cálculo para Revaluación de Costos
                </h4>
                <p class="text-muted mb-4">Sistema de actualización automática de valores según índices oficiales</p>

                <!-- Configuración de Índices -->
                <div class="card border border-primary border-opacity-25 mb-4">
                  <div class="card-header bg-primary bg-opacity-10">
                    <h6 class="fw-bold mb-0 text-primary">
                      <i class="fas fa-chart-line me-2"></i>Índices de Revaluación
                    </h6>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Tipo de Índice</label>
                        <select class="form-select">
                          <option>INPC (Índice Nacional de Precios)</option>
                          <option>UMA (Unidad de Medida y Actualización)</option>
                          <option>Índice Estatal</option>
                          <option>Índice Municipal</option>
                        </select>
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Período Base</label>
                        <input type="month" class="form-control">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Valor Índice Base</label>
                        <input type="number" class="form-control" placeholder="108.24" step="0.01">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Valor Índice Actual</label>
                        <input type="number" class="form-control" placeholder="115.67" step="0.01">
                      </div>
                    </div>

                    <div class="mt-3 alert alert-light">
                      <p class="mb-2"><strong>Factor de Actualización:</strong> <span class="text-primary">1.0686</span></p>
                      <p class="mb-0"><small class="text-muted">Factor = Índice Actual / Índice Base</small></p>
                    </div>
                  </div>
                </div>

                <!-- Cálculo de Revaluación -->
                <div class="card border border-success border-opacity-25">
                  <div class="card-header bg-success bg-opacity-10">
                    <h6 class="fw-bold mb-0 text-success">
                      <i class="fas fa-calculator me-2"></i>Cálculo de Revaluación
                    </h6>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-md-6">
                        <label class="form-label fw-medium">RFC del Contribuyente</label>
                        <input type="text" class="form-control" placeholder="PEGJ800101ABC">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Concepto a Revaluar</label>
                        <select class="form-select">
                          <option>Impuesto Predial</option>
                          <option>Licencias de Funcionamiento</option>
                          <option>Multas y Sanciones</option>
                          <option>Derechos Municipales</option>
                        </select>
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Importe Original</label>
                        <input type="number" class="form-control" placeholder="15000.00" step="0.01">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Fecha del Importe</label>
                        <input type="date" class="form-control">
                      </div>
                    </div>

                    <div class="mt-4 row">
                      <div class="col-md-6">
                        <h6 class="fw-bold text-dark">Valores Originales</h6>
                        <div class="bg-light p-3 rounded">
                          <p class="mb-1">Importe Base: <strong>$15,000.00</strong></p>
                          <p class="mb-1">Fecha: <strong>Enero 2023</strong></p>
                          <p class="mb-0">Índice Base: <strong>108.24</strong></p>
                        </div>
                      </div>
                      <div class="col-md-6">
                        <h6 class="fw-bold text-success">Valores Actualizados</h6>
                        <div class="bg-success bg-opacity-10 p-3 rounded border border-success border-opacity-25">
                          <p class="mb-1">Importe Actualizado: <strong class="text-success">$16,029.00</strong></p>
                          <p class="mb-1">Factor Aplicado: <strong>1.0686</strong></p>
                          <p class="mb-0">Diferencia: <strong class="text-success">+$1,029.00</strong></p>
                        </div>
                      </div>
                    </div>

                    <div class="mt-3 d-flex gap-2">
                      <button class="btn btn-primary">
                        <i class="fas fa-calculator me-2"></i>Calcular Revaluación
                      </button>
                      <button class="btn btn-success">
                        <i class="fas fa-save me-2"></i>Aplicar Actualización
                      </button>
                      <button class="btn btn-outline-primary">
                        <i class="fas fa-print me-2"></i>Imprimir Cálculo
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="bg-primary bg-opacity-10 rounded-3 p-3 mb-3">
                  <h6 class="fw-bold text-primary mb-2">
                    <i class="fas fa-info-circle me-2"></i>Marco Legal
                  </h6>
                  <p class="small text-muted mb-2">• Código Fiscal de la Federación</p>
                  <p class="small text-muted mb-2">• Ley de Ingresos Municipal</p>
                  <p class="small text-muted mb-0">• Índices oficiales INEGI</p>
                </div>

                <div class="bg-warning bg-opacity-10 rounded-3 p-3">
                  <h6 class="fw-bold text-warning mb-2">
                    <i class="fas fa-calendar me-2"></i>Actualización Automática
                  </h6>
                  <p class="small text-muted mb-2">Los índices se actualizan automáticamente cada mes</p>
                  <p class="small text-muted mb-0">Última actualización: <strong>Octubre 2024</strong></p>
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
  name: 'SistemaDescuentosApremios',
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
  border-bottom-color: #fd7e14;
  color: #fd7e14;
  font-weight: 600;
}

.nav-tabs .nav-link:hover {
  border-bottom-color: #fd7e14;
  color: #fd7e14;
}
</style>