<template>
  <div class="adeudos-cn-cond-page">
    <h1>Condonación de Adeudos</h1>
    <form @submit.prevent="onSubmit">
      <div class="form-group">
        <label for="contrato">Contrato</label>
        <input v-model="form.num_contrato" id="contrato" maxlength="10" required type="text" @keypress="onlyNumber($event, 10)" />
      </div>
      <div class="form-group">
        <label for="tipoAseo">Tipo de Aseo</label>
        <select v-model="form.ctrol_aseo" id="tipoAseo" required>
          <option v-for="t in catalogs.tipoAseo" :key="t.ctrol_aseo" :value="t.ctrol_aseo">
            {{ t.ctrol_aseo.toString().padStart(3, '0') }} - {{ t.tipo_aseo }} - {{ t.descripcion }}
          </option>
        </select>
      </div>
      <div class="form-group">
        <label for="aso">Año</label>
        <input v-model="form.aso" id="aso" maxlength="4" required type="text" @keypress="onlyNumber($event, 4)" />
      </div>
      <div class="form-group">
        <label for="mes">Mes</label>
        <select v-model="form.mes" id="mes" required>
          <option v-for="m in meses" :key="m" :value="m">{{ m.toString().padStart(2, '0') }}</option>
        </select>
      </div>
      <div class="form-group">
        <label for="tipoOperacion">Tipo de Movimiento</label>
        <select v-model="form.ctrol_operacion" id="tipoOperacion" required>
          <option v-for="t in catalogs.tipoOperacion" :key="t.ctrol_operacion" :value="t.ctrol_operacion">
            {{ t.ctrol_operacion.toString().padStart(3, '0') }} - {{ t.cve_operacion }} - {{ t.descripcion }}
          </option>
        </select>
      </div>
      <div class="form-group">
        <label for="oficio">Oficio</label>
        <input v-model="form.oficio" id="oficio" maxlength="10" required type="text" />
      </div>
      <div class="form-actions">
        <button type="submit" :disabled="loading">Ejecutar</button>
        <button type="button" @click="resetForm">Cancelar</button>
      </div>
      <div v-if="message" :class="{'success': success, 'error': !success}" class="message">{{ message }}</div>
    </form>
  </div>
</template>

<script>
export default {
  name: 'AdeudosCNCondPage',
  data() {
    return {
      catalogs: {
        tipoAseo: [],
        tipoOperacion: []
      },
      meses: [1,2,3,4,5,6,7,8,9,10,11,12],
      form: {
        num_contrato: '',
        ctrol_aseo: '',
        aso: '',
        mes: 1,
        ctrol_operacion: '',
        oficio: ''
      },
      loading: false,
      message: '',
      success: false
    }
  },
  created() {
    this.fetchCatalogs();
  },
  methods: {
    async fetchCatalogs() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getCatalogs' })
      });
      const data = await res.json();
      this.catalogs.tipoAseo = data.tipoAseo;
      this.catalogs.tipoOperacion = data.tipoOperacion;
      if (this.catalogs.tipoAseo.length > 0) this.form.ctrol_aseo = this.catalogs.tipoAseo[0].ctrol_aseo;
      if (this.catalogs.tipoOperacion.length > 0) this.form.ctrol_operacion = this.catalogs.tipoOperacion[0].ctrol_operacion;
    },
    onlyNumber(e, maxlen) {
      const k = e.key;
      if (!/\d/.test(k) || e.target.value.length >= maxlen) e.preventDefault();
    },
    async onSubmit() {
      this.loading = true;
      this.message = '';
      this.success = false;
      // Validación básica
      if (!this.form.num_contrato || !this.form.ctrol_aseo || !this.form.aso || !this.form.mes || !this.form.ctrol_operacion || !this.form.oficio) {
        this.message = 'Todos los campos son obligatorios.';
        this.loading = false;
        return;
      }
      // Paso 1: obtener info del contrato
      const contratoRes = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'getContratoInfo',
          params: {
            num_contrato: this.form.num_contrato,
            ctrol_aseo: this.form.ctrol_aseo
          }
        })
      });
      const contrato = await contratoRes.json();
      if (!contrato || !contrato.control_contrato) {
        this.message = 'No existe el contrato.';
        this.loading = false;
        return;
      }
      // Paso 2: verificar exedencia vigente
      const aso_mes_pago = `${this.form.aso}-${this.form.mes.toString().padStart(2, '0')}`;
      const exedenciaRes = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'checkExedenciaVigente',
          params: {
            control_contrato: contrato.control_contrato,
            aso_mes_pago,
            ctrol_operacion: this.form.ctrol_operacion
          }
        })
      });
      const exedencia = await exedenciaRes.json();
      if (!exedencia.exists) {
        this.message = 'No existe EXEDENCIA vigente para condonar.';
        this.loading = false;
        return;
      }
      // Paso 3: ejecutar condonación
      const condonaRes = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'condonarAdeudo',
          params: {
            num_contrato: this.form.num_contrato,
            ctrol_aseo: this.form.ctrol_aseo,
            aso_mes_pago,
            ctrol_operacion: this.form.ctrol_operacion,
            oficio: this.form.oficio
          }
        })
      });
      const condona = await condonaRes.json();
      this.message = condona.message;
      this.success = condona.success;
      this.loading = false;
      if (condona.success) this.resetForm();
    },
    resetForm() {
      this.form.num_contrato = '';
      this.form.aso = '';
      this.form.mes = 1;
      this.form.oficio = '';
      // Mantener tipoAseo y tipoOperacion seleccionados
    }
  }
}
</script>

<style scoped>
.adeudos-cn-cond-page {
  max-width: 500px;
  margin: 0 auto;
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px #0001;
}
.form-group {
  margin-bottom: 1rem;
}
.form-actions {
  display: flex;
  gap: 1rem;
}
.message {
  margin-top: 1rem;
  padding: 0.5rem 1rem;
  border-radius: 4px;
}
.success {
  background: #e0ffe0;
  color: #0a0;
}
.error {
  background: #ffe0e0;
  color: #a00;
}
</style>
