<template>
  <div class="min-vh-100 bg-light">
    <!-- Header del Módulo -->
    <div class="bg-white shadow-sm border-bottom">
      <div class="container-fluid py-5">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-secondary bg-gradient rounded-3 d-flex align-items-center justify-content-center shadow me-4" style="width: 64px; height: 64px;">
              <i class="fas fa-exclamation-triangle fa-2x text-white"></i>
            </div>
            <div>
              <h1 class="display-5 fw-bold text-dark mb-2">Módulo Apremios</h1>
              <p class="fs-5 text-muted">Sistema de Cobranza Coactiva y Procedimientos Administrativos</p>
            </div>
          </div>
          <div>
            <router-link 
              to="/" 
              class="btn btn-outline-secondary d-flex align-items-center"
            >
              <i class="fas fa-arrow-left me-2"></i>
              Volver al Dashboard
            </router-link>
          </div>
        </div>
      </div>
    </div>

    <!-- Contenido Principal -->
    <div class="container-fluid py-5">
      
      <!-- Estadísticas del Módulo -->
      <div class="row g-4 mb-5">
        <div class="col-md-6 col-xl-3">
          <div class="card border-0 shadow-sm h-100">
            <div class="card-body p-4">
              <div class="d-flex align-items-center">
                <div class="bg-secondary bg-opacity-10 rounded-3 p-3 me-3">
                  <i class="fas fa-check-circle fa-lg text-secondary"></i>
                </div>
                <div>
                  <p class="small text-muted mb-1">Formularios</p>
                  <p class="h2 fw-bold text-secondary mb-0">59</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-md-6 col-xl-3">
          <div class="card border-0 shadow-sm h-100">
            <div class="card-body p-4">
              <div class="d-flex align-items-center">
                <div class="bg-secondary bg-opacity-10 rounded-3 p-3 me-3">
                  <i class="fas fa-cube fa-lg text-secondary"></i>
                </div>
                <div>
                  <p class="small text-muted mb-1">Módulos</p>
                  <p class="h2 fw-bold text-secondary mb-0">12</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-md-6 col-xl-3">
          <div class="card border-0 shadow-sm h-100">
            <div class="card-body p-4">
              <div class="d-flex align-items-center">
                <div class="bg-secondary bg-opacity-10 rounded-3 p-3 me-3">
                  <i class="fas fa-database fa-lg text-secondary"></i>
                </div>
                <div>
                  <p class="small text-muted mb-1">Stored Procedures</p>
                  <p class="h2 fw-bold text-secondary mb-0">13</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-md-6 col-xl-3">
          <div class="card border-0 shadow-sm h-100">
            <div class="card-body p-4">
              <div class="d-flex align-items-center">
                <div class="bg-success bg-opacity-10 rounded-3 p-3 me-3">
                  <div class="spinner-grow spinner-grow-sm text-success" role="status"></div>
                </div>
                <div>
                  <p class="small text-muted mb-1">Estado</p>
                  <p class="h5 fw-bold text-success mb-0">Activo</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Descripción del Módulo -->
      <div class="card border-0 shadow-sm mb-5">
        <div class="card-body p-5">
          <h2 class="h3 fw-bold text-dark mb-4">Descripción del Módulo</h2>
          <p class="text-muted fs-6 lh-lg mb-3">
            El <strong>Módulo de Apremios</strong> es un sistema especializado para la gestión de procedimientos 
            de cobranza coactiva y ejecución de adeudos fiscales. Permite el control integral de procesos 
            administrativos de cobro, gestión de ejecutores y facturación electrónica especializada.
          </p>
          <p class="text-muted fs-6 lh-lg">
            Desarrollado con arquitectura moderna Laravel + Vue.js + PostgreSQL, ofrece herramientas 
            avanzadas para la gestión eficiente de procedimientos legales y administrativos de cobranza.
          </p>
        </div>
      </div>

      <!-- Características Principales -->
      <div class="row g-4 mb-5">
        <div class="col-lg-6">
          <div class="card border-0 shadow-sm h-100">
            <div class="card-body p-5">
              <h3 class="h4 fw-bold text-dark mb-4">Características Principales</h3>
              <div class="d-flex flex-column gap-3">
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Gestión de Ejecutores</h4>
                    <p class="text-muted small mb-0">Administración y control de ejecutores fiscales</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Facturación Electrónica</h4>
                    <p class="text-muted small mb-0">Sistema de facturación y firma digital</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Cobranza Coactiva</h4>
                    <p class="text-muted small mb-0">Procedimientos legales de recuperación de cartera</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Reportes Especializados</h4>
                    <p class="text-muted small mb-0">Informes detallados de gestión y seguimiento</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-lg-6">
          <div class="card border-0 shadow-sm h-100">
            <div class="card-body p-5">
              <h3 class="h4 fw-bold text-dark mb-4">Funciones Especializadas</h3>
              <div class="d-flex flex-column gap-3">
                <div class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3">
                  <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                    <i class="fas fa-search text-secondary"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Consulta de Registros</h4>
                    <p class="text-muted small mb-0">Búsqueda avanzada de expedientes</p>
                  </div>
                </div>
                
                <div class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3">
                  <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                    <i class="fas fa-folder text-secondary"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Control de Folios</h4>
                    <p class="text-muted small mb-0">Emisión y seguimiento de folios</p>
                  </div>
                </div>
                
                <div class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3">
                  <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                    <i class="fas fa-bell text-secondary"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Listados y Notificaciones</h4>
                    <p class="text-muted small mb-0">Generación de notificaciones oficiales</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Módulos Principales -->
      <div class="card border-0 shadow-sm mb-5">
        <div class="card-body p-5">
          <h3 class="h4 fw-bold text-dark mb-4">Módulos Principales</h3>
          <div class="row g-3">
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">ABC Ejecutores</h4>
                <p class="text-muted small mb-0">Administración de ejecutores fiscales</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Consulta Registros</h4>
                <p class="text-muted small mb-0">Búsqueda y consulta de expedientes</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Facturación</h4>
                <p class="text-muted small mb-0">Emisión de facturas electrónicas</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Firma Electrónica</h4>
                <p class="text-muted small mb-0">Gestión de firmas digitales</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Requerimientos</h4>
                <p class="text-muted small mb-0">Emisión de requerimientos de pago</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Reportes</h4>
                <p class="text-muted small mb-0">Informes estadísticos y de gestión</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 🆕 MODERNIZACIÓN DEL MÓDULO -->
      <div class="card border-0 shadow-sm mb-5" style="border-left: 5px solid #198754 !important;">
        <div class="card-body p-5">
          <div class="d-flex align-items-center mb-4">
            <div class="bg-success bg-opacity-10 rounded-3 p-3 me-3">
              <i class="fas fa-rocket fa-lg text-success"></i>
            </div>
            <div>
              <h3 class="h4 fw-bold text-dark mb-1">🚀 Modernización del Módulo</h3>
              <p class="text-muted small mb-0">Nuevas funcionalidades implementadas</p>
            </div>
            <div class="ms-auto">
              <span class="badge bg-success fs-6">+3 NUEVOS</span>
            </div>
          </div>

          <div class="row g-4">
            <div class="col-lg-4">
              <div class="card border border-success border-opacity-25 h-100">
                <div class="card-body p-4">
                  <div class="d-flex align-items-center mb-3">
                    <div class="bg-success bg-opacity-10 rounded-3 p-2 me-3">
                      <i class="fas fa-handshake text-success"></i>
                    </div>
                    <div>
                      <h4 class="fw-bold text-dark mb-1">Sistema de Convenios</h4>
                      <span class="badge bg-danger small">NUEVO</span>
                    </div>
                  </div>
                  <p class="text-muted small mb-3">Sistema completo de convenios de pago con gestión integral de acuerdos y parcialidades.</p>
                  <div class="d-flex align-items-center">
                    <router-link
                      to="/apremios/SistemaConveniosApremios"
                      class="btn btn-success btn-sm"
                    >
                      <i class="fas fa-external-link-alt me-2"></i>Acceder
                    </router-link>
                  </div>
                </div>
              </div>
            </div>

            <div class="col-lg-4">
              <div class="card border border-success border-opacity-25 h-100">
                <div class="card-body p-4">
                  <div class="d-flex align-items-center mb-3">
                    <div class="bg-success bg-opacity-10 rounded-3 p-2 me-3">
                      <i class="fas fa-gavel text-success"></i>
                    </div>
                    <div>
                      <h4 class="fw-bold text-dark mb-1">Sistema de Apremios</h4>
                      <span class="badge bg-danger small">NUEVO</span>
                    </div>
                  </div>
                  <p class="text-muted small mb-3">Gestión integral de procedimientos administrativos con control de ejecutores y folios.</p>
                  <div class="d-flex align-items-center">
                    <router-link
                      to="/apremios/SistemaApremiosApremios"
                      class="btn btn-success btn-sm"
                    >
                      <i class="fas fa-external-link-alt me-2"></i>Acceder
                    </router-link>
                  </div>
                </div>
              </div>
            </div>

            <div class="col-lg-4">
              <div class="card border border-success border-opacity-25 h-100">
                <div class="card-body p-4">
                  <div class="d-flex align-items-center mb-3">
                    <div class="bg-success bg-opacity-10 rounded-3 p-2 me-3">
                      <i class="fas fa-percentage text-success"></i>
                    </div>
                    <div>
                      <h4 class="fw-bold text-dark mb-1">Descuentos y Conversión</h4>
                      <span class="badge bg-danger small">NUEVO</span>
                    </div>
                  </div>
                  <p class="text-muted small mb-3">Sistema automatizado de descuentos, conversión de procedimientos y revaluación de costos.</p>
                  <div class="d-flex align-items-center">
                    <router-link
                      to="/apremios/SistemaDescuentosApremios"
                      class="btn btn-success btn-sm"
                    >
                      <i class="fas fa-external-link-alt me-2"></i>Acceder
                    </router-link>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Características de la Modernización -->
          <div class="mt-4 p-4 bg-success bg-opacity-10 rounded-3">
            <h5 class="fw-bold text-success mb-3">
              <i class="fas fa-star me-2"></i>Características de la Modernización
            </h5>
            <div class="row g-3">
              <div class="col-md-6">
                <div class="d-flex align-items-center">
                  <i class="fas fa-cog text-success me-2"></i>
                  <span class="small">Administración integral de convenios</span>
                </div>
              </div>
              <div class="col-md-6">
                <div class="d-flex align-items-center">
                  <i class="fas fa-users text-success me-2"></i>
                  <span class="small">Control especializado de ejecutores</span>
                </div>
              </div>
              <div class="col-md-6">
                <div class="d-flex align-items-center">
                  <i class="fas fa-file-alt text-success me-2"></i>
                  <span class="small">Generación automática de folios</span>
                </div>
              </div>
              <div class="col-md-6">
                <div class="d-flex align-items-center">
                  <i class="fas fa-calculator text-success me-2"></i>
                  <span class="small">Descuentos y revaluación automatizada</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Acciones Rápidas -->
      <div class="card border-0 shadow-sm">
        <div class="card-body p-5">
          <h3 class="h4 fw-bold text-dark mb-4">Acciones Rápidas</h3>
          <div class="row g-3">
            <div class="col-md-4">
              <router-link 
                to="/apremios/acceso" 
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-shield-alt text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Control de Acceso</h4>
                  <p class="text-muted small mb-0">Gestión de usuarios</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-4">
              <router-link 
                to="/apremios/consulta" 
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-search text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Consulta General</h4>
                  <p class="text-muted small mb-0">Búsqueda de expedientes</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-4">
              <router-link 
                to="/apremios/ejecutores" 
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-user-tie text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Gestión Ejecutores</h4>
                  <p class="text-muted small mb-0">Administrar ejecutores</p>
                </div>
              </router-link>
            </div>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
export default {
  name: 'ApremiosInfo',
  data() {
    return {
      // Datos específicos del módulo de apremios
    }
  }
}
</script>

<style scoped>
.hover-bg-secondary-subtle:hover {
  background-color: var(--bs-secondary-bg) !important;
}

.transition {
  transition: all 0.2s ease;
}
</style>