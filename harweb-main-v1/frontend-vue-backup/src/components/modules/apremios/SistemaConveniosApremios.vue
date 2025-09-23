<template>
  <div class="container-fluid mt-4">
    <!-- Header del Sistema -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #dc3545 !important;">
      <div class="card-body p-4">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-danger bg-opacity-10 rounded-3 p-3 me-3">
              <i class="fas fa-handshake fa-2x text-danger"></i>
            </div>
            <div>
              <h1 class="h3 fw-bold text-dark mb-1">Sistema de Convenios - Apremios</h1>
              <p class="text-muted mb-0">Gestión integral de convenios de pago para procedimientos de apremio</p>
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
                <h4 class="fw-bold text-danger mb-3">
                  <i class="fas fa-percentage me-2"></i>Catálogo de Intereses
                </h4>
                <p class="text-muted mb-4">Gestión completa de tasas de interés aplicables a procedimientos de apremio</p>

                <div class="row g-3 mb-4">
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Tipo de Interés</label>
                    <select class="form-select">
                      <option>Seleccionar tipo...</option>
                      <option>Interés Moratorio</option>
                      <option>Interés Legal</option>
                      <option>Interés Compensatorio</option>
                    </select>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Tasa (%)</label>
                    <input type="number" class="form-control" placeholder="0.00" step="0.01">
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Fecha Inicio Vigencia</label>
                    <input type="date" class="form-control">
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Fecha Fin Vigencia</label>
                    <input type="date" class="form-control">
                  </div>
                </div>

                <div class="d-flex gap-2 mb-4">
                  <button class="btn btn-danger">
                    <i class="fas fa-plus me-2"></i>Agregar
                  </button>
                  <button class="btn btn-outline-danger">
                    <i class="fas fa-edit me-2"></i>Modificar
                  </button>
                  <button class="btn btn-outline-secondary">
                    <i class="fas fa-trash me-2"></i>Eliminar
                  </button>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="bg-danger bg-opacity-10 rounded-3 p-3">
                  <h6 class="fw-bold text-danger mb-2">
                    <i class="fas fa-info-circle me-2"></i>Información
                  </h6>
                  <p class="small text-muted mb-2">• Control preciso de intereses según normativa fiscal</p>
                  <p class="small text-muted mb-2">• Vigencias automáticas por período</p>
                  <p class="small text-muted mb-0">• Aplicación automática en cálculos</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 2: ABC del Convenio -->
          <div class="tab-pane fade" id="convenio" role="tabpanel">
            <div class="row">
              <div class="col-lg-8">
                <h4 class="fw-bold text-danger mb-3">
                  <i class="fas fa-file-contract me-2"></i>ABC del Convenio
                </h4>
                <p class="text-muted mb-4">Administración integral de convenios de pago para procedimientos de apremio</p>

                <div class="row g-3 mb-4">
                  <div class="col-md-6">
                    <label class="form-label fw-medium">No. Expediente</label>
                    <input type="text" class="form-control" placeholder="EXP-2024-001">
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Contribuyente</label>
                    <input type="text" class="form-control" placeholder="Nombre/Razón Social">
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">RFC</label>
                    <input type="text" class="form-control" placeholder="RFC del contribuyente">
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Importe Total</label>
                    <input type="number" class="form-control" placeholder="0.00" step="0.01">
                  </div>
                  <div class="col-md-4">
                    <label class="form-label fw-medium">Número de Parcialidades</label>
                    <select class="form-select">
                      <option>Seleccionar...</option>
                      <option>3 parcialidades</option>
                      <option>6 parcialidades</option>
                      <option>12 parcialidades</option>
                      <option>24 parcialidades</option>
                    </select>
                  </div>
                  <div class="col-md-4">
                    <label class="form-label fw-medium">Enganche (%)</label>
                    <input type="number" class="form-control" placeholder="20" step="1">
                  </div>
                  <div class="col-md-4">
                    <label class="form-label fw-medium">Fecha Primer Pago</label>
                    <input type="date" class="form-control">
                  </div>
                </div>

                <div class="d-flex gap-2 mb-4">
                  <button class="btn btn-danger">
                    <i class="fas fa-plus me-2"></i>Crear Convenio
                  </button>
                  <button class="btn btn-outline-danger">
                    <i class="fas fa-calculator me-2"></i>Generar Parcialidades
                  </button>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="bg-danger bg-opacity-10 rounded-3 p-3">
                  <h6 class="fw-bold text-danger mb-2">
                    <i class="fas fa-calculator me-2"></i>Cálculo Automático
                  </h6>
                  <p class="small text-muted mb-2">• Generación automática de parcialidades</p>
                  <p class="small text-muted mb-2">• Aplicación de intereses configurados</p>
                  <p class="small text-muted mb-0">• Cronograma de pagos detallado</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 3: Desglose de Parcialidades -->
          <div class="tab-pane fade" id="parcialidades" role="tabpanel">
            <h4 class="fw-bold text-danger mb-3">
              <i class="fas fa-list-ol me-2"></i>Desglose de Parcialidades
            </h4>
            <p class="text-muted mb-4">Administración detallada de parcialidades con rubros específicos</p>

            <div class="table-responsive">
              <table class="table table-hover">
                <thead class="table-danger">
                  <tr>
                    <th>No.</th>
                    <th>Fecha Vencimiento</th>
                    <th>Importe Capital</th>
                    <th>Intereses</th>
                    <th>Recargos</th>
                    <th>Total</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td><span class="badge bg-danger">1</span></td>
                    <td>15/10/2024</td>
                    <td>$5,000.00</td>
                    <td>$250.00</td>
                    <td>$100.00</td>
                    <td><strong>$5,350.00</strong></td>
                    <td><span class="badge bg-success">Pagado</span></td>
                    <td>
                      <button class="btn btn-sm btn-outline-danger">
                        <i class="fas fa-eye"></i>
                      </button>
                    </td>
                  </tr>
                  <tr>
                    <td><span class="badge bg-danger">2</span></td>
                    <td>15/11/2024</td>
                    <td>$5,000.00</td>
                    <td>$275.00</td>
                    <td>$110.00</td>
                    <td><strong>$5,385.00</strong></td>
                    <td><span class="badge bg-warning">Pendiente</span></td>
                    <td>
                      <button class="btn btn-sm btn-outline-danger">
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
            <h4 class="fw-bold text-danger mb-3">
              <i class="fas fa-credit-card me-2"></i>ABC de Pagos
            </h4>
            <p class="text-muted mb-4">Gestión integral de pagos realizados en convenios</p>

            <div class="row g-3 mb-4">
              <div class="col-md-4">
                <label class="form-label fw-medium">No. Convenio</label>
                <input type="text" class="form-control" placeholder="CONV-2024-001">
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
                <input type="text" class="form-control" placeholder="REC-2024-001">
              </div>
            </div>

            <div class="d-flex gap-2">
              <button class="btn btn-danger">
                <i class="fas fa-save me-2"></i>Registrar Pago
              </button>
              <button class="btn btn-outline-danger">
                <i class="fas fa-print me-2"></i>Imprimir Recibo
              </button>
            </div>
          </div>

          <!-- Pestaña 5: Impresión -->
          <div class="tab-pane fade" id="impresion" role="tabpanel">
            <h4 class="fw-bold text-danger mb-3">
              <i class="fas fa-print me-2"></i>Impresión de Documentos
            </h4>
            <p class="text-muted mb-4">Generación de documentos oficiales del convenio</p>

            <div class="row g-4">
              <div class="col-md-6">
                <div class="card border border-danger border-opacity-25">
                  <div class="card-body text-center">
                    <div class="bg-danger bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-file-contract fa-2x text-danger"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Convenio Oficial</h5>
                    <p class="text-muted small mb-3">Documento oficial del convenio de pago</p>
                    <button class="btn btn-danger">
                      <i class="fas fa-print me-2"></i>Imprimir Convenio
                    </button>
                  </div>
                </div>
              </div>

              <div class="col-md-6">
                <div class="card border border-danger border-opacity-25">
                  <div class="card-body text-center">
                    <div class="bg-danger bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-money-check fa-2x text-danger"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Pagaré</h5>
                    <p class="text-muted small mb-3">Pagaré correspondiente al convenio</p>
                    <button class="btn btn-danger">
                      <i class="fas fa-print me-2"></i>Imprimir Pagaré
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 6: Consulta -->
          <div class="tab-pane fade" id="consulta" role="tabpanel">
            <h4 class="fw-bold text-danger mb-3">
              <i class="fas fa-search me-2"></i>Consulta General
            </h4>
            <p class="text-muted mb-4">Sistema de consulta integral de convenios</p>

            <div class="row g-3 mb-4">
              <div class="col-md-4">
                <label class="form-label fw-medium">Buscar por:</label>
                <select class="form-select">
                  <option>No. Convenio</option>
                  <option>RFC</option>
                  <option>Expediente</option>
                  <option>Contribuyente</option>
                </select>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-medium">Criterio de Búsqueda</label>
                <input type="text" class="form-control" placeholder="Ingrese el criterio...">
              </div>
              <div class="col-md-2">
                <label class="form-label fw-medium">&nbsp;</label>
                <button class="btn btn-danger w-100">
                  <i class="fas fa-search me-2"></i>Buscar
                </button>
              </div>
            </div>

            <div class="card border border-danger border-opacity-25">
              <div class="card-header bg-danger bg-opacity-10">
                <h6 class="fw-bold mb-0">Resultado de Búsqueda</h6>
              </div>
              <div class="card-body">
                <div class="row">
                  <div class="col-md-6">
                    <p><strong>No. Convenio:</strong> CONV-2024-001</p>
                    <p><strong>Contribuyente:</strong> Juan Pérez García</p>
                    <p><strong>RFC:</strong> PEGJ800101ABC</p>
                    <p><strong>Importe Total:</strong> $25,000.00</p>
                  </div>
                  <div class="col-md-6">
                    <p><strong>Parcialidades:</strong> 6</p>
                    <p><strong>Pagos Realizados:</strong> 2</p>
                    <p><strong>Saldo Pendiente:</strong> $15,000.00</p>
                    <p><strong>Estado:</strong> <span class="badge bg-warning">Vigente</span></p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 7: Reportes -->
          <div class="tab-pane fade" id="reportes" role="tabpanel">
            <h4 class="fw-bold text-danger mb-3">
              <i class="fas fa-chart-bar me-2"></i>Reportes del Padrón
            </h4>
            <p class="text-muted mb-4">Sistema de reportes especializados con exportación a Excel</p>

            <div class="row g-4">
              <div class="col-md-4">
                <div class="card border border-danger border-opacity-25 h-100">
                  <div class="card-body text-center">
                    <div class="bg-danger bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-users fa-2x text-danger"></i>
                    </div>
                    <h6 class="fw-bold">Padrón de Convenios</h6>
                    <p class="small text-muted mb-3">Listado completo de convenios registrados</p>
                    <button class="btn btn-outline-danger btn-sm">
                      <i class="fas fa-file-excel me-2"></i>Exportar
                    </button>
                  </div>
                </div>
              </div>

              <div class="col-md-4">
                <div class="card border border-danger border-opacity-25 h-100">
                  <div class="card-body text-center">
                    <div class="bg-danger bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-exclamation-triangle fa-2x text-danger"></i>
                    </div>
                    <h6 class="fw-bold">Reporte de Adeudos</h6>
                    <p class="small text-muted mb-3">Convenios con saldos pendientes</p>
                    <button class="btn btn-outline-danger btn-sm">
                      <i class="fas fa-file-excel me-2"></i>Exportar
                    </button>
                  </div>
                </div>
              </div>

              <div class="col-md-4">
                <div class="card border border-danger border-opacity-25 h-100">
                  <div class="card-body text-center">
                    <div class="bg-danger bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-money-bill fa-2x text-danger"></i>
                    </div>
                    <h6 class="fw-bold">Reporte de Pagos</h6>
                    <p class="small text-muted mb-3">Histórico de pagos realizados</p>
                    <button class="btn btn-outline-danger btn-sm">
                      <i class="fas fa-file-excel me-2"></i>Exportar
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 8: Cancelación Masiva -->
          <div class="tab-pane fade" id="cancelacion" role="tabpanel">
            <h4 class="fw-bold text-danger mb-3">
              <i class="fas fa-ban me-2"></i>Cancelación Masiva
            </h4>
            <p class="text-muted mb-4">Herramienta de cancelación automática de convenios incumplidos</p>

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
                        <label class="form-label fw-medium">Mínimo de Parcialidades Vencidas</label>
                        <select class="form-select">
                          <option>2 o más parcialidades</option>
                          <option>3 o más parcialidades</option>
                          <option>4 o más parcialidades</option>
                        </select>
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Días de Vencimiento</label>
                        <input type="number" class="form-control" placeholder="30" value="30">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Fecha Desde</label>
                        <input type="date" class="form-control">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Fecha Hasta</label>
                        <input type="date" class="form-control">
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
                    <i class="fas fa-exclamation-triangle me-2"></i>Advertencia
                  </h6>
                  <p class="small text-muted mb-2">Esta acción es irreversible</p>
                  <p class="small text-muted mb-2">Se aplicará a todos los convenios que cumplan los criterios</p>
                  <p class="small text-muted mb-0">Revisar cuidadosamente antes de proceder</p>
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
  name: 'SistemaConveniosApremios',
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
  border-bottom-color: #dc3545;
  color: #dc3545;
  font-weight: 600;
}

.nav-tabs .nav-link:hover {
  border-bottom-color: #dc3545;
  color: #dc3545;
}
</style>