<template>
  <div class="info-container">
    <!-- Header del Módulo -->
    <div class="module-header">
      <div class="container-fluid">
        <div class="header-content">
          <div class="module-info">
            <div class="module-icon-large">
              <i class="fas fa-exclamation-triangle"></i>
            </div>
            <div class="module-details">
              <h1 class="module-title">Módulo Apremios</h1>
              <p class="module-subtitle">Sistema de Cobranza Coactiva y Procedimientos Administrativos</p>
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
              <p class="stat-label">Formularios</p>
              <p class="stat-value success">59</p>
            </div>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-content">
            <div class="stat-icon-wrapper">
              <i class="fas fa-cube"></i>
            </div>
            <div>
              <p class="stat-label">Módulos</p>
              <p class="stat-value">12</p>
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
              <p class="stat-value">13</p>
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
          El <strong>Módulo de Apremios</strong> es un sistema especializado para la gestión de procedimientos
          de cobranza coactiva y ejecución de adeudos fiscales. Permite el control integral de procesos
          administrativos de cobro, gestión de ejecutores y facturación electrónica especializada.
        </p>
        <p class="description-text">
          Desarrollado con arquitectura moderna Laravel + Vue.js + PostgreSQL, ofrece herramientas
          avanzadas para la gestión eficiente de procedimientos legales y administrativos de cobranza.
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
                <h4 class="feature-title">Gestión de Ejecutores</h4>
                <p class="feature-description">Administración y control de ejecutores fiscales</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Facturación Electrónica</h4>
                <p class="feature-description">Sistema de facturación y firma digital</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Cobranza Coactiva</h4>
                <p class="feature-description">Procedimientos legales de recuperación de cartera</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Reportes Especializados</h4>
                <p class="feature-description">Informes detallados de gestión y seguimiento</p>
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
            to="/apremios/SistemaConveniosApremios"
            class="new-feature-card feature-primary"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-handshake"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Sistema de Convenios</h4>
              <p class="feature-desc-new">Gestión integral de</p>
              <p class="feature-desc-new">acuerdos y parcialidades</p>
            </div>
          </router-link>

          <router-link
            to="/apremios/SistemaApremiosApremios"
            class="new-feature-card feature-success"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-gavel"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Sistema de Apremios</h4>
              <p class="feature-desc-new">Control de ejecutores</p>
              <p class="feature-desc-new">y folios administrativos</p>
            </div>
          </router-link>

          <router-link
            to="/apremios/SistemaDescuentosApremios"
            class="new-feature-card feature-warning"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-percentage"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Descuentos y Conversión</h4>
              <p class="feature-desc-new">Revaluación de costos</p>
              <p class="feature-desc-new">y conversión automatizada</p>
            </div>
          </router-link>
        </div>
      </div>

      <!-- Acciones Rápidas -->
      <div class="quick-actions-card">
        <h3 class="card-title">Acciones Rápidas Existentes</h3>
        <div class="quick-actions-grid">
          <router-link
            to="/apremios/acceso"
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
            to="/apremios/consulta"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-search"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Consulta General</h4>
              <p class="quick-action-desc">Búsqueda de expedientes</p>
            </div>
          </router-link>

          <router-link
            to="/apremios/ejecutores"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-user-tie"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Gestión Ejecutores</h4>
              <p class="quick-action-desc">Administrar ejecutores</p>
            </div>
          </router-link>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
export default {
  name: 'ApremiosInfo',
  data() {
    return {
      currentSlide: 0,
      carouselImages: [
        {
          src: '/img/dashboard/cobranza-administrativa.svg',
          alt: 'Cobranza Administrativa',
          title: 'Cobranza Administrativa',
          description: 'Gestión de procedimientos de cobro y ejecución de adeudos municipales'
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
/* Estilos específicos del componente ApremiosInfo */
.container-fluid {
  padding: 2rem 3rem;
}
</style>