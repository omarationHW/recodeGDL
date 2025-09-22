<template>
  <div class="adeudos-exe-del-page">
    <h1>Baja de Adeudos</h1>
    <form @submit.prevent="onSubmit">
      <div class="form-row">
        <label>Contrato:</label>
        <input v-model="form.contrato" type="number" maxlength="10" required />
      </div>
      <div class="form-row">
        <label>Tipo de Aseo:</label>
        <select v-model="form.ctrol_aseo" required>
          <option v-for="t in tiposAseo" :key="t.ctrol_aseo" :value="t.ctrol_aseo">
            {{ t.ctrol_aseo.toString().padStart(3, '0') }} - {{ t.tipo_aseo }} - {{ t.descripcion }}
          </option>
        </select>
      </div>
      <div class="form-row">
        <label>Año:</label>
        <input v-model="form.aso" type="number" maxlength="4" required />
        <label>Mes:</label>
        <select v-model="form.mes" required>
          <option v-for="m in meses" :key="m" :value="m">{{ m.toString().padStart(2, '0') }}</option>
        </select>
      </div>
      <div class="form-row">
        <label>Tipo de Movimiento:</label>
        <select v-model="form.ctrol_operacion" required>
          <option v-for="op in tiposOperacion" :key="op.ctrol_operacion" :value="op.ctrol_operacion">
            {{ op.ctrol_operacion.toString().padStart(3, '0') }} - {{ op.cve_operacion }} - {{ op.descripcion }}
          </option>
        </select>
      </div>
      <div class="form-row">
        <label>Oficio:</label>
        <input v-model="form.oficio" maxlength="10" />
      </div>
      <div class="form-row">
        <label>Opción de Movimiento:</label>
        <input type="radio" id="fisica" value="delete" v-model="form.action" />
        <label for="fisica">Baja Física</label>
        <input type="radio" id="logica" value="logic_delete" v-model="form.action" />
        <label for="logica">Baja Lógica</label>
      </div>
      <div class="form-row">
        <button type="submit">Ejecutar</button>
        <button type="button" @click="resetForm">Cancelar</button>
      </div>
    </form>
    <div v-if="result" class="result">
      <h3>Resultado</h3>
      <pre>{{ result }}</pre>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdeudosExeDelPage',
  data() {
    return {
      tiposAseo: [],
      tiposOperacion: [],
      meses: [1,2,3,4,5,6,7,8,9,10,11,12],
      form: {
        contrato: '',
        ctrol_aseo: '',
        aso: '',
        mes: 1,
        ctrol_operacion: '',
        oficio: '',
        action: 'delete', // default: baja física
        usuario_id: 1 // Simulación, debe venir del login
      },
      result: null
    }
  },
  mounted() {
    this.loadTiposAseo();
    this.loadTiposOperacion();
  },
  methods: {
    async loadTiposAseo() {
      // Simulación: Debe ser un endpoint real
      this.tiposAseo = await fetch('/api/catalog/tipos-aseo').then(r => r.json());
    },
    async loadTiposOperacion() {
      // Simulación: Debe ser un endpoint real
      this.tiposOperacion = await fetch('/api/catalog/tipos-operacion').then(r => r.json());
    },
    async onSubmit() {
      // Validación básica
      if (!this.form.contrato || !this.form.ctrol_aseo || !this.form.aso || !this.form.mes || !this.form.ctrol_operacion) {
        alert('Todos los campos son obligatorios');
        return;
      }
      // Enviar petición
      const payload = {
        eRequest: {
          action: this.form.action,
          contrato: parseInt(this.form.contrato),
          ctrol_aseo: parseInt(this.form.ctrol_aseo),
          aso: parseInt(this.form.aso),
          mes: parseInt(this.form.mes),
          ctrol_operacion: parseInt(this.form.ctrol_operacion),
          oficio: this.form.oficio,
          usuario_id: this.form.usuario_id
        }
      };
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      this.result = await res.json();
    },
    resetForm() {
      this.form = {
        contrato: '',
        ctrol_aseo: '',
        aso: '',
        mes: 1,
        ctrol_operacion: '',
        oficio: '',
        action: 'delete',
        usuario_id: 1
      };
      this.result = null;
    }
  }
}
</script>

<style scoped>
.adeudos-exe-del-page {
  max-width: 600px;
  margin: 0 auto;
  background: #f9f9f9;
  padding: 2rem;
  border-radius: 8px;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
}
.form-row label {
  min-width: 120px;
  margin-right: 1rem;
}
.form-row input, .form-row select {
  flex: 1;
}
.result {
  background: #eef;
  padding: 1rem;
  margin-top: 2rem;
  border-radius: 4px;
}
</style>
