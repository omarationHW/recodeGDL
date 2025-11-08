<template>
  <div class="contratos-upd-undc-page">
    <h1>Actualización de Unidades de Recolección (Cantidad)</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / <span>Actualizar Unidades Contrato</span>
    </div>
    <form @submit.prevent="buscarContrato">
      <div class="form-row">
        <label for="contrato">No. Contrato</label>
        <input v-model="form.contrato" id="contrato" maxlength="10" required />
        <label for="ctrol_aseo">Tipo de Aseo</label>
        <select v-model="form.ctrol_aseo" id="ctrol_aseo" required>
          <option v-for="tipo in tiposAseo" :key="tipo.ctrol_aseo" :value="tipo.ctrol_aseo">
            {{ tipo.ctrol_aseo }} - {{ tipo.tipo_aseo }} - {{ tipo.descripcion }}
          </option>
        </select>
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="contrato" class="contrato-info">
      <h2>Datos del Contrato</h2>
      <table>
        <tr><th>Contrato</th><td>{{ contrato.num_contrato }}</td></tr>
        <tr><th>Empresa</th><td>{{ contrato.descripcion_1 }}</td></tr>
        <tr><th>Representante</th><td>{{ contrato.representante }}</td></tr>
        <tr><th>Tipo Aseo</th><td>{{ contrato.tipo_aseo }} - {{ contrato.descripcion_2 }}</td></tr>
        <tr><th>Unidades actuales</th><td>{{ contrato.cantidad_recolec }}</td></tr>
        <tr><th>Domicilio</th><td>{{ contrato.domicilio }}</td></tr>
        <tr><th>Zona</th><td>{{ contrato.zona }} / {{ contrato.sub_zona }} - {{ contrato.descripcion_4 }}</td></tr>
        <tr><th>Recaudadora</th><td>{{ contrato.recaudadora }}</td></tr>
        <tr><th>Inicio Obligación</th><td>{{ contrato.aso_mes_oblig }}</td></tr>
        <tr><th>Vigencia</th><td>{{ contrato.status_vigencia }}</td></tr>
      </table>
      <form @submit.prevent="actualizarUnidades">
        <div class="form-row">
          <label for="nueva_cantidad">Nueva Cantidad</label>
          <input v-model.number="form.nueva_cantidad" id="nueva_cantidad" type="number" min="1" required />
          <label for="ejercicio">Ejercicio</label>
          <input v-model.number="form.ejercicio" id="ejercicio" type="number" min="1989" required />
          <label for="mes">Mes</label>
          <select v-model="form.mes" id="mes" required>
            <option v-for="m in 12" :key="m" :value="m">{{ m.toString().padStart(2, '0') }}</option>
          </select>
        </div>
        <div class="form-row">
          <label for="documento">Documento</label>
          <input v-model="form.documento" id="documento" maxlength="15" required />
          <label for="descripcion_docto">Descripción del Documento</label>
          <textarea v-model="form.descripcion_docto" id="descripcion_docto" maxlength="100" required></textarea>
        </div>
        <button type="submit">Actualizar Unidades</button>
      </form>
    </div>
    <div v-if="message" :class="{'success': success, 'error': !success}">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'ContratosUpdUndCPage',
  data() {
    return {
      tiposAseo: [],
      form: {
        contrato: '',
        ctrol_aseo: '',
        nueva_cantidad: '',
        ejercicio: new Date().getFullYear(),
        mes: (new Date().getMonth() + 1),
        documento: '',
        descripcion_docto: ''
      },
      contrato: null,
      message: '',
      success: false
    };
  },
  created() {
    this.cargarTiposAseo();
  },
  methods: {
    async cargarTiposAseo() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'listarTiposAseo' })
      });
      const data = await res.json();
      if (data.success) {
        this.tiposAseo = data.data;
        if (this.tiposAseo.length > 0) {
          this.form.ctrol_aseo = this.tiposAseo[0].ctrol_aseo;
        }
      }
    },
    async buscarContrato() {
      this.message = '';
      this.success = false;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'buscarContrato',
          params: {
            contrato: this.form.contrato,
            ctrol_aseo: this.form.ctrol_aseo
          }
        })
      });
      const data = await res.json();
      if (data.success) {
        this.contrato = data.data;
        this.form.nueva_cantidad = this.contrato.cantidad_recolec;
        this.form.ejercicio = new Date().getFullYear();
        this.form.mes = new Date().getMonth() + 1;
      } else {
        this.contrato = null;
        this.message = data.message;
        this.success = false;
      }
    },
    async actualizarUnidades() {
      this.message = '';
      this.success = false;
      if (!this.contrato) {
        this.message = 'Debe buscar un contrato primero.';
        return;
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'actualizarUnidades',
          params: {
            contrato_id: this.contrato.control_contrato,
            nueva_cantidad: this.form.nueva_cantidad,
            ejercicio: this.form.ejercicio,
            mes: this.form.mes,
            documento: this.form.documento,
            descripcion_docto: this.form.descripcion_docto
          }
        })
      });
      const data = await res.json();
      this.message = data.message;
      this.success = data.success;
      if (data.success) {
        this.buscarContrato();
      }
    }
  }
};
</script>

<style scoped>
.contratos-upd-undc-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.form-row {
  display: flex;
  gap: 1rem;
  margin-bottom: 1rem;
  align-items: center;
}
table {
  margin-bottom: 1rem;
  border-collapse: collapse;
}
td, th {
  border: 1px solid #ccc;
  padding: 0.25rem 0.5rem;
}
.success {
  color: green;
}
.error {
  color: red;
}
</style>
