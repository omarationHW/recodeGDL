<template>
  <div class="unit9-preview-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Vista previa de Reporte (UNIT9)</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header d-flex align-items-center">
        <span class="me-3">Vista previa de Reporte</span>
        <div class="btn-group btn-group-sm ms-auto" role="group">
          <button class="btn btn-outline-secondary" :disabled="pageIndex === 0" @click="firstPage" title="Primera página"><i class="bi bi-skip-backward-fill"></i></button>
          <button class="btn btn-outline-secondary" :disabled="pageIndex === 0" @click="prevPage" title="Página anterior"><i class="bi bi-caret-left-fill"></i></button>
          <button class="btn btn-outline-secondary" :disabled="pageIndex === pages.length - 1" @click="nextPage" title="Página siguiente"><i class="bi bi-caret-right-fill"></i></button>
          <button class="btn btn-outline-secondary" :disabled="pageIndex === pages.length - 1" @click="lastPage" title="Última página"><i class="bi bi-skip-forward-fill"></i></button>
          <button class="btn btn-outline-secondary" @click="loadReport" title="Cargar reporte"><i class="bi bi-folder2-open"></i></button>
          <button class="btn btn-outline-secondary" @click="saveReport" title="Guardar reporte"><i class="bi bi-save"></i></button>
          <button class="btn btn-outline-secondary" @click="printReport" title="Imprimir"><i class="bi bi-printer"></i></button>
          <button class="btn btn-outline-secondary" @click="zoomToFit" title="Zoom a una página"><i class="bi bi-arrows-fullscreen"></i></button>
          <button class="btn btn-outline-secondary" @click="zoom100" title="Zoom 100%"><i class="bi bi-zoom-in"></i></button>
          <button class="btn btn-outline-secondary" @click="zoomWidth" title="Zoom ancho de página"><i class="bi bi-arrows-angle-expand"></i></button>
          <button class="btn btn-outline-danger" @click="closePreview" title="Cerrar"><i class="bi bi-x-lg"></i></button>
        </div>
      </div>
      <div class="card-body preview-container" style="min-height: 400px; background: #f8f9fa;">
        <div v-if="loading" class="text-center py-5">
          <div class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
        </div>
        <div v-else-if="pages.length > 0">
          <div class="report-preview" :style="previewStyle">
            <div v-html="pages[pageIndex].content"></div>
          </div>
          <div class="text-center mt-2">
            Página {{ pageIndex + 1 }} de {{ pages.length }}
          </div>
        </div>
        <div v-else class="text-center py-5 text-muted">
          No hay datos de reporte para mostrar.
        </div>
      </div>
    </div>
    <!-- Modal para cargar/guardar -->
    <div class="modal fade" id="fileModal" tabindex="-1" aria-labelledby="fileModalLabel" aria-hidden="true" ref="fileModal">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="fileModalLabel">{{ modalTitle }}</h5>
            <button type="button" class="btn-close" @click="closeFileModal"></button>
          </div>
          <div class="modal-body">
            <input type="text" class="form-control" v-model="filename" placeholder="Nombre de archivo...">
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="closeFileModal">Cancelar</button>
            <button type="button" class="btn btn-primary" @click="confirmFileModal">Aceptar</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Unit9Preview',
  data() {
    return {
      loading: false,
      pages: [], // [{content: '<html>'}]
      pageIndex: 0,
      zoom: 100,
      showFileModal: false,
      modalTitle: '',
      filename: '',
      fileAction: null // 'load' or 'save'
    };
  },
  computed: {
    previewStyle() {
      return {
        transform: `scale(${this.zoom / 100})`,
        transformOrigin: 'top left',
        border: '1px solid #ccc',
        background: '#fff',
        margin: '0 auto',
        minHeight: '500px',
        minWidth: '700px',
        boxShadow: '0 2px 8px rgba(0,0,0,0.05)'
      };
    }
  },
  mounted() {
    this.fetchReportPreview();
  },
  methods: {
    async fetchReportPreview() {
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: 'UNIT9_REPORT_PREVIEW' })
        });
        const json = await res.json();
        if (json.eResponse.success) {
          // Simulate pages: [{content: ...}]
          this.pages = json.eResponse.data.length ? json.eResponse.data : [];
          this.pageIndex = 0;
        } else {
          this.pages = [];
          this.$toast && this.$toast.error(json.eResponse.message || 'Error al cargar reporte');
        }
      } catch (e) {
        this.pages = [];
        this.$toast && this.$toast.error('Error de red');
      } finally {
        this.loading = false;
      }
    },
    firstPage() {
      this.pageIndex = 0;
    },
    prevPage() {
      if (this.pageIndex > 0) this.pageIndex--;
    },
    nextPage() {
      if (this.pageIndex < this.pages.length - 1) this.pageIndex++;
    },
    lastPage() {
      this.pageIndex = this.pages.length - 1;
    },
    zoomToFit() {
      this.zoom = 80;
    },
    zoom100() {
      this.zoom = 100;
    },
    zoomWidth() {
      this.zoom = 120;
    },
    loadReport() {
      this.modalTitle = 'Cargar reporte';
      this.fileAction = 'load';
      this.filename = '';
      this.openFileModal();
    },
    saveReport() {
      this.modalTitle = 'Guardar reporte';
      this.fileAction = 'save';
      this.filename = '';
      this.openFileModal();
    },
    printReport() {
      // Simula impresión
      window.print();
      // O llamar API para imprimir en backend
      // this.apiPrintReport();
    },
    closePreview() {
      this.$router.push('/');
    },
    openFileModal() {
      this.showFileModal = true;
      setTimeout(() => {
        if (this.$refs.fileModal) {
          // Bootstrap 5 modal
          const modal = new window.bootstrap.Modal(this.$refs.fileModal);
          modal.show();
          this.bsModal = modal;
        }
      }, 100);
    },
    closeFileModal() {
      this.showFileModal = false;
      if (this.bsModal) {
        this.bsModal.hide();
      }
    },
    async confirmFileModal() {
      if (!this.filename) {
        this.$toast && this.$toast.error('Debe ingresar un nombre de archivo');
        return;
      }
      if (this.fileAction === 'load') {
        await this.apiLoadReport();
      } else if (this.fileAction === 'save') {
        await this.apiSaveReport();
      }
      this.closeFileModal();
    },
    async apiLoadReport() {
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: 'UNIT9_REPORT_LOAD', params: { filename: this.filename } })
        });
        const json = await res.json();
        if (json.eResponse.success) {
          this.pages = json.eResponse.data.length ? json.eResponse.data : [];
          this.pageIndex = 0;
          this.$toast && this.$toast.success('Reporte cargado');
        } else {
          this.$toast && this.$toast.error(json.eResponse.message || 'Error al cargar reporte');
        }
      } catch (e) {
        this.$toast && this.$toast.error('Error de red');
      } finally {
        this.loading = false;
      }
    },
    async apiSaveReport() {
      this.loading = true;
      try {
        const report_data = JSON.stringify(this.pages);
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: 'UNIT9_REPORT_SAVE', params: { filename: this.filename, report_data } })
        });
        const json = await res.json();
        if (json.eResponse.success) {
          this.$toast && this.$toast.success('Reporte guardado');
        } else {
          this.$toast && this.$toast.error(json.eResponse.message || 'Error al guardar reporte');
        }
      } catch (e) {
        this.$toast && this.$toast.error('Error de red');
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.unit9-preview-page {
  max-width: 1000px;
  margin: 0 auto;
  padding: 2rem 0;
}
.preview-container {
  min-height: 400px;
  background: #f8f9fa;
}
.report-preview {
  background: #fff;
  min-height: 500px;
  min-width: 700px;
  margin: 0 auto;
  padding: 2rem;
  border-radius: 6px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
</style>
