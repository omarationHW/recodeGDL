<template>
  <div class="catalogo-giros-importes">
    <!-- 🆕 NUEVO COMPONENTE - GESTIÓN DE IMPORTES -->
    <div class="alert alert-warning mb-4">
      <h4 class="alert-heading">🆕 NUEVO: Gestión de Importes en Catálogo de Giros</h4>
      <p class="mb-0">Extensión del catálogo existente para que usuarios "ingresos" puedan asignar importes</p>
    </div>

    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-money-check-alt me-2 text-warning"></i>
              Catálogo de Giros - Gestión de Importes
            </h2>
            <p class="text-muted mb-0">Asignación y control de importes por tipo de giro comercial</p>
          </div>
          <div class="badge badge-warning">MÓDULO EXTENDIDO</div>
        </div>
      </div>
    </div>

    <!-- Filtros para Usuarios Ingresos -->
    <div class="card mb-4">
      <div class="card-header bg-warning text-dark">
        <h5 class="mb-0">
          <i class="fas fa-user-tie me-2"></i>
          Panel Exclusivo - Perfil Ingresos
        </h5>
      </div>
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-4">
            <label class="form-label">Filtrar por Giro</label>
            <select class="form-select" v-model="filtroGiro">
              <option value="">Todos los giros</option>
              <option value="restaurante">Restaurante</option>
              <option value="comercio">Comercio al por menor</option>
              <option value="servicios">Servicios profesionales</option>
            </select>
          </div>
          <div class="col-md-4">
            <label class="form-label">Estado de Importes</label>
            <select class="form-select" v-model="filtroImporte">
              <option value="">Todos</option>
              <option value="asignado">Con importe asignado</option>
              <option value="pendiente">Pendiente de asignar</option>
            </select>
          </div>
          <div class="col-md-4">
            <label class="form-label">Vigencia</label>
            <select class="form-select" v-model="filtroVigencia">
              <option value="">Todas</option>
              <option value="vigente">Vigente</option>
              <option value="proximo_vencer">Próximo a vencer</option>
            </select>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de Giros con Gestión de Importes -->
    <div class="card">
      <div class="card-header">
        <div class="d-flex justify-content-between align-items-center">
          <h5 class="mb-0">Catálogo de Giros con Importes</h5>
          <button class="btn btn-success btn-sm" @click="openAssignImporteModal">
            <i class="fas fa-dollar-sign me-2"></i>Asignar Importes Masivos
          </button>
        </div>
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="table table-hover">
            <thead class="table-dark">
              <tr>
                <th>ID Giro</th>
                <th>Descripción del Giro</th>
                <th>Categoría</th>
                <th>Importe Actual</th>
                <th>Última Actualización</th>
                <th>Estado</th>
                <th>🆕 Acciones Ingresos</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>001</td>
                <td>Restaurante con venta de bebidas alcohólicas</td>
                <td>Alimentación</td>
                <td class="fw-bold text-success">$5,200.00</td>
                <td>15/09/2025</td>
                <td><span class="badge bg-success">Vigente</span></td>
                <td>
                  <button class="btn btn-warning btn-sm me-1" title="Modificar Importe">
                    <i class="fas fa-edit"></i>
                  </button>
                  <button class="btn btn-info btn-sm" title="Historial de Cambios">
                    <i class="fas fa-history"></i>
                  </button>
                </td>
              </tr>
              <tr>
                <td>002</td>
                <td>Comercio al por menor - Ropa y accesorios</td>
                <td>Comercio</td>
                <td class="fw-bold text-danger">PENDIENTE</td>
                <td>-</td>
                <td><span class="badge bg-warning">Sin asignar</span></td>
                <td>
                  <button class="btn btn-primary btn-sm me-1" title="Asignar Importe">
                    <i class="fas fa-plus-circle"></i>
                  </button>
                  <button class="btn btn-secondary btn-sm" disabled title="Sin historial">
                    <i class="fas fa-history"></i>
                  </button>
                </td>
              </tr>
              <tr>
                <td>003</td>
                <td>Servicios profesionales - Consultoría</td>
                <td>Servicios</td>
                <td class="fw-bold text-success">$3,800.00</td>
                <td>10/09/2025</td>
                <td><span class="badge bg-info">Revaluado</span></td>
                <td>
                  <button class="btn btn-warning btn-sm me-1" title="Modificar Importe">
                    <i class="fas fa-edit"></i>
                  </button>
                  <button class="btn btn-info btn-sm" title="Historial de Cambios">
                    <i class="fas fa-history"></i>
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Panel de Estadísticas para Ingresos -->
        <div class="row mt-4">
          <div class="col-md-3">
            <div class="card border-success">
              <div class="card-body text-center">
                <h3 class="text-success">156</h3>
                <p class="mb-0">Giros con Importe</p>
              </div>
            </div>
          </div>
          <div class="col-md-3">
            <div class="card border-warning">
              <div class="card-body text-center">
                <h3 class="text-warning">23</h3>
                <p class="mb-0">Pendientes</p>
              </div>
            </div>
          </div>
          <div class="col-md-3">
            <div class="card border-info">
              <div class="card-body text-center">
                <h3 class="text-info">$2,458,900</h3>
                <p class="mb-0">Ingresos Estimados</p>
              </div>
            </div>
          </div>
          <div class="col-md-3">
            <div class="card border-primary">
              <div class="card-body text-center">
                <h3 class="text-primary">12</h3>
                <p class="mb-0">Revaluados Hoy</p>
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
  name: 'CatalogoGirosImportes',
  data() {
    return {
      filtroGiro: '',
      filtroImporte: '',
      filtroVigencia: ''
    }
  },
  methods: {
    openAssignImporteModal() {
      alert('🆕 NUEVO: Modal para asignación masiva de importes')
    }
  }
}
</script>

<style scoped>
.catalogo-giros-importes {
  padding: 1rem;
}

.alert-warning {
  border-left: 4px solid #ffc107;
}

.card-header.bg-warning {
  background-color: #fff3cd !important;
  border-bottom: 2px solid #ffc107;
}
</style>