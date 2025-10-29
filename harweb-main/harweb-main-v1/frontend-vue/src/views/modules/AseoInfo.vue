<template>
  <div class="info-container">
    <!-- Header del Módulo -->
    <div class="module-header">
      <div class="container-fluid">
        <div class="header-content">
          <div class="module-info">
            <div class="module-icon-large">
              <i class="fas fa-trash"></i>
            </div>
            <div class="module-details">
              <h1 class="module-title">Módulo Aseo</h1>
              <p class="module-subtitle">Sistema de Gestión de Servicios de Aseo Urbano</p>
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
            <div
              class="carousel-track"
              :style="{ transform: `translateX(-${currentSlide * 100}%)` }"
            >
              <div
                v-for="(image, index) in carouselImages"
                :key="index"
                class="carousel-slide"
              >
                <img
                  :src="image.src"
                  :alt="image.alt"
                  class="carousel-image"
                />
                <div class="carousel-caption">
                  <h3 class="carousel-title">{{ image.title }}</h3>
                  <p class="carousel-description">{{ image.description }}</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Controles del carrusel -->
          <button
            class="carousel-btn carousel-btn-prev"
            @click="prevSlide"
            :disabled="currentSlide === 0"
          >
            <i class="fas fa-chevron-left"></i>
          </button>
          <button
            class="carousel-btn carousel-btn-next"
            @click="nextSlide"
            :disabled="currentSlide === carouselImages.length - 1"
          >
            <i class="fas fa-chevron-right"></i>
          </button>

          <!-- Indicadores -->
          <div class="carousel-indicators">
            <button
              v-for="(image, index) in carouselImages"
              :key="index"
              class="carousel-indicator"
              :class="{ 'active': currentSlide === index }"
              @click="goToSlide(index)"
            ></button>
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
              <p class="stat-value">11</p>
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
          El <strong>Módulo de Aseo</strong> es un sistema especializado para la gestión integral de servicios
          de aseo urbano y recolección de residuos. Permite la administración de empresas recolectoras,
          control de contratos de servicios, gestión de adeudos y cálculo de recargos operativos.
        </p>
        <p class="description-text">
          Migrado completamente de Delphi a arquitectura moderna con Laravel + Vue.js + PostgreSQL,
          ofrece herramientas avanzadas para la optimización de servicios públicos municipales.
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
                <h4 class="feature-title">Gestión de Empresas</h4>
                <p class="feature-description">Administración de empresas recolectoras y proveedores</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Control de Contratos</h4>
                <p class="feature-description">Manejo de contratos de servicios y obligaciones</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Gestión de Adeudos</h4>
                <p class="feature-description">Control de pagos y recuperación de cartera</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Recargos y Gastos</h4>
                <p class="feature-description">Cálculo automático de recargos operativos</p>
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
            to="/aseo/SistemaConveniosAseo"
            class="new-feature-card feature-success"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-handshake"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Sistema de Convenios</h4>
              <p class="feature-desc-new">Gestión integral por</p>
              <p class="feature-desc-new">zona de servicio</p>
            </div>
          </router-link>

          <router-link
            to="/aseo/SistemaApremiosAseo"
            class="new-feature-card feature-primary"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-gavel"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Sistema de Apremios</h4>
              <p class="feature-desc-new">Cobranza especializada</p>
              <p class="feature-desc-new">en servicios de aseo</p>
            </div>
          </router-link>

          <router-link
            to="/aseo/SistemaDescuentosAseo"
            class="new-feature-card feature-warning"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-percentage"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Descuentos y Conversión</h4>
              <p class="feature-desc-new">Sistema automatizado</p>
              <p class="feature-desc-new">para aseo urbano</p>
            </div>
          </router-link>

          <router-link
            to="/aseo/FuncionesExcluidasAseo"
            class="new-feature-card feature-info"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-ban"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Funciones Excluidas</h4>
              <p class="feature-desc-new">Documentación de</p>
              <p class="feature-desc-new">funciones removidas</p>
            </div>
          </router-link>
        </div>
      </div>

      <!-- Acciones Rápidas -->
      <div class="quick-actions-card">
        <h3 class="card-title">Acciones Rápidas Existentes</h3>
        <div class="quick-actions-grid">
          <router-link
            to="/aseo/abc_empresas"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-building"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Gestión Empresas</h4>
              <p class="quick-action-desc">Administrar empresas</p>
            </div>
          </router-link>

          <router-link
            to="/aseo/contratos"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-file-contract"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Control Contratos</h4>
              <p class="quick-action-desc">Gestionar contratos</p>
            </div>
          </router-link>

          <router-link
            to="/aseo/adeudos"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-money-bill"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Gestión Adeudos</h4>
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
  name: 'AseoInfo',
  data() {
    return {
      currentSlide: 0,
      carouselImages: [
        {
          src: '/img/dashboard/limpieza-urbana.svg',
          alt: 'Limpieza Urbana',
          title: 'Limpieza Urbana',
          description: 'Gestión integral de servicios de limpieza y mantenimiento urbano'
        },
        {
          src: '/img/dashboard/recoleccion-residuos.svg',
          alt: 'Recolección de Residuos',
          title: 'Recolección de Residuos',
          description: 'Sistema integral de recolección y tratamiento de residuos urbanos'
        },
        {
          src: '/img/dashboard/mantenimiento-urbano.svg',
          alt: 'Mantenimiento Urbano',
          title: 'Mantenimiento Urbano',
          description: 'Servicios especializados de mantenimiento de infraestructura urbana'
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
/* Estilos específicos del componente AseoInfo */
.container-fluid {
  padding: 2rem 3rem;
}
</style>