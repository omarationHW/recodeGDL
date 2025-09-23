<template>
  <div class="adeudos-mult-ins-page">
    <h1>Generación Múltiple de Excedentes</h1>
    <div class="form-section">
      <div class="row">
        <div class="col">
          <label>Tipo de Aseo</label>
          <select v-model="form.tipoAseo">
            <option v-for="t in catalogs.tiposAseo" :key="t.ctrol_aseo" :value="t.ctrol_aseo">
              {{ t.ctrol_aseo }} - {{ t.tipo_aseo }} - {{ t.descripcion }}
            </option>
          </select>
        </div>
        <div class="col">
          <label>Periodo de Adeudo</label>
          <input v-model="form.anio" type="number" maxlength="4" style="width:70px" />
          <select v-model="form.mes" style="width:70px">
            <option v-for="m in catalogs.meses" :key="m.value" :value="m.value">{{ m.value }}</option>
          </select>
        </div>
        <div class="col">
          <label>Oficio</label>
          <input v-model="form.oficio" maxlength="15" style="width:120px" />
        </div>
        <div class="col">
          <label>Tipo de Movimiento</label>
          <select v-model="form.tipoOper">
            <option v-for="t in catalogs.tiposOper" :key="t.ctrol_operacion" :value="t.ctrol_operacion">
              {{ t.ctrol_operacion }} - {{ t.cve_operacion }} - {{ t.descripcion }}
            </option>
          </select>
        </div>
      </div>
    </div>
    <div class="sheet-section">
      <table class="sheet-table">
        <thead>
          <tr>
            <th>Contrato</th>
            <th>Excedencia</th>
            <th>Diagnóstico</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in sheetRows" :key="idx">
            <td><input v-model="row.contrato" type="number" min="1" /></td>
            <td><input v-model="row.excedencia" type="number" min="1" /></td>
            <td>{{ row.diagnostico || '' }}</td>
          </tr>
        </tbody>
      </table>
      <button @click="addRow">Agregar fila</button>
      <button @click="removeRow" :disabled="sheetRows.length <= 1">Eliminar última fila</button>
    </div>
    <div class="actions">
      <button @click="validateSheet">Validar</button>
      <button @click="saveSheet" :disabled="!sheetValid">Grabar</button>
      <span v-if="sheetErrors.length" class="error-list">
        <ul>
          <li v-for="(err, i) in sheetErrors" :key="i">{{ err }}</li>
        </ul>
      </span>
      <span v-if="successMessage" class="success">{{ successMessage }}</span>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdeudosMultInsPage',
  data() {
    return {
      catalogs: {
        tiposAseo: [],
        tiposOper: [],
        meses: []
      },
      form: {
        tipoAseo: '',
        tipoOper: '',
        anio: new Date().getFullYear(),
        mes: '01',
        oficio: ''
      },
      sheetRows: [
        { contrato: '', excedencia: '', diagnostico: '' }
      ],
      sheetValid: false,
      sheetErrors: [],
      successMessage: ''
    };
  },
  created() {
    this.loadCatalogs();
  },
  methods: {
    async loadCatalogs() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getCatalogs' })
      });
      this.catalogs = await res.json();
      if (this.catalogs.tiposAseo.length) this.form.tipoAseo = this.catalogs.tiposAseo[0].ctrol_aseo;
      if (this.catalogs.tiposOper.length) this.form.tipoOper = this.catalogs.tiposOper[0].ctrol_operacion;
      if (this.catalogs.meses.length) this.form.mes = this.catalogs.meses[0].value;
    },
    addRow() {
      this.sheetRows.push({ contrato: '', excedencia: '', diagnostico: '' });
    },
    removeRow() {
      if (this.sheetRows.length > 1) this.sheetRows.pop();
    },
    async validateSheet() {
      this.sheetErrors = [];
      this.successMessage = '';
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'validateSheet',
          params: {
            tipoAseo: this.form.tipoAseo,
            tipoOper: this.form.tipoOper,
            anio: this.form.anio,
            mes: this.form.mes,
            oficio: this.form.oficio,
            rows: this.sheetRows
          }
        })
      });
      const data = await res.json();
      this.sheetValid = data.valid;
      this.sheetErrors = data.errors || [];
      if (this.sheetValid) this.successMessage = 'Validación exitosa. Puede grabar.';
    },
    async saveSheet() {
      this.sheetErrors = [];
      this.successMessage = '';
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'saveSheet',
          params: {
            tipoAseo: this.form.tipoAseo,
            tipoOper: this.form.tipoOper,
            anio: this.form.anio,
            mes: this.form.mes,
            oficio: this.form.oficio,
            rows: this.sheetRows
          }
        })
      });
      const data = await res.json();
      if (data.success) {
        this.successMessage = data.message;
        this.sheetRows = [{ contrato: '', excedencia: '', diagnostico: '' }];
        this.sheetValid = false;
      } else {
        this.sheetErrors = data.errors || [data.message];
      }
    }
  }
};
</script>

<style scoped>
.adeudos-mult-ins-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 1.5rem;
}
.form-section .row {
  display: flex;
  gap: 1.5rem;
  margin-bottom: 1rem;
}
.col {
  flex: 1;
  min-width: 180px;
}
.sheet-section {
  margin: 1.5rem 0;
}
.sheet-table {
  width: 100%;
  border-collapse: collapse;
}
.sheet-table th, .sheet-table td {
  border: 1px solid #ccc;
  padding: 0.3rem 0.5rem;
}
.actions {
  margin-top: 1.5rem;
}
.error-list {
  color: #b00;
  margin-top: 1rem;
}
.success {
  color: #080;
  margin-left: 1rem;
}
</style>
