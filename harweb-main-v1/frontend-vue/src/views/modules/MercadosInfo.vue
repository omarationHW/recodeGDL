<template>
  <div class="info-container">
    <!-- Header del Módulo -->
    <div class="module-header">
      <div class="container-fluid">
        <div class="header-content">
          <div class="module-info">
            <div class="module-icon-large">
              <i class="fas fa-store-alt"></i>
            </div>
            <div class="module-details">
              <h1 class="module-title">Módulo Mercados</h1>
              <p class="module-subtitle">Sistema de Gestión Comercial Municipal</p>
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
              <p class="stat-value success">107</p>
              <p class="stat-highlight">+8 NUEVOS</p>
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
              <p class="stat-value">6</p>
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
              <p class="stat-value">8</p>
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
          El <strong>Módulo de Mercados</strong> es un sistema integral diseñado para la administración
          completa de mercados municipales, locales comerciales, gestión de adeudos energéticos y
          control de pagos especializados para el sector comercial municipal.
        </p>
        <p class="description-text">
          Migrado completamente de Delphi a una arquitectura moderna con Laravel + Vue.js + PostgreSQL,
          proporciona herramientas avanzadas para la gestión comercial y control administrativo
          de espacios comerciales municipales.
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
                <h4 class="feature-title">Administración de Locales</h4>
                <p class="feature-description">Control completo de espacios comerciales municipales</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Gestión de Adeudos Energéticos</h4>
                <p class="feature-description">Control y seguimiento de consumos y pagos de servicios</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Pagos Especializados</h4>
                <p class="feature-description">Sistema de cobro y facturación para comerciantes</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Control Comercial</h4>
                <p class="feature-description">Seguimiento de actividades y regulaciones comerciales</p>
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
          <h3 class="card-title">⭐ Funcionalidades Principales</h3>
          <span class="badge-new">SISTEMA COMPLETO</span>
        </div>
        <div class="new-features-grid">
          <router-link
            to="/mercados/acceso"
            class="new-feature-card feature-primary"
          >
            <span class="feature-badge">PRINCIPAL</span>
            <div class="feature-icon-new">
              <i class="fas fa-store"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Gestión de Locales</h4>
              <p class="feature-desc-new">Administración completa</p>
              <p class="feature-desc-new">de espacios comerciales</p>
            </div>
          </router-link>

          <router-link
            to="/mercados/adeudos"
            class="new-feature-card feature-warning"
          >
            <span class="feature-badge">ADEUDOS</span>
            <div class="feature-icon-new">
              <i class="fas fa-bolt"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Adeudos Energéticos</h4>
              <p class="feature-desc-new">Control de servicios</p>
              <p class="feature-desc-new">y consumos</p>
            </div>
          </router-link>

          <router-link
            to="/mercados/pagos"
            class="new-feature-card feature-info"
          >
            <span class="feature-badge">PAGOS</span>
            <div class="feature-icon-new">
              <i class="fas fa-credit-card"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Pagos Especializados</h4>
              <p class="feature-desc-new">Facturación y cobro</p>
              <p class="feature-desc-new">para comerciantes</p>
            </div>
          </router-link>

          <router-link
            to="/mercados/reportes"
            class="new-feature-card feature-success"
          >
            <span class="feature-badge">REPORTES</span>
            <div class="feature-icon-new">
              <i class="fas fa-chart-bar"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Reportes y Análisis</h4>
              <p class="feature-desc-new">Estadísticas comerciales</p>
              <p class="feature-desc-new">y control de ingresos</p>
            </div>
          </router-link>
        </div>
      </div>

      <!-- Acciones Rápidas -->
      <div class="quick-actions-card">
        <h3 class="card-title">Acciones Rápidas del Sistema</h3>
        <div class="quick-actions-grid">
          <router-link
            to="/mercados/busqueda"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-search"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Búsqueda de Locales</h4>
              <p class="quick-action-desc">Consultar información comercial</p>
            </div>
          </router-link>

          <router-link
            to="/mercados/registro"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-plus"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Registrar Local</h4>
              <p class="quick-action-desc">Agregar nuevo espacio comercial</p>
            </div>
          </router-link>

          <router-link
            to="/mercados/control"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-clipboard-check"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Control de Pagos</h4>
              <p class="quick-action-desc">Verificar estado de cuentas</p>
            </div>
          </router-link>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
export default {
  name: 'MercadosInfo',
  data() {
    return {
      currentSlide: 0,
      carouselImages: [
        {
          src: '/img/dashboard/mercados-municipales.svg',
          alt: 'Mercados Municipales',
          title: 'Mercados Municipales',
          description: 'Administración y control de espacios comerciales en mercados públicos'
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
/* Estilos específicos del componente MercadosInfo */
.container-fluid {
  padding: 2rem 3rem;
}
</style>