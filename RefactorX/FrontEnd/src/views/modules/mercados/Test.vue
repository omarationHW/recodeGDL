<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="vial" />
      </div>
      <div class="module-view-info">
        <h1>Componente de Prueba</h1>
        <p>Mercados - Test Component</p>
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
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h2>Test Component</h2>
        </div>
        <div class="municipal-card-body">
          <p>Si puedes ver esto, Vue está funcionando correctamente.</p>
          <button class="btn-municipal-primary" @click="count++">Count: {{ count }}</button>
        </div>
      </div>
    </div>
  </div>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Test'"
      :moduleName="'mercados'"
      @close="closeTechDocs"
    />

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - Test"
    >
      <h3>Test</h3>
      <p>Documentacion del modulo mercados.</p>
    </DocumentationModal>
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref } from 'vue'

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false
const count = ref(0)
</script>
