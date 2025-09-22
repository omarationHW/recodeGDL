<template>
  <div class="valet-paso-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Pasar datos de Valet</li>
      </ol>
    </nav>
    <h1 class="mb-4">Pasar datos de Valet</h1>
    <div class="card mb-4">
      <div class="card-body">
        <form @submit.prevent="onFileUpload">
          <div class="mb-3">
            <label for="valetFile" class="form-label">Seleccionar archivo</label>
            <input type="file" class="form-control" id="valetFile" ref="fileInput" @change="onFileChange" accept=".csv,.xlsx" required />
          </div>
          <button type="submit" class="btn btn-primary" :disabled="uploading">Abrir archivo</button>
        </form>
        <div v-if="filePreview.length" class="mt-4">
          <h5>Vista previa del archivo</h5>
          <table class="table table-bordered table-sm">
            <tbody>
              <tr v-for="(row, idx) in filePreview" :key="idx">
                <td v-for="(cell, cidx) in row" :key="cidx">{{ cell }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-if="filePath" class="mt-3">
          <button class="btn btn-success" @click="onProcessValet" :disabled="processing">
            Pasar datos de valet
          </button>
        </div>
        <div v-if="message" class="alert mt-3" :class="{'alert-success': success, 'alert-danger': !success}">
          {{ message }}
        </div>
      </div>
    </div>
    <div v-if="processResult && processResult.length">
      <h5>Resultado del procesamiento</h5>
      <pre>{{ processResult }}</pre>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ValetPasoPage',
  data() {
    return {
      file: null,
      filePreview: [],
      filePath: '',
      uploading: false,
      processing: false,
      message: '',
      success: false,
      processResult: null
    };
  },
  methods: {
    onFileChange(e) {
      this.file = e.target.files[0];
      this.filePreview = [];
      this.filePath = '';
      this.message = '';
      this.success = false;
      this.processResult = null;
    },
    async onFileUpload() {
      if (!this.file) return;
      this.uploading = true;
      this.message = '';
      this.success = false;
      const formData = new FormData();
      formData.append('file', this.file);
      formData.append('eRequest[action]', 'open_file');
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          body: formData
        });
        const json = await resp.json();
        if (json.eResponse.success) {
          this.filePreview = json.eResponse.data.preview;
          this.filePath = json.eResponse.data.path;
          this.success = true;
          this.message = json.eResponse.message;
        } else {
          this.success = false;
          this.message = json.eResponse.message;
        }
      } catch (e) {
        this.success = false;
        this.message = 'Error al subir el archivo';
      }
      this.uploading = false;
    },
    async onProcessValet() {
      if (!this.filePath) return;
      this.processing = true;
      this.message = '';
      this.success = false;
      this.processResult = null;
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'process_valet_data',
              file_path: this.filePath
            }
          })
        });
        const json = await resp.json();
        if (json.eResponse.success) {
          this.success = true;
          this.message = json.eResponse.message;
          this.processResult = json.eResponse.data;
        } else {
          this.success = false;
          this.message = json.eResponse.message;
        }
      } catch (e) {
        this.success = false;
        this.message = 'Error al procesar los datos';
      }
      this.processing = false;
    }
  }
};
</script>

<style scoped>
.valet-paso-page {
  max-width: 700px;
  margin: 0 auto;
}
</style>
