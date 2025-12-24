<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bolt" />
      </div>
      <div class="module-view-info">
        <h1>Sistema de Multas y Reglamentos</h1>
        <p>Bienvenido al módulo de gestión</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Mensaje de bienvenida -->
      <div class="municipal-card splash-card">
        <div class="municipal-card-body text-center">
          <div class="splash-icon">
            <font-awesome-icon icon="gavel" size="4x" />
          </div>
          <h2 class="splash-title">Módulo de Multas y Reglamentos</h2>
          <p class="splash-description">
            Sistema integral para la gestión de multas, sanciones y cumplimiento de reglamentos municipales
          </p>
        </div>
      </div>

      <!-- Características principales -->
      <div class="features-grid">
        <div class="feature-card">
          <div class="feature-icon">
            <font-awesome-icon icon="file-invoice-dollar" size="2x" />
          </div>
          <h3>Gestión de Multas</h3>
          <p>Registro y seguimiento de multas administrativas</p>
        </div>

        <div class="feature-card">
          <div class="feature-icon">
            <font-awesome-icon icon="calculator" size="2x" />
          </div>
          <h3>Cálculos</h3>
          <p>Cálculo automático de recargos y descuentos</p>
        </div>

        <div class="feature-card">
          <div class="feature-icon">
            <font-awesome-icon icon="chart-line" size="2x" />
          </div>
          <h3>Reportes</h3>
          <p>Generación de reportes y estadísticas</p>
        </div>

        <div class="feature-card">
          <div class="feature-icon">
            <font-awesome-icon icon="search" size="2x" />
          </div>
          <h3>Consultas</h3>
          <p>Búsqueda avanzada de registros</p>
        </div>

        <div class="feature-card">
          <div class="feature-icon">
            <font-awesome-icon icon="hand-holding-dollar" size="2x" />
          </div>
          <h3>Pagos</h3>
          <p>Registro y control de pagos</p>
        </div>

        <div class="feature-card">
          <div class="feature-icon">
            <font-awesome-icon icon="users" size="2x" />
          </div>
          <h3>Contribuyentes</h3>
          <p>Gestión de padrones y contribuyentes</p>
        </div>
      </div>

      <!-- Información adicional -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>📋 Información del Sistema</h5>
        </div>
        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item">
              <strong>Versión:</strong>
              <span>2.0</span>
            </div>
            <div class="info-item">
              <strong>Módulo:</strong>
              <span>Multas y Reglamentos</span>
            </div>
            <div class="info-item">
              <strong>Estado:</strong>
              <span class="badge-success">Activo</span>
            </div>
            <div class="info-item">
              <strong>Última actualización:</strong>
              <span>{{ currentDate }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Acciones rápidas -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>⚡ Acciones Rápidas</h5>
        </div>
        <div class="municipal-card-body">
          <div class="quick-actions">
            <button class="action-btn" @click="navigateTo('busque')">
              <font-awesome-icon icon="search" />
              <span>Buscar Registros</span>
            </button>
            <button class="action-btn" @click="navigateTo('pruebacalcas')">
              <font-awesome-icon icon="calculator" />
              <span>Calculadora</span>
            </button>
            <button class="action-btn" @click="navigateTo('proyecfrm')">
              <font-awesome-icon icon="diagram-project" />
              <span>Proyectos</span>
            </button>
            <button class="action-btn" @click="navigateTo('Propuestatab')">
              <font-awesome-icon icon="table" />
              <span>Propuestas</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'psplash'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Sistema de Multas y Reglamentos'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'psplash'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Sistema de Multas y Reglamentos'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const router = useRouter()

const currentDate = computed(() => {
  return new Date().toLocaleDateString('es-MX', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
})

function navigateTo(module) {
  router.push(`/multas_reglamentos/${module}`)
}
</script>

