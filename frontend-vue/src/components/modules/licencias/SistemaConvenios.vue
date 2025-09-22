<template>
  <div class="sistema-convenios">
    <!-- 🆕 NUEVO COMPONENTE - SISTEMA INTEGRAL DE CONVENIOS -->
    <div class="alert alert-success mb-4">
      <h4 class="alert-heading">🆕 NUEVO: Sistema Integral de Convenios</h4>
      <p class="mb-0">ABC completo de convenios: catálogo de intereses, convenios, parcialidades y pagos</p>
    </div>

    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-handshake me-2 text-success"></i>
              Sistema Integral de Convenios
            </h2>
            <p class="text-muted mb-0">Gestión completa de convenios de pago, intereses y parcialidades</p>
          </div>
          <div class="badge badge-success">SISTEMA COMPLETO NUEVO</div>
        </div>
      </div>
    </div>

    <!-- Navegación por Módulos -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="nav nav-pills nav-justified" role="tablist">
          <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#intereses" type="button">
            <i class="fas fa-percentage me-2"></i>Catálogo de Intereses
          </button>
          <button class="nav-link" data-bs-toggle="tab" data-bs-target="#convenios" type="button">
            <i class="fas fa-file-contract me-2"></i>ABC Convenios
          </button>
          <button class="nav-link" data-bs-toggle="tab" data-bs-target="#parcialidades" type="button">
            <i class="fas fa-list-ol me-2"></i>Parcialidades
          </button>
          <button class="nav-link" data-bs-toggle="tab" data-bs-target="#pagos" type="button">
            <i class="fas fa-credit-card me-2"></i>ABC Pagos
          </button>
        </div>
      </div>
    </div>

    <div class="tab-content">
      <!-- Catálogo de Intereses -->
      <div class="tab-pane fade show active" id="intereses">
        <div class="card">
          <div class="card-header bg-primary text-white">
            <div class="d-flex justify-content-between align-items-center">
              <h5 class="mb-0">📊 Catálogo de Intereses</h5>
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
                    <th>Periodo</th>
                    <th>Vigencia</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td><strong>INT-001</strong></td>
                    <td>Interés Moratorio Licencias</td>
                    <td class="text-primary fw-bold">1.5%</td>
                    <td>Mensual</td>
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
                    <td><strong>INT-002</strong></td>
                    <td>Interés Convenio Especial</td>
                    <td class="text-success fw-bold">0.8%</td>
                    <td>Mensual</td>
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

      <!-- ABC Convenios -->
      <div class="tab-pane fade" id="convenios">
        <div class="card">
          <div class="card-header bg-warning text-dark">
            <div class="d-flex justify-content-between align-items-center">
              <h5 class="mb-0">📋 ABC de Convenios</h5>
              <button class="btn btn-dark btn-sm">
                <i class="fas fa-plus me-2"></i>Nuevo Convenio
              </button>
            </div>
          </div>
          <div class="card-body">
            <!-- Filtros -->
            <div class="row mb-3">
              <div class="col-md-3">
                <select class="form-select" v-model="filtroEstado">
                  <option value="">Todos los estados</option>
                  <option value="activo">Activos</option>
                  <option value="vencido">Vencidos</option>
                  <option value="liquidado">Liquidados</option>
                </select>
              </div>
              <div class="col-md-3">
                <input type="text" class="form-control" placeholder="Buscar por contribuyente" v-model="busquedaConvenio">
              </div>
              <div class="col-md-6">
                <div class="d-flex gap-2">
                  <button class="btn btn-outline-primary btn-sm">
                    <i class="fas fa-search me-1"></i>Buscar
                  </button>
                  <button class="btn btn-outline-success btn-sm">
                    <i class="fas fa-file-excel me-1"></i>Exportar
                  </button>
                </div>
              </div>
            </div>

            <div class="table-responsive">
              <table class="table table-striped">
                <thead class="table-warning">
                  <tr>
                    <th>Folio</th>
                    <th>Contribuyente</th>
                    <th>Importe Total</th>
                    <th>Parcialidades</th>
                    <th>Pagadas</th>
                    <th>Saldo</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td><strong>CONV-2025-001</strong></td>
                    <td>COMERCIAL LÓPEZ SA</td>
                    <td class="fw-bold">$125,000.00</td>
                    <td class="text-center">12</td>
                    <td class="text-center">8</td>
                    <td class="text-danger fw-bold">$41,667.00</td>
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
                    <td><strong>CONV-2025-002</strong></td>
                    <td>RESTAURANTE FAMILIAR</td>
                    <td class="fw-bold">$85,000.00</td>
                    <td class="text-center">6</td>
                    <td class="text-center">6</td>
                    <td class="text-success fw-bold">$0.00</td>
                    <td><span class="badge bg-primary">LIQUIDADO</span></td>
                    <td>
                      <button class="btn btn-sm btn-info me-1" title="Ver parcialidades">
                        <i class="fas fa-list"></i>
                      </button>
                      <button class="btn btn-sm btn-secondary" disabled title="Convenio liquidado">
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

      <!-- Parcialidades -->
      <div class="tab-pane fade" id="parcialidades">
        <div class="card">
          <div class="card-header bg-info text-white">
            <h5 class="mb-0">📅 Desglose de Parcialidades</h5>
          </div>
          <div class="card-body">
            <div class="d-flex justify-content-between align-items-center mb-3">
              <h6>Convenio: <strong>CONV-2025-001</strong> - COMERCIAL LÓPEZ SA</h6>
              <button class="btn btn-outline-info btn-sm">
                <i class="fas fa-calculator me-1"></i>Recalcular Intereses
              </button>
            </div>

            <div class="table-responsive">
              <table class="table table-bordered">
                <thead class="table-info">
                  <tr>
                    <th>No.</th>
                    <th>Fecha Vencimiento</th>
                    <th>Capital</th>
                    <th>Intereses</th>
                    <th>Total Parcialidad</th>
                    <th>Estado</th>
                    <th>Fecha Pago</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr class="table-success">
                    <td>1</td>
                    <td>15/01/2025</td>
                    <td>$10,000.00</td>
                    <td>$150.00</td>
                    <td class="fw-bold">$10,150.00</td>
                    <td><span class="badge bg-success">PAGADA</span></td>
                    <td>14/01/2025</td>
                    <td>
                      <button class="btn btn-sm btn-info" title="Ver comprobante">
                        <i class="fas fa-receipt"></i>
                      </button>
                    </td>
                  </tr>
                  <tr class="table-warning">
                    <td>2</td>
                    <td>15/02/2025</td>
                    <td>$10,000.00</td>
                    <td>$150.00</td>
                    <td class="fw-bold">$10,150.00</td>
                    <td><span class="badge bg-warning">VENCIDA</span></td>
                    <td>-</td>
                    <td>
                      <button class="btn btn-sm btn-primary" title="Registrar pago">
                        <i class="fas fa-plus"></i>
                      </button>
                    </td>
                  </tr>
                  <tr>
                    <td>3</td>
                    <td>15/03/2025</td>
                    <td>$10,000.00</td>
                    <td>$150.00</td>
                    <td class="fw-bold">$10,150.00</td>
                    <td><span class="badge bg-secondary">PENDIENTE</span></td>
                    <td>-</td>
                    <td>
                      <button class="btn btn-sm btn-secondary" disabled>
                        <i class="fas fa-clock"></i>
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>

      <!-- ABC Pagos -->
      <div class="tab-pane fade" id="pagos">
        <div class="card">
          <div class="card-header bg-success text-white">
            <div class="d-flex justify-content-between align-items-center">
              <h5 class="mb-0">💳 ABC de Pagos</h5>
              <button class="btn btn-light btn-sm">
                <i class="fas fa-plus me-2"></i>Registrar Pago
              </button>
            </div>
          </div>
          <div class="card-body">
            <div class="table-responsive">
              <table class="table table-hover">
                <thead class="table-success">
                  <tr>
                    <th>Recibo</th>
                    <th>Fecha</th>
                    <th>Convenio</th>
                    <th>Parcialidad</th>
                    <th>Importe</th>
                    <th>Forma de Pago</th>
                    <th>Cajero</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td><strong>REC-001234</strong></td>
                    <td>14/01/2025</td>
                    <td>CONV-2025-001</td>
                    <td>1 de 12</td>
                    <td class="fw-bold text-success">$10,150.00</td>
                    <td><span class="badge bg-primary">EFECTIVO</span></td>
                    <td>María González</td>
                    <td>
                      <button class="btn btn-sm btn-info me-1" title="Ver recibo">
                        <i class="fas fa-print"></i>
                      </button>
                      <button class="btn btn-sm btn-secondary" title="Reenviar email">
                        <i class="fas fa-envelope"></i>
                      </button>
                    </td>
                  </tr>
                  <tr>
                    <td><strong>REC-001235</strong></td>
                    <td>15/01/2025</td>
                    <td>CONV-2025-002</td>
                    <td>6 de 6</td>
                    <td class="fw-bold text-success">$14,167.00</td>
                    <td><span class="badge bg-info">TRANSFERENCIA</span></td>
                    <td>Carlos López</td>
                    <td>
                      <button class="btn btn-sm btn-info me-1" title="Ver recibo">
                        <i class="fas fa-print"></i>
                      </button>
                      <button class="btn btn-sm btn-secondary" title="Reenviar email">
                        <i class="fas fa-envelope"></i>
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SistemaConvenios',
  data() {
    return {
      filtroEstado: '',
      busquedaConvenio: ''
    }
  }
}
</script>

<style scoped>
.sistema-convenios {
  padding: 1rem;
}

.alert-success {
  border-left: 4px solid #28a745;
}

.nav-pills .nav-link {
  color: #6c757d;
  border-radius: 0.5rem;
  margin: 0 0.25rem;
}

.nav-pills .nav-link.active {
  background-color: #007bff;
  color: white;
}
</style>