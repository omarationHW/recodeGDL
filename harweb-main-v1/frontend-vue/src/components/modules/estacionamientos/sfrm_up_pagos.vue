<template>
  <div class="up-pagos-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Actualización de Pagos</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        <h4>Actualización de pagos en el sistema</h4>
      </div>
      <div class="card-body">
        <div class="mb-3">
          <label for="fileInput" class="form-label">Seleccionar el archivo para actualizarlo</label>
          <input type="file" class="form-control" id="fileInput" @change="onFileChange" accept=".txt" />
        </div>
        <button class="btn btn-success mb-3" :disabled="!file || loading" @click="uploadFile">
          Aplicar la actualización
        </button>
        <div v-if="loading" class="alert alert-info">Procesando archivo, por favor espere...</div>
        <div v-if="result">
          <div class="alert" :class="{'alert-success': result.success, 'alert-warning': !result.success}">
            {{ result.message }}
          </div>
          <ul class="list-group mb-2">
            <li class="list-group-item">Registros leídos: <strong>{{ result.total }}</strong></li>
            <li class="list-group-item">Registros actualizados: <strong>{{ result.updated }}</strong></li>
            <li class="list-group-item">Errores: <strong>{{ result.errors }}</strong></li>
          </ul>
          <div v-if="result.error_lines && result.error_lines.length > 0">
            <h6>Errores detallados:</h6>
            <ul class="list-group">
              <li v-for="(err, idx) in result.error_lines" :key="idx" class="list-group-item list-group-item-danger">
                Línea: <code>{{ err.line }}</code><br />
                Error: {{ err.error }}
              </li>
            </ul>
          </div>
        </div>
        <div v-if="currentLine" class="alert alert-secondary mt-3">
          <strong>Línea actual:</strong> <code>{{ currentLine }}</code>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'UpPagosPage',
  data() {
    return {
      file: null,
      fileName: '',
      loading: false,
      result: null,
      currentLine: ''
    };
  },
  methods: {
    onFileChange(e) {
      const files = e.target.files;
      if (files && files.length > 0) {
        this.file = files[0];
        this.fileName = files[0].name;
        this.result = null;
        this.currentLine = '';
      }
    },
    uploadFile() {
      if (!this.file) return;
      this.loading = true;
      this.result = null;
      const reader = new FileReader();
      reader.onload = (evt) => {
        const content = evt.target.result;
        // Show first line as currentLine
        const lines = content.split(/\r?\n/);
        this.currentLine = lines[0] || '';
        // Send to API
        this.sendToApi(content);
      };
      reader.readAsText(this.file);
    },
    async sendToApi(content) {
      try {
        const base64 = btoa(unescape(encodeURIComponent(content)));
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: JSON.stringify({
            eRequest: {
              action: 'up_pagos_upload',
              data: {
                file_content: base64,
                filename: this.fileName
              }
            }
          })
        });
        const data = await response.json();
        if (data.eResponse) {
          this.result = data.eResponse;
        } else {
          this.result = { success: false, message: 'Respuesta inesperada del servidor.' };
        }
      } catch (err) {
        this.result = { success: false, message: 'Error de red o del servidor.' };
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.up-pagos-page {
  max-width: 600px;
  margin: 40px auto;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
</style>
