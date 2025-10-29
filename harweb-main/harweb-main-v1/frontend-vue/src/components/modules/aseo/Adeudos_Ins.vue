<template>
  <div class="adeudos-ins-page">
    <h1>Captura de Excedencias y/o Contenedores</h1>
    <form @submit.prevent="onSubmit">
      <div class="form-row">
        <label>No. Contrato</label>
        <input v-model="form.contrato" type="number" maxlength="10" required />
        <label>Tipo de Aseo</label>
        <select v-model="form.ctrol_aseo" required>
          <option v-for="ta in catalogs.tipo_aseo" :key="ta.ctrol_aseo" :value="ta.ctrol_aseo">
            {{ ta.ctrol_aseo.toString().padStart(3, '0') }} - {{ ta.tipo_aseo }} - {{ ta.descripcion }}
          </option>
        </select>
      </div>
      <div class="form-row">
        <label>Año</label>
        <input v-model="form.aso" type="number" maxlength="4" required />
        <label>Mes</label>
        <select v-model="form.mes" required>
          <option v-for="m in catalogs.meses" :key="m.value" :value="m.value">{{ m.value }}</option>
        </select>
      </div>
      <div class="form-row">
        <label>Tipo de Movimiento</label>
        <select v-model="form.ctrol_operacion" required>
          <option v-for="op in catalogs.tipo_operacion" :key="op.ctrol_operacion" :value="op.ctrol_operacion">
            {{ op.ctrol_operacion.toString().padStart(3, '0') }} - {{ op.cve_operacion }} - {{ op.descripcion }}
          </option>
        </select>
      </div>
      <div class="form-row">
        <label>Cantidad de Excedencias</label>
        <input v-model="form.exedencias" type="number" min="1" maxlength="4" required />
      </div>
      <div class="form-row">
        <label>Oficio (opcional)</label>
        <input v-model="form.oficio" type="text" maxlength="15" />
      </div>
      <div class="form-actions">
        <button type="submit" :disabled="loading">Ejecutar</button>
        <button type="button" @click="onReset">Cancelar</button>
      </div>
      <div v-if="message" :class="{'success': success, 'error': !success}" class="form-message">
        {{ message }}
      </div>
    </form>
  </div>
</template>

<script>
export default {
  name: 'AdeudosInsPage',
  data() {
    return {
      catalogs: {
        tipo_aseo: [],
        tipo_operacion: [],
        meses: []
      },
      form: {
        contrato: '',
        ctrol_aseo: '',
        aso: '',
        mes: '',
        ctrol_operacion: '',
        exedencias: '',
        oficio: ''
      },
      loading: false,
      message: '',
      success: false
    }
  },
  created() {
    this.loadCatalogs();
  },
  methods: {
    async loadCatalogs() {
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'adeudos_ins_get_catalogs' })
        });
        const data = await res.json();
        if (data.success) {
          this.catalogs = data.data;
          if (this.catalogs.tipo_aseo.length > 0) this.form.ctrol_aseo = this.catalogs.tipo_aseo[0].ctrol_aseo;
          if (this.catalogs.tipo_operacion.length > 0) this.form.ctrol_operacion = this.catalogs.tipo_operacion[0].ctrol_operacion;
          if (this.catalogs.meses.length > 0) this.form.mes = this.catalogs.meses[0].value;
        }
      } finally {
        this.loading = false;
      }
    },
    async onSubmit() {
      this.loading = true;
      this.message = '';
      this.success = false;
      try {
        // Validación básica
        if (!this.form.contrato || !this.form.ctrol_aseo || !this.form.aso || !this.form.mes || !this.form.ctrol_operacion || !this.form.exedencias) {
          this.message = 'Todos los campos obligatorios deben estar completos';
          return;
        }
        // Validar contrato
        const validRes = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'adeudos_ins_validate_contrato',
            params: {
              contrato: this.form.contrato,
              ctrol_aseo: this.form.ctrol_aseo,
              ejercicio: this.form.aso
            }
          })
        });
        const validData = await validRes.json();
        if (!validData.success) {
          this.message = validData.message || 'Contrato no válido';
          return;
        }
        // Insertar
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'adeudos_ins_insert',
            params: { ...this.form }
          })
        });
        const data = await res.json();
        this.message = data.message;
        this.success = data.success;
        if (data.success) {
          this.onReset();
        }
      } catch (e) {
        this.message = e.message || 'Error inesperado';
      } finally {
        this.loading = false;
      }
    },
    onReset() {
      this.form = {
        contrato: '',
        ctrol_aseo: this.catalogs.tipo_aseo.length > 0 ? this.catalogs.tipo_aseo[0].ctrol_aseo : '',
        aso: '',
        mes: this.catalogs.meses.length > 0 ? this.catalogs.meses[0].value : '',
        ctrol_operacion: this.catalogs.tipo_operacion.length > 0 ? this.catalogs.tipo_operacion[0].ctrol_operacion : '',
        exedencias: '',
        oficio: ''
      };
      this.message = '';
      this.success = false;
    }
  }
}
</script>

<style scoped>
.adeudos-ins-page {
  max-width: 600px;
  margin: 0 auto;
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px #0001;
}
.form-row {
  display: flex;
  align-items: center;
  margin-bottom: 1rem;
}
.form-row label {
  width: 160px;
  font-weight: bold;
}
.form-row input, .form-row select {
  flex: 1;
  margin-left: 1rem;
  padding: 0.4rem;
}
.form-actions {
  display: flex;
  gap: 1rem;
  margin-top: 1.5rem;
}
.form-message {
  margin-top: 1rem;
  padding: 0.7rem;
  border-radius: 4px;
}
.success {
  background: #e6ffed;
  color: #1a7f37;
  border: 1px solid #b7ebc6;
}
.error {
  background: #ffeaea;
  color: #a94442;
  border: 1px solid #f5c6cb;
}
</style>
