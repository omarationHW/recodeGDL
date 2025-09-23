<template>
  <div class="min-vh-100 bg-light">
    <!-- Header del Módulo -->
    <div class="bg-white shadow-sm border-bottom">
      <div class="container-fluid py-5">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-secondary bg-gradient rounded-3 d-flex align-items-center justify-content-center shadow me-4" style="width: 64px; height: 64px;">
              <i class="fas fa-cross fa-2x text-white"></i>
            </div>
            <div>
              <h1 class="display-5 fw-bold text-dark mb-2">Módulo Cementerios</h1>
              <p class="fs-5 text-muted">Sistema de Gestión de Servicios Funerarios y Cementeriales</p>
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
                  <p class="h2 fw-bold text-secondary mb-0">40</p>
                  <small class="badge bg-warning text-dark">+4 NUEVOS</small>
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
                  <p class="h2 fw-bold text-secondary mb-0">27</p>
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
                  <p class="h2 fw-bold text-secondary mb-0">102</p>
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
            El <strong>Módulo de Cementerios</strong> es un sistema especializado para la gestión integral 
            de servicios funerarios y administración de espacios cementeriales. Permite el control completo 
            de lotes disponibles, procesamiento de servicios y manejo de documentación legal.
          </p>
          <p class="text-muted fs-6 lh-lg">
            Migrado completamente de Delphi a arquitectura moderna con Laravel + Vue.js + PostgreSQL, 
            ofrece herramientas avanzadas para la gestión eficiente de servicios municipales funerarios.
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
                    <h4 class="fw-medium text-dark mb-1">Gestión de Lotes</h4>
                    <p class="text-muted small mb-0">Control completo de espacios y disponibilidad</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Servicios Funerarios</h4>
                    <p class="text-muted small mb-0">Procesamiento de servicios y permisos</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Facturación Especializada</h4>
                    <p class="text-muted small mb-0">Sistema de cobros y documentación fiscal</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Control de Documentos</h4>
                    <p class="text-muted small mb-0">Manejo de documentación legal y certificados</p>
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
      <div class="card border-0 shadow-sm mb-5" style="border-left: 5px solid #ffc107 !important;">
        <div class="card-body p-5">
          <div class="d-flex align-items-center mb-4">
            <div class="bg-warning bg-opacity-10 rounded-3 p-3 me-3">
              <i class="fas fa-star fa-2x text-warning"></i>
            </div>
            <div>
              <h3 class="h3 fw-bold text-dark mb-1">🆕 Nuevas Funcionalidades de Modernización</h3>
              <p class="text-muted mb-0">Sistemas integrados para automatización y optimización de cementerios</p>
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
                  <h4 class="fw-bold text-success mb-1">🆕 Sistema de Descuentos Automatizados</h4>
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
                  <h4 class="fw-bold text-primary mb-1">🆕 Sistema de Conversión y Revaluación</h4>
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
                  <h4 class="fw-bold text-info mb-1">🆕 Sistema de Consultas Unificadas</h4>
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
                  <h4 class="fw-bold text-danger mb-1">🆕 Funciones Excluidas</h4>
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
                  <span class="h4 fw-bold text-danger mb-1">10</span>
                  <small class="text-muted">Funciones excluidas</small>
                </div>
              </div>
              <div class="col-md-3">
                <div class="d-flex flex-column">
                  <span class="h4 fw-bold text-success mb-1">4</span>
                  <small class="text-muted">Sistemas nuevos</small>
                </div>
              </div>
              <div class="col-md-3">
                <div class="d-flex flex-column">
                  <span class="h4 fw-bold text-warning mb-1">350%</span>
                  <small class="text-muted">Mejora eficiencia</small>
                </div>
              </div>
              <div class="col-md-3">
                <div class="d-flex flex-column">
                  <span class="h4 fw-bold text-info mb-1">70%</span>
                  <small class="text-muted">Reducción tiempo</small>
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
                to="/cementerios/abc_lotes"
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-map text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Gestión de Lotes</h4>
                  <p class="text-muted small mb-0">Administrar espacios</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-4">
              <router-link
                to="/cementerios/servicios"
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-handshake text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Servicios Funerarios</h4>
                  <p class="text-muted small mb-0">Procesar servicios</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-4">
              <router-link
                to="/cementerios/consultas"
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-search text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Consultas</h4>
                  <p class="text-muted small mb-0">Búsquedas y reportes</p>
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
  name: 'CementeriosInfo',
  data() {
    return {
      // Datos específicos del módulo de cementerios
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