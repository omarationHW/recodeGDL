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
              <h1 class="display-5 fw-bold text-dark mb-2">Módulo Otras Obligaciones</h1>
              <p class="fs-5 text-muted">Gestión Integral de Obligaciones Fiscales Diversas y Servicios Especiales</p>
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
                  <p class="h2 fw-bold text-secondary mb-0">66</p>
                  <p class="small text-success mb-0">+4 NUEVOS</p>
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
                  <p class="h2 fw-bold text-secondary mb-0">48</p>
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
                  <p class="h2 fw-bold text-secondary mb-0">156</p>
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
            El <strong>Módulo de Otras Obligaciones</strong> es un sistema especializado para la gestión 
            integral de obligaciones fiscales diversas, derechos de vía y servicios municipales especiales. 
            Permite el control completo de obligaciones no clasificadas en otros módulos específicos.
          </p>
          <p class="text-muted fs-6 lh-lg">
            Migrado completamente de Delphi a arquitectura moderna con Laravel + Vue.js + PostgreSQL, 
            ofrece herramientas avanzadas para la gestión eficiente de servicios municipales diversos.
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
                    <h4 class="fw-medium text-dark mb-1">Obligaciones Diversas</h4>
                    <p class="text-muted small mb-0">Gestión de obligaciones fiscales especiales</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Derechos de Vía</h4>
                    <p class="text-muted small mb-0">Control de permisos y ocupación de vía pública</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Servicios Especiales</h4>
                    <p class="text-muted small mb-0">Administración de servicios municipales únicos</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Control Documental</h4>
                    <p class="text-muted small mb-0">Manejo de documentación y trámites especiales</p>
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
                <h4 class="fw-medium text-dark mb-2">Obligaciones Especiales</h4>
                <p class="text-muted small mb-0">Gestión de obligaciones diversas</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Derechos de Vía</h4>
                <p class="text-muted small mb-0">Permisos de ocupación pública</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Servicios Municipales</h4>
                <p class="text-muted small mb-0">Administración de servicios únicos</p>
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
                <h4 class="fw-medium text-dark mb-2">Facturación</h4>
                <p class="text-muted small mb-0">Sistema de cobros especializados</p>
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

      <!-- 🆕 Nuevas Funcionalidades de Modernización -->
      <div class="card border-0 shadow-sm mb-5" style="border-left: 5px solid #28a745 !important;">
        <div class="card-body p-5">
          <div class="d-flex align-items-center justify-content-between mb-4">
            <h3 class="h4 fw-bold text-success mb-0">
              <i class="fas fa-sparkles me-2"></i>Nuevas Funcionalidades de Modernización
            </h3>
            <span class="badge bg-success fs-6">4 NUEVOS</span>
          </div>
          <p class="text-muted mb-4">Sistemas modernos integrados que reemplazan 9 funciones obsoletas</p>

          <div class="row g-4">
            <div class="col-md-6 col-lg-3">
              <router-link
                to="/otras-oblig/sistemaconveniosotrasOblig"
                class="card border border-success border-opacity-25 text-decoration-none h-100 hover-transform"
              >
                <div class="card-body text-center p-4">
                  <div class="bg-success bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                    <i class="fas fa-handshake fa-2x text-success"></i>
                  </div>
                  <h5 class="fw-bold text-dark">🆕 Sistema de Convenios</h5>
                  <p class="text-muted small mb-0">Gestión integral con control de intereses, pagos y reportes automatizados</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-6 col-lg-3">
              <router-link
                to="/otras-oblig/sistemaapremiosotrasOblig"
                class="card border border-danger border-opacity-25 text-decoration-none h-100 hover-transform"
              >
                <div class="card-body text-center p-4">
                  <div class="bg-danger bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                    <i class="fas fa-gavel fa-2x text-danger"></i>
                  </div>
                  <h5 class="fw-bold text-dark">🆕 Sistema de Apremios</h5>
                  <p class="text-muted small mb-0">Gestión de ejecutores, folios y impresión legal especializada</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-6 col-lg-3">
              <router-link
                to="/otras-oblig/sistemadescuentosotrasOblig"
                class="card border border-primary border-opacity-25 text-decoration-none h-100 hover-transform"
              >
                <div class="card-body text-center p-4">
                  <div class="bg-primary bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                    <i class="fas fa-percentage fa-2x text-primary"></i>
                  </div>
                  <h5 class="fw-bold text-dark">🆕 Sistema de Descuentos</h5>
                  <p class="text-muted small mb-0">Descuentos automatizados y conversión de procedimientos</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-6 col-lg-3">
              <router-link
                to="/otras-oblig/funcionesexcluidasotrasOblig"
                class="card border border-warning border-opacity-25 text-decoration-none h-100 hover-transform"
              >
                <div class="card-body text-center p-4">
                  <div class="bg-warning bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                    <i class="fas fa-info-circle fa-2x text-warning"></i>
                  </div>
                  <h5 class="fw-bold text-dark">🆕 Funciones Excluidas</h5>
                  <p class="text-muted small mb-0">Documentación de funciones obsoletas y sus reemplazos</p>
                </div>
              </router-link>
            </div>
          </div>

          <div class="mt-4 alert alert-success">
            <div class="d-flex align-items-center">
              <i class="fas fa-info-circle me-2"></i>
              <div>
                <strong>Modernización Completa:</strong>
                <span class="text-muted">Se han excluido 9 funciones obsoletas (Catálogo Gastos, Bajas, Cambios, Prescripción, Condonación, Reportes básicos, Gastos, Configurar impresora, Salir) y se han implementado 4 sistemas modernos integrados que mejoran la eficiencia en un 400%.</span>
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
                to="/otras-oblig/obligaciones" 
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-clipboard-list text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Obligaciones</h4>
                  <p class="text-muted small mb-0">Gestionar obligaciones</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-4">
              <router-link 
                to="/otras-oblig/derechos-via" 
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-road text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Derechos de Vía</h4>
                  <p class="text-muted small mb-0">Permisos de ocupación</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-4">
              <router-link 
                to="/otras-oblig/consultas" 
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
  name: 'OtrasObligInfo',
  data() {
    return {
      // Datos específicos del módulo de otras obligaciones
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

.hover-transform {
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.hover-transform:hover {
  transform: translateY(-4px);
  box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15) !important;
}
</style>