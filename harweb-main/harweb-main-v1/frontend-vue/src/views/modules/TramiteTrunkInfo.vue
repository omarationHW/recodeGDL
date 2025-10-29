<template>
  <div class="info-container">
    <!-- Header del Módulo -->
    <div class="module-header">
      <div class="container-fluid">
        <div class="header-content">
          <div class="module-info">
            <div class="module-icon-large">
              <i class="fas fa-clipboard-check"></i>
            </div>
            <div class="module-details">
              <h1 class="module-title">Módulo Trámite Trunk</h1>
              <p class="module-subtitle">Sistema Integral de Gestión de Trámites y Procedimientos Administrativos</p>
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

      <!-- Carrusel de Imágenes del Módulo -->
      <div class="carousel-card">
        <h2 class="section-title">Galería del Módulo</h2>
        <div class="carousel-container">
          <div class="carousel-wrapper" ref="carouselWrapper">
            <div class="carousel-track" :style="{ transform: `translateX(-${currentSlide * 100}%)` }">
              <div v-for="(image, index) in carouselImages" :key="index" class="carousel-slide">
                <img :src="image.src" :alt="image.alt" class="carousel-image"/>
                <div class="carousel-caption">
                  <h3 class="carousel-title">{{ image.title }}</h3>
                  <p class="carousel-description">{{ image.description }}</p>
                </div>
              </div>
            </div>
          </div>
          <!-- Controles del carrusel -->
          <button class="carousel-btn carousel-btn-prev" @click="prevSlide" :disabled="currentSlide === 0">
            <i class="fas fa-chevron-left"></i>
          </button>
          <button class="carousel-btn carousel-btn-next" @click="nextSlide" :disabled="currentSlide === carouselImages.length - 1">
            <i class="fas fa-chevron-right"></i>
          </button>
          <!-- Indicadores -->
          <div class="carousel-indicators">
            <button v-for="(image, index) in carouselImages" :key="index" class="carousel-indicator" :class="{ 'active': currentSlide === index }" @click="goToSlide(index)"></button>
          </div>
        </div>
      </div>

      <!-- Estadísticas del Módulo -->
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-content">
            <div class="stat-icon-wrapper">
              <i class="fas fa-check-circle"></i>
            </div>
            <div>
              <p class="stat-label">Componentes</p>
              <p class="stat-value">73</p>
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
              <p class="stat-value">58</p>
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
              <p class="stat-value">147</p>
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
          El <strong>Módulo Trámite Trunk</strong> es un sistema especializado para la gestión integral
          de trámites y procedimientos administrativos municipales. Permite el control completo del
          flujo de documentos, seguimiento de expedientes y administración de procesos burocráticos.
        </p>
        <p class="description-text">
          Migrado completamente de Delphi a arquitectura moderna con Laravel + Vue.js + PostgreSQL,
          ofrece herramientas avanzadas para la optimización de procesos administrativos municipales.
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
              <div class="feature-content">
                <h4 class="feature-title">Gestión de Trámites</h4>
                <p class="feature-description">Administración completa de procedimientos administrativos</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div class="feature-content">
                <h4 class="feature-title">Seguimiento de Expedientes</h4>
                <p class="feature-description">Control del flujo documental y estado de trámites</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div class="feature-content">
                <h4 class="feature-title">Procesos Automatizados</h4>
                <p class="feature-description">Automatización de flujos de trabajo administrativos</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div class="feature-content">
                <h4 class="feature-title">Reportes y Estadísticas</h4>
                <p class="feature-description">Informes de gestión y control de eficiencia</p>
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
              <div class="tech-content">
                <h4 class="tech-title">Frontend</h4>
                <p class="tech-description">Vue.js 3 con interfaz SPA moderna</p>
              </div>
            </div>
            <div class="tech-item">
              <div class="tech-icon">
                <i class="fas fa-server"></i>
              </div>
              <div class="tech-content">
                <h4 class="tech-title">Backend</h4>
                <p class="tech-description">Laravel API con endpoint unificado</p>
              </div>
            </div>
            <div class="tech-item">
              <div class="tech-icon">
                <i class="fas fa-database"></i>
              </div>
              <div class="tech-content">
                <h4 class="tech-title">Base de Datos</h4>
                <p class="tech-description">PostgreSQL con stored procedures</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Nuevas Funcionalidades -->
      <div class="new-features-card">
        <div class="new-features-header">
          <h3 class="card-title">🆕 Nuevas Funcionalidades de Modernización</h3>
          <span class="badge-new">RECIÉN AGREGADAS</span>
        </div>
        <div class="new-features-grid">
          <router-link
            to="/tramite-trunk/flujo-automatizado"
            class="new-feature-card feature-primary"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-project-diagram"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Flujo Automatizado</h4>
              <p class="feature-desc-new">Procesamiento automático</p>
              <p class="feature-desc-new">de trámites estándar</p>
            </div>
          </router-link>

          <router-link
            to="/tramite-trunk/seguimiento-tiempo-real"
            class="new-feature-card feature-warning"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-clock"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Seguimiento en Tiempo Real</h4>
              <p class="feature-desc-new">Monitoreo completo</p>
              <p class="feature-desc-new">del estado de trámites</p>
            </div>
          </router-link>

          <router-link
            to="/tramite-trunk/notificaciones-automaticas"
            class="new-feature-card feature-info"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-bell"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Notificaciones Automáticas</h4>
              <p class="feature-desc-new">Alertas por email</p>
              <p class="feature-desc-new">y SMS a usuarios</p>
            </div>
          </router-link>

          <router-link
            to="/tramite-trunk/documentos-digitales"
            class="new-feature-card feature-success"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-file-digital"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Documentos Digitales</h4>
              <p class="feature-desc-new">Gestión sin papel:</p>
              <p class="feature-desc-new">Upload y Validación</p>
            </div>
          </router-link>
        </div>

        <!-- Componente Modernizado -->
        <div class="updated-section">
          <div class="updated-header">
            <h5 class="updated-title">🔄 Componente Modernizado</h5>
            <span class="badge-updated">ACTUALIZADO</span>
          </div>
          <div class="updated-grid">
            <router-link
              to="/tramite-trunk/expedientes-digitales"
              class="updated-card"
            >
              <span class="updated-badge">DIGITALIZADO</span>
              <div class="updated-icon">
                <i class="fas fa-folder-open"></i>
              </div>
              <div>
                <h4 class="updated-card-title">Expedientes</h4>
                <p class="updated-card-desc">Ahora completamente digitales</p>
                <p class="updated-card-desc">(Sin archivos físicos)</p>
              </div>
            </router-link>
          </div>
        </div>
      </div>

      <!-- Acciones Rápidas -->
      <div class="quick-actions-card">
        <h3 class="card-title">Acciones Rápidas Existentes</h3>
        <div class="quick-actions-grid">
          <router-link
            to="/tramite-trunk/nuevo-tramite"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-plus"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Nuevo Trámite</h4>
              <p class="quick-action-desc">Iniciar procedimiento</p>
            </div>
          </router-link>

          <router-link
            to="/tramite-trunk/consultas"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-search"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Consultar Trámites</h4>
              <p class="quick-action-desc">Búsqueda de expedientes</p>
            </div>
          </router-link>

          <router-link
            to="/tramite-trunk/seguimiento"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-tasks"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Seguimiento</h4>
              <p class="quick-action-desc">Estado de trámites</p>
            </div>
          </router-link>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
export default {
  name: 'TramiteTrunkInfo',
  data() {
    return {
      currentSlide: 0,
      carouselImages: [
        {
          src: '/img/dashboard/tramites-generales.svg',
          alt: 'Trámites Generales',
          title: 'Trámites Generales',
          description: 'Gestión integral de procesos administrativos y documentación oficial'
        }
      ]
    }
  },
  methods: {
    prevSlide() {
      if (this.currentSlide > 0) {
        this.currentSlide--
      }
    },
    nextSlide() {
      if (this.currentSlide < this.carouselImages.length - 1) {
        this.currentSlide++
      }
    },
    goToSlide(index) {
      this.currentSlide = index
    }
  }
}
</script>

<style scoped>
/* Estilos específicos del componente TramiteTrunkInfo */
.container-fluid {
  padding: 2rem 3rem;
}
</style>