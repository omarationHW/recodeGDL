<template>
  <div class="min-vh-100 bg-light">
    <!-- Header del Dashboard -->
    <div class="bg-white shadow-sm border-bottom">
      <div class="container-fluid py-5">
        <div class="text-center">
          <h1 class="display-4 fw-bold text-dark mb-3">
            <i class="fas fa-rocket me-3 text-primary"></i>RefactorX
          </h1>
          <p class="fs-4 text-muted mb-4">
            Sistema de Gestión Municipal
          </p>
          <div class="d-inline-flex align-items-center px-4 py-2 rounded-pill bg-success bg-opacity-10 text-success">
            <i class="fas fa-circle me-2 text-success" style="font-size: 8px;"></i>
            <span class="small fw-medium">Sistema Operativo</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Estadísticas Generales -->
    <div class="container-fluid py-5">
      <div class="row g-4 mb-5">
        <div class="col-lg-3 col-md-6">
          <div class="card border-0 shadow-sm h-100">
            <div class="card-body p-4">
              <div class="d-flex align-items-center">
                <div class="flex-shrink-0">
                  <div class="bg-primary bg-opacity-10 rounded p-3">
                    <i class="fas fa-cubes fa-lg text-primary"></i>
                  </div>
                </div>
                <div class="ms-3">
                  <p class="small fw-medium text-muted mb-1">Total Módulos</p>
                  <p class="h2 fw-bold text-dark mb-0">{{ totalModules }}</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-lg-3 col-md-6">
          <div class="card border-0 shadow-sm h-100">
            <div class="card-body p-4">
              <div class="d-flex align-items-center">
                <div class="flex-shrink-0">
                  <div class="bg-success bg-opacity-10 rounded p-3">
                    <i class="fas fa-check-circle fa-lg text-success"></i>
                  </div>
                </div>
                <div class="ms-3">
                  <p class="small fw-medium text-muted mb-1">Componentes Totales</p>
                  <p class="h2 fw-bold text-dark mb-0">736</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-lg-3 col-md-6">
          <div class="card border-0 shadow-sm h-100">
            <div class="card-body p-4">
              <div class="d-flex align-items-center">
                <div class="flex-shrink-0">
                  <div class="bg-info bg-opacity-10 rounded p-3">
                    <i class="fas fa-code-branch fa-lg text-info"></i>
                  </div>
                </div>
                <div class="ms-3">
                  <p class="small fw-medium text-muted mb-1">Versión</p>
                  <p class="h2 fw-bold text-dark mb-0">2.0.0</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-lg-3 col-md-6">
          <div class="card border-0 shadow-sm h-100">
            <div class="card-body p-4">
              <div class="d-flex align-items-center">
                <div class="flex-shrink-0">
                  <div class="bg-warning bg-opacity-10 rounded p-3">
                    <i class="fas fa-shield-alt fa-lg text-warning"></i>
                  </div>
                </div>
                <div class="ms-3">
                  <p class="small fw-medium text-muted mb-1">Estado</p>
                  <p class="h5 fw-bold text-success mb-0">Activo</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Cards de Módulos -->
      <div class="mb-5">
        <h2 class="h3 fw-bold text-dark mb-4">
          <i class="fas fa-th-large me-2"></i>Módulos del Sistema
        </h2>
        <div class="row g-4">
          <!-- Card Licencias -->
          <div class="col-xl-4 col-md-6">
            <div class="card border-0 shadow-sm h-100 position-relative">
              <div class="position-absolute top-0 end-0 translate-middle">
                <span class="badge bg-secondary rounded-pill">97</span>
              </div>
              <div class="card-body p-4">
                <div class="d-flex align-items-center mb-3">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-3 me-3">
                    <i class="fas fa-file-contract fa-2x text-secondary"></i>
                  </div>
                  <div>
                    <h4 class="fw-bold text-dark mb-1">Licencias</h4>
                    <p class="text-muted small mb-0">Permisos y trámites</p>
                  </div>
                </div>
                <p class="text-muted mb-4">
                  Sistema completo de gestión de licencias comerciales, anuncios publicitarios, 
                  tramitación y consultas administrativas.
                </p>
                <div class="d-flex justify-content-between align-items-center mb-3">
                  <span class="small text-muted">97 Componentes</span>
                  <span class="badge bg-success bg-opacity-10 text-success">
                    <i class="fas fa-circle me-1" style="font-size: 6px;"></i>Activo
                  </span>
                </div>
                <div class="d-flex gap-2">
                  <router-link 
                    to="/info/licencias" 
                    class="btn btn-outline-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-info-circle me-1"></i>Info
                  </router-link>
                  <router-link 
                    to="/licencias/empleadoslistado" 
                    class="btn btn-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-sign-in-alt me-1"></i>Acceder
                  </router-link>
                </div>
              </div>
            </div>
          </div>

          <!-- Card Aseo -->
          <div class="col-xl-4 col-md-6">
            <div class="card border-0 shadow-sm h-100 position-relative">
              <div class="position-absolute top-0 end-0 translate-middle">
                <span class="badge bg-secondary rounded-pill">103</span>
              </div>
              <div class="card-body p-4">
                <div class="d-flex align-items-center mb-3">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-3 me-3">
                    <i class="fas fa-broom fa-2x text-secondary"></i>
                  </div>
                  <div>
                    <h4 class="fw-bold text-dark mb-1">Aseo</h4>
                    <p class="text-muted small mb-0">Servicios públicos</p>
                  </div>
                </div>
                <p class="text-muted mb-4">
                  Gestión de servicios de aseo urbano, empresas recolectoras, 
                  gastos operativos y recargos del sistema.
                </p>
                <div class="d-flex justify-content-between align-items-center mb-3">
                  <span class="small text-muted">103 Componentes</span>
                  <span class="badge bg-success bg-opacity-10 text-success">
                    <i class="fas fa-circle me-1" style="font-size: 6px;"></i>Activo
                  </span>
                </div>
                <div class="d-flex gap-2">
                  <router-link 
                    to="/info/aseo" 
                    class="btn btn-outline-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-info-circle me-1"></i>Info
                  </router-link>
                  <router-link 
                    to="/aseo/abc_empresas" 
                    class="btn btn-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-sign-in-alt me-1"></i>Acceder
                  </router-link>
                </div>
              </div>
            </div>
          </div>

          <!-- Card Apremios -->
          <div class="col-xl-4 col-md-6">
            <div class="card border-0 shadow-sm h-100 position-relative">
              <div class="position-absolute top-0 end-0 translate-middle">
                <span class="badge bg-secondary rounded-pill">61</span>
              </div>
              <div class="card-body p-4">
                <div class="d-flex align-items-center mb-3">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-3 me-3">
                    <i class="fas fa-exclamation-triangle fa-2x text-secondary"></i>
                  </div>
                  <div>
                    <h4 class="fw-bold text-dark mb-1">Apremios</h4>
                    <p class="text-muted small mb-0">Cobranza coactiva</p>
                  </div>
                </div>
                <p class="text-muted mb-4">
                  Sistema de apremios y cobranza coactiva, gestión de ejecutores, 
                  facturación electrónica y procedimientos legales.
                </p>
                <div class="d-flex justify-content-between align-items-center mb-3">
                  <span class="small text-muted">61 Componentes</span>
                  <span class="badge bg-success bg-opacity-10 text-success">
                    <i class="fas fa-circle me-1" style="font-size: 6px;"></i>Activo
                  </span>
                </div>
                <div class="d-flex gap-2">
                  <router-link 
                    to="/info/apremios" 
                    class="btn btn-outline-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-info-circle me-1"></i>Info
                  </router-link>
                  <router-link 
                    to="/apremiossvn/acceso" 
                    class="btn btn-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-sign-in-alt me-1"></i>Acceder
                  </router-link>
                </div>
              </div>
            </div>
          </div>

          <!-- Card Cementerios -->
          <div class="col-xl-4 col-md-6">
            <div class="card border-0 shadow-sm h-100 position-relative">
              <div class="position-absolute top-0 end-0 translate-middle">
                <span class="badge bg-secondary rounded-pill">36</span>
              </div>
              <div class="card-body p-4">
                <div class="d-flex align-items-center mb-3">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-3 me-3">
                    <i class="fas fa-cross fa-2x text-secondary"></i>
                  </div>
                  <div>
                    <h4 class="fw-bold text-dark mb-1">Cementerios</h4>
                    <p class="text-muted small mb-0">Servicios funerarios</p>
                  </div>
                </div>
                <p class="text-muted mb-4">
                  Administración de cementerios municipales, gestión de folios 
                  y control de servicios funerarios públicos.
                </p>
                <div class="d-flex justify-content-between align-items-center mb-3">
                  <span class="small text-muted">36 Componentes</span>
                  <span class="badge bg-success bg-opacity-10 text-success">
                    <i class="fas fa-circle me-1" style="font-size: 6px;"></i>Activo
                  </span>
                </div>
                <div class="d-flex gap-2">
                  <router-link 
                    to="/info/cementerios" 
                    class="btn btn-outline-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-info-circle me-1"></i>Info
                  </router-link>
                  <router-link 
                    to="/cementerios/abcementer" 
                    class="btn btn-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-sign-in-alt me-1"></i>Acceder
                  </router-link>
                </div>
              </div>
            </div>
          </div>

          <!-- Card Convenios -->
          <div class="col-xl-4 col-md-6">
            <div class="card border-0 shadow-sm h-100 position-relative">
              <div class="position-absolute top-0 end-0 translate-middle">
                <span class="badge bg-secondary rounded-pill">94</span>
              </div>
              <div class="card-body p-4">
                <div class="d-flex align-items-center mb-3">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-3 me-3">
                    <i class="fas fa-handshake fa-2x text-secondary"></i>
                  </div>
                  <div>
                    <h4 class="fw-bold text-dark mb-1">Convenios</h4>
                    <p class="text-muted small mb-0">Acuerdos de pago</p>
                  </div>
                </div>
                <p class="text-muted mb-4">
                  Gestión de convenios de pago, actualización de contratos, 
                  cálculo de recargos y administración de adeudos.
                </p>
                <div class="d-flex justify-content-between align-items-center mb-3">
                  <span class="small text-muted">94 Componentes</span>
                  <span class="badge bg-success bg-opacity-10 text-success">
                    <i class="fas fa-circle me-1" style="font-size: 6px;"></i>Activo
                  </span>
                </div>
                <div class="d-flex gap-2">
                  <router-link 
                    to="/info/convenios" 
                    class="btn btn-outline-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-info-circle me-1"></i>Info
                  </router-link>
                  <router-link 
                    to="/convenios/acceso" 
                    class="btn btn-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-sign-in-alt me-1"></i>Acceder
                  </router-link>
                </div>
              </div>
            </div>
          </div>

          <!-- Card Estacionamientos -->
          <div class="col-xl-4 col-md-6">
            <div class="card border-0 shadow-sm h-100 position-relative">
              <div class="position-absolute top-0 end-0 translate-middle">
                <span class="badge bg-secondary rounded-pill">61</span>
              </div>
              <div class="card-body p-4">
                <div class="d-flex align-items-center mb-3">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-3 me-3">
                    <i class="fas fa-car fa-2x text-secondary"></i>
                  </div>
                  <div>
                    <h4 class="fw-bold text-dark mb-1">Estacionamientos</h4>
                    <p class="text-muted small mb-0">Control vehicular</p>
                  </div>
                </div>
                <p class="text-muted mb-4">
                  Gestión integral de estacionamientos públicos, control de acceso, 
                  pagos electrónicos y administración de folios.
                </p>
                <div class="d-flex justify-content-between align-items-center mb-3">
                  <span class="small text-muted">61 Componentes</span>
                  <span class="badge bg-success bg-opacity-10 text-success">
                    <i class="fas fa-circle me-1" style="font-size: 6px;"></i>Activo
                  </span>
                </div>
                <div class="d-flex gap-2">
                  <router-link 
                    to="/info/estacionamientos" 
                    class="btn btn-outline-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-info-circle me-1"></i>Info
                  </router-link>
                  <router-link 
                    to="/estacionamientos/acceso" 
                    class="btn btn-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-sign-in-alt me-1"></i>Acceder
                  </router-link>
                </div>
              </div>
            </div>
          </div>

          <!-- Card Mercados -->
          <div class="col-xl-4 col-md-6">
            <div class="card border-0 shadow-sm h-100 position-relative">
              <div class="position-absolute top-0 end-0 translate-middle">
                <span class="badge bg-secondary rounded-pill">107</span>
              </div>
              <div class="card-body p-4">
                <div class="d-flex align-items-center mb-3">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-3 me-3">
                    <i class="fas fa-shopping-cart fa-2x text-secondary"></i>
                  </div>
                  <div>
                    <h4 class="fw-bold text-dark mb-1">Mercados</h4>
                    <p class="text-muted small mb-0">Gestión comercial</p>
                  </div>
                </div>
                <p class="text-muted mb-4">
                  Administración de mercados municipales, locales comerciales, 
                  adeudos energéticos y pagos especializados.
                </p>
                <div class="d-flex justify-content-between align-items-center mb-3">
                  <span class="small text-muted">107 Componentes</span>
                  <span class="badge bg-success bg-opacity-10 text-success">
                    <i class="fas fa-circle me-1" style="font-size: 6px;"></i>Activo
                  </span>
                </div>
                <div class="d-flex gap-2">
                  <router-link 
                    to="/info/mercados" 
                    class="btn btn-outline-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-info-circle me-1"></i>Info
                  </router-link>
                  <router-link 
                    to="/mercados/acceso" 
                    class="btn btn-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-sign-in-alt me-1"></i>Acceder
                  </router-link>
                </div>
              </div>
            </div>
          </div>

          <!-- Card Otras Obligaciones -->
          <div class="col-xl-4 col-md-6">
            <div class="card border-0 shadow-sm h-100 position-relative">
              <div class="position-absolute top-0 end-0 translate-middle">
                <span class="badge bg-secondary rounded-pill">3</span>
              </div>
              <div class="card-body p-4">
                <div class="d-flex align-items-center mb-3">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-3 me-3">
                    <i class="fas fa-tasks fa-2x text-secondary"></i>
                  </div>
                  <div>
                    <h4 class="fw-bold text-dark mb-1">Otras Obligaciones</h4>
                    <p class="text-muted small mb-0">Gestión diversa</p>
                  </div>
                </div>
                <p class="text-muted mb-4">
                  Gestión de obligaciones diversas, carga de carteras, 
                  valores, etiquetas y reportes auxiliares especializados.
                </p>
                <div class="d-flex justify-content-between align-items-center mb-3">
                  <span class="small text-muted">3 Componentes</span>
                  <span class="badge bg-success bg-opacity-10 text-success">
                    <i class="fas fa-circle me-1" style="font-size: 6px;"></i>Activo
                  </span>
                </div>
                <div class="d-flex gap-2">
                  <router-link 
                    to="/info/otras-oblig" 
                    class="btn btn-outline-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-info-circle me-1"></i>Info
                  </router-link>
                  <router-link 
                    to="/otras-oblig/apremios" 
                    class="btn btn-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-sign-in-alt me-1"></i>Acceder
                  </router-link>
                </div>
              </div>
            </div>
          </div>

          <!-- Card Recaudadora -->
          <div class="col-xl-4 col-md-6">
            <div class="card border-0 shadow-sm h-100 position-relative">
              <div class="position-absolute top-0 end-0 translate-middle">
                <span class="badge bg-secondary rounded-pill">106</span>
              </div>
              <div class="card-body p-4">
                <div class="d-flex align-items-center mb-3">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-3 me-3">
                    <i class="fas fa-coins fa-2x text-secondary"></i>
                  </div>
                  <div>
                    <h4 class="fw-bold text-dark mb-1">Recaudadora</h4>
                    <p class="text-muted small mb-0">Padrón recaudación</p>
                  </div>
                </div>
                <p class="text-muted mb-4">
                  Módulo de recaudación fiscal, gestión de pagos, descuentos, 
                  multas y administración del padrón contributivo.
                </p>
                <div class="d-flex justify-content-between align-items-center mb-3">
                  <span class="small text-muted">106 Componentes</span>
                  <span class="badge bg-success bg-opacity-10 text-success">
                    <i class="fas fa-circle me-1" style="font-size: 6px;"></i>Activo
                  </span>
                </div>
                <div class="d-flex gap-2">
                  <router-link 
                    to="/info/recaudadora" 
                    class="btn btn-outline-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-info-circle me-1"></i>Info
                  </router-link>
                  <router-link 
                    to="/recaudadora/busque" 
                    class="btn btn-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-sign-in-alt me-1"></i>Acceder
                  </router-link>
                </div>
              </div>
            </div>
          </div>

          <!-- Card Tramite Trunk -->
          <div class="col-xl-4 col-md-6">
            <div class="card border-0 shadow-sm h-100 position-relative">
              <div class="position-absolute top-0 end-0 translate-middle">
                <span class="badge bg-secondary rounded-pill">68</span>
              </div>
              <div class="card-body p-4">
                <div class="d-flex align-items-center mb-3">
                  <div class="bg-secondary bg-opacity-10 rounded-3 p-3 me-3">
                    <i class="fas fa-file-alt fa-2x text-secondary"></i>
                  </div>
                  <div>
                    <h4 class="fw-bold text-dark mb-1">Tramite Trunk</h4>
                    <p class="text-muted small mb-0">Gestión de trámites</p>
                  </div>
                </div>
                <p class="text-muted mb-4">
                  Sistema de tramitación general, gestión documental 
                  y seguimiento de procedimientos administrativos.
                </p>
                <div class="d-flex justify-content-between align-items-center mb-3">
                  <span class="small text-muted">68 Componentes</span>
                  <span class="badge bg-success bg-opacity-10 text-success">
                    <i class="fas fa-circle me-1" style="font-size: 6px;"></i>Activo
                  </span>
                </div>
                <div class="d-flex gap-2">
                  <router-link 
                    to="/info/tramite-trunk" 
                    class="btn btn-outline-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-info-circle me-1"></i>Info
                  </router-link>
                  <router-link 
                    to="/tramite-trunk/busque" 
                    class="btn btn-secondary btn-sm flex-fill"
                  >
                    <i class="fas fa-sign-in-alt me-1"></i>Acceder
                  </router-link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Sección de Pruebas -->
      <div class="mb-5">
        <h2 class="h3 fw-bold text-dark mb-4">
          <i class="fas fa-flask me-2"></i>Pruebas del Sistema
        </h2>
        <div class="card border-0 shadow-sm border-start border-primary border-4">
          <div class="card-body p-4">
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center">
              <div class="mb-3 mb-md-0">
                <h4 class="fw-semibold text-dark mb-2">
                  <i class="fas fa-database me-2 text-primary"></i>Test de Base de Datos PostgreSQL
                </h4>
                <p class="text-muted mb-0">
                  Prueba la conexión real con PostgreSQL, CRUD de usuarios y stored procedures.
                  Incluye simulación para desarrollo.
                </p>
              </div>
              <router-link 
                to="/test/usuarios" 
                class="btn btn-primary d-flex align-items-center"
              >
                <i class="fas fa-database me-2"></i>
                Probar PostgreSQL
              </router-link>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <div class="text-center py-4">
        <div class="text-muted">
          <i class="fas fa-bolt me-1"></i>
          <strong>Powered by generic.studio</strong>
          <i class="fas fa-bolt ms-1"></i>
          <br>
          <small>RefactorX v2.0.0 - Sistema de Gestión Municipal</small>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Dashboard',
  data() {
    return {
      totalModules: 10,
      totalComponents: 736
    }
  }
}
</script>