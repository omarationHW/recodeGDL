<template>
  <div class="container mt-4">
    <h2>Transferencia de datos del HP3000 a Informix</h2>
    <div class="mb-3">
      <label for="formType" class="form-label">Tipo de Operación</label>
      <select v-model="formType" id="formType" class="form-select" @change="resetForm">
        <option value="A">Altas de Multas de Estacionómetros</option>
        <option value="B">Bajas de Multas de Estacionómetros</option>
        <option value="C">Altas de Calcomanías sin Propietario</option>
      </select>
    </div>
    <div class="mb-3">
      <label for="fileInput" class="form-label">Archivo de datos (TXT)</label>
      <input type="file" id="fileInput" class="form-control" @change="onFileChange" accept=".txt" />
      <div v-if="fileName" class="mt-2"><strong>Archivo seleccionado:</strong> {{ fileName }}</div>
    </div>
    <div v-if="formType === 'B'" class="mb-3">
      <input type="checkbox" id="municipioEstado" v-model="municipioEstado" />
      <label for="municipioEstado">Municipio / Estado (Marcado)</label>
    </div>
    <div v-if="tableData.length > 0" class="mb-3">
      <h5>Vista previa de datos</h5>
      <div class="table-responsive">
        <table class="table table-bordered table-sm">
          <thead>
            <tr>
              <th v-for="col in columns" :key="col">{{ col }}</th>
              <th>Resultado</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in tableData" :key="idx">
              <td v-for="col in columns" :key="col">{{ row[col] }}</td>
              <td>{{ row.result || '' }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div class="mb-3">
      <button class="btn btn-primary me-2" :disabled="!canProcess" @click="processFile">Procesar Archivo</button>
      <button class="btn btn-success" :disabled="!canSend" @click="sendToApi">Enviar a Servidor</button>
    </div>
    <div v-if="apiResult" class="alert" :class="{'alert-success': apiResult.status==='ok', 'alert-danger': apiResult.status==='error'}">
      <div><strong>{{ apiResult.message }}</strong></div>
      <div v-if="apiResult.results && apiResult.results.length">
        <ul>
          <li v-for="(res, idx) in apiResult.results" :key="idx">
            {{ res.status }} - {{ res.message }}
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TransfoliosForm',
  data() {
    return {
      formType: 'A',
      file: null,
      fileName: '',
      tableData: [],
      columns: [],
      municipioEstado: false,
      apiResult: null,
      usuario_id: 1, // Simulado, debe venir de sesión real
      ejercicio: 2024 // Simulado, debe venir de sesión real
    };
  },
  computed: {
    canProcess() {
      return !!this.file;
    },
    canSend() {
      return this.tableData.length > 0;
    }
  },
  methods: {
    resetForm() {
      this.file = null;
      this.fileName = '';
      this.tableData = [];
      this.columns = [];
      this.apiResult = null;
    },
    onFileChange(e) {
      this.file = e.target.files[0];
      this.fileName = this.file ? this.file.name : '';
      this.tableData = [];
      this.apiResult = null;
    },
    processFile() {
      if (!this.file) return;
      const reader = new FileReader();
      reader.onload = (e) => {
        const lines = e.target.result.split(/\r?\n/).filter(l => l.trim() !== '');
        let data = [];
        if (this.formType === 'A') {
          // Altas de Multas de Estacionómetros
          this.columns = ['axo', 'folio', 'placa', 'fecha_folio', 'infraccion'];
          lines.forEach(line => {
            data.push({
              axo: line.substr(4,4).trim(),
              folio: line.substr(40,7).trim(),
              placa: line.substr(9,7).trim(),
              fecha_folio: line.substr(37,2) + line.substr(33,4) + line.substr(29,4),
              infraccion: line.substr(48,1).trim()
            });
          });
        } else if (this.formType === 'B') {
          // Bajas de Multas de Estacionómetros
          this.columns = ['axo', 'folio', 'placa'];
          lines.forEach(line => {
            data.push({
              axo: line.substr(0,4).trim(),
              folio: line.substr(5,7).trim(),
              placa: line.substr(24,7).trim()
            });
          });
        } else if (this.formType === 'C') {
          // Altas de Calcomanías sin Propietario
          this.columns = ['calco', 'tipo', 'turno', 'fecha_inicial', 'fecha_final', 'placa'];
          lines.forEach(line => {
            data.push({
              calco: line.substr(0,10).trim(),
              tipo: line.substr(10,10).trim(),
              turno: line.substr(20,10).trim(),
              fecha_inicial: line.substr(30,10).trim(),
              fecha_final: line.substr(40,10).trim(),
              placa: line.substr(50,10).trim()
            });
          });
        }
        this.tableData = data;
      };
      reader.readAsText(this.file);
    },
    async sendToApi() {
      this.apiResult = null;
      let action = '';
      let payload = [];
      if (this.formType === 'A') {
        action = 'altas_folios';
        payload = this.tableData.map(row => ({
          axo: row.axo,
          folio: row.folio,
          placa: row.placa,
          fec: this.parseDate(row.fecha_folio),
          clave: row.infraccion
        }));
      } else if (this.formType === 'B') {
        action = 'bajas_folios';
        payload = this.tableData.map(row => ({
          axo: row.axo,
          folio: row.folio,
          placa: row.placa,
          fecha: new Date().toISOString().slice(0,10),
          opc: this.municipioEstado ? 6 : 7
        }));
      } else if (this.formType === 'C') {
        action = 'altas_calcomanias';
        payload = this.tableData.map(row => ({
          calco: row.calco,
          status: row.tipo,
          turno: row.turno,
          fecini: this.parseDate(row.fecha_inicial),
          fecfin: this.parseDate(row.fecha_final),
          placa: row.placa
        }));
      }
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action,
              data: payload,
              usuario_id: this.usuario_id,
              ejercicio: this.ejercicio
            }
          })
        });
        const json = await res.json();
        this.apiResult = json.eResponse;
        // Marcar resultados en tabla
        if (this.apiResult.results && this.apiResult.results.length === this.tableData.length) {
          this.tableData = this.tableData.map((row, idx) => ({
            ...row,
            result: this.apiResult.results[idx].status
          }));
        }
      } catch (e) {
        this.apiResult = { status: 'error', message: e.message, results: [] };
      }
    },
    parseDate(str) {
      // Intenta parsear fechas tipo DDMMYYYY o similar
      if (!str) return null;
      let s = str.replace(/[^0-9]/g, '');
      if (s.length === 8) {
        // Asume DDMMYYYY
        return `${s.substr(4,4)}-${s.substr(2,2)}-${s.substr(0,2)}`;
      }
      return str;
    }
  }
};
</script>

<style scoped>
.container {
  max-width: 900px;
}
</style>
