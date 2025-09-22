<template>
  <div class="permisos-provisionales">
    <!-- 🆕 NUEVO COMPONENTE - PERMISOS PROVISIONALES -->
    <div class="alert alert-info mb-4">
      <h4 class="alert-heading">🆕 NUEVO: Sistema de Permisos Provisionales</h4>
      <p class="mb-0">Gestión de permisos temporales para Espectáculos, Licencias y Anuncios</p>
    </div>

    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-clock me-2 text-info"></i>
              Permisos Provisionales
            </h2>
            <p class="text-muted mb-0">Gestión de permisos temporales con vigencia limitada</p>
          </div>
          <div class="badge badge-info">NUEVO SISTEMA</div>
        </div>
      </div>
    </div>

    <!-- Tabs por Tipo de Permiso -->
    <div class="card">
      <div class="card-header">
        <ul class="nav nav-tabs card-header-tabs" role="tablist">
          <li class="nav-item" role="presentation">
            <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#espectaculos" type="button">
              <i class="fas fa-music me-2"></i>Espectáculos
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" data-bs-toggle="tab" data-bs-target="#licencias-temp" type="button">
              <i class="fas fa-certificate me-2"></i>Licencias Temporales
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" data-bs-toggle="tab" data-bs-target="#anuncios-temp" type="button">
              <i class="fas fa-bullhorn me-2"></i>Anuncios Temporales
            </button>
          </li>
        </ul>
      </div>

      <div class="card-body">
        <div class="tab-content">
          <!-- Permisos de Espectáculos -->
          <div class="tab-pane fade show active" id="espectaculos">
            <div class="d-flex justify-content-between align-items-center mb-3">
              <h5 class="text-primary">🎭 Permisos de Espectáculos Temporales</h5>
              <button class="btn btn-primary btn-sm">
                <i class="fas fa-plus me-2"></i>Nuevo Permiso Espectáculo
              </button>
            </div>

            <div class="table-responsive">
              <table class="table table-striped">
                <thead class="table-primary">
                  <tr>
                    <th>Folio</th>
                    <th>Tipo de Evento</th>
                    <th>Solicitante</th>
                    <th>Fecha Evento</th>
                    <th>Vigencia</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td><strong>ESP-2025-001</strong></td>
                    <td>Concierto al aire libre</td>
                    <td>Eventos México SA</td>
                    <td>25/09/2025</td>
                    <td class="text-success">5 días restantes</td>
                    <td><span class="badge bg-success">VIGENTE</span></td>
                    <td>
                      <button class="btn btn-sm btn-info me-1" title="Ver detalles">
                        <i class="fas fa-eye"></i>
                      </button>
                      <button class="btn btn-sm btn-warning" title="Extender">
                        <i class="fas fa-calendar-plus"></i>
                      </button>
                    </td>
                  </tr>
                  <tr>
                    <td><strong>ESP-2025-002</strong></td>
                    <td>Festival gastronómico</td>
                    <td>Cámara de Restaurantes</td>
                    <td>30/09/2025</td>
                    <td class="text-warning">10 días restantes</td>
                    <td><span class="badge bg-warning">PRÓXIMO VENCER</span></td>
                    <td>
                      <button class="btn btn-sm btn-info me-1" title="Ver detalles">
                        <i class="fas fa-eye"></i>
                      </button>
                      <button class="btn btn-sm btn-warning" title="Extender">
                        <i class="fas fa-calendar-plus"></i>
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Licencias Temporales -->
          <div class="tab-pane fade" id="licencias-temp">
            <div class="d-flex justify-content-between align-items-center mb-3">
              <h5 class="text-warning">📋 Licencias Provisionales</h5>
              <button class="btn btn-warning btn-sm">
                <i class="fas fa-plus me-2"></i>Nueva Licencia Temporal
              </button>
            </div>

            <div class="table-responsive">
              <table class="table table-striped">
                <thead class="table-warning">
                  <tr>
                    <th>Folio</th>
                    <th>Tipo de Negocio</th>
                    <th>Comerciante</th>
                    <th>Duración</th>
                    <th>Vigencia</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td><strong>LIC-TEMP-001</strong></td>
                    <td>Venta ambulante</td>
                    <td>María González</td>
                    <td>30 días</td>
                    <td class="text-success">15 días restantes</td>
                    <td><span class="badge bg-success">VIGENTE</span></td>
                    <td>
                      <button class="btn btn-sm btn-info me-1" title="Ver detalles">
                        <i class="fas fa-eye"></i>
                      </button>
                      <button class="btn btn-sm btn-success" title="Convertir a permanente">
                        <i class="fas fa-arrow-up"></i>
                      </button>
                    </td>
                  </tr>
                  <tr>
                    <td><strong>LIC-TEMP-002</strong></td>
                    <td>Puesto temporal navideño</td>
                    <td>Carlos Hernández</td>
                    <td>60 días</td>
                    <td class="text-info">45 días restantes</td>
                    <td><span class="badge bg-info">VIGENTE</span></td>
                    <td>
                      <button class="btn btn-sm btn-info me-1" title="Ver detalles">
                        <i class="fas fa-eye"></i>
                      </button>
                      <button class="btn btn-sm btn-success" title="Convertir a permanente">
                        <i class="fas fa-arrow-up"></i>
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Anuncios Temporales -->
          <div class="tab-pane fade" id="anuncios-temp">
            <div class="d-flex justify-content-between align-items-center mb-3">
              <h5 class="text-success">📢 Anuncios Publicitarios Temporales</h5>
              <button class="btn btn-success btn-sm">
                <i class="fas fa-plus me-2"></i>Nuevo Anuncio Temporal
              </button>
            </div>

            <div class="table-responsive">
              <table class="table table-striped">
                <thead class="table-success">
                  <tr>
                    <th>Folio</th>
                    <th>Tipo de Anuncio</th>
                    <th>Anunciante</th>
                    <th>Ubicación</th>
                    <th>Vigencia</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td><strong>ANU-TEMP-001</strong></td>
                    <td>Banner promocional</td>
                    <td>Super Mercado Familiar</td>
                    <td>Av. Principal #123</td>
                    <td class="text-success">7 días restantes</td>
                    <td><span class="badge bg-success">VIGENTE</span></td>
                    <td>
                      <button class="btn btn-sm btn-info me-1" title="Ver detalles">
                        <i class="fas fa-eye"></i>
                      </button>
                      <button class="btn btn-sm btn-warning" title="Renovar">
                        <i class="fas fa-redo"></i>
                      </button>
                    </td>
                  </tr>
                  <tr>
                    <td><strong>ANU-TEMP-002</strong></td>
                    <td>Valla publicitaria</td>
                    <td>Coca-Cola México</td>
                    <td>Entrada de la ciudad</td>
                    <td class="text-danger">VENCIDO</td>
                    <td><span class="badge bg-danger">VENCIDO</span></td>
                    <td>
                      <button class="btn btn-sm btn-info me-1" title="Ver detalles">
                        <i class="fas fa-eye"></i>
                      </button>
                      <button class="btn btn-sm btn-danger" title="Retirar">
                        <i class="fas fa-trash"></i>
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

        <!-- Estadísticas de Permisos -->
        <div class="row mt-4">
          <div class="col-md-4">
            <div class="card border-primary">
              <div class="card-body text-center">
                <h4 class="text-primary">12</h4>
                <p class="mb-0">Permisos de Espectáculos</p>
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card border-warning">
              <div class="card-body text-center">
                <h4 class="text-warning">8</h4>
                <p class="mb-0">Licencias Temporales</p>
              </div>
            </div>
          </div>
          <div class="col-md-4">
            <div class="card border-success">
              <div class="card-body text-center">
                <h4 class="text-success">15</h4>
                <p class="mb-0">Anuncios Temporales</p>
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
  name: 'PermisosProvisionales'
}
</script>

<style scoped>
.permisos-provisionales {
  padding: 1rem;
}

.alert-info {
  border-left: 4px solid #17a2b8;
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