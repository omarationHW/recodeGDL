<template>
  <div class="info-container">
    <!-- Header del Módulo -->
    <div class="module-header">
      <div class="container-fluid">
        <div class="header-content">
          <div class="module-info">
            <div class="module-icon-large">
              <i class="fas fa-file-contract"></i>
            </div>
            <div class="module-details">
              <h1 class="module-title">Módulo Licencias</h1>
              <p class="module-subtitle">Sistema de Gestión de Licencias Comerciales y Permisos</p>
            </div>
          </div>
          <div>
            <router-link to="/" class="btn-back">
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
              <p class="stat-label">Formularios</p>
              <p class="stat-value success">101</p>
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
              <p class="stat-value">5</p>
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

      <!-- Descripción del Módulo -->
      <div class="description-card">
        <h2 class="section-title">Descripción del Módulo</h2>
        <p class="description-text">
          El <strong>Módulo de Licencias</strong> es un sistema integral diseñado para la gestión completa
          de licencias comerciales, anuncios publicitarios y permisos municipales. Este módulo permite
          la tramitación eficiente de solicitudes, seguimiento de procesos y consultas administrativas.
        </p>
        <p class="description-text">
          Migrado completamente de Delphi a una arquitectura moderna con Laravel + Vue.js + PostgreSQL,
          ofrece una interfaz intuitiva y procesos automatizados para optimizar la gestión municipal.
        </p>
      </div>

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
                <h4 class="feature-title">Gestión de Licencias Comerciales</h4>
                <p class="feature-description">Administración completa del ciclo de vida de licencias</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Control de Anuncios Publicitarios</h4>
                <p class="feature-description">Regulación y seguimiento de publicidad comercial</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Tramitación Digital</h4>
                <p class="feature-description">Procesos automatizados y seguimiento en línea</p>
              </div>
            </div>
            <div class="feature-item">
              <div class="feature-icon">
                <i class="fas fa-check"></i>
              </div>
              <div>
                <h4 class="feature-title">Consultas Administrativas</h4>
                <p class="feature-description">Sistema de consultas y reportes especializados</p>
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
            to="/licencias/perfilesusuariomoderno"
            class="new-feature-card feature-primary"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-users-cog"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Perfiles de Usuario</h4>
              <p class="feature-desc-new">Separación granular</p>
              <p class="feature-desc-new">(Padrón/Licencias/Ingresos)</p>
            </div>
          </router-link>

          <router-link
            to="/licencias/catalogogirosimportes"
            class="new-feature-card feature-warning"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-money-check-alt"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Giros con Importes</h4>
              <p class="feature-desc-new">Gestión de costos</p>
              <p class="feature-desc-new">para usuarios ingresos</p>
            </div>
          </router-link>

          <router-link
            to="/licencias/permisosprovisionales"
            class="new-feature-card feature-info"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-clock"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Permisos Temporales</h4>
              <p class="feature-desc-new">Espectáculos, Licencias</p>
              <p class="feature-desc-new">y Anuncios</p>
            </div>
          </router-link>

          <router-link
            to="/licencias/sistemaconvenios"
            class="new-feature-card feature-success"
          >
            <span class="feature-badge">NUEVO</span>
            <div class="feature-icon-new">
              <i class="fas fa-handshake"></i>
            </div>
            <div class="feature-content-new">
              <h4 class="feature-title-new">Sistema Convenios</h4>
              <p class="feature-desc-new">ABC completo:</p>
              <p class="feature-desc-new">Intereses y Parcialidades</p>
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
              to="/licencias/empresasfrm"
              class="updated-card"
            >
              <span class="updated-badge">CAMPO GÉNERO</span>
              <div class="updated-icon">
                <i class="fas fa-building"></i>
              </div>
              <div>
                <h4 class="updated-card-title">Empresas</h4>
                <p class="updated-card-desc">Ahora con campo Género</p>
                <p class="updated-card-desc">(Mujer/Hombre/Sociedad)</p>
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
            to="/licencias/agendavisitasfrm"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-calendar"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Agenda de Visitas</h4>
              <p class="quick-action-desc">Programar inspecciones</p>
            </div>
          </router-link>

          <router-link
            to="/licencias/busque"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-search"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Búsqueda General</h4>
              <p class="quick-action-desc">Consultar licencias</p>
            </div>
          </router-link>

          <router-link
            to="/licencias/nuevalicencia"
            class="quick-action-item"
          >
            <div class="quick-action-icon">
              <i class="fas fa-plus"></i>
            </div>
            <div>
              <h4 class="quick-action-title">Nueva Licencia</h4>
              <p class="quick-action-desc">Crear solicitud</p>
            </div>
          </router-link>
        </div>
      </div>

    </div>
  </div>

  
</template>

<script>
export default {
  name: 'LicenciasInfo',
  data() {
    return {
      currentSlide: 0,
      carouselImages: [
        {
          src: '/img/dashboard/licencias-comerciales.svg',
          alt: 'Gestión de Licencias Comerciales',
          title: 'Licencias Comerciales',
          description: 'Administración completa del ciclo de vida de licencias para establecimientos comerciales'
        },
        {
          src: '/img/dashboard/anuncios-publicitarios.svg',
          alt: 'Control de Anuncios Publicitarios',
          title: 'Anuncios Publicitarios',
          description: 'Regulación y seguimiento de publicidad comercial en espacios públicos'
        },
        {
          src: '/img/dashboard/tramitacion-digital.svg',
          alt: 'Tramitación Digital',
          title: 'Tramitación Digital',
          description: 'Procesos automatizados y seguimiento en línea de trámites municipales'
        },
        {
          src: '/img/dashboard/consultas-administrativas.svg',
          alt: 'Consultas Administrativas',
          title: 'Consultas Administrativas',
          description: 'Sistema de consultas y reportes especializados para gestión municipal'
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
/* Estilos específicos del componente LicenciasInfo */
.container-fluid {
  padding: 2rem 3rem;
}
</style>