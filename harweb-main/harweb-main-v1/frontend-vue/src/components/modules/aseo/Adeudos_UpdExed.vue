<template>
  <div class="adeudos-upd-exed-page">
    <h1>Modificación de Excedencias (Cantidad)</h1>
    <div v-if="!showUpdate">
      <form @submit.prevent="onSearch">
        <div class="form-row">
          <label>Contrato:</label>
          <input v-model="form.contrato" maxlength="10" required pattern="\\d+" />
          <label>Tipo de Aseo:</label>
          <select v-model="form.ctrol_aseo" required>
            <option v-for="t in catalogs.tiposAseo" :key="t.ctrol_aseo" :value="t.ctrol_aseo">
              {{ t.ctrol_aseo }} - {{ t.tipo_aseo }} - {{ t.descripcion }}
            </option>
          </select>
        </div>
        <div class="form-row">
          <label>Año:</label>
          <input v-model="form.ejercicio" maxlength="4" required pattern="\\d{4}" />
          <label>Mes:</label>
          <select v-model="form.mes" required>
            <option v-for="m in catalogs.meses" :key="m" :value="parseInt(m)">{{ m }}</option>
          </select>
        </div>
        <div class="form-row">
          <label>Tipo de Movimiento:</label>
          <select v-model="form.ctrol_operacion" required>
            <option v-for="t in catalogs.tiposOperacion" :key="t.ctrol_operacion" :value="t.ctrol_operacion">
              {{ t.ctrol_operacion }} - {{ t.cve_operacion }} - {{ t.descripcion }}
            </option>
          </select>
        </div>
        <div class="form-actions">
          <button type="submit">Buscar</button>
          <button type="button" @click="onReset">Limpiar</button>
        </div>
      </form>
      <div v-if="error" class="error">{{ error }}</div>
    </div>
    <div v-else>
      <div class="excedencia-info">
        <h2>Excedencia encontrada</h2>
        <p><b>Contrato:</b> {{ result.contrato.num_contrato }}</p>
        <p><b>Tipo de Aseo:</b> {{ result.contrato.ctrol_aseo }}</p>
        <p><b>Periodo:</b> {{ form.ejercicio }}-{{ form.mes.toString().padStart(2, '0') }}</p>
        <p><b>Tipo de Movimiento:</b> {{ form.ctrol_operacion }}</p>
        <p><b>Cantidad actual:</b> {{ result.excedencia.exedencias }}</p>
      </div>
      <form @submit.prevent="onUpdate">
        <div class="form-row">
          <label>Nueva Cantidad:</label>
          <input v-model="form.cantidad" maxlength="4" required pattern="\\d+" />
        </div>
        <div class="form-row">
          <label>Oficio:</label>
          <input v-model="form.oficio" maxlength="15" />
        </div>
        <div class="form-actions">
          <button type="submit">Actualizar</button>
          <button type="button" @click="onReset">Cancelar</button>
        </div>
      </form>
      <div v-if="success" class="success">{{ success }}</div>
      <div v-if="error" class="error">{{ error }}</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdeudosUpdExedPage',
  data() {
    return {
      catalogs: {
        tiposAseo: [],
        tiposOperacion: [],
        meses: []
      },
      form: {
        contrato: '',
        ctrol_aseo: '',
        ejercicio: '',
        mes: '',
        ctrol_operacion: '',
        cantidad: '',
        oficio: ''
      },
      result: null,
      showUpdate: false,
      error: '',
      success: ''
    };
  },
  created() {
    this.loadCatalogs();
  },
  methods: {
    async loadCatalogs() {
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'catalogs' } })
      });
      const data = await resp.json();
      if (data.eResponse.success) {
        this.catalogs = data.eResponse.data;
        // Defaults
        if (this.catalogs.tiposAseo.length) this.form.ctrol_aseo = this.catalogs.tiposAseo[0].ctrol_aseo;
        if (this.catalogs.tiposOperacion.length) this.form.ctrol_operacion = this.catalogs.tiposOperacion[0].ctrol_operacion;
        if (this.catalogs.meses.length) this.form.mes = parseInt(this.catalogs.meses[0]);
        this.form.ejercicio = new Date().getFullYear().toString();
      }
    },
    async onSearch() {
      this.error = '';
      this.success = '';
      this.showUpdate = false;
      this.result = null;
      const payload = {
        action: 'search',
        contrato: this.form.contrato,
        ctrol_aseo: this.form.ctrol_aseo,
        ejercicio: this.form.ejercicio,
        mes: this.form.mes,
        ctrol_operacion: this.form.ctrol_operacion
      };
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: payload })
      });
      const data = await resp.json();
      if (data.eResponse.success) {
        this.result = data.eResponse.data;
        this.form.cantidad = this.result.excedencia.exedencias;
        this.showUpdate = true;
      } else {
        this.error = data.eResponse.message;
      }
    },
    async onUpdate() {
      this.error = '';
      this.success = '';
      const payload = {
        action: 'update',
        contrato: this.form.contrato,
        ctrol_aseo: this.form.ctrol_aseo,
        ejercicio: this.form.ejercicio,
        mes: this.form.mes,
        ctrol_operacion: this.form.ctrol_operacion,
        cantidad: this.form.cantidad,
        oficio: this.form.oficio,
        usuario: 1 // TODO: obtener de sesión
      };
      const resp = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: payload })
      });
      const data = await resp.json();
      if (data.eResponse.success) {
        this.success = data.eResponse.message;
        this.showUpdate = false;
        this.result = null;
      } else {
        this.error = data.eResponse.message;
      }
    },
    onReset() {
      this.form = {
        contrato: '',
        ctrol_aseo: this.catalogs.tiposAseo.length ? this.catalogs.tiposAseo[0].ctrol_aseo : '',
        ejercicio: new Date().getFullYear().toString(),
        mes: this.catalogs.meses.length ? parseInt(this.catalogs.meses[0]) : '',
        ctrol_operacion: this.catalogs.tiposOperacion.length ? this.catalogs.tiposOperacion[0].ctrol_operacion : '',
        cantidad: '',
        oficio: ''
      };
      this.result = null;
      this.showUpdate = false;
      this.error = '';
      this.success = '';
    }
  }
};
</script>

<style scoped>
.adeudos-upd-exed-page {
  max-width: 600px;
  margin: 0 auto;
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px #ccc;
}
.form-row {
  display: flex;
  align-items: center;
  margin-bottom: 1rem;
}
.form-row label {
  width: 120px;
  font-weight: bold;
}
.form-row input, .form-row select {
  flex: 1;
  margin-right: 1rem;
}
.form-actions {
  margin-top: 1rem;
  display: flex;
  gap: 1rem;
}
.error {
  color: #b00;
  margin-top: 1rem;
}
.success {
  color: #080;
  margin-top: 1rem;
}
.excedencia-info {
  background: #f8f8f8;
  padding: 1rem;
  border-radius: 6px;
  margin-bottom: 1rem;
}
</style>
