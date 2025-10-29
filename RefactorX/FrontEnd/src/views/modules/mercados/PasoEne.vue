<template>
  <div class="module-view">
    <h1>Paso Pagos Energía</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Paso Pagos Energía
    </div>
    <div class="municipal-card">
      <div class="municipal-card-body">
        <form @submit.prevent="onFileUpload">
          <div class="form-group">
            <label for="file">Archivo de Pagos de Energía (.txt)</label>
            <input type="file" id="file" ref="fileInput" @change="handleFile" accept=".txt" required />
          </div>
          <button type="submit" class="btn-municipal-primary" :disabled="loading">Cargar y Previsualizar</button>
        </form>
        <div v-if="parseErrors.length" class="alert alert-danger mt-2">
          <ul>
            <li v-for="err in parseErrors" :key="err">{{ err }}</li>
          </ul>
        </div>
      </div>
    </div>
    <div v-if="rows.length" class="mt-4">
      <h3>Previsualización de Pagos</h3>
      <div class="table-responsive" style="max-height: 400px; overflow:auto;">
        <table class="municipal-table">
          <thead>
            <tr>
              <th>#</th>
              <th>Id Energía</th>
              <th>Año</th>
              <th>Periodo</th>
              <th>Fecha Pago</th>
              <th>Oficina</th>
              <th>Caja</th>
              <th>Operación</th>
              <th>Importe</th>
              <th>Consumo</th>
              <th>Cantidad</th>
              <th>Folio</th>
              <th>Fecha Actualización</th>
              <th>Usuario</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in rows" :key="idx">
              <td>{{ idx+1 }}</td>
              <td>{{ row.id_energia }}</td>
              <td>{{ row.axo }}</td>
              <td>{{ row.periodo }}</td>
              <td>{{ row.fecha_pago }}</td>
              <td>{{ row.oficina_pago }}</td>
              <td>{{ row.caja_pago }}</td>
              <td>{{ row.operacion_pago }}</td>
              <td>{{ row.importe_pago }}</td>
              <td>{{ row.consumo }}</td>
              <td>{{ row.cantidad }}</td>
              <td>{{ row.folio }}</td>
              <td>{{ row.fecha_actualizacion }}</td>
              <td>{{ row.id_usuario }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <button class="btn btn-success mt-3" @click="onBulkInsert" :disabled="loading">Ejecutar Actualización</button>
      <div v-if="insertResult" class="mt-3">
        <div v-if="insertResult.status==='ok'" class="alert alert-success">
          <strong>{{ insertResult.data.inserted }}</strong> registros insertados correctamente.
          <div v-if="insertResult.data.errors.length">
            <hr/>
            <b>Errores:</b>
            <ul>
              <li v-for="err in insertResult.data.errors" :key="err">{{ err }}</li>
            </ul>
          </div>
        </div>
        <div v-else class="alert alert-danger">
          <ul>
            <li v-for="err in insertResult.errors" :key="err">{{ err }}</li>
          </ul>
        </div>
      </div>
    </div>
    <div v-if="loading" class="mt-3">
      <span class="spinner-border spinner-border-sm"></span> Procesando...
    </div>
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'PasoEnePage',
  data() {
    return {
      rows: [],
      parseErrors: [],
      loading: false,
      insertResult: null
    }
  },
  methods: {
    handleFile(e) {
      this.parseErrors = [];
      this.rows = [];
      this.insertResult = null;
      const file = e.target.files[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = (evt) => {
        this.loading = true;
        fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'parse_txt',
            data: { file_content: evt.target.result }
          })
        })
        .then(res => res.json())
        .then(json => {
          if (json.status === 'ok') {
            this.rows = json.data;
          } else {
            this.parseErrors = json.errors || ['Error al parsear archivo'];
          }
        })
        .catch(() => {
          this.parseErrors = ['Error de red o formato'];
        })
        .finally(() => {
          this.loading = false;
        });
      };
      reader.readAsText(file);
    },
    onFileUpload() {
      // Triggered by form submit
      if (!this.$refs.fileInput.files.length) {
        this.parseErrors = ['Seleccione un archivo'];
        return;
      }
      // handleFile is already called on change
    },
    onBulkInsert() {
      if (!this.rows.length) return;
      this.loading = true;
      this.insertResult = null;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'bulk_insert',
          data: { rows: this.rows }
        })
      })
      .then(res => res.json())
      .then(json => {
        this.insertResult = json;
      })
      .catch(() => {
        this.insertResult = { status: 'error', errors: ['Error de red'] };
      })
      .finally(() => {
        this.loading = false;
      });
    }
  }
}
</script>

<style scoped>
.pasoene-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.card {
  margin-bottom: 2rem;
}
.table-responsive {
  border: 1px solid #eee;
  border-radius: 4px;
  background: #fff;
}
</style>
