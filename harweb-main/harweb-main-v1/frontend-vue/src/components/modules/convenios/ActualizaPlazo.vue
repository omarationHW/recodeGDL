<template>
  <div class="actualiza-plazo-page">
    <h1>Actualización de Contratos con Ampliación de Plazo</h1>
    <div class="actions">
      <input type="file" @change="onFileChange" accept=".txt,.csv" />
      <button @click="previewGrid" :disabled="!fileContent">Previsualizar</button>
      <button @click="ejecutarActualizacion" :disabled="!parsedRows.length">Actualizar Plazo</button>
    </div>
    <div v-if="preview.headers.length">
      <h2>Previsualización</h2>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th v-for="(h, i) in preview.headers" :key="i">{{ h }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, i) in preview.rows" :key="i">
            <td v-for="(cell, j) in row" :key="j">{{ cell }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="result.message">
      <div :class="{'alert': true, 'alert-success': result.success, 'alert-danger': !result.success}">
        {{ result.message }}
        <ul v-if="result.data && result.data.errores && result.data.errores.length">
          <li v-for="(err, idx) in result.data.errores" :key="idx">{{ err }}</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ActualizaPlazoPage',
  data() {
    return {
      fileContent: '',
      parsedRows: [],
      preview: { headers: [], rows: [] },
      result: {},
      userId: 1 // Simulación, reemplazar por auth real
    };
  },
  methods: {
    onFileChange(e) {
      const file = e.target.files[0];
      if (!file) return;
      const reader = new FileReader();
      reader.onload = (evt) => {
        this.fileContent = evt.target.result;
      };
      reader.readAsText(file);
    },
    previewGrid() {
      if (!this.fileContent) return;
      const lines = this.fileContent.split(/\r?\n/).filter(l => l.trim() !== '');
      this.parsedRows = lines.map(line => line.split('|').map(f => f.trim()));
      this.preview.headers = [
        'TODO', 'SERIAL', 'OSC', 'EXPEDIENTE', 'FECHA ACT', 'COL', 'CAL', 'FOL',
        'SALDO', 'RECARGOS', 'TOTAL', 'PAGOS', 'INICIAL', 'CANTIDADP', 'FINAL',
        'INICIO', 'FIN', 'TIPO', 'OBSERVACIONES'
      ];
      this.preview.rows = this.parsedRows;
    },
    async ejecutarActualizacion() {
      if (!this.parsedRows.length) return;
      this.result = { message: 'Procesando...', success: true };
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'convenios.actualizarPlazo',
          payload: {
            user_id: this.userId,
            rows: this.parsedRows
          }
        });
        if (res.data.status === 'success') {
          this.result = { success: true, message: res.data.message, data: res.data.data };
        } else {
          this.result = { success: false, message: res.data.message, data: res.data.data };
        }
      } catch (error) {
        this.result = { success: false, message: 'Error de conexión con el servidor' };
      }
    }
  }
};
</script>

<style scoped>
.actualiza-plazo-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.actions {
  margin-bottom: 1rem;
}
table {
  width: 100%;
  font-size: 0.95em;
}
.alert {
  margin-top: 1rem;
  padding: 1rem;
}
.alert-success {
  background: #e6ffe6;
  color: #1a661a;
}
.alert-danger {
  background: #ffe6e6;
  color: #a94442;
}
</style>
