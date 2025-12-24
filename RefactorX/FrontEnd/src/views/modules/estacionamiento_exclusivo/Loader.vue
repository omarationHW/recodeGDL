<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="parking" /></div>
      <div class="module-view-info">
        <h1>Estacionamiento Exclusivo · {{ viewName }}</h1>
        <p v-if="loading">Cargando componente...</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
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

      <!-- Modal de Ayuda y Documentación -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'Loader'"
        :moduleName="'estacionamiento_exclusivo'"
        :docType="docType"
        :title="'Loader'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const route = useRoute()
const viewName = ref('')
const Component = ref(null)
const loading = ref(false)
const { showLoading, hideLoading } = useGlobalLoading()

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

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

</script>


