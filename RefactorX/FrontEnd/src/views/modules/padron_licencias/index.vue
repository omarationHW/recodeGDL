<template>
  <div class="module-view">
    <h1><font-awesome-icon icon="id-card" /> Padrón de Licencias</h1>
    <div class="module-content">
      <p>Módulo en desarrollo...</p>
    </div>
  </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'index'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import { ref } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { useApi } from '@/composables/useApi'

const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { loading, error, data, execute } = useApi()
</script>

