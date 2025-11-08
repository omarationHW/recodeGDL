<template>
  <div class="contratos-upd-und-page">
    <h1>Actualización de Unidades de Recolección (Unidades)</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / <span>Contratos</span> / <span>Actualizar Unidades</span>
    </div>
    <form @submit.prevent="buscarContrato">
      <div class="form-row">
        <label>No. Contrato:</label>
        <input v-model="form.num_contrato" maxlength="10" required />
        <label>Tipo de Aseo:</label>
        <select v-model="form.ctrol_aseo" required>
          <option v-for="tipo in tiposAseo" :key="tipo.ctrol_aseo" :value="tipo.ctrol_aseo">
            {{ tipo.ctrol_aseo }} - {{ tipo.tipo_aseo }} - {{ tipo.descripcion }}
          </option>
        </select>
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="contrato">
      <h2>Datos del Contrato</h2>
      <div class="contrato-info">
        <div><strong>Contrato:</strong> {{ contrato.num_contrato }}</div>
        <div><strong>Empresa:</strong> {{ contrato.descripcion_1 }}</div>
        <div><strong>Representante:</strong> {{ contrato.representante }}</div>
        <div><strong>Domicilio:</strong> {{ contrato.domicilio }}</div>
        <div><strong>Zona:</strong> {{ contrato.zona }} - {{ contrato.sub_zona }} - {{ contrato.descripcion_4 }}</div>
        <div><strong>Tipo de Aseo:</strong> {{ contrato.tipo_aseo }} - {{ contrato.descripcion_2 }}</div>
        <div><strong>Unidad Actual:</strong> {{ contrato.ctrol_recolec }} - {{ contrato.cve_recolec }} - {{ contrato.descripcion_3 }}</div>
        <div><strong>Cantidad Actual:</strong> {{ contrato.cantidad_recolec }}</div>
        <div><strong>Inicio Obligación:</strong> {{ contrato.aso_mes_oblig }}</div>
        <div><strong>Vigencia:</strong> {{ contrato.status_vigencia }}</div>
      </div>
      <form @submit.prevent="actualizarUnidades">
        <h3>Actualizar Unidades</h3>
        <div class="form-row">
          <label>Unidad de Recolección:</label>
          <select v-model="updForm.ctrol_recolec" required>
            <option v-for="unidad in unidades" :key="unidad.ctrol_recolec" :value="unidad.ctrol_recolec">
              {{ unidad.ctrol_recolec }} - {{ unidad.cve_recolec }} - {{ unidad.descripcion }} - ${{ unidad.costo_unidad }}
            </option>
          </select>
        </div>
        <div class="form-row">
          <label>Cantidad:</label>
          <input v-model.number="updForm.cantidad" type="number" min="1" max="9999" required />
        </div>
        <div class="form-row">
          <label>Ejercicio:</label>
          <input v-model="updForm.ejercicio" type="number" min="1989" max="2099" required />
          <label>Mes:</label>
          <select v-model="updForm.mes" required>
            <option v-for="m in 12" :key="m" :value="m">{{ m.toString().padStart(2, '0') }}</option>
          </select>
        </div>
        <div class="form-row">
          <label>Documento:</label>
          <input v-model="updForm.documento" maxlength="15" required />
        </div>
        <div class="form-row">
          <label>Descripción:</label>
          <textarea v-model="updForm.descripcion" maxlength="100" required></textarea>
        </div>
        <div class="form-row">
          <button type="submit">Actualizar</button>
        </div>
      </form>
    </div>
    <div v-if="message" :class="{'success': success, 'error': !success}">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'ContratosUpdUndPage',
  data() {
    return {
      form: {
        num_contrato: '',
        ctrol_aseo: ''
      },
      updForm: {
        ctrol_recolec: '',
        cantidad: '',
        ejercicio: new Date().getFullYear(),
        mes: (new Date().getMonth() + 1),
        documento: '',
        descripcion: ''
      },
      tiposAseo: [],
      unidades: [],
      contrato: null,
      message: '',
      success: false
    };
  },
  created() {
    this.loadTiposAseo();
  },
  methods: {
    async loadTiposAseo() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'catalogo_tipo_aseo' })
      });
      const data = await res.json();
      if (data.success) {
        this.tiposAseo = data.tipos;
      }
    },
    async buscarContrato() {
      this.message = '';
      this.success = false;
      this.contrato = null;
      this.unidades = [];
      if (!this.form.num_contrato || !this.form.ctrol_aseo) {
        this.message = 'Debe ingresar número de contrato y tipo de aseo';
        return;
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'buscar_contrato',
          params: {
            num_contrato: this.form.num_contrato,
            ctrol_aseo: this.form.ctrol_aseo,
            ejercicio: this.updForm.ejercicio
          }
        })
      });
      const data = await res.json();
      if (data.success) {
        this.contrato = data.contrato;
        this.unidades = data.unidades;
        this.updForm.ctrol_recolec = this.contrato.ctrol_recolec;
        this.updForm.cantidad = this.contrato.cantidad_recolec;
      } else {
        this.message = data.message;
      }
    },
    async actualizarUnidades() {
      this.message = '';
      this.success = false;
      if (!this.updForm.ctrol_recolec || !this.updForm.cantidad || !this.updForm.ejercicio || !this.updForm.mes || !this.updForm.documento) {
        this.message = 'Todos los campos son obligatorios';
        return;
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'actualizar_unidades',
          params: {
            control_contrato: this.contrato.control_contrato,
            ctrol_recolec: this.updForm.ctrol_recolec,
            cantidad: this.updForm.cantidad,
            ejercicio: this.updForm.ejercicio,
            mes: this.updForm.mes,
            documento: this.updForm.documento,
            descripcion: this.updForm.descripcion
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
.contratos-upd-und-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  font-size: 0.95em;
}
.form-row {
  display: flex;
  align-items: center;
  margin-bottom: 1rem;
}
.form-row label {
  min-width: 120px;
  margin-right: 0.5rem;
}
.form-row input, .form-row select, .form-row textarea {
  margin-right: 1rem;
  flex: 1;
}
.success {
  color: green;
  margin-top: 1rem;
}
.error {
  color: red;
  margin-top: 1rem;
}
.contrato-info {
  background: #f8f8f8;
  padding: 1rem;
  margin-bottom: 1.5rem;
  border-radius: 4px;
}
</style>
