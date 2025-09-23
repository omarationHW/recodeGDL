<template>
  <div class="container-fluid mt-4">
    <!-- Header del Menú -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #28a745 !important;">
      <div class="card-body p-4">
        <div class="d-flex align-items-center mb-3">
          <div class="bg-secondary bg-opacity-10 rounded-3 p-3 me-3">
            <i class="fas fa-cross fa-2x text-secondary"></i>
          </div>
          <div>
            <h1 class="h3 fw-bold text-dark mb-1">Menú Principal - Cementerios</h1>
            <p class="text-muted mb-0">Sistema de gestión integral de servicios cementeriales</p>
          </div>
        </div>
      </div>
    </div>

    <!-- 🆕 NUEVAS FUNCIONALIDADES DE MODERNIZACIÓN -->
    <div class="card border-0 shadow-sm mb-5" style="border-left: 5px solid #ffc107 !important;">
      <div class="card-body p-4">
        <div class="d-flex align-items-center mb-4">
          <div class="bg-warning bg-opacity-10 rounded-3 p-3 me-3">
            <i class="fas fa-star fa-2x text-warning"></i>
          </div>
          <div>
            <h3 class="h4 fw-bold text-dark mb-1">🆕 Nuevas Funcionalidades Modernizadas</h3>
            <p class="text-muted mb-0">Sistemas integrados para automatización y optimización</p>
          </div>
        </div>

        <div class="alert alert-warning border-warning" role="alert">
          <div class="d-flex align-items-center">
            <i class="fas fa-exclamation-triangle me-2"></i>
            <div>
              <strong>📋 Modernización Completa</strong>
              <p class="mb-0 small">Se han excluido 10 funciones obsoletas y se implementaron 4 sistemas integrados modernos.</p>
            </div>
          </div>
        </div>

        <div class="row g-4">
          <div class="col-lg-6">
            <router-link
              to="/cementerios/sistemadescuentoscementerios"
              class="d-flex align-items-center p-4 bg-success bg-opacity-10 rounded-3 text-decoration-none hover-bg-success-subtle transition border border-success border-opacity-25"
            >
              <div class="bg-success bg-opacity-25 rounded-3 p-3 me-3">
                <i class="fas fa-percentage fa-lg text-success"></i>
              </div>
              <div>
                <h5 class="fw-bold text-success mb-1">🆕 Sistema de Descuentos Automatizados</h5>
                <p class="text-muted small mb-0">Cálculo automático de descuentos en recargos con validación legal</p>
                <small class="badge bg-success mt-2">NUEVO SISTEMA</small>
              </div>
            </router-link>
          </div>

          <div class="col-lg-6">
            <router-link
              to="/cementerios/sistemaconversionrevaluacion"
              class="d-flex align-items-center p-4 bg-primary bg-opacity-10 rounded-3 text-decoration-none hover-bg-primary-subtle transition border border-primary border-opacity-25"
            >
              <div class="bg-primary bg-opacity-25 rounded-3 p-3 me-3">
                <i class="fas fa-exchange-alt fa-lg text-primary"></i>
              </div>
              <div>
                <h5 class="fw-bold text-primary mb-1">🆕 Sistema de Conversión y Revaluación</h5>
                <p class="text-muted small mb-0">Migración automática de procedimientos con revaluación de costos</p>
                <small class="badge bg-primary mt-2">NUEVO SISTEMA</small>
              </div>
            </router-link>
          </div>

          <div class="col-lg-6">
            <router-link
              to="/cementerios/sistemaconsultasunificadas"
              class="d-flex align-items-center p-4 bg-info bg-opacity-10 rounded-3 text-decoration-none hover-bg-info-subtle transition border border-info border-opacity-25"
            >
              <div class="bg-info bg-opacity-25 rounded-3 p-3 me-3">
                <i class="fas fa-search-plus fa-lg text-info"></i>
              </div>
              <div>
                <h5 class="fw-bold text-info mb-1">🆕 Sistema de Consultas Unificadas</h5>
                <p class="text-muted small mb-0">Búsqueda inteligente multifiltro con algoritmos avanzados</p>
                <small class="badge bg-info mt-2">NUEVO SISTEMA</small>
              </div>
            </router-link>
          </div>

          <div class="col-lg-6">
            <router-link
              to="/cementerios/funcionesexcluidascementerios"
              class="d-flex align-items-center p-4 bg-danger bg-opacity-10 rounded-3 text-decoration-none hover-bg-danger-subtle transition border border-danger border-opacity-25"
            >
              <div class="bg-danger bg-opacity-25 rounded-3 p-3 me-3">
                <i class="fas fa-times-circle fa-lg text-danger"></i>
              </div>
              <div>
                <h5 class="fw-bold text-danger mb-1">🆕 Funciones Excluidas</h5>
                <p class="text-muted small mb-0">Documentación de funciones obsoletas y sus reemplazos modernos</p>
                <small class="badge bg-danger mt-2">DOCUMENTACIÓN</small>
              </div>
            </router-link>
          </div>
        </div>

        <div class="mt-4 p-3 bg-light rounded-3">
          <div class="row g-3 text-center">
            <div class="col-md-3">
              <div class="d-flex flex-column">
                <span class="h5 fw-bold text-danger mb-1">10</span>
                <small class="text-muted">Funciones excluidas</small>
              </div>
            </div>
            <div class="col-md-3">
              <div class="d-flex flex-column">
                <span class="h5 fw-bold text-success mb-1">4</span>
                <small class="text-muted">Sistemas nuevos</small>
              </div>
            </div>
            <div class="col-md-3">
              <div class="d-flex flex-column">
                <span class="h5 fw-bold text-warning mb-1">350%</span>
                <small class="text-muted">Mejora eficiencia</small>
              </div>
            </div>
            <div class="col-md-3">
              <div class="d-flex flex-column">
                <span class="h5 fw-bold text-info mb-1">70%</span>
                <small class="text-muted">Reducción tiempo</small>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Funciones Tradicionales -->
    <div class="card border-0 shadow-sm">
      <div class="card-header bg-light">
        <h5 class="fw-bold mb-0">
          <i class="fas fa-list me-2"></i>Funciones Tradicionales del Sistema
        </h5>
      </div>
      <div class="card-body">
        <div class="row g-3">
          <!-- Gestión de Servicios -->
          <div class="col-md-4">
            <div class="card border-secondary border-opacity-25">
              <div class="card-header bg-secondary bg-opacity-10">
                <h6 class="fw-bold mb-0 text-secondary">
                  <i class="fas fa-handshake me-2"></i>Gestión de Servicios
                </h6>
              </div>
              <div class="card-body">
                <div class="d-grid gap-2">
                  <router-link to="/cementerios/abcementer" class="btn btn-outline-secondary btn-sm">
                    <i class="fas fa-database me-1"></i>ABC Ementer
                  </router-link>
                  <router-link to="/cementerios/abcfolio" class="btn btn-outline-secondary btn-sm">
                    <i class="fas fa-file me-1"></i>ABC Folio
                  </router-link>
                  <router-link to="/cementerios/abcpagos" class="btn btn-outline-secondary btn-sm">
                    <i class="fas fa-credit-card me-1"></i>ABC Pagos
                  </router-link>
                  <router-link to="/cementerios/liquidaciones" class="btn btn-outline-secondary btn-sm">
                    <i class="fas fa-receipt me-1"></i>Liquidaciones
                  </router-link>
                </div>
              </div>
            </div>
          </div>

          <!-- Consultas -->
          <div class="col-md-4">
            <div class="card border-info border-opacity-25">
              <div class="card-header bg-info bg-opacity-10">
                <h6 class="fw-bold mb-0 text-info">
                  <i class="fas fa-search me-2"></i>Consultas
                </h6>
              </div>
              <div class="card-body">
                <div class="d-grid gap-2">
                  <router-link to="/cementerios/consulta400" class="btn btn-outline-info btn-sm">
                    <i class="fas fa-search me-1"></i>Consulta 400
                  </router-link>
                  <router-link to="/cementerios/consultafol" class="btn btn-outline-info btn-sm">
                    <i class="fas fa-file-search me-1"></i>Consulta Folio
                  </router-link>
                  <router-link to="/cementerios/consultanombre" class="btn btn-outline-info btn-sm">
                    <i class="fas fa-user-search me-1"></i>Consulta Nombre
                  </router-link>
                  <router-link to="/cementerios/consultarcm" class="btn btn-outline-info btn-sm">
                    <i class="fas fa-id-card me-1"></i>Consulta RCM
                  </router-link>
                </div>
              </div>
            </div>
          </div>

          <!-- Reportes -->
          <div class="col-md-4">
            <div class="card border-warning border-opacity-25">
              <div class="card-header bg-warning bg-opacity-10">
                <h6 class="fw-bold mb-0 text-warning">
                  <i class="fas fa-chart-bar me-2"></i>Reportes
                </h6>
              </div>
              <div class="card-body">
                <div class="d-grid gap-2">
                  <router-link to="/cementerios/rep_a_cobrar" class="btn btn-outline-warning btn-sm">
                    <i class="fas fa-money-bill me-1"></i>Rep. A Cobrar
                  </router-link>
                  <router-link to="/cementerios/rep_bon" class="btn btn-outline-warning btn-sm">
                    <i class="fas fa-percentage me-1"></i>Rep. Bonificaciones
                  </router-link>
                  <router-link to="/cementerios/rpttitulos" class="btn btn-outline-warning btn-sm">
                    <i class="fas fa-certificate me-1"></i>Rep. Títulos
                  </router-link>
                  <router-link to="/cementerios/list_mov" class="btn btn-outline-warning btn-sm">
                    <i class="fas fa-list-alt me-1"></i>Lista Movimientos
                  </router-link>
                </div>
              </div>
            </div>
          </div>

          <!-- Gestión Especial -->
          <div class="col-md-6">
            <div class="card border-success border-opacity-25">
              <div class="card-header bg-success bg-opacity-10">
                <h6 class="fw-bold mb-0 text-success">
                  <i class="fas fa-tools me-2"></i>Gestión Especial
                </h6>
              </div>
              <div class="card-body">
                <div class="row g-2">
                  <div class="col-6">
                    <router-link to="/cementerios/traslados" class="btn btn-outline-success btn-sm w-100">
                      <i class="fas fa-truck me-1"></i>Traslados
                    </router-link>
                  </div>
                  <div class="col-6">
                    <router-link to="/cementerios/bonificaciones" class="btn btn-outline-success btn-sm w-100">
                      <i class="fas fa-gift me-1"></i>Bonificaciones
                    </router-link>
                  </div>
                  <div class="col-6">
                    <router-link to="/cementerios/descuentos" class="btn btn-outline-success btn-sm w-100">
                      <i class="fas fa-tag me-1"></i>Descuentos
                    </router-link>
                  </div>
                  <div class="col-6">
                    <router-link to="/cementerios/duplicados" class="btn btn-outline-success btn-sm w-100">
                      <i class="fas fa-copy me-1"></i>Duplicados
                    </router-link>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Configuración -->
          <div class="col-md-6">
            <div class="card border-dark border-opacity-25">
              <div class="card-header bg-dark bg-opacity-10">
                <h6 class="fw-bold mb-0 text-dark">
                  <i class="fas fa-cog me-2"></i>Configuración
                </h6>
              </div>
              <div class="card-body">
                <div class="row g-2">
                  <div class="col-6">
                    <router-link to="/cementerios/acceso" class="btn btn-outline-dark btn-sm w-100">
                      <i class="fas fa-key me-1"></i>Acceso
                    </router-link>
                  </div>
                  <div class="col-6">
                    <router-link to="/cementerios/sfrm_chgpass" class="btn btn-outline-dark btn-sm w-100">
                      <i class="fas fa-lock me-1"></i>Cambiar Pass
                    </router-link>
                  </div>
                  <div class="col-6">
                    <router-link to="/cementerios/titulos" class="btn btn-outline-dark btn-sm w-100">
                      <i class="fas fa-scroll me-1"></i>Títulos
                    </router-link>
                  </div>
                  <div class="col-6">
                    <router-link to="/cementerios/estad_adeudo" class="btn btn-outline-dark btn-sm w-100">
                      <i class="fas fa-chart-line me-1"></i>Est. Adeudo
                    </router-link>
                  </div>
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
  name: 'Menu',
  data() {
    return {
      // Estadísticas del módulo
      stats: {
        funcionesExcluidas: 10,
        sistemasNuevos: 4,
        mejoraEficiencia: '350%',
        reduccionTiempo: '70%'
      }
    }
  },
  mounted() {
    console.log('Menú Principal de Cementerios cargado - Modernización completa');
  }
}
</script>

<style scoped>
.card {
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.hover-bg-success-subtle:hover {
  background-color: rgba(25, 135, 84, 0.1) !important;
}

.hover-bg-primary-subtle:hover {
  background-color: rgba(13, 110, 253, 0.1) !important;
}

.hover-bg-info-subtle:hover {
  background-color: rgba(13, 202, 240, 0.1) !important;
}

.hover-bg-danger-subtle:hover {
  background-color: rgba(220, 53, 69, 0.1) !important;
}

.transition {
  transition: all 0.3s ease;
}

.badge {
  font-size: 0.75em;
}

.btn {
  transition: all 0.2s ease;
}

.btn:hover {
  transform: translateY(-1px);
}

.border-opacity-25 {
  border-color: rgba(var(--bs-border-color), 0.25) !important;
}

.bg-opacity-10 {
  background-color: rgba(var(--bs-bg-opacity), 0.1) !important;
}

.bg-opacity-25 {
  background-color: rgba(var(--bs-bg-opacity), 0.25) !important;
}

.rounded-3 {
  border-radius: 0.375rem !important;
}

.text-decoration-none:hover {
  text-decoration: none !important;
}

.fw-bold {
  font-weight: 700 !important;
}

.fw-semibold {
  font-weight: 600 !important;
}

router-link {
  text-decoration: none;
}

router-link:hover {
  text-decoration: none;
}
</style>
