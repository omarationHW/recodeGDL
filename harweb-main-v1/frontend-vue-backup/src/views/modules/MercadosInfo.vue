<template>
  <div class="min-vh-100 bg-light">
    <!-- Header del Módulo -->
    <div class="bg-white shadow-sm border-bottom">
      <div class="container-fluid py-5">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-secondary bg-gradient rounded-3 d-flex align-items-center justify-content-center shadow me-4" style="width: 64px; height: 64px;">
              <i class="fas fa-store fa-2x text-white"></i>
            </div>
            <div>
              <h1 class="display-5 fw-bold text-dark mb-2">Módulo Mercados</h1>
              <p class="fs-5 text-muted">Control y Administración Integral de Mercados Municipales</p>
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
                  <p class="h2 fw-bold text-warning mb-0">109</p>
                  <p class="small text-warning fw-bold mb-0">+2 NUEVOS</p>
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
                  <p class="h2 fw-bold text-secondary mb-0">523</p>
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
                  <i class="fas fa-file-alt fa-lg text-secondary"></i>
                </div>
                <div>
                  <p class="small text-muted mb-1">Documentos</p>
                  <p class="h2 fw-bold text-secondary mb-0">78</p>
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
            El <strong>Módulo de Mercados</strong> es un sistema especializado para el control y administración 
            integral de mercados municipales, locales comerciales y servicios. Permite la gestión completa 
            de arrendamientos, cobros, mantenimiento y control de espacios comerciales públicos.
          </p>
          <p class="text-muted fs-6 lh-lg">
            Migrado completamente de Delphi a arquitectura moderna con Laravel + Vue.js + PostgreSQL, 
            ofrece herramientas avanzadas para la optimización de servicios comerciales municipales.
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
                    <h4 class="fw-medium text-dark mb-1">Gestión de Locales</h4>
                    <p class="text-muted small mb-0">Administración completa de espacios comerciales</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Control de Arrendamientos</h4>
                    <p class="text-muted small mb-0">Gestión de contratos y rentas</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Sistema de Cobros</h4>
                    <p class="text-muted small mb-0">Facturación y control de pagos</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Mantenimiento</h4>
                    <p class="text-muted small mb-0">Control de servicios y mantenimiento</p>
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
                <h4 class="fw-medium text-dark mb-2">Administración de Locales</h4>
                <p class="text-muted small mb-0">Gestión de espacios comerciales</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Control de Arrendatarios</h4>
                <p class="text-muted small mb-0">Gestión de inquilinos y contratos</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Facturación</h4>
                <p class="text-muted small mb-0">Sistema de cobros y facturación</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Consultas</h4>
                <p class="text-muted small mb-0">Búsquedas y reportes especializados</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Mantenimiento</h4>
                <p class="text-muted small mb-0">Control de servicios y reparaciones</p>
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

      <!-- 🆕 NUEVAS FUNCIONALIDADES DE MODERNIZACIÓN - MERCADOS -->
      <div class="card border-0 shadow-sm mb-5">
        <div class="card-body p-5">
          <div class="d-flex align-items-center mb-4">
            <h3 class="h4 fw-bold text-warning mb-0 me-3">🆕 Modernización del Módulo Mercados</h3>
            <span class="badge bg-warning text-dark">RECIÉN AGREGADAS</span>
          </div>

          <!-- Nuevos Componentes -->
          <div class="row g-3 mb-4">
            <div class="col-md-6">
              <router-link
                to="/mercados/sistemaconveniosmercados"
                class="d-flex flex-column align-items-center p-4 bg-success bg-opacity-10 rounded-3 text-decoration-none hover-bg-success-subtle transition position-relative"
              >
                <span class="badge bg-success position-absolute top-0 end-0 translate-middle">NUEVO</span>
                <div class="bg-success bg-opacity-25 rounded-3 p-3 mb-3">
                  <i class="fas fa-store fa-2x text-success"></i>
                </div>
                <div class="text-center">
                  <h4 class="fw-medium text-dark mb-1">Sistema Convenios Integral</h4>
                  <p class="text-muted small mb-0">ABC completo: Intereses, Convenios,</p>
                  <p class="text-muted small mb-0">Parcialidades, Pagos y Reportes</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-6">
              <router-link
                to="/mercados/funcionesexcluidas"
                class="d-flex flex-column align-items-center p-4 bg-danger bg-opacity-10 rounded-3 text-decoration-none hover-bg-danger-subtle transition position-relative"
              >
                <span class="badge bg-danger position-absolute top-0 end-0 translate-middle">EXCLUSIONES</span>
                <div class="bg-danger bg-opacity-25 rounded-3 p-3 mb-3">
                  <i class="fas fa-times-circle fa-2x text-danger"></i>
                </div>
                <div class="text-center">
                  <h4 class="fw-medium text-dark mb-1">Funciones Excluidas</h4>
                  <p class="text-muted small mb-0">10 funciones obsoletas</p>
                  <p class="text-muted small mb-0">identificadas para remoción</p>
                </div>
              </router-link>
            </div>
          </div>

          <!-- Resumen de Cambios -->
          <div class="row g-3">
            <div class="col-md-4">
              <div class="card border-success">
                <div class="card-body text-center">
                  <h4 class="text-success">1</h4>
                  <p class="mb-0 small">Sistema Nuevo</p>
                </div>
              </div>
            </div>
            <div class="col-md-4">
              <div class="card border-danger">
                <div class="card-body text-center">
                  <h4 class="text-danger">10</h4>
                  <p class="mb-0 small">Funciones Excluidas</p>
                </div>
              </div>
            </div>
            <div class="col-md-4">
              <div class="card border-warning">
                <div class="card-body text-center">
                  <h4 class="text-warning">7</h4>
                  <p class="mb-0 small">Módulos Nuevos</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Acciones Rápidas Existentes -->
      <div class="card border-0 shadow-sm">
        <div class="card-body p-5">
          <h3 class="h4 fw-bold text-dark mb-4">Acciones Rápidas Existentes</h3>
          <div class="row g-3">
            <div class="col-md-4">
              <router-link 
                to="/mercados/locales" 
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-store text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Administrar Locales</h4>
                  <p class="text-muted small mb-0">Gestión de espacios</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-4">
              <router-link 
                to="/mercados/arrendatarios" 
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-users text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Arrendatarios</h4>
                  <p class="text-muted small mb-0">Control de inquilinos</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-4">
              <router-link 
                to="/mercados/facturacion" 
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-file-invoice text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Facturación</h4>
                  <p class="text-muted small mb-0">Sistema de cobros</p>
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
  name: 'MercadosInfo',
  data() {
    return {
      // Datos específicos del módulo de mercados
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