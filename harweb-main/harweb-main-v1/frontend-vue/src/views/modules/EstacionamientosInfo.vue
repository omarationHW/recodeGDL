<template>
  <div class="info-container">
    <!-- Header del Módulo -->
    <div class="module-header">
      <div class="container-fluid">
        <div class="header-content">
          <div class="module-info">
            <div class="module-icon-large">
              <i class="fas fa-car"></i>
            </div>
            <div class="module-details">
              <h1 class="module-title">Módulo Estacionamientos</h1>
              <p class="module-subtitle">Control Integral de Espacios de Estacionamiento y Parquímetros</p>
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
              <p class="stat-value success">87+</p>
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
              <p class="stat-value">60</p>
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
              <p class="stat-value">182</p>
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
          El <strong>Módulo de Estacionamientos</strong> es un sistema especializado para el control integral
          de espacios de estacionamiento, parquímetros e infracciones municipales. Permite la administración
          completa de permisos especiales, procesamiento de multas y generación de reportes operativos.
        </p>
        <p class="description-text">
          Migrado completamente de Delphi a arquitectura moderna con Laravel + Vue.js + PostgreSQL,
          ofrece herramientas avanzadas para la optimización de servicios públicos de movilidad urbana.
        </p>
      </div>

      <!-- Características y Arquitectura -->
      <div class="features-grid">
        <div class="features-card">
          <h3 class="card-title">Funcionalidades Principales</h3>
          <div class="features-list">
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Administración de Parquímetros</h4>
                <p class="feature-description">Control completo de espacios públicos</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Permisos Especiales</h4>
                <p class="feature-description">Gestión de estacionamientos exclusivos</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Procesamiento de Infracciones</h4>
                <p class="feature-description">Sistema automático de multas</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Sistema Bancario</h4>
                <p class="feature-description">Generación automática de archivos</p>
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

      <!-- Modernización del Módulo -->
      <div class="new-features-card">
        <div class="new-features-header">
          <h3 class="card-title">🚀 Modernización del Módulo</h3>
          <span class="badge-new">+3 NUEVOS</span>
        </div>
        <div class="new-features-grid">
          <router-link
            to="/estacionamientos/SistemaConveniosEstacionamientos"
            class="new-feature-card feature-primary"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-handshake"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Sistema de Convenios</h4>
              <p class="feature-desc-new">Georreferenciación y</p>
              <p class="feature-desc-new">gestión integral</p>
            </div>
          </router-link>

          <router-link
            to="/estacionamientos/SistemaApremiosEstacionamientos"
            class="new-feature-card feature-success"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-gavel"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Sistema de Apremios</h4>
              <p class="feature-desc-new">Apremios por zonas</p>
              <p class="feature-desc-new">con seguimiento automático</p>
            </div>
          </router-link>

          <router-link
            to="/estacionamientos/SistemaDescuentosConversion"
            class="new-feature-card feature-warning"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-percentage"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Descuentos y Conversión</h4>
              <p class="feature-desc-new">Sistema unificado</p>
              <p class="feature-desc-new">de beneficios</p>
            </div>
          </router-link>
        </div>

        <!-- Características de la Modernización -->
        <div class="modernization-features">
          <h5 class="features-title">🌟 Características de la Modernización</h5>
          <div class="features-list-modern">
            <div class="feature-modern-item">
              <i class="fas fa-map-marker-alt"></i>
              <span>Georreferenciación de espacios</span>
            </div>
            <div class="feature-modern-item">
              <i class="fas fa-chart-area"></i>
              <span>Gestión por zonas</span>
            </div>
            <div class="feature-modern-item">
              <i class="fas fa-calculator"></i>
              <span>Descuentos automatizados</span>
            </div>
            <div class="feature-modern-item">
              <i class="fas fa-sync-alt"></i>
              <span>Conversión de procedimientos</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Módulos de Gestión -->
      <div class="modules-card">
        <h3 class="card-title">Módulos de Gestión</h3>
        <div class="modules-grid">
          <div class="module-item">
            <h4 class="module-title">Control de Acceso</h4>
            <p class="module-description">Gestión de usuarios y permisos</p>
          </div>
          <div class="module-item">
            <h4 class="module-title">Administración</h4>
            <p class="module-description">Configuración general del sistema</p>
          </div>
          <div class="module-item">
            <h4 class="module-title">Bajas y Cancelaciones</h4>
            <p class="module-description">Procesamiento de cancelaciones</p>
          </div>
          <div class="module-item">
            <h4 class="module-title">Consultas</h4>
            <p class="module-description">Sistema de búsquedas avanzadas</p>
          </div>
          <div class="module-item">
            <h4 class="module-title">Generador de Archivos</h4>
            <p class="module-description">Exportación para sistemas bancarios</p>
          </div>
          <div class="module-item">
            <h4 class="module-title">Procesamiento de Pagos</h4>
            <p class="module-description">Gestión integral de pagos</p>
          </div>
        </div>
      </div>

      <!-- Acciones Rápidas -->
      <div class="quick-actions-card">
        <h3 class="card-title">Acciones Rápidas Existentes</h3>
        <div class="quick-actions-grid">
          <router-link
            to="/estacionamientos/acceso"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-shield-alt"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Control de Acceso</h4>
              <p class="quick-action-desc">Gestión de usuarios</p>
            </div>
          </router-link>

          <router-link
            to="/estacionamientos/consultas"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-search"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Consultas</h4>
              <p class="quick-action-desc">Búsquedas avanzadas</p>
            </div>
          </router-link>

          <router-link
            to="/estacionamientos/pagos"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-credit-card"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Procesamiento Pagos</h4>
              <p class="quick-action-desc">Gestión de pagos</p>
            </div>
          </router-link>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
export default {
  name: 'EstacionamientosInfo',
  data() {
    return {
      currentSlide: 0,
      carouselImages: [
        {
          src: '/img/dashboard/parking-municipal.svg',
          alt: 'Estacionamiento Municipal',
          title: 'Estacionamiento Municipal',
          description: 'Control y gestión de espacios de estacionamiento público'
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
/* Estilos específicos del componente EstacionamientosInfo */
.container-fluid {
  padding: 2rem 3rem;
}
</style>