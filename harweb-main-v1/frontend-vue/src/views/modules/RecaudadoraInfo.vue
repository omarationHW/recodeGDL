<template>
  <div class="info-container">
    <!-- Header del Módulo -->
    <div class="module-header">
      <div class="container-fluid">
        <div class="header-content">
          <div class="module-info">
            <div class="module-icon-large">
              <i class="fas fa-coins"></i>
            </div>
            <div class="module-details">
              <h1 class="module-title">Módulo Recaudadora</h1>
              <p class="module-subtitle">Sistema de Padrón Recaudación Municipal</p>
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
              <p class="stat-value success">106</p>
              <p class="stat-highlight">+12 NUEVOS</p>
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
              <p class="stat-value">8</p>
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
              <p class="stat-value">12</p>
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
          El <strong>Módulo Recaudadora</strong> es un sistema especializado para la gestión fiscal
          integral del padrón contributivo municipal. Administra el control de pagos, descuentos,
          multas, reportes de recaudación y la gestión completa del padrón de contribuyentes.
        </p>
        <p class="description-text">
          Migrado completamente de Delphi a una arquitectura moderna con Laravel + Vue.js + PostgreSQL,
          proporciona herramientas avanzadas para la administración eficiente de la recaudación
          municipal y control del padrón contributivo.
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
                <h4 class="feature-title">Padrón Contributivo</h4>
                <p class="feature-description">Gestión completa del padrón de contribuyentes</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Control de Pagos</h4>
                <p class="feature-description">Administración de recaudación y pagos fiscales</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Descuentos y Multas</h4>
                <p class="feature-description">Sistema de incentivos y penalizaciones</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Reportes Fiscales</h4>
                <p class="feature-description">Informes estadísticos y de recaudación</p>
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

      <!-- Funcionalidades Principales -->
      <div class="new-features-card">
        <div class="new-features-header">
          <h3 class="card-title">🆕 Sistemas Modernizados</h3>
          <span class="badge-new">NUEVOS SISTEMAS</span>
        </div>
        <div class="new-features-grid">
          <router-link
            to="/recaudadora/sistemaapremios"
            class="new-feature-card feature-primary"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-gavel"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Sistema de Apremios</h4>
              <p class="feature-desc-new">Gestión de ejecutores</p>
              <p class="feature-desc-new">y cobranza coactiva</p>
            </div>
          </router-link>

          <router-link
            to="/recaudadora/sistemaconvenios"
            class="new-feature-card feature-warning"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-handshake"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Sistema de Convenios</h4>
              <p class="feature-desc-new">ABC completo de</p>
              <p class="feature-desc-new">convenios de pago</p>
            </div>
          </router-link>

          <router-link
            to="/recaudadora/busque"
            class="new-feature-card feature-info"
          >
            <span class="feature-badge">ACCESO</span>
            <div class="feature-icon-new">
              <i class="fas fa-search"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Búsqueda Principal</h4>
              <p class="feature-desc-new">Consulta general</p>
              <p class="feature-desc-new">del padrón</p>
            </div>
          </router-link>

          <router-link
            to="/recaudadora/funcionesexcluidas"
            class="new-feature-card feature-success"
          >
            <span class="feature-badge">INFO</span>
            <div class="feature-icon-new">
              <i class="fas fa-info-circle"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Funciones Excluidas</h4>
              <p class="feature-desc-new">Documentación de</p>
              <p class="feature-desc-new">funciones obsoletas</p>
            </div>
          </router-link>
        </div>
      </div>

      <!-- Acciones Rápidas -->
      <div class="quick-actions-card">
        <h3 class="card-title">Acciones Rápidas del Sistema</h3>
        <div class="quick-actions-grid">
          <router-link
            to="/recaudadora/padron"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-users"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Padrón Contributivo</h4>
              <p class="quick-action-desc">Gestionar contribuyentes</p>
            </div>
          </router-link>

          <router-link
            to="/recaudadora/pagos"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-credit-card"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Control de Pagos</h4>
              <p class="quick-action-desc">Administrar recaudación</p>
            </div>
          </router-link>

          <router-link
            to="/recaudadora/reportes"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-chart-bar"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Reportes Fiscales</h4>
              <p class="quick-action-desc">Informes de recaudación</p>
            </div>
          </router-link>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
export default {
  name: 'RecaudadoraInfo',
  data() {
    return {
      currentSlide: 0,
      carouselImages: [
        {
          src: '/img/dashboard/recaudacion-municipal.svg',
          alt: 'Recaudación Municipal',
          title: 'Recaudación Municipal',
          description: 'Sistema integral de cobros y recaudación de impuestos municipales'
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
/* Estilos específicos del componente RecaudadoraInfo */
.container-fluid {
  padding: 2rem 3rem;
}
</style>