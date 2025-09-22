<template>
  <div class="sistema-convenios-mercados">
    <!-- 🆕 NUEVO COMPONENTE - SISTEMA INTEGRAL DE CONVENIOS MERCADOS -->
    <div class="alert alert-success mb-4">
      <h4 class="alert-heading">🆕 NUEVO: Sistema Integral de Convenios - Mercados</h4>
      <p class="mb-0">ABC completo de convenios para comerciantes de mercados: intereses, convenios, parcialidades y pagos</p>
    </div>

    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-shopping-cart me-2 text-success"></i>
              Sistema de Convenios - Mercados
            </h2>
            <p class="text-muted mb-0">Gestión integral de convenios de pago para comerciantes de mercados municipales</p>
          </div>
          <div class="badge badge-success">SISTEMA COMPLETO NUEVO</div>
        </div>
      </div>
    </div>

    <!-- Navegación por Módulos -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="nav nav-pills nav-justified" role="tablist">
          <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#intereses-mercados" type="button">
            <i class="fas fa-percentage me-2"></i>Catálogo Intereses
          </button>
          <button class="nav-link" data-bs-toggle="tab" data-bs-target="#convenios-mercados" type="button">
            <i class="fas fa-file-contract me-2"></i>ABC Convenios
          </button>
          <button class="nav-link" data-bs-toggle="tab" data-bs-target="#parcialidades-mercados" type="button">
            <i class="fas fa-list-ol me-2"></i>Parcialidades
          </button>
          <button class="nav-link" data-bs-toggle="tab" data-bs-target="#pagos-mercados" type="button">
            <i class="fas fa-credit-card me-2"></i>ABC Pagos
          </button>
          <button class="nav-link" data-bs-toggle="tab" data-bs-target="#impresion-mercados" type="button">
            <i class="fas fa-print me-2"></i>Impresión
          </button>
          <button class="nav-link" data-bs-toggle="tab" data-bs-target="#consultas-mercados" type="button">
            <i class="fas fa-search me-2"></i>Consultas
          </button>
          <button class="nav-link" data-bs-toggle="tab" data-bs-target="#reportes-mercados" type="button">
            <i class="fas fa-chart-bar me-2"></i>Reportes
          </button>
        </div>
      </div>
    </div>

    <div class="tab-content">
      <!-- Catálogo de Intereses para Mercados -->
      <div class="tab-pane fade show active" id="intereses-mercados">
        <div class="card">
          <div class="card-header bg-primary text-white">
            <div class="d-flex justify-content-between align-items-center">
              <h5 class="mb-0">🏪 Catálogo de Intereses - Mercados</h5>
              <button class="btn btn-light btn-sm">
                <i class="fas fa-plus me-2"></i>Nuevo Tipo de Interés
              </button>
            </div>
          </div>
          <div class="card-body">
            <div class="table-responsive">
              <table class="table table-hover">
                <thead class="table-primary">
                  <tr>
                    <th>ID</th>
                    <th>Tipo de Interés</th>
                    <th>Tasa (%)</th>
                    <th>Aplicable a</th>
                    <th>Vigencia</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td><strong>INT-MER-001</strong></td>
                    <td>Interés Moratorio Renta Locales</td>
                    <td class="text-primary fw-bold">2.0%</td>
                    <td>Locales fijos</td>
                    <td>01/01/2025 - 31/12/2025</td>
                    <td><span class="badge bg-success">VIGENTE</span></td>
                    <td>
                      <button class="btn btn-sm btn-warning me-1" title="Editar">
                        <i class="fas fa-edit"></i>
                      </button>
                      <button class="btn btn-sm btn-info" title="Historial">
                        <i class="fas fa-history"></i>
                      </button>
                    </td>
                  </tr>
                  <tr>
                    <td><strong>INT-MER-002</strong></td>
                    <td>Interés Convenio Comerciantes</td>
                    <td class="text-success fw-bold">1.2%</td>
                    <td>Semicijos y temporales</td>
                    <td>01/01/2025 - 31/12/2025</td>
                    <td><span class="badge bg-success">VIGENTE</span></td>
                    <td>
                      <button class="btn btn-sm btn-warning me-1" title="Editar">
                        <i class="fas fa-edit"></i>
                      </button>
                      <button class="btn btn-sm btn-info" title="Historial">
                        <i class="fas fa-history"></i>
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <!-- ABC Convenios Mercados -->
      <div class="tab-pane fade" id="convenios-mercados">
        <div class="card">
          <div class="card-header bg-warning text-dark">
            <div class="d-flex justify-content-between align-items-center">
              <h5 class="mb-0">🏪 ABC de Convenios - Comerciantes de Mercados</h5>
              <button class="btn btn-dark btn-sm">
                <i class="fas fa-plus me-2"></i>Nuevo Convenio Comerciante
              </button>
            </div>
          </div>
          <div class="card-body">
            <div class="table-responsive">
              <table class="table table-striped">
                <thead class="table-warning">
                  <tr>
                    <th>Folio</th>
                    <th>Comerciante</th>
                    <th>Local/Puesto</th>
                    <th>Tipo</th>
                    <th>Importe Total</th>
                    <th>Parcialidades</th>
                    <th>Saldo</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td><strong>CONV-MER-001</strong></td>
                    <td>María González López</td>
                    <td>Local A-15</td>
                    <td>Renta</td>
                    <td class="fw-bold">$45,000.00</td>
                    <td class="text-center">6</td>
                    <td class="text-warning fw-bold">$15,000.00</td>
                    <td><span class="badge bg-success">VIGENTE</span></td>
                    <td>
                      <button class="btn btn-sm btn-info me-1" title="Ver parcialidades">
                        <i class="fas fa-list"></i>
                      </button>
                      <button class="btn btn-sm btn-success" title="Registrar pago">
                        <i class="fas fa-dollar-sign"></i>
                      </button>
                    </td>
                  </tr>
                  <tr>
                    <td><strong>CONV-MER-002</strong></td>
                    <td>Carlos Hernández</td>
                    <td>Puesto T-08</td>
                    <td>Servicios</td>
                    <td class="fw-bold">$28,000.00</td>
                    <td class="text-center">4</td>
                    <td class="text-success fw-bold">$0.00</td>
                    <td><span class="badge bg-primary">LIQUIDADO</span></td>
                    <td>
                      <button class="btn btn-sm btn-info me-1" title="Ver historial">
                        <i class="fas fa-eye"></i>
                      </button>
                      <button class="btn btn-sm btn-secondary" disabled>
                        <i class="fas fa-check"></i>
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <!-- Reportes Integrales -->
      <div class="tab-pane fade" id="reportes-mercados">
        <div class="card">
          <div class="card-header bg-info text-white">
            <h5 class="mb-0">📊 Reportes Integrales - Mercados</h5>
          </div>
          <div class="card-body">
            <div class="row g-4">
              <!-- Reporte Padrón Convenios -->
              <div class="col-md-6">
                <div class="card border-primary">
                  <div class="card-body">
                    <h6 class="card-title text-primary">
                      <i class="fas fa-users me-2"></i>Padrón de Convenios
                    </h6>
                    <p class="card-text small">Lista completa de convenios activos con filtros avanzados</p>
                    <div class="d-grid gap-2">
                      <button class="btn btn-primary btn-sm">
                        <i class="fas fa-file-excel me-2"></i>Generar Reporte
                      </button>
                      <button class="btn btn-outline-primary btn-sm">
                        <i class="fas fa-filter me-2"></i>Filtros Avanzados
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Reporte Adeudos -->
              <div class="col-md-6">
                <div class="card border-danger">
                  <div class="card-body">
                    <h6 class="card-title text-danger">
                      <i class="fas fa-exclamation-triangle me-2"></i>Reporte de Adeudos
                    </h6>
                    <p class="card-text small">Convenios vencidos con mora e intereses calculados</p>
                    <div class="d-grid gap-2">
                      <button class="btn btn-danger btn-sm">
                        <i class="fas fa-file-pdf me-2"></i>Generar Reporte
                      </button>
                      <button class="btn btn-outline-danger btn-sm">
                        <i class="fas fa-bell me-2"></i>Alertas de Riesgo
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Reporte Pagos -->
              <div class="col-md-6">
                <div class="card border-success">
                  <div class="card-body">
                    <h6 class="card-title text-success">
                      <i class="fas fa-money-bill-wave me-2"></i>Reporte de Pagos
                    </h6>
                    <p class="card-text small">Historial de recaudación con análisis y proyecciones</p>
                    <div class="d-grid gap-2">
                      <button class="btn btn-success btn-sm">
                        <i class="fas fa-chart-line me-2"></i>Generar Análisis
                      </button>
                      <button class="btn btn-outline-success btn-sm">
                        <i class="fas fa-calendar me-2"></i>Por Período
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Comparativos -->
              <div class="col-md-6">
                <div class="card border-info">
                  <div class="card-body">
                    <h6 class="card-title text-info">
                      <i class="fas fa-chart-bar me-2"></i>Comparativos
                    </h6>
                    <p class="card-text small">Análisis mensuales, anuales y por tipo de comercio</p>
                    <div class="d-grid gap-2">
                      <button class="btn btn-info btn-sm">
                        <i class="fas fa-analytics me-2"></i>Dashboard
                      </button>
                      <button class="btn btn-outline-info btn-sm">
                        <i class="fas fa-download me-2"></i>Exportar Datos
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Impresión -->
      <div class="tab-pane fade" id="impresion-mercados">
        <div class="card">
          <div class="card-header bg-secondary text-white">
            <h5 class="mb-0">🖨️ Sistema de Impresión - Documentos Oficiales</h5>
          </div>
          <div class="card-body">
            <div class="row g-4">
              <div class="col-md-6">
                <div class="card border-primary">
                  <div class="card-body text-center">
                    <i class="fas fa-file-contract fa-3x text-primary mb-3"></i>
                    <h6>Oficio del Convenio</h6>
                    <p class="small text-muted">Documento oficial con términos y condiciones</p>
                    <button class="btn btn-primary">
                      <i class="fas fa-print me-2"></i>Generar Oficio
                    </button>
                  </div>
                </div>
              </div>
              <div class="col-md-6">
                <div class="card border-success">
                  <div class="card-body text-center">
                    <i class="fas fa-sticky-note fa-3x text-success mb-3"></i>
                    <h6>Pagaré</h6>
                    <p class="small text-muted">Documento legal de respaldo del convenio</p>
                    <button class="btn btn-success">
                      <i class="fas fa-print me-2"></i>Generar Pagaré
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Consultas Generales -->
      <div class="tab-pane fade" id="consultas-mercados">
        <div class="card">
          <div class="card-header bg-info text-white">
            <h5 class="mb-0">🔍 Consulta General de Convenios</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-4">
                <label class="form-label">Buscar Convenio</label>
                <input type="text" class="form-control" placeholder="Folio, comerciante o local">
              </div>
              <div class="col-md-3">
                <label class="form-label">Estado</label>
                <select class="form-select">
                  <option>Todos</option>
                  <option>Vigente</option>
                  <option>Vencido</option>
                  <option>Liquidado</option>
                </select>
              </div>
              <div class="col-md-3">
                <label class="form-label">Tipo</label>
                <select class="form-select">
                  <option>Todos</option>
                  <option>Renta</option>
                  <option>Servicios</option>
                  <option>Mantenimiento</option>
                </select>
              </div>
              <div class="col-md-2">
                <label class="form-label">&nbsp;</label>
                <button class="btn btn-info d-block w-100">
                  <i class="fas fa-search"></i>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Otras pestañas simplificadas -->
      <div class="tab-pane fade" id="parcialidades-mercados">
        <div class="alert alert-info">
          <h6>📅 Desglose de Parcialidades - Mercados</h6>
          <p class="mb-0">Sistema detallado de parcialidades con rubros específicos para comerciantes de mercados</p>
        </div>
      </div>

      <div class="tab-pane fade" id="pagos-mercados">
        <div class="alert alert-success">
          <h6>💳 ABC de Pagos - Mercados</h6>
          <p class="mb-0">Control completo de pagos con múltiples formas de pago y validación automática</p>
        </div>
      </div>
    </div>

    <!-- Estadísticas Generales -->
    <div class="row mt-4">
      <div class="col-md-3">
        <div class="card border-primary">
          <div class="card-body text-center">
            <h3 class="text-primary">45</h3>
            <p class="mb-0">Convenios Activos</p>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-warning">
          <div class="card-body text-center">
            <h3 class="text-warning">12</h3>
            <p class="mb-0">Pagos Pendientes</p>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-success">
          <div class="card-body text-center">
            <h3 class="text-success">$1,250,000</h3>
            <p class="mb-0">Recaudado este mes</p>
          </div>
        </div>
      </div>
      <div class="col-md-3">
        <div class="card border-info">
          <div class="card-body text-center">
            <h3 class="text-info">156</h3>
            <p class="mb-0">Comerciantes</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SistemaConveniosMercados'
}
</script>

<style scoped>
.sistema-convenios-mercados {
  padding: 1rem;
}

.alert-success {
  border-left: 4px solid #28a745;
}

.nav-pills .nav-link {
  color: #6c757d;
  border-radius: 0.5rem;
  margin: 0 0.25rem;
  font-size: 0.875rem;
}

.nav-pills .nav-link.active {
  background-color: #007bff;
  color: white;
}
</style>