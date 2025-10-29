<template>
  <div class="container py-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Transferencia de datos del Estado al Municipio</li>
      </ol>
    </nav>
    <div class="card mb-4">
      <div class="card-header text-center bg-primary text-white">
        <h5 class="mb-0">Transferencia de datos del Estado al Municipio</h5>
      </div>
      <div class="card-body">
        <h6 class="text-center mb-3">Multas de estacionómetros</h6>
        <form @submit.prevent="onUploadArchivo" enctype="multipart/form-data">
          <div class="row align-items-center mb-3">
            <div class="col-md-6">
              <label for="archivo" class="form-label">Archivo:</label>
              <input type="file" class="form-control" id="archivo" ref="archivo" @change="onFileChange" required />
            </div>
            <div class="col-md-6">
              <button type="submit" class="btn btn-success mt-3 mt-md-0">
                <i class="bi bi-upload"></i> Subir y Procesar Archivo
              </button>
            </div>
          </div>
          <div v-if="archivoNombre" class="alert alert-info py-2">
            Archivo seleccionado: <strong>{{ archivoNombre }}</strong>
          </div>
        </form>
        <div v-if="mensaje" class="alert" :class="{'alert-success': exito, 'alert-danger': !exito}">
          {{ mensaje }}
        </div>
      </div>
    </div>
    <div class="card">
      <div class="card-header bg-secondary text-white">
        <h6 class="mb-0">Últimas Remesas Procesadas</h6>
      </div>
      <div class="card-body p-0">
        <table class="table table-striped mb-0">
          <thead>
            <tr>
              <th class="text-center">Remesa</th>
              <th class="text-center">Fecha Remesa</th>
              <th class="text-center">Fecha Aplicado</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="remesa in remesas" :key="remesa.remesa">
              <td class="text-center">{{ remesa.remesa }}</td>
              <td class="text-center">{{ formatFecha(remesa.fecharemesa) }}</td>
              <td class="text-center">{{ formatFecha(remesa.aplicadoteso) }}</td>
            </tr>
            <tr v-if="remesas.length === 0">
              <td colspan="3" class="text-center">No hay remesas registradas.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'EstadoMpioTransferencia',
  data() {
    return {
      remesas: [],
      archivo: null,
      archivoNombre: '',
      mensaje: '',
      exito: false
    };
  },
  methods: {
    async cargarRemesas() {
      try {
        const resp = await axios.post('/api/execute', {
          eRequest: 'get_remesas_estado_mpio'
        });
        if (resp.data.success) {
          this.remesas = resp.data.data;
        } else {
          this.mensaje = resp.data.message || 'Error al cargar remesas';
          this.exito = false;
        }
      } catch (err) {
        this.mensaje = 'Error de red al cargar remesas';
        this.exito = false;
      }
    },
    onFileChange(e) {
      const files = e.target.files;
      if (files.length > 0) {
        this.archivo = files[0];
        this.archivoNombre = files[0].name;
      } else {
        this.archivo = null;
        this.archivoNombre = '';
      }
    },
    async onUploadArchivo() {
      if (!this.archivo) {
        this.mensaje = 'Seleccione un archivo para subir.';
        this.exito = false;
        return;
      }
      const formData = new FormData();
      formData.append('archivo', this.archivo);
      formData.append('eRequest', 'upload_archivo_estado_mpio');
      try {
        const resp = await axios.post('/api/execute', formData, {
          headers: { 'Content-Type': 'multipart/form-data' }
        });
        if (resp.data.success) {
          this.mensaje = resp.data.message || 'Archivo procesado correctamente.';
          this.exito = true;
          this.archivo = null;
          this.archivoNombre = '';
          this.cargarRemesas();
        } else {
          this.mensaje = resp.data.message || 'Error al procesar archivo.';
          this.exito = false;
        }
      } catch (err) {
        this.mensaje = 'Error de red al subir archivo.';
        this.exito = false;
      }
    },
    formatFecha(fecha) {
      if (!fecha) return '';
      // PostgreSQL devuelve fecha como string ISO
      return new Date(fecha).toLocaleDateString();
    }
  },
  mounted() {
    this.cargarRemesas();
  }
};
</script>

<style scoped>
.container {
  max-width: 700px;
}
.card-header {
  font-weight: bold;
}
</style>
