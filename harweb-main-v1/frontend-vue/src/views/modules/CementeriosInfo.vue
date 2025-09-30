<template>
  <div class="info-container">
    <!-- Header del Módulo -->
    <div class="module-header">
      <div class="container-fluid">
        <div class="header-content">
          <div class="module-info">
            <div class="module-icon-large">
              <i class="fas fa-cross"></i>
            </div>
            <div class="module-details">
              <h1 class="module-title">Módulo Cementerios</h1>
              <p class="module-subtitle">Sistema de Gestión de Servicios Funerarios y Cementeriales</p>
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
              <p class="stat-value success">40</p>
              <p class="stat-highlight">+4 NUEVOS</p>
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
              <p class="stat-value">27</p>
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
              <p class="stat-value">102</p>
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
          El <strong>Módulo de Cementerios</strong> es un sistema especializado para la gestión integral
          de servicios funerarios y administración de espacios cementeriales. Permite el control completo
          de lotes disponibles, procesamiento de servicios y manejo de documentación legal.
        </p>
        <p class="description-text">
          Migrado completamente de Delphi a arquitectura moderna con Laravel + Vue.js + PostgreSQL,
          ofrece herramientas avanzadas para la gestión eficiente de servicios municipales funerarios.
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
                <h4 class="feature-title">Gestión de Lotes</h4>
                <p class="feature-description">Control completo de espacios y disponibilidad</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Servicios Funerarios</h4>
                <p class="feature-description">Procesamiento de servicios y permisos</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Facturación Especializada</h4>
                <p class="feature-description">Sistema de cobros y documentación fiscal</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Control de Documentos</h4>
                <p class="feature-description">Manejo de documentación legal y certificados</p>
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

      <!-- Nuevas Funcionalidades -->
      <div class="new-features-card">
        <div class="new-features-header">
          <h3 class="card-title">🆕 Nuevas Funcionalidades de Modernización</h3>
          <span class="badge-new">RECIÉN AGREGADAS</span>
        </div>
        <div class="new-features-grid">
          <router-link
            to="/cementerios/sistemadescuentoscementerios"
            class="new-feature-card feature-success"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-percentage"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Descuentos Automatizados</h4>
              <p class="feature-desc-new">Cálculo automático</p>
              <p class="feature-desc-new">con validación legal</p>
            </div>
          </router-link>

          <router-link
            to="/cementerios/sistemaconversionrevaluacion"
            class="new-feature-card feature-primary"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-exchange-alt"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Conversión y Revaluación</h4>
              <p class="feature-desc-new">Migración automática</p>
              <p class="feature-desc-new">de procedimientos</p>
            </div>
          </router-link>

          <router-link
            to="/cementerios/sistemaconsultasunificadas"
            class="new-feature-card feature-info"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-search-plus"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Consultas Unificadas</h4>
              <p class="feature-desc-new">Búsqueda inteligente</p>
              <p class="feature-desc-new">multifiltro avanzada</p>
            </div>
          </router-link>

          <router-link
            to="/cementerios/funcionesexcluidascementerios"
            class="new-feature-card feature-warning"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-times-circle"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Funciones Excluidas</h4>
              <p class="feature-desc-new">Documentación de</p>
              <p class="feature-desc-new">funciones obsoletas</p>
            </div>
          </router-link>
        </div>

        <!-- Métricas de Modernización -->
        <div class="modernization-metrics">
          <h5 class="metrics-title">Métricas de Modernización</h5>
          <div class="metrics-grid">
            <div class="metric-item">
              <span class="metric-value danger">10</span>
              <span class="metric-label">Funciones excluidas</span>
            </div>
            <div class="metric-item">
              <span class="metric-value success">4</span>
              <span class="metric-label">Sistemas nuevos</span>
            </div>
            <div class="metric-item">
              <span class="metric-value warning">350%</span>
              <span class="metric-label">Mejora eficiencia</span>
            </div>
            <div class="metric-item">
              <span class="metric-value info">70%</span>
              <span class="metric-label">Reducción tiempo</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Acciones Rápidas -->
      <div class="quick-actions-card">
        <h3 class="card-title">Acciones Rápidas Existentes</h3>
        <div class="quick-actions-grid">
          <router-link
            to="/cementerios/abc_lotes"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-map"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Gestión de Lotes</h4>
              <p class="quick-action-desc">Administrar espacios</p>
            </div>
          </router-link>

          <router-link
            to="/cementerios/servicios"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-handshake"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Servicios Funerarios</h4>
              <p class="quick-action-desc">Procesar servicios</p>
            </div>
          </router-link>

          <router-link
            to="/cementerios/consultas"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-search"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Consultas</h4>
              <p class="quick-action-desc">Búsquedas y reportes</p>
            </div>
          </router-link>
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
      currentSlide: 0,
      carouselImages: [
        {
          src: '/img/dashboard/gestion-sepulcros.svg',
          alt: 'Gestión de Sepulcros',
          title: 'Gestión de Sepulcros',
          description: 'Administración integral de servicios funerarios y cementerios municipales'
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
/* Estilos específicos del componente CementeriosInfo */
.container-fluid {
  padding: 2rem 3rem;
}
</style>