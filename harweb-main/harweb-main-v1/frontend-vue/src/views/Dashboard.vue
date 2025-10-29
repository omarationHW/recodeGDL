<template>
  <div class="dashboard-container">
    <!-- Hero Section Simplified -->
    <div class="hero-section">
      <div class="hero-content">

        <h1 class="page-title">Sistema Municipal Digital</h1>
        <p class="page-subtitle">Gobierno de Guadalajara, Jalisco</p>

        <!-- Simple Stats -->
        <div class="stats-row">
          <div class="stat-card" v-for="metric in realTimeMetrics" :key="metric.id">
            <div class="stat-icon">
              <i :class="metric.icon"></i>
            </div>
            <div class="stat-info">
              <div class="stat-value">{{ metric.value }}</div>
              <div class="stat-label">{{ metric.label }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modules Section -->
    <div class="modules-section">
      <div class="section-header">
        <h2 class="section-title">Módulos del Sistema</h2>
        <p class="section-subtitle">Gestión integral de servicios municipales</p>
      </div>

      <div class="modules-grid">
        <div
          class="module-card"
          v-for="module in modules"
          :key="module.id"
          @click="navigateToModule(module)"
        >
          <div class="module-header">
            <div class="module-icon" :class="module.colorClass">
              <i :class="module.icon"></i>
            </div>
            <div class="module-count">{{ module.components }}</div>
          </div>

          <div class="module-content">
            <h3 class="module-title">{{ module.name }}</h3>
            <p class="module-category">{{ module.category }}</p>
            <div class="module-users">{{ module.activeUsers }} usuarios activos</div>
          </div>

          <div class="module-actions">
            <button class="btn-info" @click.stop="showInfo(module)">
              <i class="fas fa-info-circle"></i>
            </button>
            <button class="btn-access" @click.stop="accessModule(module)">
              <i class="fas fa-arrow-right"></i>
            </button>
          </div>
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
      totalComponents: 739,
      activeUsers: 89,

      realTimeMetrics: [
        {
          id: 1,
          icon: 'fas fa-users',
          value: '1,263',
          label: 'Ciudadanos Atendidos'
        },
        {
          id: 2,
          icon: 'fas fa-file-alt',
          value: '468',
          label: 'Trámites Hoy'
        },
        {
          id: 3,
          icon: 'fas fa-coins',
          value: '$2.3M',
          label: 'Recaudación'
        }
      ],

      modules: [
        {
          id: 1,
          name: 'Licencias',
          category: 'Permisos y Trámites',
          description: 'Sistema integral de gestión de licencias comerciales, anuncios publicitarios y tramitación administrativa municipal.',
          icon: 'fas fa-file-contract',
          colorClass: 'module-purple',
          components: 97,
          activeUsers: 24,
          status: 'active',
          infoPath: '/info/licencias',
          accessPath: '/licencias/nuevalicencia'
        },
        {
          id: 2,
          name: 'Aseo Urbano',
          category: 'Servicios Públicos',
          description: 'Gestión de servicios de aseo urbano, empresas recolectoras, gastos operativos y sistema de recargos.',
          icon: 'fas fa-broom',
          colorClass: 'module-green',
          components: 103,
          activeUsers: 18,
          status: 'active',
          infoPath: '/info/aseo',
          accessPath: '/aseo/SistemaConveniosAseo'
        },
        {
          id: 3,
          name: 'Apremios',
          category: 'Cobranza Coactiva',
          description: 'Sistema de apremios y cobranza coactiva, gestión de ejecutores, facturación electrónica y procedimientos legales.',
          icon: 'fas fa-exclamation-triangle',
          colorClass: 'module-red',
          components: 61,
          activeUsers: 12,
          status: 'active',
          infoPath: '/info/apremios',
          accessPath: '/apremios/SistemaApremiosApremios'
        },
        {
          id: 4,
          name: 'Cementerios',
          category: 'Servicios Funerarios',
          description: 'Administración de cementerios municipales, gestión de folios y control integral de servicios funerarios.',
          icon: 'fas fa-cross',
          colorClass: 'module-gray',
          components: 36,
          activeUsers: 8,
          status: 'active',
          infoPath: '/info/cementerios',
          accessPath: '/cementerios/SistemaConsultasUnificadas'
        },
        {
          id: 5,
          name: 'Convenios',
          category: 'Acuerdos de Pago',
          description: 'Gestión de convenios de pago, actualización de contratos, cálculo de recargos y administración de adeudos.',
          icon: 'fas fa-handshake',
          colorClass: 'module-pink',
          components: 94,
          activeUsers: 16,
          status: 'active',
          infoPath: '/info/convenios',
          accessPath: '/licencias/sistemaconvenios'
        },
        {
          id: 6,
          name: 'Estacionamientos',
          category: 'Control Vehicular',
          description: 'Gestión integral de estacionamientos públicos, control de acceso, pagos electrónicos y administración de folios.',
          icon: 'fas fa-car-side',
          colorClass: 'module-blue',
          components: 61,
          activeUsers: 22,
          status: 'active',
          infoPath: '/info/estacionamientos',
          accessPath: '/estacionamientos/SistemaApremiosEstacionamientos'
        },
        {
          id: 7,
          name: 'Mercados',
          category: 'Gestión Comercial',
          description: 'Administración de mercados municipales, locales comerciales, adeudos energéticos y pagos especializados.',
          icon: 'fas fa-store-alt',
          colorClass: 'module-orange',
          components: 107,
          activeUsers: 31,
          status: 'active',
          infoPath: '/info/mercados',
          accessPath: '/mercados/SistemaConveniosMercados'
        },
        {
          id: 8,
          name: 'Otras Obligaciones',
          category: 'Gestión Diversa',
          description: 'Gestión de obligaciones diversas, carga de carteras, valores, etiquetas y reportes auxiliares especializados.',
          icon: 'fas fa-tasks',
          colorClass: 'module-gold',
          components: 3,
          activeUsers: 4,
          status: 'active',
          infoPath: '/info/otras-oblig',
          accessPath: '/otras-oblig/SistemaApremiosOtrasOblig'
        },
        {
          id: 9,
          name: 'Recaudadora',
          category: 'Padrón Recaudación',
          description: 'Módulo de recaudación fiscal, gestión de pagos, descuentos, multas y administración del padrón contributivo.',
          icon: 'fas fa-coins',
          colorClass: 'module-green',
          components: 106,
          activeUsers: 28,
          status: 'active',
          infoPath: '/info/recaudadora',
          accessPath: '/recaudadora/SistemaApremiosRecaudadora'
        },
        {
          id: 10,
          name: 'Tramite Trunk',
          category: 'Padrón Catastral',
          description: 'Sistema de tramitación general, gestión documental y seguimiento de procedimientos administrativos.',
          icon: 'fas fa-file-invoice',
          colorClass: 'module-purple',
          components: 68,
          activeUsers: 19,
          status: 'active',
          infoPath: '/info/tramite-trunk',
          accessPath: '/tramite-trunk/busque'
        }
      ]
    }
  },
  methods: {
    navigateToModule(module) {
      this.$router.push(module.accessPath);
    },

    showInfo(module) {
      this.$router.push(module.infoPath);
    },

    accessModule(module) {
      this.$router.push(module.accessPath);
    }
  }
}
</script>

<style scoped>
/* Clean and Professional Dashboard */
.dashboard-container {
  background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
  min-height: 100vh;
  padding: 0.5rem;
}

/* Hero Section - Simple and Clean */
.hero-section {
  background: white;
  border-radius: 12px;
  padding: 1rem;
  margin: 0.5rem 0;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
  text-align: center;
}


.page-title {
  font-size: 2.5rem;
  font-weight: var(--font-weight-bold);
  font-family: var(--font-municipal);
  color: var(--municipal-primary);
  margin: 0 0 0.5rem 0;
}

.page-subtitle {
  font-size: 1.2rem;
  font-family: var(--font-municipal);
  font-weight: var(--font-weight-regular);
  color: var(--slate-600);
  margin: 0 0 2rem 0;
}

/* Stats Row - Clean Cards */
.stats-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-top: 2rem;
}

.stat-card {
  background: white;
  padding: 1.5rem;
  border-radius: 8px;
  border: 1px solid #e2e8f0;
  display: flex;
  align-items: center;
  gap: 1rem;
  transition: all 0.2s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 15px rgba(0, 0, 0, 0.1);
}

.stat-icon {
  width: 50px;
  height: 50px;
  background: var(--municipal-secondary);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.25rem;
}

.stat-value {
  font-size: 1.75rem;
  font-weight: var(--font-weight-bold);
  font-family: var(--font-municipal);
  color: var(--municipal-primary);
  line-height: 1;
}

.stat-label {
  font-size: 0.9rem;
  color: var(--slate-600);
  margin-top: 0.25rem;
}

/* Modules Section */
.modules-section {
  background: white;
  border-radius: 12px;
  padding: 2rem;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
}

.section-header {
  text-align: center;
  margin-bottom: 2rem;
}

.section-title {
  font-size: 2rem;
  font-weight: var(--font-weight-bold);
  font-family: var(--font-municipal);
  color: var(--municipal-primary);
  margin: 0 0 0.5rem 0;
}

.section-subtitle {
  font-size: 1rem;
  color: var(--slate-600);
  margin: 0;
}

/* Modules Grid - Clean Cards */
.modules-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

.module-card {
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  padding: 1.5rem;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
}

.module-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
  border-color: var(--municipal-primary);
}

.module-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 1rem;
}

.module-icon {
  width: 50px;
  height: 50px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.5rem;
}

/* Paleta completa de colores complementarios oficiales */
.module-orange { background: var(--gov-primary-orange); }    /* Licencias - Naranja Principal #ea8215 */
.module-green { background: var(--gov-green); }              /* Aseo - Verde #6cca98 */
.module-red { background: var(--gov-pink); }                 /* Apremios - Rosa #e96cb0 */
.module-gray { background: var(--gov-gray); }                /* Cementerios - Gris #808080 */
.module-pink { background: var(--gov-peach); }               /* Convenios - Durazno #ff9d6c */
.module-blue { background: var(--gov-blue); }                /* Estacionamientos - Azul #009ade */
.module-teal { background: var(--gov-yellow); }              /* Mercados - Amarillo #ffb700 */
.module-purple { background: var(--gov-purple); }            /* Tramite Trunk - Púrpura #9264cc */

/* Asignación de todos los colores oficiales únicos */
.module-gold { background: var(--gov-primary-gold); }        /* Otras Obligaciones - Dorado Principal #cc9f52 */        /* Otras Obligaciones - Dorado Principal #cc9f52 */            /* Tramite Trunk - Púrpura #9264cc */                /* Mercados/Otras Oblig */

.module-count {
  background: var(--municipal-secondary);
  color: white;
  padding: 0.25rem 0.75rem;
  border-radius: 20px;
  font-size: 0.875rem;
  font-weight: var(--font-weight-bold);
}

.module-content {
  margin-bottom: 1rem;
}

.module-title {
  font-size: 1.25rem;
  font-weight: var(--font-weight-bold);
  font-family: var(--font-municipal);
  color: var(--slate-800);
  margin: 0 0 0.25rem 0;
}

.module-category {
  font-size: 0.875rem;
  color: var(--slate-500);
  margin: 0 0 0.5rem 0;
}

.module-users {
  font-size: 0.8rem;
  color: var(--slate-600);
}

.module-actions {
  display: flex;
  gap: 0.5rem;
  justify-content: flex-end;
}

.btn-info,
.btn-access {
  width: 35px;
  height: 35px;
  border: none;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-info {
  background: #e2e8f0;
  color: var(--slate-600);
}

.btn-info:hover {
  background: var(--slate-300);
}

.btn-access {
  background: var(--municipal-primary);
  color: white;
}

.btn-access:hover {
  background: var(--gov-primary-gold);
}

/* Responsive Design */
@media (max-width: 768px) {
  .dashboard-container {
    padding: 1rem;
  }

  .hero-section {
    padding: 2rem 1rem;
  }

  .page-title {
    font-size: 2rem;
  }

  .stats-row {
    grid-template-columns: 1fr;
  }

  .modules-grid {
    grid-template-columns: 1fr;
  }
}
</style>