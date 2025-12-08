<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="parking" /></div>
      <div class="module-view-info">
        <h1>Estacionamiento Exclusivo · {{ viewName }}</h1>
        <p v-if="loading">Cargando componente...</p>
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

    <!-- Mostrar spinner mientras carga -->
    <div v-if="loading" class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body text-center">
          <font-awesome-icon icon="spinner" spin size="3x" class="text-primary" />
          <p class="mt-3 text-muted">Cargando {{ viewName }}...</p>
        </div>
      </div>
    </div>

    <!-- Componente cargado dinámicamente -->
    <component v-else-if="Component" :is="Component" />

    <!-- Vista no encontrada -->
    <div v-else class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="error-state">
            <font-awesome-icon icon="exclamation-triangle" size="3x" class="error-icon" />
            <h3>Vista no encontrada</h3>
            <p class="text-muted">No se pudo cargar el componente: <code>{{ viewName }}</code></p>
            <router-link :to="{ name: 'estacionamiento-exclusivo' }" class="btn-municipal-primary mt-3">
              <font-awesome-icon icon="arrow-left" />
              Volver al Inicio
            </router-link>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - Loader"
    >
      <h3>Loader</h3>
      <p>Documentacion del modulo Estacionamiento Exclusivo.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Loader'"
      :moduleName="'estacionamiento_exclusivo'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const viewName = ref('')
const Component = ref(null)
const loading = ref(false)

async function load() {
  loading.value = true
  viewName.value = route.params.view

  try {
    const mod = await import(`./${viewName.value}.vue`)
    Component.value = mod.default || mod
  } catch (e) {
    console.error(`Error al cargar componente ${viewName.value}:`, e)
    Component.value = null
  } finally {
    loading.value = false
  }
}

onMounted(load)
watch(() => route.params.view, load)

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>


