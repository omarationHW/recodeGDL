<template>
  <div class="min-vh-100 bg-light">
    <!-- Header del Módulo -->
    <div class="bg-white shadow-sm border-bottom">
      <div class="container-fluid py-5">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-secondary bg-gradient rounded-3 d-flex align-items-center justify-content-center shadow me-4" style="width: 64px; height: 64px;">
              <i class="fas fa-trash fa-2x text-white"></i>
            </div>
            <div>
              <h1 class="display-5 fw-bold text-dark mb-2">Módulo Aseo</h1>
              <p class="fs-5 text-muted">Sistema de Gestión de Servicios de Aseo Urbano</p>
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
                  <p class="h2 fw-bold text-secondary mb-0">107</p>
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
                  <p class="h2 fw-bold text-secondary mb-0">11</p>
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
            El <strong>Módulo de Aseo</strong> es un sistema especializado para la gestión integral de servicios 
            de aseo urbano y recolección de residuos. Permite la administración de empresas recolectoras, 
            control de contratos de servicios, gestión de adeudos y cálculo de recargos operativos.
          </p>
          <p class="text-muted fs-6 lh-lg">
            Migrado completamente de Delphi a arquitectura moderna con Laravel + Vue.js + PostgreSQL, 
            ofrece herramientas avanzadas para la optimización de servicios públicos municipales.
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
                    <h4 class="fw-medium text-dark mb-1">Gestión de Empresas</h4>
                    <p class="text-muted small mb-0">Administración de empresas recolectoras y proveedores</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Control de Contratos</h4>
                    <p class="text-muted small mb-0">Manejo de contratos de servicios y obligaciones</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Gestión de Adeudos</h4>
                    <p class="text-muted small mb-0">Control de pagos y recuperación de cartera</p>
                  </div>
                </div>
                <div class="d-flex align-items-start">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3 mt-1">
                    <i class="fas fa-check text-secondary small"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Recargos y Gastos</h4>
                    <p class="text-muted small mb-0">Cálculo automático de recargos operativos</p>
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
                    <h4 class="fw-medium text-dark mb-1">Consulta de Empresas</h4>
                    <p class="text-muted small mb-0">Búsqueda avanzada por nombre o número</p>
                  </div>
                </div>
                
                <div class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3">
                  <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                    <i class="fas fa-calendar text-secondary"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Control de Pagos</h4>
                    <p class="text-muted small mb-0">Gestión de pagos múltiples y parciales</p>
                  </div>
                </div>
                
                <div class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3">
                  <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                    <i class="fas fa-chart-bar text-secondary"></i>
                  </div>
                  <div>
                    <h4 class="fw-medium text-dark mb-1">Reportes Estadísticos</h4>
                    <p class="text-muted small mb-0">Informes de gestión y estadísticas</p>
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
                <h4 class="fw-medium text-dark mb-2">ABC Empresas</h4>
                <p class="text-muted small mb-0">Gestión integral de empresas recolectoras</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Contratos</h4>
                <p class="text-muted small mb-0">Administración de contratos de servicio</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Adeudos</h4>
                <p class="text-muted small mb-0">Control de adeudos y cartera vencida</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Gastos Operativos</h4>
                <p class="text-muted small mb-0">Registro y control de gastos</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Tipos de Aseo</h4>
                <p class="text-muted small mb-0">Catálogo de tipos de servicio</p>
              </div>
            </div>
            <div class="col-md-6 col-lg-4">
              <div class="p-3 bg-secondary bg-opacity-10 rounded-3 border border-secondary border-opacity-25">
                <h4 class="fw-medium text-dark mb-2">Zonas de Servicio</h4>
                <p class="text-muted small mb-0">Gestión de zonas geográficas</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Arquitectura Técnica -->
      <div class="row g-4 mb-5">
        <div class="col-lg-12">
          <div class="card border-0 shadow-sm h-100">
            <div class="card-body p-5">
              <h3 class="h4 fw-bold text-dark mb-4">Arquitectura Técnica</h3>
              <div class="row g-3">
                <div class="col-md-4">
                  <div class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3">
                    <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                      <i class="fas fa-desktop text-secondary"></i>
                    </div>
                    <div>
                      <h4 class="fw-medium text-dark mb-1">Frontend</h4>
                      <p class="text-muted small mb-0">Vue.js 3 con interfaz SPA moderna</p>
                    </div>
                  </div>
                </div>
                
                <div class="col-md-4">
                  <div class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3">
                    <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                      <i class="fas fa-server text-secondary"></i>
                    </div>
                    <div>
                      <h4 class="fw-medium text-dark mb-1">Backend</h4>
                      <p class="text-muted small mb-0">Laravel API con endpoint unificado</p>
                    </div>
                  </div>
                </div>
                
                <div class="col-md-4">
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
      </div>

      <!-- 🆕 MODERNIZACIÓN DEL MÓDULO -->
      <div class="card border-0 shadow-sm mb-5" style="border-left: 5px solid #6c757d !important;">
        <div class="card-body p-5">
          <div class="d-flex align-items-center mb-4">
            <div class="bg-secondary bg-opacity-10 rounded-3 p-3 me-3">
              <i class="fas fa-rocket fa-lg text-secondary"></i>
            </div>
            <div>
              <h3 class="h4 fw-bold text-dark mb-1">🚀 Modernización del Módulo</h3>
              <p class="text-muted small mb-0">Nuevas funcionalidades implementadas</p>
            </div>
            <div class="ms-auto">
              <span class="badge bg-secondary fs-6">+4 NUEVOS</span>
            </div>
          </div>

          <div class="row g-4">
            <div class="col-lg-3">
              <div class="card border border-secondary border-opacity-25 h-100">
                <div class="card-body p-4">
                  <div class="d-flex align-items-center mb-3">
                    <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3">
                      <i class="fas fa-handshake text-secondary"></i>
                    </div>
                    <div>
                      <h4 class="fw-bold text-dark mb-1">Sistema de Convenios</h4>
                      <span class="badge bg-danger small">NUEVO</span>
                    </div>
                  </div>
                  <p class="text-muted small mb-3">Sistema completo de convenios de pago con gestión integral por zona de servicio.</p>
                  <div class="d-flex align-items-center">
                    <router-link
                      to="/aseo/SistemaConveniosAseo"
                      class="btn btn-secondary btn-sm"
                    >
                      <i class="fas fa-external-link-alt me-2"></i>Acceder
                    </router-link>
                  </div>
                </div>
              </div>
            </div>

            <div class="col-lg-3">
              <div class="card border border-secondary border-opacity-25 h-100">
                <div class="card-body p-4">
                  <div class="d-flex align-items-center mb-3">
                    <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3">
                      <i class="fas fa-gavel text-secondary"></i>
                    </div>
                    <div>
                      <h4 class="fw-bold text-dark mb-1">Sistema de Apremios</h4>
                      <span class="badge bg-danger small">NUEVO</span>
                    </div>
                  </div>
                  <p class="text-muted small mb-3">Gestión integral de procedimientos de cobranza especializada en servicios de aseo.</p>
                  <div class="d-flex align-items-center">
                    <router-link
                      to="/aseo/SistemaApremiosAseo"
                      class="btn btn-secondary btn-sm"
                    >
                      <i class="fas fa-external-link-alt me-2"></i>Acceder
                    </router-link>
                  </div>
                </div>
              </div>
            </div>

            <div class="col-lg-3">
              <div class="card border border-secondary border-opacity-25 h-100">
                <div class="card-body p-4">
                  <div class="d-flex align-items-center mb-3">
                    <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3">
                      <i class="fas fa-percentage text-secondary"></i>
                    </div>
                    <div>
                      <h4 class="fw-bold text-dark mb-1">Descuentos y Conversión</h4>
                      <span class="badge bg-danger small">NUEVO</span>
                    </div>
                  </div>
                  <p class="text-muted small mb-3">Sistema automatizado de descuentos y conversión específico para aseo urbano.</p>
                  <div class="d-flex align-items-center">
                    <router-link
                      to="/aseo/SistemaDescuentosAseo"
                      class="btn btn-secondary btn-sm"
                    >
                      <i class="fas fa-external-link-alt me-2"></i>Acceder
                    </router-link>
                  </div>
                </div>
              </div>
            </div>

            <div class="col-lg-3">
              <div class="card border border-secondary border-opacity-25 h-100">
                <div class="card-body p-4">
                  <div class="d-flex align-items-center mb-3">
                    <div class="bg-secondary bg-opacity-10 rounded-3 p-2 me-3">
                      <i class="fas fa-ban text-secondary"></i>
                    </div>
                    <div>
                      <h4 class="fw-bold text-dark mb-1">Funciones Excluidas</h4>
                      <span class="badge bg-danger small">NUEVO</span>
                    </div>
                  </div>
                  <p class="text-muted small mb-3">Documentación completa de funciones obsoletas removidas y sus reemplazos.</p>
                  <div class="d-flex align-items-center">
                    <router-link
                      to="/aseo/FuncionesExcluidasAseo"
                      class="btn btn-secondary btn-sm"
                    >
                      <i class="fas fa-external-link-alt me-2"></i>Acceder
                    </router-link>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Características de la Modernización -->
          <div class="mt-4 p-4 bg-secondary bg-opacity-10 rounded-3">
            <h5 class="fw-bold text-secondary mb-3">
              <i class="fas fa-star me-2"></i>Características de la Modernización
            </h5>
            <div class="row g-3">
              <div class="col-md-6">
                <div class="d-flex align-items-center">
                  <i class="fas fa-recycle text-secondary me-2"></i>
                  <span class="small">Especialización en servicios de aseo</span>
                </div>
              </div>
              <div class="col-md-6">
                <div class="d-flex align-items-center">
                  <i class="fas fa-map-marker-alt text-secondary me-2"></i>
                  <span class="small">Gestión por zona de recolección</span>
                </div>
              </div>
              <div class="col-md-6">
                <div class="d-flex align-items-center">
                  <i class="fas fa-trash text-secondary me-2"></i>
                  <span class="small">Eliminación de funciones obsoletas</span>
                </div>
              </div>
              <div class="col-md-6">
                <div class="d-flex align-items-center">
                  <i class="fas fa-sync-alt text-secondary me-2"></i>
                  <span class="small">Conversión automática de procedimientos</span>
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
                to="/aseo/abc_empresas" 
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-building text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Gestión Empresas</h4>
                  <p class="text-muted small mb-0">Administrar empresas</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-4">
              <router-link 
                to="/aseo/contratos" 
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-file-contract text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Control Contratos</h4>
                  <p class="text-muted small mb-0">Gestionar contratos</p>
                </div>
              </router-link>
            </div>

            <div class="col-md-4">
              <router-link 
                to="/aseo/adeudos" 
                class="d-flex align-items-center p-3 bg-secondary bg-opacity-10 rounded-3 text-decoration-none hover-bg-secondary-subtle transition"
              >
                <div class="bg-secondary bg-opacity-25 rounded-3 p-2 me-3">
                  <i class="fas fa-money-bill text-secondary"></i>
                </div>
                <div>
                  <h4 class="fw-medium text-dark mb-1">Gestión Adeudos</h4>
                  <p class="text-muted small mb-0">Control de pagos</p>
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
  name: 'AseoInfo',
  data() {
    return {
      // Datos específicos del módulo de aseo
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