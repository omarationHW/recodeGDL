<template>
  <div class="module-view">
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="users" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Usuarios</h1>
        <p>Padrón de Licencias - Gestión de Usuarios</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <div class="placeholder-section">
        <font-awesome-icon icon="users" class="placeholder-icon" />
        <h2>Módulo: Consulta de Usuarios</h2>
        <p class="placeholder-text">
          Este módulo permite consultar y gestionar los usuarios registrados en el Padrón de Licencias.
        </p>
        <p class="placeholder-text">
          <strong>Funcionalidades a implementar:</strong>
        </p>
        <ul class="features-list">
          <li><font-awesome-icon icon="users" /> Listado de usuarios registrados</li>
          <li><font-awesome-icon icon="user" /> Detalle de información del usuario</li>
          <li><font-awesome-icon icon="id-card" /> Licencias asociadas al usuario</li>
          <li><font-awesome-icon icon="file-contract" /> Historial de trámites</li>
        </ul>
      </div>
    </div>
  </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'ConsultaUsuarios'"
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

// Aquí implementaremos la lógica del módulo
</script>
