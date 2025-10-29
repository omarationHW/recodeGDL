<template>
  <div class="container-fluid">
    <h2>Carga de Información de Contratos (PasoContratos)</h2>
    <div class="mb-3">
      <input type="file" @change="onFileChange" accept=".txt,.csv" />
      <button class="btn btn-secondary" @click="limpiarTablaPaso">Limpiar Tabla Paso</button>
    </div>
    <div v-if="filePreview.length">
      <h5>Previsualización del archivo</h5>
      <div class="table-responsive" style="max-height: 300px; overflow:auto;">
        <table class="table table-sm table-bordered">
          <thead>
            <tr>
              <th v-for="(col, idx) in columns" :key="idx">{{ col }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in filePreview" :key="idx">
              <td v-for="(cell, cidx) in row" :key="cidx">{{ cell }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <button class="btn btn-primary mt-2" @click="importarArchivo">Importar a BD</button>
    </div>
    <div v-if="importResult">
      <div class="alert alert-info mt-3">{{ importResult.message }}</div>
    </div>
    <div class="mt-4">
      <h5>Preview de datos cargados en tabla de paso</h5>
      <button class="btn btn-outline-info mb-2" @click="getPasoContratosPreview">Refrescar</button>
      <div class="table-responsive" style="max-height: 300px; overflow:auto;">
        <table class="table table-sm table-bordered">
          <thead>
            <tr>
              <th v-for="(col, idx) in columns" :key="idx">{{ col }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in pasoPreview" :key="idx">
              <td v-for="(col, cidx) in columns" :key="cidx">{{ row[col] }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'PasoContratosPage',
  data() {
    return {
      file: null,
      filePreview: [],
      pasoPreview: [],
      columns: [
        'consecutivo','colonia','calle','folio','nombre','desc_calle','numero','tipo','mtrs_frente','mtrs_ancho','metros2','entre_calle_1','entre_calle_2','pago_total','pago_inicial','pago_quincenal','fecha_firma','escritura','propiedad','com_domicilio','otros','observaciones','fecha_imp','fecha_rev','fecha_canc','clave','saldoprra','mensualidad','descuento','motivo','fecha_inicio','fecha_fin','saldo_insoluto','documentacion','impobra_conv','recargos_conv','clave_historia','todo'
      ],
      importResult: null,
      error: null
    }
  },
  methods: {
    onFileChange(e) {
      this.file = e.target.files[0];
      this.importResult = null;
      if (!this.file) return;
      const reader = new FileReader();
      reader.onload = (evt) => {
        const content = evt.target.result;
        this.previewFileContent(content);
      };
      reader.readAsText(this.file);
    },
    previewFileContent(content) {
      this.filePreview = content.split('\n').filter(l => l.trim() !== '').map(l => l.split('|'));
    },
    async importarArchivo() {
      if (!this.file) return;
      this.importResult = null;
      this.error = null;
      const content = await this.readFileAsync(this.file);
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'importPasoContratos',
            payload: { file_content: content }
          })
        });
        const data = await resp.json();
        this.importResult = data;
        if (data.success) {
          this.getPasoContratosPreview();
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async limpiarTablaPaso() {
      this.error = null;
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'limpiarTablaPaso' })
        });
        const data = await resp.json();
        this.importResult = data;
        this.getPasoContratosPreview();
      } catch (e) {
        this.error = e.message;
      }
    },
    async getPasoContratosPreview() {
      this.error = null;
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'getPasoContratosPreview' })
        });
        const data = await resp.json();
        if (data.success) {
          this.pasoPreview = data.data;
        } else {
          this.error = data.message;
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    readFileAsync(file) {
      return new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = (evt) => resolve(evt.target.result);
        reader.onerror = reject;
        reader.readAsText(file);
      });
    }
  },
  mounted() {
    this.getPasoContratosPreview();
  }
}
</script>

<style scoped>
.container-fluid {
  max-width: 1200px;
}
</style>
