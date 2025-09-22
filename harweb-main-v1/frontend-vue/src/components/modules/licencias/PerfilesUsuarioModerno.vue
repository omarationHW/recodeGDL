<template>
  <div class="perfiles-usuario-moderno">
    <!-- 🆕 NUEVO COMPONENTE - SEPARACIÓN DE PERFILES GRANULAR -->
    <div class="alert alert-success mb-4">
      <h4 class="alert-heading">🆕 NUEVO: Separación de Perfiles de Usuario</h4>
      <p class="mb-0">Sistema modernizado para separar perfiles de usuarios de padrón, licencias e ingresos</p>
    </div>

    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-users-cog me-2 text-primary"></i>
              Gestión de Perfiles de Usuario Modernizada
            </h2>
            <p class="text-muted mb-0">Separación granular de perfiles: Padrón, Licencias e Ingresos</p>
          </div>
          <div class="badge badge-success">NUEVO MÓDULO</div>
        </div>
      </div>
    </div>

    <!-- Tabs de Separación de Perfiles -->
    <div class="card">
      <div class="card-header">
        <ul class="nav nav-tabs card-header-tabs" role="tablist">
          <li class="nav-item" role="presentation">
            <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#perfil-padron" type="button">
              <i class="fas fa-database me-2"></i>Usuarios Padrón
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" data-bs-toggle="tab" data-bs-target="#perfil-licencias" type="button">
              <i class="fas fa-certificate me-2"></i>Usuarios Licencias
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" data-bs-toggle="tab" data-bs-target="#perfil-ingresos" type="button">
              <i class="fas fa-money-bill-wave me-2"></i>Usuarios Ingresos
            </button>
          </li>
        </ul>
      </div>

      <div class="card-body">
        <div class="tab-content">
          <!-- Perfil Padrón -->
          <div class="tab-pane fade show active" id="perfil-padron">
            <div class="row">
              <div class="col-md-6">
                <h5 class="text-primary">👥 Usuarios del Padrón</h5>
                <p>Gestión de usuarios con acceso al padrón de contribuyentes</p>
                <div class="list-group">
                  <div class="list-group-item d-flex justify-content-between align-items-center">
                    Juan Pérez - Consultor Padrón
                    <span class="badge bg-primary">ACTIVO</span>
                  </div>
                  <div class="list-group-item d-flex justify-content-between align-items-center">
                    María González - Supervisor Padrón
                    <span class="badge bg-primary">ACTIVO</span>
                  </div>
                </div>
              </div>
              <div class="col-md-6">
                <h6>Permisos del Perfil Padrón:</h6>
                <ul class="list-unstyled">
                  <li><i class="fas fa-check text-success me-2"></i>Consulta de contribuyentes</li>
                  <li><i class="fas fa-check text-success me-2"></i>Actualización de datos</li>
                  <li><i class="fas fa-times text-danger me-2"></i>Asignación de importes</li>
                  <li><i class="fas fa-times text-danger me-2"></i>Gestión de ingresos</li>
                </ul>
              </div>
            </div>
          </div>

          <!-- Perfil Licencias -->
          <div class="tab-pane fade" id="perfil-licencias">
            <div class="row">
              <div class="col-md-6">
                <h5 class="text-warning">📋 Usuarios de Licencias</h5>
                <p>Gestión de usuarios con acceso a licencias comerciales</p>
                <div class="list-group">
                  <div class="list-group-item d-flex justify-content-between align-items-center">
                    Ana Rodríguez - Gestor Licencias
                    <span class="badge bg-warning">ACTIVO</span>
                  </div>
                  <div class="list-group-item d-flex justify-content-between align-items-center">
                    Carlos López - Supervisor Licencias
                    <span class="badge bg-warning">ACTIVO</span>
                  </div>
                </div>
              </div>
              <div class="col-md-6">
                <h6>Permisos del Perfil Licencias:</h6>
                <ul class="list-unstyled">
                  <li><i class="fas fa-check text-success me-2"></i>Gestión de licencias</li>
                  <li><i class="fas fa-check text-success me-2"></i>Consulta de trámites</li>
                  <li><i class="fas fa-check text-success me-2"></i>Bloqueos y bajas</li>
                  <li><i class="fas fa-times text-danger me-2"></i>Asignación de importes</li>
                </ul>
              </div>
            </div>
          </div>

          <!-- Perfil Ingresos -->
          <div class="tab-pane fade" id="perfil-ingresos">
            <div class="row">
              <div class="col-md-6">
                <h5 class="text-success">💰 Usuarios de Ingresos</h5>
                <p>Gestión de usuarios con acceso a gestión de importes y giros</p>
                <div class="list-group">
                  <div class="list-group-item d-flex justify-content-between align-items-center">
                    Luis Martínez - Gestor Ingresos
                    <span class="badge bg-success">ACTIVO</span>
                  </div>
                  <div class="list-group-item d-flex justify-content-between align-items-center">
                    Elena Sánchez - Supervisor Ingresos
                    <span class="badge bg-success">ACTIVO</span>
                  </div>
                </div>
              </div>
              <div class="col-md-6">
                <h6>Permisos del Perfil Ingresos:</h6>
                <ul class="list-unstyled">
                  <li><i class="fas fa-check text-success me-2"></i>Asignación de importes a giros</li>
                  <li><i class="fas fa-check text-success me-2"></i>Gestión de costos</li>
                  <li><i class="fas fa-check text-success me-2"></i>Revaluación de precios</li>
                  <li><i class="fas fa-check text-success me-2"></i>Reportes financieros</li>
                </ul>
              </div>
            </div>
          </div>
        </div>

        <!-- Botones de Acción -->
        <div class="mt-4">
          <button class="btn btn-primary me-2">
            <i class="fas fa-user-plus me-2"></i>Agregar Usuario
          </button>
          <button class="btn btn-success me-2">
            <i class="fas fa-user-cog me-2"></i>Gestionar Perfiles
          </button>
          <button class="btn btn-info">
            <i class="fas fa-chart-bar me-2"></i>Reportes de Acceso
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PerfilesUsuarioModerno',
  data() {
    return {
      activeTab: 'perfil-padron'
    }
  }
}
</script>

<style scoped>
.perfiles-usuario-moderno {
  padding: 1rem;
}

.badge {
  font-size: 0.75rem;
}

.alert-success {
  border-left: 4px solid #28a745;
}

.nav-tabs .nav-link {
  border: none;
  color: #6c757d;
}

.nav-tabs .nav-link.active {
  background-color: #fff;
  border-bottom: 2px solid #007bff;
  color: #007bff;
}
</style>