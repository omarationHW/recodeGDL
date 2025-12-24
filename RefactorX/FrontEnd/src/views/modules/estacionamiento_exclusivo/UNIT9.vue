<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="cubes" />
      </div>
      <div class="module-view-info">
        <h1>UNIT9</h1>
        <p>Unidad de compatibilidad con módulos legacy</p>
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

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Información
          </h5>
        </div>
        <div class="municipal-card-body">
          <p class="text-muted">
            Esta es una vista de compatibilidad para módulos legacy del sistema original.
            UNIT9 servía como módulo base compartido entre diferentes componentes del sistema Delphi.
          </p>
          <div class="alert-info mt-3">
            <font-awesome-icon icon="info-circle" />
            <span>En la versión Vue.js, esta funcionalidad ha sido reemplazada por composables y utilidades compartidas.</span>
          </div>
        </div>
      </div>

      <!-- Modal de Ayuda y Documentación -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'UNIT9'"
        :moduleName="'estacionamiento_exclusivo'"
        :docType="docType"
        :title="'UNIT9'"
        @close="showDocModal = false"
      />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script setup>
import { ref } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

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


