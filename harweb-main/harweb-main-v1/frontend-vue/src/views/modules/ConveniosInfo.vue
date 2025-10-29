<template>
  <div class="info-container">
    <!-- Header del Módulo -->
    <div class="module-header">
      <div class="container-fluid">
        <div class="header-content">
          <div class="module-info">
            <div class="module-icon-large">
              <i class="fas fa-handshake"></i>
            </div>
            <div class="module-details">
              <h1 class="module-title">Módulo Convenios</h1>
              <p class="module-subtitle">Gestión Integral de Convenios de Pago y Acuerdos Municipales</p>
            </div>
          </div>
          <div>
            <router-link
              to="/"
              class="btn-back"
            >
              <i class="fas fa-arrow-left me-2"></i>
              Volver al Dashboard
            </router-link>
          </div>
        </div>
      </div>
    </div>

    <!-- Contenido Principal -->
    <div class="content-container">

      <!-- Estadísticas del Módulo -->
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-content">
            <div class="stat-icon-wrapper">
              <i class="fas fa-check-circle"></i>
            </div>
            <div>
              <p class="stat-label">Componentes</p>
              <p class="stat-value success">94</p>
            </div>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-content">
            <div class="stat-icon-wrapper">
              <i class="fas fa-cube"></i>
            </div>
            <div>
              <p class="stat-label">Formularios</p>
              <p class="stat-value">75</p>
            </div>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-content">
            <div class="stat-icon-wrapper">
              <i class="fas fa-database"></i>
            </div>
            <div>
              <p class="stat-label">Stored Procedures</p>
              <p class="stat-value">309</p>
            </div>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-content">
            <div class="stat-icon-wrapper active">
              <div class="status-indicator"></div>
            </div>
            <div>
              <p class="stat-label">Estado</p>
              <p class="stat-value success">Activo</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Descripción del Módulo -->
      <div class="description-card">
        <h2 class="section-title">Descripción del Módulo</h2>
        <p class="description-text">
          El <strong>Módulo de Convenios</strong> es un sistema especializado para la gestión integral
          de convenios de pago, acuerdos y planes de financiamiento municipal. Permite el control completo
          de adeudos, negociaciones y seguimiento de compromisos de pago entre ciudadanos y el municipio.
        </p>
        <p class="description-text">
          Migrado completamente de Delphi a arquitectura moderna con Laravel + Vue.js + PostgreSQL,
          ofrece herramientas avanzadas para la gestión eficiente de convenios y acuerdos fiscales.
        </p>
      </div>

      <!-- Características y Arquitectura -->
      <div class="features-grid">
        <div class="features-card">
          <h3 class="card-title">Características Principales</h3>
          <div class="features-list">
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Gestión de Convenios</h4>
                <p class="feature-description">Administración completa de acuerdos de pago</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Planes de Financiamiento</h4>
                <p class="feature-description">Estructuración de planes de pago personalizados</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Control de Adeudos</h4>
                <p class="feature-description">Seguimiento de compromisos y pagos</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Documentación Legal</h4>
                <p class="feature-description">Generación de documentos y contratos</p>
              </div>
            </div>
          </div>
        </div>

        <div class="features-card">
          <h3 class="card-title">Arquitectura Técnica</h3>
          <div class="tech-stack">
            <div class="tech-item">
              <div class="tech-icon">
                <i class="fas fa-desktop"></i>
              </div>
              <div>
                <h4 class="tech-title">Frontend</h4>
                <p class="tech-description">Vue.js 3 con interfaz SPA moderna</p>
              </div>
            </div>

            <div class="tech-item">
              <div class="tech-icon">
                <i class="fas fa-server"></i>
              </div>
              <div>
                <h4 class="tech-title">Backend</h4>
                <p class="tech-description">Laravel API con endpoint unificado</p>
              </div>
            </div>

            <div class="tech-item">
              <div class="tech-icon">
                <i class="fas fa-database"></i>
              </div>
              <div>
                <h4 class="tech-title">Base de Datos</h4>
                <p class="tech-description">PostgreSQL con stored procedures</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Módulos de Gestión -->
      <div class="modules-card">
        <h3 class="card-title">Módulos de Gestión</h3>
        <div class="modules-grid">
          <div class="module-item">
            <h4 class="module-title">Creación de Convenios</h4>
            <p class="module-description">Generación de nuevos acuerdos</p>
          </div>
          <div class="module-item">
            <h4 class="module-title">Seguimiento</h4>
            <p class="module-description">Control de cumplimiento de pagos</p>
          </div>
          <div class="module-item">
            <h4 class="module-title">Consultas</h4>
            <p class="module-description">Búsquedas y reportes especializados</p>
          </div>
          <div class="module-item">
            <h4 class="module-title">Renegociación</h4>
            <p class="module-description">Modificación de términos existentes</p>
          </div>
          <div class="module-item">
            <h4 class="module-title">Cancelación</h4>
            <p class="module-description">Proceso de cancelación de convenios</p>
          </div>
          <div class="module-item">
            <h4 class="module-title">Reportes</h4>
            <p class="module-description">Informes estadísticos y de gestión</p>
          </div>
        </div>
      </div>

      <!-- Acciones Rápidas -->
      <div class="quick-actions-card">
        <h3 class="card-title">Acciones Rápidas Existentes</h3>
        <div class="quick-actions-grid">
          <router-link
            to="/convenios/nuevo"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-plus"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Nuevo Convenio</h4>
              <p class="quick-action-desc">Crear acuerdo de pago</p>
            </div>
          </router-link>

          <router-link
            to="/convenios/consultas"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-search"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Consultas</h4>
              <p class="quick-action-desc">Buscar convenios</p>
            </div>
          </router-link>

          <router-link
            to="/convenios/seguimiento"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-chart-line"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Seguimiento</h4>
              <p class="quick-action-desc">Control de pagos</p>
            </div>
          </router-link>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
export default {
  name: 'ConveniosInfo',
  data() {
    return {
      // Datos específicos del módulo de convenios
    }
  }
}
</script>

<style scoped>
/* Tema Municipal para Páginas de Información */
.info-container {
  background: linear-gradient(135deg, var(--slate-50) 0%, #ffffff 100%);
  min-height: 100vh;
  font-family: var(--font-municipal);
}

/* Header del Módulo */
.module-header {
  background: white;
  box-shadow: var(--shadow-sm);
  border-bottom: 1px solid var(--slate-200);
}

.container-fluid {
  padding: 2rem 3rem;
}

.header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.module-info {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.module-icon-large {
  width: 64px;
  height: 64px;
  background: var(--gradient-municipal);
  border-radius: var(--radius-lg);
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 2rem;
  box-shadow: var(--shadow-lg);
}

.module-title {
  font-size: 2.5rem;
  font-weight: var(--font-weight-bold);
  color: var(--municipal-primary);
  margin: 0 0 0.5rem 0;
  font-family: var(--font-heading);
}

.module-subtitle {
  font-size: 1.25rem;
  color: var(--slate-600);
  margin: 0;
  font-weight: var(--font-weight-regular);
}

.btn-back {
  display: flex;
  align-items: center;
  padding: 0.75rem 1.5rem;
  background: transparent;
  border: 2px solid var(--municipal-secondary);
  border-radius: var(--radius-md);
  color: var(--municipal-primary);
  text-decoration: none;
  font-weight: var(--font-weight-bold);
  transition: var(--transition-normal);
}

.btn-back:hover {
  background: var(--municipal-secondary);
  color: white;
  transform: translateY(-1px);
}

/* Contenido Principal */
.content-container {
  padding: 2rem 3rem;
}

/* Estadísticas */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-bottom: 3rem;
}

.stat-card {
  background: white;
  border-radius: var(--radius-lg);
  padding: 1.5rem;
  box-shadow: var(--shadow-md);
  border: 1px solid var(--slate-200);
}

.stat-content {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.stat-icon-wrapper {
  width: 50px;
  height: 50px;
  background: rgba(255, 157, 108, 0.1);
  border-radius: var(--radius-lg);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--municipal-primary);
  font-size: 1.25rem;
}

.stat-icon-wrapper.active {
  background: rgba(255, 157, 108, 0.1);
  color: var(--municipal-primary);
}

.status-indicator {
  width: 12px;
  height: 12px;
  background: var(--municipal-secondary);
  border-radius: var(--radius-full);
  animation: pulse 2s infinite;
}

.stat-label {
  font-size: 0.875rem;
  color: var(--slate-500);
  margin: 0 0 0.25rem 0;
  font-weight: var(--font-weight-regular);
}

.stat-value {
  font-size: 1.75rem;
  font-weight: var(--font-weight-bold);
  color: var(--municipal-primary);
  margin: 0;
  line-height: 1;
}

.stat-value.success {
  color: var(--municipal-primary);
}

.stat-highlight {
  font-size: 0.75rem;
  color: var(--municipal-primary);
  font-weight: var(--font-weight-bold);
  margin: 0.25rem 0 0 0;
}

/* Descripción */
.description-card {
  background: white;
  border-radius: var(--radius-lg);
  padding: 2.5rem;
  box-shadow: var(--shadow-md);
  border: 1px solid var(--slate-200);
  margin-bottom: 3rem;
}

.section-title {
  font-size: 1.5rem;
  font-weight: var(--font-weight-bold);
  color: var(--municipal-primary);
  margin: 0 0 1.5rem 0;
  font-family: var(--font-heading);
}

.description-text {
  font-size: 1rem;
  color: var(--slate-600);
  line-height: 1.7;
  margin-bottom: 1rem;
}

.description-text:last-child {
  margin-bottom: 0;
}

/* Características y Arquitectura */
.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 2rem;
  margin-bottom: 3rem;
}

.features-card {
  background: white;
  border-radius: var(--radius-lg);
  padding: 2.5rem;
  box-shadow: var(--shadow-md);
  border: 1px solid var(--slate-200);
}

.card-title {
  font-size: 1.25rem;
  font-weight: var(--font-weight-bold);
  color: var(--municipal-primary);
  margin: 0 0 1.5rem 0;
  font-family: var(--font-heading);
}

.features-list {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.feature-item {
  display: flex;
  align-items: flex-start;
  gap: 1rem;
}

.feature-icon {
  width: 32px;
  height: 32px;
  background: rgba(255, 157, 108, 0.1);
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--municipal-primary);
  font-size: 0.875rem;
  flex-shrink: 0;
  margin-top: 0.25rem;
}

.feature-title {
  font-size: 1rem;
  font-weight: var(--font-weight-bold);
  color: var(--slate-800);
  margin: 0 0 0.25rem 0;
}

.feature-description {
  font-size: 0.875rem;
  color: var(--slate-600);
  margin: 0;
}

/* Stack Técnico */
.tech-stack {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.tech-item {
  display: flex;
  align-items: center;
  padding: 1rem;
  background: rgba(255, 157, 108, 0.05);
  border-radius: var(--radius-md);
  gap: 1rem;
}

.tech-icon {
  width: 40px;
  height: 40px;
  background: rgba(255, 157, 108, 0.1);
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--municipal-primary);
}

.tech-title {
  font-size: 1rem;
  font-weight: var(--font-weight-bold);
  color: var(--slate-800);
  margin: 0 0 0.25rem 0;
}

.tech-description {
  font-size: 0.875rem;
  color: var(--slate-600);
  margin: 0;
}

/* Módulos de Gestión */
.modules-card {
  background: white;
  border-radius: var(--radius-lg);
  padding: 2.5rem;
  box-shadow: var(--shadow-md);
  border: 1px solid var(--slate-200);
  margin-bottom: 3rem;
}

.modules-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1rem;
}

.module-item {
  padding: 1rem;
  background: rgba(255, 157, 108, 0.05);
  border-radius: var(--radius-md);
  border: 1px solid rgba(255, 157, 108, 0.2);
}

.module-title {
  font-size: 1rem;
  font-weight: var(--font-weight-bold);
  color: var(--slate-800);
  margin: 0 0 0.5rem 0;
}

.module-description {
  font-size: 0.875rem;
  color: var(--slate-600);
  margin: 0;
}

/* Acciones Rápidas */
.quick-actions-card {
  background: white;
  border-radius: var(--radius-lg);
  padding: 2.5rem;
  box-shadow: var(--shadow-md);
  border: 1px solid var(--slate-200);
}

.quick-actions-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1rem;
}

.quick-action-item {
  display: flex;
  align-items: center;
  padding: 1rem;
  background: rgba(255, 157, 108, 0.05);
  border-radius: var(--radius-md);
  text-decoration: none;
  transition: var(--transition-normal);
  gap: 1rem;
}

.quick-action-item:hover {
  background: rgba(255, 157, 108, 0.1);
  transform: translateY(-1px);
}

.quick-action-icon {
  width: 40px;
  height: 40px;
  background: rgba(255, 157, 108, 0.1);
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--municipal-primary);
}

.quick-action-title {
  font-size: 1rem;
  font-weight: var(--font-weight-bold);
  color: var(--slate-800);
  margin: 0 0 0.25rem 0;
}

.quick-action-desc {
  font-size: 0.875rem;
  color: var(--slate-600);
  margin: 0;
}

/* Responsive Design */
@media (max-width: 768px) {
  .container-fluid {
    padding: 1rem;
  }

  .content-container {
    padding: 1rem;
  }

  .header-content {
    flex-direction: column;
    gap: 1rem;
    text-align: center;
  }

  .module-info {
    flex-direction: column;
    text-align: center;
  }

  .module-title {
    font-size: 2rem;
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }

  .features-grid {
    grid-template-columns: 1fr;
  }

  .modules-grid {
    grid-template-columns: 1fr;
  }

  .quick-actions-grid {
    grid-template-columns: 1fr;
  }
}
</style>