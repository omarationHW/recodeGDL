<template>
  <div class="info-container">
    <!-- Header del Módulo -->
    <div class="module-header">
      <div class="container-fluid">
        <div class="header-content">
          <div class="module-info">
            <div class="module-icon-large">
              <i class="fas fa-tasks"></i>
            </div>
            <div class="module-details">
              <h1 class="module-title">Módulo Otras Obligaciones</h1>
              <p class="module-subtitle">Sistema de Gestión de Obligaciones Diversas</p>
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
              <p class="stat-value success">3</p>
              <p class="stat-highlight">SISTEMAS MODERNOS</p>
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
              <p class="stat-value">4</p>
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
              <p class="stat-value">6</p>
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
          El <strong>Módulo de Otras Obligaciones</strong> es un sistema especializado para la gestión
          integral de obligaciones fiscales diversas, carga de carteras, valores, etiquetas y reportes
          auxiliares especializados que no se clasifican en otros módulos específicos.
        </p>
        <p class="description-text">
          Migrado completamente de Delphi a una arquitectura moderna con Laravel + Vue.js + PostgreSQL,
          ofrece herramientas avanzadas para la administración de obligaciones municipales diversas
          y servicios especiales.
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
                <h4 class="feature-title">Carga de Carteras</h4>
                <p class="feature-description">Gestión de carteras de obligaciones diversas</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Valores y Etiquetas</h4>
                <p class="feature-description">Control de documentos de valor y etiquetado</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Reportes Auxiliares</h4>
                <p class="feature-description">Informes especializados y reportes auxiliares</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Gestión Diversa</h4>
                <p class="feature-description">Administración de obligaciones no clasificadas</p>
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
            to="/otras-oblig/sistemaapremios"
            class="new-feature-card feature-primary"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-gavel"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Sistema de Apremios</h4>
              <p class="feature-desc-new">Gestión de cobranza</p>
              <p class="feature-desc-new">coactiva especializada</p>
            </div>
          </router-link>

          <router-link
            to="/otras-oblig/sistemaconvenios"
            class="new-feature-card feature-warning"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-handshake"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Sistema de Convenios</h4>
              <p class="feature-desc-new">Acuerdos de pago</p>
              <p class="feature-desc-new">e intereses</p>
            </div>
          </router-link>

          <router-link
            to="/otras-oblig/sistemadescuentos"
            class="new-feature-card feature-info"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-percentage"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Sistema de Descuentos</h4>
              <p class="feature-desc-new">Descuentos automáticos</p>
              <p class="feature-desc-new">y conversiones</p>
            </div>
          </router-link>

          <router-link
            to="/otras-oblig/funcionesexcluidas"
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
            to="/otras-oblig/busqueda"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-search"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Búsqueda General</h4>
              <p class="quick-action-desc">Consultar obligaciones</p>
            </div>
          </router-link>

          <router-link
            to="/otras-oblig/cargar"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-upload"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Cargar Cartera</h4>
              <p class="quick-action-desc">Importar obligaciones</p>
            </div>
          </router-link>

          <router-link
            to="/otras-oblig/reportes"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-chart-bar"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Reportes Auxiliares</h4>
              <p class="quick-action-desc">Informes especializados</p>
            </div>
          </router-link>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
export default {
  name: 'OtrasObligInfo',
  data() {
    return {
      currentSlide: 0,
      carouselImages: [
        {
          src: '/img/dashboard/otras-obligaciones.svg',
          alt: 'Otras Obligaciones',
          title: 'Otras Obligaciones',
          description: 'Servicios múltiples y trámites diversos de obligaciones municipales'
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
/* Estilos específicos del componente OtrasObligInfo */
.container-fluid {
  padding: 2rem 3rem;
}
</style>