<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-alt" />
      </div>
      <div class="module-view-info">
        <h1>Otras Obligaciones</h1>
        <p>Sistema de gestión de otras obligaciones fiscales</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="quick-access-grid">
      <div class="quick-access-card">
        <div class="card-icon gestion">
          <font-awesome-icon icon="folder-open" />
        </div>
        <h3>Gestión</h3>
        <p>Operaciones de gestión de obligaciones</p>
        <div class="card-links">
          <router-link to="/otras-obligaciones/g-nuevos">Nuevos</router-link>
          <router-link to="/otras-obligaciones/g-consulta">Consulta</router-link>
          <router-link to="/otras-obligaciones/g-actualiza">Actualizar</router-link>
          <router-link to="/otras-obligaciones/g-baja">Baja</router-link>
          <router-link to="/otras-obligaciones/g-adeudos">Adeudos</router-link>
        </div>
      </div>

      <div class="quick-access-card">
        <div class="card-icon recaudadora">
          <font-awesome-icon icon="hand-holding-usd" />
        </div>
        <h3>Recaudadora</h3>
        <p>Operaciones de recaudadora</p>
        <div class="card-links">
          <router-link to="/otras-obligaciones/r-nuevos">Nuevos</router-link>
          <router-link to="/otras-obligaciones/r-consulta">Consulta</router-link>
          <router-link to="/otras-obligaciones/r-actualiza">Actualizar</router-link>
          <router-link to="/otras-obligaciones/r-baja">Baja</router-link>
          <router-link to="/otras-obligaciones/r-adeudos">Adeudos</router-link>
        </div>
      </div>

      <div class="quick-access-card">
        <div class="card-icon reportes">
          <font-awesome-icon icon="chart-bar" />
        </div>
        <h3>Reportes</h3>
        <p>Reportes y estadísticas</p>
        <div class="card-links">
          <router-link to="/otras-obligaciones/g-rep-padron">Padrón Gestión</router-link>
          <router-link to="/otras-obligaciones/r-rep-padron">Padrón Recaudadora</router-link>
          <router-link to="/otras-obligaciones/aux-rep">Auxiliares</router-link>
          <router-link to="/otras-obligaciones/etiquetas">Etiquetas</router-link>
        </div>
      </div>

      <div class="quick-access-card">
        <div class="card-icon config">
          <font-awesome-icon icon="cog" />
        </div>
        <h3>Configuración</h3>
        <p>Catálogos y configuración</p>
        <div class="card-links">
          <router-link to="/otras-obligaciones/rubros">Rubros</router-link>
          <router-link to="/otras-obligaciones/carga-cartera">Carga Cartera</router-link>
          <router-link to="/otras-obligaciones/carga-valores">Carga Valores</router-link>
          <router-link to="/otras-obligaciones/apremios">Apremios</router-link>
        </div>
      </div>
      </div>
    </div>
  </div>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'index'"
      :moduleName="'otras_obligaciones'"
      @close="closeTechDocs"
    />

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - index"
    >
      <h3>index</h3>
      <p>Documentacion del modulo otras_obligaciones.</p>
    </DocumentationModal>
</template>

<script setup>
import { ref } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false
</script>
