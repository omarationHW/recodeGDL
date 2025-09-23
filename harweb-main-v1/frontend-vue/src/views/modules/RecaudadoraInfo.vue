<template>
  <div class="min-vh-100 bg-light">
    <!-- Header del Módulo -->
    <div class="bg-white shadow-sm border-bottom">
      <div class="container-fluid py-5">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-secondary bg-gradient rounded-3 d-flex align-items-center justify-content-center shadow me-4" style="width: 64px; height: 64px;">
              <i class="fas fa-coins fa-2x text-white"></i>
            </div>
            <div>
              <h1 class="display-5 fw-bold text-dark mb-2">Módulo Recaudadora</h1>
              <p class="fs-5 text-muted">Sistema Integral de Recaudación e Ingresos Municipales</p>
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
                  <p class="small text-muted mb-1">Componentes</p>
                  <p class="h2 fw-bold text-secondary mb-0">88</p>
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
                  <p class="small text-muted mb-1">Formularios</p>
                  <p class="h2 fw-bold text-secondary mb-0">62</p>
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
                  <p class="h2 fw-bold text-secondary mb-0">234</p>
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
            El <strong>Módulo Recaudadora</strong> es un sistema especializado para la gestión integral 
            de recaudación e ingresos municipales. Permite el control completo de cobros, tesorería, 
            reportes financieros y administración de ingresos de todos los servicios municipales.
          </p>
          <p class="text-muted fs-6 lh-lg">
            Migrado completamente de Delphi a arquitectura moderna con Laravel + Vue.js + PostgreSQL, 
            ofrece herramientas avanzadas para la optimización de procesos de recaudación municipal.
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
                    <h4 class="fw-medium text-dark mb-1">Control de Ingresos</h4>
                    <p class="text-muted small mb-0">Administración completa de ingresos municipales</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Gestión de Tesorería</h4>
                    <p class="text-muted small mb-0">Control de flujos de efectivo y caja</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Reportes Financieros</h4>
                    <p class="text-muted small mb-0">Informes estadísticos y contables</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Integración de Servicios</h4>
                    <p class="text-muted small mb-0">Consolidación de cobros de todos los módulos</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-lg-6">
          <div class="card border-0 shadow-sm h-100">
            <div class="card-body p-5">
              <h3 class="h4 fw-bold text-dark mb-4">Arquitectura Técnica</h3>
              <div class="d-flex flex-column gap-3">
                <div class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3">
                  <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                    <i class="fas fa-desktop text-secondary"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Frontend</h4>
                    <p class="text-muted small mb-0">Vue.js 3 con interfaz SPA moderna</p>
                  </div>
                </div>
                
                <div class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3">
                  <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                    <i class="fas fa-server text-secondary"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Backend</h4>
                    <p class="text-muted small mb-0">Laravel API con endpoint unificado</p>
                  </div>
                </div>
                
                <div class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3">
                  <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                    <i class="fas fa-database text-secondary"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Base de Datos</h4>
                    <p class="text-muted small mb-0">PostgreSQL con stored procedures</p>
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
          <h3 class="h4 fw-bold text-dark mb-4">Módulos de Gestión</h3>
          <div class="row g-3">
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Control de Cajas</h4>
                <p class="text-muted small mb-0">Gestión de cajas recaudadoras</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Tesorería</h4>
                <p class="text-muted small mb-0">Administración de fondos municipales</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Conciliación</h4>
                <p class="text-muted small mb-0">Proceso de conciliación bancaria</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Reportes</h4>
                <p class="text-muted small mb-0">Informes financieros y estadísticos</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Consultas</h4>
                <p class="text-muted small mb-0">Búsquedas de movimientos y pagos</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Administración</h4>
                <p class="text-muted small mb-0">Configuración del sistema</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 🆕 SECCIÓN DE MODERNIZACIÓN -->
      <div class="card border-0 shadow-sm mb-5 border-start border-info border-5">
        <div class="card-body p-5">
          <div class="d-flex align-items-center mb-4">
            <div class="bg-info bg-gradient rounded-3 d-flex align-items-center justify-content-center shadow me-3" style="width: 48px; height: 48px;">
              <i class="fas fa-rocket fa-lg text-white"></i>
            </div>
            <div>
              <h3 class="h4 fw-bold text-dark mb-1">🆕 Modernización Recaudadora 2024</h3>
              <p class="text-muted mb-0">Nuevos sistemas integrales para convenios y apremios</p>
            </div>
            <div class="ms-auto">
              <span class="badge bg-info px-3 py-2">+3 NUEVOS MÓDULOS</span>
            </div>
          </div>

          <div class="row g-4">
            <div class="col-lg-4">
              <div class="card border-info border-2 h-100">
                <div class="card-body p-4">
                  <div class="d-flex align-items-center mb-3">
                    <div class="bg-info bg-opacity-10 rounded-3 p-2 me-3">
                      <i class="fas fa-handshake text-info"></i>
                    </div>
                    <div>
                      <h5 class="fw-bold mb-0">Sistema Integral de Convenios</h5>
                      <span class="badge bg-danger small">NUEVO</span>
                    </div>
                  </div>
                  <p class="text-muted small mb-3">ABC completo de convenios con intereses, parcialidades, pagos e impresión de documentos oficiales</p>
                  <router-link
                    to="/recaudadora/sistemaconveniosrecaudadora"
                    class="btn btn-info btn-sm w-100"
                  >
                    <i class="fas fa-arrow-right me-2"></i>
                    Acceder al Sistema
                  </router-link>
                </div>
              </div>
            </div>

            <div class="col-lg-4">
              <div class="card border-warning border-2 h-100">
                <div class="card-body p-4">
                  <div class="d-flex align-items-center mb-3">
                    <div class="bg-warning bg-opacity-10 rounded-3 p-2 me-3">
                      <i class="fas fa-gavel text-warning"></i>
                    </div>
                    <div>
                      <h5 class="fw-bold mb-0">Sistema Integral de Apremios</h5>
                      <span class="badge bg-danger small">NUEVO</span>
                    </div>
                  </div>
                  <p class="text-muted small mb-3">Gestión completa de ejecutores, folios, notificaciones y reportes especializados de apremios</p>
                  <router-link
                    to="/recaudadora/sistemaapremiosrecaudadora"
                    class="btn btn-warning btn-sm w-100"
                  >
                    <i class="fas fa-arrow-right me-2"></i>
                    Acceder al Sistema
                  </router-link>
                </div>
              </div>
            </div>

            <div class="col-lg-4">
              <div class="card border-danger border-2 h-100">
                <div class="card-body p-4">
                  <div class="d-flex align-items-center mb-3">
                    <div class="bg-danger bg-opacity-10 rounded-3 p-2 me-3">
                      <i class="fas fa-ban text-danger"></i>
                    </div>
                    <div>
                      <h5 class="fw-bold mb-0">Funciones Excluidas</h5>
                      <span class="badge bg-warning small">MIGRACIÓN</span>
                    </div>
                  </div>
                  <p class="text-muted small mb-3">Listado de funciones obsoletas que serán removidas y sus reemplazos modernos</p>
                  <router-link
                    to="/recaudadora/funcionesexcluidasrecaudadora"
                    class="btn btn-danger btn-sm w-100"
                  >
                    <i class="fas fa-eye me-2"></i>
                    Ver Funciones
                  </router-link>
                </div>
              </div>
            </div>
          </div>

          <!-- Características principales de la modernización -->
          <div class="row mt-4">
            <div class="col-12">
              <div class="bg-light rounded-3 p-4">
                <h6 class="fw-bold text-dark mb-3">🎯 Características Principales de la Modernización</h6>
                <div class="row g-3">
                  <div class="col-md-6 col-lg-3">
                    <div class="d-flex align-items-center">
                      <i class="fas fa-percentage text-info me-2"></i>
                      <small>ABC de Catálogo de Intereses</small>
                    </div>
                  </div>
                  <div class="col-md-6 col-lg-3">
                    <div class="d-flex align-items-center">
                      <i class="fas fa-print text-info me-2"></i>
                      <small>Impresión de Documentos Oficiales</small>
                    </div>
                  </div>
                  <div class="col-md-6 col-lg-3">
                    <div class="d-flex align-items-center">
                      <i class="fas fa-user-shield text-warning me-2"></i>
                      <small>Gestión de Ejecutores</small>
                    </div>
                  </div>
                  <div class="col-md-6 col-lg-3">
                    <div class="d-flex align-items-center">
                      <i class="fas fa-file-alt text-warning me-2"></i>
                      <small>Generación Automática de Folios</small>
                    </div>
                  </div>
                  <div class="col-md-6 col-lg-3">
                    <div class="d-flex align-items-center">
                      <i class="fas fa-chart-bar text-success me-2"></i>
                      <small>Reportes Avanzados</small>
                    </div>
                  </div>
                  <div class="col-md-6 col-lg-3">
                    <div class="d-flex align-items-center">
                      <i class="fas fa-times-circle text-danger me-2"></i>
                      <small>Cancelación Masiva Inteligente</small>
                    </div>
                  </div>
                  <div class="col-md-6 col-lg-3">
                    <div class="d-flex align-items-center">
                      <i class="fas fa-sync-alt text-info me-2"></i>
                      <small>Conversión de Procedimientos</small>
                    </div>
                  </div>
                  <div class="col-md-6 col-lg-3">
                    <div class="d-flex align-items-center">
                      <i class="fas fa-shield-alt text-success me-2"></i>
                      <small>Eliminación de AS400</small>
                    </div>
                  </div>
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
                to="/recaudadora/cajas" 
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-cash-register text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Control de Cajas</h4>
                  <p class="text-muted small mb-0">Gestión de recaudación</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-4">
              <router-link 
                to="/recaudadora/tesoreria" 
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-university text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Tesorería</h4>
                  <p class="text-muted small mb-0">Administración de fondos</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-4">
              <router-link 
                to="/recaudadora/reportes" 
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-chart-bar text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Reportes</h4>
                  <p class="text-muted small mb-0">Informes financieros</p>
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
  name: 'RecaudadoraInfo',
  data() {
    return {
      // Datos específicos del módulo recaudadora
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