<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Cons Condonacion Energia</h1>
        <p>Mercados - Gestión de Energía</p>
      </div>
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
      <div class="container-fluid mt-4">
          <div class="alert alert-info" role="alert">
            <h4 class="alert-heading">🏪 Cons Condonacion Energia</h4>
            <p>Este componente está en desarrollo y será implementado próximamente.</p>
            <hr>
            <p class="mb-0">
              <small><strong>Módulo:</strong> Mercados | <strong>Componente:</strong> ConsCondonacionEnergia</small>
            </p>
          </div>
          
          <div class="municipal-card">
            <div class="municipal-card">
              <h5 class="mb-0">Cons Condonacion Energia</h5>
            </div>
            <div class="municipal-card">
              <p class="text-muted">
                Funcionalidad pendiente de implementación para el sistema de mercados.
              </p>
              <div class="d-flex justify-content-between align-items-center">
                <span class="badge bg-warning">En desarrollo</span>
                <small class="text-muted">Módulo: Mercados</small>
              </div>
            </div>
          </div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'ConsCondonacionEnergia'"
      :moduleName="'mercados'"
      @close="closeDocumentation"
    />
  </div>
  <!-- /module-view -->
</template>

<script>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

export default {
  components: {
    DocumentationModal
  },
  name: 'ConsCondonacionEnergia',
  data() {
    return {
      // Datos del componente,
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }}
  },
  mounted() {
    console.log('Componente ConsCondonacionEnergia montado (placeholder)');
  }
}
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
