<template>
  <div class="container-fluid mt-4">
    <!-- Header del Sistema -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #20c997 !important;">
      <div class="card-body p-4">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-info bg-opacity-10 rounded-3 p-3 me-3">
              <i class="fas fa-handshake fa-2x text-info"></i>
            </div>
            <div>
              <h1 class="h3 fw-bold text-dark mb-1">Sistema de Convenios - Aseo</h1>
              <p class="text-muted mb-0">Gestión integral de convenios de pago para servicios de aseo urbano</p>
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
        <ul class="nav nav-tabs card-header-tabs" id="conveniosTab" role="tablist">
          <li class="nav-item" role="presentation">
            <button class="nav-link active" id="intereses-tab" data-bs-toggle="tab" data-bs-target="#intereses" type="button" role="tab">
              <i class="fas fa-percentage me-2"></i>Catálogo Intereses
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="convenio-tab" data-bs-toggle="tab" data-bs-target="#convenio" type="button" role="tab">
              <i class="fas fa-file-contract me-2"></i>ABC Convenio
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="parcialidades-tab" data-bs-toggle="tab" data-bs-target="#parcialidades" type="button" role="tab">
              <i class="fas fa-list-ol me-2"></i>Parcialidades
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="pagos-tab" data-bs-toggle="tab" data-bs-target="#pagos" type="button" role="tab">
              <i class="fas fa-credit-card me-2"></i>ABC Pagos
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="impresion-tab" data-bs-toggle="tab" data-bs-target="#impresion" type="button" role="tab">
              <i class="fas fa-print me-2"></i>Impresión
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="consulta-tab" data-bs-toggle="tab" data-bs-target="#consulta" type="button" role="tab">
              <i class="fas fa-search me-2"></i>Consulta
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="reportes-tab" data-bs-toggle="tab" data-bs-target="#reportes" type="button" role="tab">
              <i class="fas fa-chart-bar me-2"></i>Reportes
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="cancelacion-tab" data-bs-toggle="tab" data-bs-target="#cancelacion" type="button" role="tab">
              <i class="fas fa-ban me-2"></i>Cancelación
            </button>
          </li>
        </ul>
      </div>

      <div class="card-body p-4">
        <div class="tab-content" id="conveniosTabContent">

          <!-- Pestaña 1: Catálogo de Intereses -->
          <div class="tab-pane fade show active" id="intereses" role="tabpanel">
            <div class="row">
              <div class="col-lg-8">
                <h4 class="fw-bold text-info mb-3">
                  <i class="fas fa-percentage me-2"></i>Catálogo de Intereses
                </h4>
                <p class="text-muted mb-4">Gestión completa de tasas de interés aplicables a servicios de aseo urbano</p>

                <div class="row g-3 mb-4">
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Tipo de Servicio</label>
                    <select class="form-select">
                      <option>Seleccionar tipo...</option>
                      <option>Servicio Domiciliario</option>
                      <option>Servicio Comercial</option>
                      <option>Servicio Industrial</option>
                      <option>Servicio Especial</option>
                    </select>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Tasa de Interés (%)</label>
                    <input type="number" class="form-control" placeholder="0.00" step="0.01">
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

                <div class="d-flex gap-2 mb-4">
                  <button class="btn btn-info">
                    <i class="fas fa-plus me-2"></i>Agregar
                  </button>
                  <button class="btn btn-outline-info">
                    <i class="fas fa-edit me-2"></i>Modificar
                  </button>
                  <button class="btn btn-outline-secondary">
                    <i class="fas fa-trash me-2"></i>Eliminar
                  </button>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="bg-info bg-opacity-10 rounded-3 p-3">
                  <h6 class="fw-bold text-info mb-2">
                    <i class="fas fa-info-circle me-2"></i>Información
                  </h6>
                  <p class="small text-muted mb-2">• Control de intereses por zona de servicio</p>
                  <p class="small text-muted mb-2">• Diferenciación por tipo de usuario</p>
                  <p class="small text-muted mb-0">• Aplicación automática en cálculos</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 2: ABC del Convenio -->
          <div class="tab-pane fade" id="convenio" role="tabpanel">
            <div class="row">
              <div class="col-lg-8">
                <h4 class="fw-bold text-info mb-3">
                  <i class="fas fa-file-contract me-2"></i>ABC del Convenio
                </h4>
                <p class="text-muted mb-4">Administración integral de convenios de pago para servicios de aseo</p>

                <div class="row g-3 mb-4">
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Cuenta de Servicio</label>
                    <input type="text" class="form-control" placeholder="ASE-2024-001">
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Usuario del Servicio</label>
                    <input type="text" class="form-control" placeholder="Nombre/Razón Social">
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">RFC</label>
                    <input type="text" class="form-control" placeholder="RFC del usuario">
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Tipo de Servicio</label>
                    <select class="form-select">
                      <option>Domiciliario</option>
                      <option>Comercial</option>
                      <option>Industrial</option>
                      <option>Especial</option>
                    </select>
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
                    <label class="form-label fw-medium">Adeudo Total</label>
                    <input type="number" class="form-control" placeholder="0.00" step="0.01">
                  </div>
                  <div class="col-md-4">
                    <label class="form-label fw-medium">Parcialidades</label>
                    <select class="form-select">
                      <option>3 mensualidades</option>
                      <option>6 mensualidades</option>
                      <option>12 mensualidades</option>
                      <option>24 mensualidades</option>
                    </select>
                  </div>
                  <div class="col-md-4">
                    <label class="form-label fw-medium">Enganche (%)</label>
                    <input type="number" class="form-control" placeholder="20" step="1">
                  </div>
                  <div class="col-md-4">
                    <label class="form-label fw-medium">Primer Pago</label>
                    <input type="date" class="form-control">
                  </div>
                </div>

                <div class="d-flex gap-2 mb-4">
                  <button class="btn btn-info">
                    <i class="fas fa-plus me-2"></i>Crear Convenio
                  </button>
                  <button class="btn btn-outline-info">
                    <i class="fas fa-calculator me-2"></i>Generar Parcialidades
                  </button>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="bg-info bg-opacity-10 rounded-3 p-3">
                  <h6 class="fw-bold text-info mb-2">
                    <i class="fas fa-recycle me-2"></i>Servicios de Aseo
                  </h6>
                  <p class="small text-muted mb-2">• Convenios por zona de recolección</p>
                  <p class="small text-muted mb-2">• Diferenciación por tipo de usuario</p>
                  <p class="small text-muted mb-0">• Cronograma adaptado al servicio</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 3: Desglose de Parcialidades -->
          <div class="tab-pane fade" id="parcialidades" role="tabpanel">
            <h4 class="fw-bold text-info mb-3">
              <i class="fas fa-list-ol me-2"></i>Desglose de Parcialidades
            </h4>
            <p class="text-muted mb-4">Administración detallada de parcialidades con rubros específicos por zona</p>

            <div class="table-responsive">
              <table class="table table-hover">
                <thead class="table-info">
                  <tr>
                    <th>No.</th>
                    <th>Fecha Vencimiento</th>
                    <th>Servicio Base</th>
                    <th>Recargos</th>
                    <th>Intereses</th>
                    <th>Total</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td><span class="badge bg-info">1</span></td>
                    <td>15/10/2024</td>
                    <td>$800.00</td>
                    <td>$160.00</td>
                    <td>$40.00</td>
                    <td><strong>$1,000.00</strong></td>
                    <td><span class="badge bg-success">Pagado</span></td>
                    <td>
                      <button class="btn btn-sm btn-outline-info">
                        <i class="fas fa-eye"></i>
                      </button>
                    </td>
                  </tr>
                  <tr>
                    <td><span class="badge bg-info">2</span></td>
                    <td>15/11/2024</td>
                    <td>$800.00</td>
                    <td>$160.00</td>
                    <td>$45.00</td>
                    <td><strong>$1,005.00</strong></td>
                    <td><span class="badge bg-warning">Pendiente</span></td>
                    <td>
                      <button class="btn btn-sm btn-outline-info">
                        <i class="fas fa-edit"></i>
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Pestaña 4: ABC de Pagos -->
          <div class="tab-pane fade" id="pagos" role="tabpanel">
            <h4 class="fw-bold text-info mb-3">
              <i class="fas fa-credit-card me-2"></i>ABC de Pagos
            </h4>
            <p class="text-muted mb-4">Gestión integral de pagos realizados en convenios de aseo</p>

            <div class="row g-3 mb-4">
              <div class="col-md-4">
                <label class="form-label fw-medium">No. Convenio</label>
                <input type="text" class="form-control" placeholder="ASE-CONV-2024-001">
              </div>
              <div class="col-md-4">
                <label class="form-label fw-medium">No. Parcialidad</label>
                <select class="form-select">
                  <option>Seleccionar...</option>
                  <option>Parcialidad 1</option>
                  <option>Parcialidad 2</option>
                  <option>Parcialidad 3</option>
                </select>
              </div>
              <div class="col-md-4">
                <label class="form-label fw-medium">Importe Pagado</label>
                <input type="number" class="form-control" placeholder="0.00" step="0.01">
              </div>
              <div class="col-md-4">
                <label class="form-label fw-medium">Fecha de Pago</label>
                <input type="date" class="form-control">
              </div>
              <div class="col-md-4">
                <label class="form-label fw-medium">Forma de Pago</label>
                <select class="form-select">
                  <option>Efectivo</option>
                  <option>Transferencia</option>
                  <option>Cheque</option>
                  <option>Tarjeta</option>
                </select>
              </div>
              <div class="col-md-4">
                <label class="form-label fw-medium">No. Recibo</label>
                <input type="text" class="form-control" placeholder="ASE-REC-2024-001">
              </div>
            </div>

            <div class="d-flex gap-2">
              <button class="btn btn-info">
                <i class="fas fa-save me-2"></i>Registrar Pago
              </button>
              <button class="btn btn-outline-info">
                <i class="fas fa-print me-2"></i>Imprimir Recibo
              </button>
            </div>
          </div>

          <!-- Pestaña 5: Impresión -->
          <div class="tab-pane fade" id="impresion" role="tabpanel">
            <h4 class="fw-bold text-info mb-3">
              <i class="fas fa-print me-2"></i>Impresión de Documentos
            </h4>
            <p class="text-muted mb-4">Generación de documentos oficiales del convenio de aseo</p>

            <div class="row g-4">
              <div class="col-md-6">
                <div class="card border border-info border-opacity-25">
                  <div class="card-body text-center">
                    <div class="bg-info bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-file-contract fa-2x text-info"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Convenio de Aseo</h5>
                    <p class="text-muted small mb-3">Documento oficial del convenio de pago</p>
                    <button class="btn btn-info">
                      <i class="fas fa-print me-2"></i>Imprimir Convenio
                    </button>
                  </div>
                </div>
              </div>

              <div class="col-md-6">
                <div class="card border border-info border-opacity-25">
                  <div class="card-body text-center">
                    <div class="bg-info bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-money-check fa-2x text-info"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Pagaré</h5>
                    <p class="text-muted small mb-3">Pagaré correspondiente al convenio</p>
                    <button class="btn btn-info">
                      <i class="fas fa-print me-2"></i>Imprimir Pagaré
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 6: Consulta -->
          <div class="tab-pane fade" id="consulta" role="tabpanel">
            <h4 class="fw-bold text-info mb-3">
              <i class="fas fa-search me-2"></i>Consulta General
            </h4>
            <p class="text-muted mb-4">Sistema de consulta integral de convenios de aseo</p>

            <div class="row g-3 mb-4">
              <div class="col-md-4">
                <label class="form-label fw-medium">Buscar por:</label>
                <select class="form-select">
                  <option>No. Convenio</option>
                  <option>Cuenta de Servicio</option>
                  <option>RFC</option>
                  <option>Usuario</option>
                  <option>Zona</option>
                </select>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-medium">Criterio de Búsqueda</label>
                <input type="text" class="form-control" placeholder="Ingrese el criterio...">
              </div>
              <div class="col-md-2">
                <label class="form-label fw-medium">&nbsp;</label>
                <button class="btn btn-info w-100">
                  <i class="fas fa-search me-2"></i>Buscar
                </button>
              </div>
            </div>

            <div class="card border border-info border-opacity-25">
              <div class="card-header bg-info bg-opacity-10">
                <h6 class="fw-bold mb-0">Resultado de Búsqueda</h6>
              </div>
              <div class="card-body">
                <div class="row">
                  <div class="col-md-6">
                    <p><strong>No. Convenio:</strong> ASE-CONV-2024-001</p>
                    <p><strong>Usuario:</strong> Juan Pérez García</p>
                    <p><strong>RFC:</strong> PEGJ800101ABC</p>
                    <p><strong>Tipo de Servicio:</strong> Domiciliario</p>
                  </div>
                  <div class="col-md-6">
                    <p><strong>Zona:</strong> Zona 1 - Centro</p>
                    <p><strong>Adeudo Total:</strong> $5,000.00</p>
                    <p><strong>Pagos Realizados:</strong> 2</p>
                    <p><strong>Estado:</strong> <span class="badge bg-success">Vigente</span></p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 7: Reportes -->
          <div class="tab-pane fade" id="reportes" role="tabpanel">
            <h4 class="fw-bold text-info mb-3">
              <i class="fas fa-chart-bar me-2"></i>Reportes del Padrón
            </h4>
            <p class="text-muted mb-4">Sistema de reportes especializados para aseo con exportación a Excel</p>

            <div class="row g-4">
              <div class="col-md-4">
                <div class="card border border-info border-opacity-25 h-100">
                  <div class="card-body text-center">
                    <div class="bg-info bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-users fa-2x text-info"></i>
                    </div>
                    <h6 class="fw-bold">Padrón de Convenios</h6>
                    <p class="small text-muted mb-3">Listado completo por zona de servicio</p>
                    <button class="btn btn-outline-info btn-sm">
                      <i class="fas fa-file-excel me-2"></i>Exportar
                    </button>
                  </div>
                </div>
              </div>

              <div class="col-md-4">
                <div class="card border border-info border-opacity-25 h-100">
                  <div class="card-body text-center">
                    <div class="bg-info bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-exclamation-triangle fa-2x text-info"></i>
                    </div>
                    <h6 class="fw-bold">Reporte de Adeudos</h6>
                    <p class="small text-muted mb-3">Convenios con saldos pendientes</p>
                    <button class="btn btn-outline-info btn-sm">
                      <i class="fas fa-file-excel me-2"></i>Exportar
                    </button>
                  </div>
                </div>
              </div>

              <div class="col-md-4">
                <div class="card border border-info border-opacity-25 h-100">
                  <div class="card-body text-center">
                    <div class="bg-info bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-money-bill fa-2x text-info"></i>
                    </div>
                    <h6 class="fw-bold">Reporte de Pagos</h6>
                    <p class="small text-muted mb-3">Histórico de pagos por zona</p>
                    <button class="btn btn-outline-info btn-sm">
                      <i class="fas fa-file-excel me-2"></i>Exportar
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 8: Cancelación Masiva -->
          <div class="tab-pane fade" id="cancelacion" role="tabpanel">
            <h4 class="fw-bold text-info mb-3">
              <i class="fas fa-ban me-2"></i>Cancelación Masiva
            </h4>
            <p class="text-muted mb-4">Herramienta de cancelación automática de convenios incumplidos por zona</p>

            <div class="row">
              <div class="col-lg-8">
                <div class="card border border-warning border-opacity-50">
                  <div class="card-header bg-warning bg-opacity-10">
                    <h6 class="fw-bold mb-0 text-warning">
                      <i class="fas fa-exclamation-triangle me-2"></i>Criterios de Cancelación
                    </h6>
                  </div>
                  <div class="card-body">
                    <div class="row g-3 mb-3">
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Zona de Servicio</label>
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
                        <label class="form-label fw-medium">Parcialidades Vencidas</label>
                        <select class="form-select">
                          <option>2 o más parcialidades</option>
                          <option>3 o más parcialidades</option>
                          <option>4 o más parcialidades</option>
                        </select>
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Días de Vencimiento</label>
                        <input type="number" class="form-control" placeholder="60" value="60">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Tipo de Servicio</label>
                        <select class="form-select">
                          <option>Todos los tipos</option>
                          <option>Domiciliario</option>
                          <option>Comercial</option>
                          <option>Industrial</option>
                        </select>
                      </div>
                    </div>

                    <div class="d-flex gap-2">
                      <button class="btn btn-warning">
                        <i class="fas fa-search me-2"></i>Buscar Convenios
                      </button>
                      <button class="btn btn-danger">
                        <i class="fas fa-ban me-2"></i>Cancelar Seleccionados
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="bg-warning bg-opacity-10 rounded-3 p-3">
                  <h6 class="fw-bold text-warning mb-2">
                    <i class="fas fa-recycle me-2"></i>Criterios Especiales
                  </h6>
                  <p class="small text-muted mb-2">Filtros específicos para servicios de aseo</p>
                  <p class="small text-muted mb-2">Consideración de rutas de recolección</p>
                  <p class="small text-muted mb-0">Análisis por zona geográfica</p>
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
  name: 'SistemaConveniosAseo',
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
  border-bottom-color: #0dcaf0;
  color: #0dcaf0;
  font-weight: 600;
}

.nav-tabs .nav-link:hover {
  border-bottom-color: #0dcaf0;
  color: #0dcaf0;
}
</style>