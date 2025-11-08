<template>
  <div class="unit9-preview-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Custom Preview</li>
      </ol>
    </nav>
    <div class="panel panel-default mb-3">
      <div class="panel-heading">
        <h3 class="panel-title">Custom Preview</h3>
      </div>
      <div class="panel-body">
        <div class="btn-toolbar mb-2" role="toolbar">
          <button class="btn btn-outline-primary" @click="navigate('first')" title="Primera página"><i class="fas fa-angle-double-left"></i></button>
          <button class="btn btn-outline-primary" @click="navigate('prev')" title="Página anterior"><i class="fas fa-angle-left"></i></button>
          <button class="btn btn-outline-primary" @click="navigate('next')" title="Página siguiente"><i class="fas fa-angle-right"></i></button>
          <button class="btn btn-outline-primary" @click="navigate('last')" title="Última página"><i class="fas fa-angle-double-right"></i></button>
          <button class="btn btn-outline-secondary" @click="loadFromFile" title="Cargar desde archivo"><i class="fas fa-folder-open"></i></button>
          <button class="btn btn-outline-secondary" @click="saveToFile" title="Guardar a archivo"><i class="fas fa-save"></i></button>
          <button class="btn btn-outline-secondary" @click="printPreview" title="Imprimir"><i class="fas fa-print"></i></button>
          <button class="btn btn-outline-secondary" @click="onePage" title="Una página"><i class="fas fa-file"></i></button>
          <button class="btn btn-outline-secondary" @click="zoom100" title="Zoom 100%"><i class="fas fa-search"></i></button>
          <button class="btn btn-outline-secondary" @click="pageWidth" title="Ancho de página"><i class="fas fa-arrows-alt-h"></i></button>
        </div>
        <div class="preview-container border p-3 mb-3" style="min-height:300px; background:#f8f9fa;">
          <div v-if="loading" class="text-center text-muted">
            <i class="fas fa-spinner fa-spin"></i> Cargando vista previa...
          </div>
          <div v-else-if="previewData">
            <!-- Aquí se mostraría la vista previa del reporte -->
            <pre>{{ previewData }}</pre>
          </div>
          <div v-else class="text-center text-muted">
            No hay vista previa disponible.
          </div>
        </div>
        <button class="btn btn-success" @click="closeModal">Aceptar</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Unit9PreviewPage',
  data() {
    return {
      previewData: null,
      loading: false
    };
  },
  methods: {
    async apiRequest(eRequest, params = {}) {
      this.loading = true;
      try {
        const response = await this.$axios.post('/api/execute', { eRequest, params });
        this.loading = false;
        if (response.data && response.data.eResponse && response.data.eResponse.success) {
          return response.data.eResponse.data;
        } else {
          this.$bvToast.toast(response.data.eResponse.message || 'Error en la operación', { title: 'Error', variant: 'danger' });
          return null;
        }
      } catch (e) {
        this.loading = false;
        this.$bvToast.toast(e.message, { title: 'Error', variant: 'danger' });
        return null;
      }
    },
    async navigate(action) {
      const data = await this.apiRequest('UNIT9_PREVIEW_NAVIGATE', { action });
      if (data) this.previewData = data;
    },
    async loadFromFile() {
      const file_path = prompt('Ingrese la ruta del archivo a cargar:');
      if (!file_path) return;
      const data = await this.apiRequest('UNIT9_PREVIEW_LOAD', { file_path });
      if (data) this.previewData = data;
    },
    async saveToFile() {
      const file_path = prompt('Ingrese la ruta del archivo para guardar:');
      if (!file_path) return;
      await this.apiRequest('UNIT9_PREVIEW_SAVE', { file_path });
      this.$bvToast.toast('Archivo guardado.', { title: 'Guardar', variant: 'success' });
    },
    async printPreview() {
      await this.apiRequest('UNIT9_PREVIEW_PRINT');
      this.$bvToast.toast('Enviado a impresión.', { title: 'Imprimir', variant: 'info' });
    },
    async onePage() {
      await this.apiRequest('UNIT9_PREVIEW_ONEPAGE');
      this.$bvToast.toast('Vista de una página.', { title: 'Vista', variant: 'info' });
    },
    async zoom100() {
      await this.apiRequest('UNIT9_PREVIEW_ZOOM', { zoom: 100 });
      this.$bvToast.toast('Zoom al 100%.', { title: 'Zoom', variant: 'info' });
    },
    async pageWidth() {
      await this.apiRequest('UNIT9_PREVIEW_PAGEWIDTH');
      this.$bvToast.toast('Ajustado al ancho de página.', { title: 'Vista', variant: 'info' });
    },
    async closeModal() {
      await this.apiRequest('UNIT9_MODAL_OK');
      this.$router.push('/');
    }
  },
  mounted() {
    // Por defecto, cargar la vista previa inicial (opcional)
    this.navigate('first');
  }
};
</script>

<style scoped>
.unit9-preview-page {
  max-width: 900px;
  margin: 0 auto;
}
.preview-container {
  min-height: 300px;
  background: #f8f9fa;
  border-radius: 4px;
}
.btn-toolbar .btn {
  margin-right: 4px;
}
</style>
