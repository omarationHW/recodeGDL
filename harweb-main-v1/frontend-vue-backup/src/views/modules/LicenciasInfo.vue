<template>
  <div class="min-vh-100 bg-light">
    <!-- Header del Módulo -->
    <div class="bg-white shadow-sm border-bottom">
      <div class="container-fluid py-5">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-secondary bg-gradient rounded-3 d-flex align-items-center justify-content-center shadow me-4" style="width: 64px; height: 64px;">
              <i class="fas fa-file-contract fa-2x text-white"></i>
            </div>
            <div>
              <h1 class="display-5 fw-bold text-dark mb-2">Módulo Licencias</h1>
              <p class="fs-5 text-muted">Sistema de Gestión de Licencias Comerciales y Permisos</p>
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
                  <p class="h2 fw-bold text-success mb-0">101</p>
                  <p class="small text-success fw-bold mb-0">+4 NUEVOS</p>
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
                  <p class="h2 fw-bold text-secondary mb-0">4</p>
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
                  <p class="h2 fw-bold text-secondary mb-0">5</p>
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
            El <strong>Módulo de Licencias</strong> es un sistema integral diseñado para la gestión completa 
            de licencias comerciales, anuncios publicitarios y permisos municipales. Este módulo permite 
            la tramitación eficiente de solicitudes, seguimiento de procesos y consultas administrativas.
          </p>
          <p class="text-muted fs-6 lh-lg">
            Migrado completamente de Delphi a una arquitectura moderna con Laravel + Vue.js + PostgreSQL, 
            ofrece una interfaz intuitiva y procesos automatizados para optimizar la gestión municipal.
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
                    <h4 class="fw-medium text-dark mb-1">Gestión de Licencias Comerciales</h4>
                    <p class="text-muted small mb-0">Administración completa del ciclo de vida de licencias</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Control de Anuncios Publicitarios</h4>
                    <p class="text-muted small mb-0">Regulación y seguimiento de publicidad comercial</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Tramitación Digital</h4>
                    <p class="text-muted small mb-0">Procesos automatizados y seguimiento en línea</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Consultas Administrativas</h4>
                    <p class="text-muted small mb-0">Sistema de consultas y reportes especializados</p>
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

      <!-- 🆕 NUEVAS FUNCIONALIDADES DE MODERNIZACIÓN -->
      <div class="card border-0 shadow-sm mb-5">
        <div class="card-body p-5">
          <div class="d-flex align-items-center mb-4">
            <h3 class="h4 fw-bold text-success mb-0 me-3">🆕 Nuevas Funcionalidades de Modernización</h3>
            <span class="badge bg-success">RECIÉN AGREGADAS</span>
          </div>
          <div class="row g-3">
            <div class="col-md-6 col-lg-3">
              <router-link
                to="/licencias/perfilesusuariomoderno"
                class="d-flex flex-column align-items-center p-4 bg-primary bg-opacity-10 rounded-3 text-decoration-none hover-bg-primary-subtle transition position-relative"
              >
                <span class="badge bg-primary position-absolute top-0 end-0 translate-middle">NUEVO</span>
                <div class="bg-primary bg-opacity-25 rounded-3 p-3 mb-3">
                  <i class="fas fa-users-cog fa-2x text-primary"></i>
                </div>
                <div class="text-center">
                  <h4 class="fw-medium text-dark mb-1">Perfiles de Usuario</h4>
                  <p class="text-muted small mb-0">Separación granular</p>
                  <p class="text-muted small mb-0">(Padrón/Licencias/Ingresos)</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-6 col-lg-3">
              <router-link
                to="/licencias/catalogogirosimportes"
                class="d-flex flex-column align-items-center p-4 bg-warning bg-opacity-10 rounded-3 text-decoration-none hover-bg-warning-subtle transition position-relative"
              >
                <span class="badge bg-warning position-absolute top-0 end-0 translate-middle">NUEVO</span>
                <div class="bg-warning bg-opacity-25 rounded-3 p-3 mb-3">
                  <i class="fas fa-money-check-alt fa-2x text-warning"></i>
                </div>
                <div class="text-center">
                  <h4 class="fw-medium text-dark mb-1">Giros con Importes</h4>
                  <p class="text-muted small mb-0">Gestión de costos</p>
                  <p class="text-muted small mb-0">para usuarios ingresos</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-6 col-lg-3">
              <router-link
                to="/licencias/permisosprovisionales"
                class="d-flex flex-column align-items-center p-4 bg-info bg-opacity-10 rounded-3 text-decoration-none hover-bg-info-subtle transition position-relative"
              >
                <span class="badge bg-info position-absolute top-0 end-0 translate-middle">NUEVO</span>
                <div class="bg-info bg-opacity-25 rounded-3 p-3 mb-3">
                  <i class="fas fa-clock fa-2x text-info"></i>
                </div>
                <div class="text-center">
                  <h4 class="fw-medium text-dark mb-1">Permisos Temporales</h4>
                  <p class="text-muted small mb-0">Espectáculos, Licencias</p>
                  <p class="text-muted small mb-0">y Anuncios</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-6 col-lg-3">
              <router-link
                to="/licencias/sistemaconvenios"
                class="d-flex flex-column align-items-center p-4 bg-success bg-opacity-10 rounded-3 text-decoration-none hover-bg-success-subtle transition position-relative"
              >
                <span class="badge bg-success position-absolute top-0 end-0 translate-middle">NUEVO</span>
                <div class="bg-success bg-opacity-25 rounded-3 p-3 mb-3">
                  <i class="fas fa-handshake fa-2x text-success"></i>
                </div>
                <div class="text-center">
                  <h4 class="fw-medium text-dark mb-1">Sistema Convenios</h4>
                  <p class="text-muted small mb-0">ABC completo:</p>
                  <p class="text-muted small mb-0">Intereses y Parcialidades</p>
                </div>
              </router-link>
            </div>
          </div>

          <!-- Componente Modificado -->
          <div class="mt-4 pt-4 border-top">
            <div class="d-flex align-items-center mb-3">
              <h5 class="fw-bold text-primary mb-0 me-3">🔄 Componente Modernizado</h5>
              <span class="badge bg-primary">ACTUALIZADO</span>
            </div>
            <div class="row g-3">
              <div class="col-md-6 col-lg-4">
                <router-link
                  to="/licencias/empresasfrm"
                  class="d-flex align-items-center p-3 bg-primary bg-opacity-10 rounded-3 text-decoration-none hover-bg-primary-subtle transition position-relative"
                >
                  <span class="badge bg-primary position-absolute top-0 end-0 translate-middle">CAMPO GÉNERO</span>
                  <div class="bg-primary bg-opacity-25 rounded-3 p-2 me-3">
                    <i class="fas fa-building text-primary"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Empresas</h4>
                    <p class="text-muted small mb-0">Ahora con campo Género</p>
                    <p class="text-muted small mb-0">(Mujer/Hombre/Sociedad)</p>
                  </div>
                </router-link>
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
                to="/licencias/agendavisitasfrm" 
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-calendar text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Agenda de Visitas</h4>
                  <p class="text-muted small mb-0">Programar inspecciones</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-4">
              <router-link 
                to="/licencias/busque" 
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-search text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Búsqueda General</h4>
                  <p class="text-muted small mb-0">Consultar licencias</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-4">
              <router-link 
                to="/licencias/nuevalicencia" 
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-plus text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Nueva Licencia</h4>
                  <p class="text-muted small mb-0">Crear solicitud</p>
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
  name: 'LicenciasInfo',
  data() {
    return {
      // Datos específicos del módulo de licencias
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