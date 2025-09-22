<template>
  <div class="carga-imagen-page">
    <h1>Documentos asociados al trámite #{{ tramiteId }}</h1>
    <div class="actions">
      <button @click="showUpload = true">Agregar documento</button>
    </div>
    <div v-if="showUpload" class="upload-form">
      <h2>Subir documento</h2>
      <form @submit.prevent="uploadImage">
        <label>Tipo de documento:
          <select v-model="uploadForm.document_type_id" required>
            <option v-for="type in documentTypes" :key="type.id" :value="type.id">{{ type.documento }}</option>
          </select>
        </label>
        <input type="file" @change="onFileChange" accept=".jpg,.jpeg,.tif,.tiff,.png" required />
        <button type="submit">Subir</button>
        <button type="button" @click="showUpload = false">Cancelar</button>
      </form>
    </div>
    <div v-if="loading">Cargando...</div>
    <div v-else>
      <table class="docs-table">
        <thead>
          <tr>
            <th>Tipo de documento</th>
            <th>Ver</th>
            <th>Eliminar</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="doc in docs" :key="doc.id_imagen">
            <td>{{ doc.documento }}</td>
            <td>
              <button @click="viewImage(doc.id_imagen)">Ver</button>
            </td>
            <td>
              <button @click="deleteImage(doc.id_imagen)">Eliminar</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="imageModal" class="modal">
      <div class="modal-content">
        <img :src="imageSrc" alt="Documento" style="max-width: 100%; max-height: 80vh;" />
        <button @click="imageModal = false">Cerrar</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CargaImagenPage',
  props: {
    tramiteId: {
      type: Number,
      required: true
    }
  },
  data() {
    return {
      docs: [],
      documentTypes: [],
      loading: false,
      showUpload: false,
      uploadForm: {
        document_type_id: null,
        file: null
      },
      imageModal: false,
      imageSrc: ''
    };
  },
  mounted() {
    this.fetchDocumentTypes();
    this.fetchDocs();
  },
  methods: {
    async fetchDocumentTypes() {
      this.loading = true;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getDocumentTypes' })
      });
      const data = await res.json();
      this.documentTypes = data.data || [];
      this.loading = false;
    },
    async fetchDocs() {
      this.loading = true;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getTramiteDocs', params: { tramite_id: this.tramiteId } })
      });
      const data = await res.json();
      this.docs = data.data || [];
      this.loading = false;
    },
    onFileChange(e) {
      this.uploadForm.file = e.target.files[0];
    },
    async uploadImage() {
      if (!this.uploadForm.file || !this.uploadForm.document_type_id) return;
      const formData = new FormData();
      formData.append('action', 'uploadImage');
      formData.append('params[tramite_id]', this.tramiteId);
      formData.append('params[document_type_id]', this.uploadForm.document_type_id);
      formData.append('file', this.uploadForm.file);
      this.loading = true;
      const res = await fetch('/api/execute', {
        method: 'POST',
        body: formData
      });
      const data = await res.json();
      this.loading = false;
      if (data.success) {
        this.showUpload = false;
        this.uploadForm.file = null;
        this.uploadForm.document_type_id = null;
        this.fetchDocs();
      } else {
        alert(data.error || 'Error al subir el documento');
      }
    },
    async viewImage(idImagen) {
      this.loading = true;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getImages', params: { id_imagen: idImagen } })
      });
      const data = await res.json();
      this.loading = false;
      if (data.success && data.data) {
        this.imageSrc = 'data:image/jpeg;base64,' + data.data;
        this.imageModal = true;
      } else {
        alert('No se pudo cargar la imagen');
      }
    },
    async deleteImage(idImagen) {
      if (!confirm('¿Está seguro de eliminar este documento?')) return;
      this.loading = true;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'deleteImage', params: { id_imagen: idImagen } })
      });
      const data = await res.json();
      this.loading = false;
      if (data.success) {
        this.fetchDocs();
      } else {
        alert(data.error || 'Error al eliminar el documento');
      }
    }
  }
};
</script>

<style scoped>
.carga-imagen-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.actions {
  margin-bottom: 1rem;
}
.docs-table {
  width: 100%;
  border-collapse: collapse;
}
.docs-table th, .docs-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.upload-form {
  background: #f9f9f9;
  padding: 1rem;
  margin-bottom: 1rem;
  border: 1px solid #eee;
}
.modal {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.modal-content {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  text-align: center;
}
</style>
