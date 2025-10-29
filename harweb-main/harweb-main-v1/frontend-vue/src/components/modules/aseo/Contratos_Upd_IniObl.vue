<template>
  <div class="contratos-upd-iniobl-page">
    <h1>Actualización del Inicio de Obligación</h1>
    <form @submit.prevent="onBuscarContrato">
      <div class="form-row">
        <label>No. Contrato:</label>
        <input v-model="form.num_contrato" type="number" required min="1" />
        <label>Tipo de Aseo:</label>
        <select v-model="form.ctrol_aseo" required>
          <option v-for="ta in catalogs.tiposAseo" :key="ta.ctrol_aseo" :value="ta.ctrol_aseo">
            {{ ta.ctrol_aseo }} - {{ ta.tipo_aseo }} - {{ ta.descripcion }}
          </option>
        </select>
        <button type="submit">Buscar</button>
      </div>
    </form>

    <div v-if="contrato" class="contrato-detalle">
      <h2>Datos del Contrato</h2>
      <table class="detalle-table">
        <tr><th>Empresa</th><td>{{ contrato.empresa_nombre }}</td></tr>
        <tr><th>Representante</th><td>{{ contrato.representante }}</td></tr>
        <tr><th>Tipo Empresa</th><td>{{ contrato.tipo_empresa_desc }}</td></tr>
        <tr><th>Tipo Aseo</th><td>{{ contrato.tipo_aseo_desc }}</td></tr>
        <tr><th>Unidad Recolección</th><td>{{ contrato.cve_recolec }} - {{ contrato.unidad_desc }}</td></tr>
        <tr><th>Cantidad Recolección</th><td>{{ contrato.cantidad_recolec }}</td></tr>
        <tr><th>Domicilio</th><td>{{ contrato.domicilio }}</td></tr>
        <tr><th>Sector</th><td>{{ contrato.sector }}</td></tr>
        <tr><th>Zona</th><td>{{ contrato.zona }}-{{ contrato.sub_zona }} {{ contrato.zona_desc }}</td></tr>
        <tr><th>Recaudadora</th><td>{{ contrato.recaudadora }}</td></tr>
        <tr><th>Inicio Obligación</th><td>{{ contrato.aso_mes_oblig | formatFechaYM }}</td></tr>
        <tr><th>Vigencia</th><td>{{ contrato.status_vigencia }}</td></tr>
      </table>
      <form @submit.prevent="onActualizar">
        <fieldset>
          <legend>Actualizar Inicio de Obligación</legend>
          <div class="form-row">
            <label>Ejercicio:</label>
            <input v-model="form.ejercicio" type="number" min="1989" required />
            <label>Mes:</label>
            <select v-model="form.mes" required>
              <option v-for="m in catalogs.meses" :key="m.value" :value="m.value">{{ m.label }}</option>
            </select>
          </div>
          <div class="form-row">
            <label>Documento:</label>
            <input v-model="form.documento" type="text" required />
            <label>Descripción Documento:</label>
            <input v-model="form.descripcion_docto" type="text" />
          </div>
          <div class="form-row">
            <button type="submit">Actualizar</button>
          </div>
        </fieldset>
      </form>
    </div>
    <div v-if="message" :class="{'success': success, 'error': !success}" class="message">
      {{ message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'ContratosUpdIniOblPage',
  data() {
    return {
      catalogs: {
        tiposAseo: [],
        meses: []
      },
      form: {
        num_contrato: '',
        ctrol_aseo: '',
        ejercicio: '',
        mes: 1,
        documento: '',
        descripcion_docto: ''
      },
      contrato: null,
      message: '',
      success: false,
      usuario_id: 1 // Debe obtenerse del login/session
    };
  },
  filters: {
    formatFechaYM(val) {
      if (!val) return '';
      const d = new Date(val);
      return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0');
    }
  },
  mounted() {
    this.loadCatalogs();
  },
  methods: {
    async loadCatalogs() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'catalogs' } })
      });
      const data = await res.json();
      if (data.eResponse.success) {
        this.catalogs = data.eResponse.data;
        if (this.catalogs.tiposAseo.length > 0) {
          this.form.ctrol_aseo = this.catalogs.tiposAseo[0].ctrol_aseo;
        }
      }
    },
    async onBuscarContrato() {
      this.message = '';
      this.contrato = null;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: {
          action: 'search',
          num_contrato: this.form.num_contrato,
          ctrol_aseo: this.form.ctrol_aseo
        }})
      });
      const data = await res.json();
      if (data.eResponse.success) {
        this.contrato = data.eResponse.data;
        this.form.ejercicio = new Date(this.contrato.aso_mes_oblig).getFullYear();
        this.form.mes = new Date(this.contrato.aso_mes_oblig).getMonth() + 1;
        this.success = true;
        this.message = 'Contrato encontrado';
      } else {
        this.success = false;
        this.message = data.eResponse.message;
      }
    },
    async onActualizar() {
      this.message = '';
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: {
          action: 'update',
          num_contrato: this.form.num_contrato,
          ctrol_aseo: this.form.ctrol_aseo,
          ejercicio: this.form.ejercicio,
          mes: this.form.mes,
          documento: this.form.documento,
          descripcion_docto: this.form.descripcion_docto,
          usuario_id: this.usuario_id
        }})
      });
      const data = await res.json();
      if (data.eResponse.success) {
        this.success = true;
        this.message = data.eResponse.message;
        this.onBuscarContrato();
      } else {
        this.success = false;
        this.message = data.eResponse.message;
      }
    }
  }
}
</script>

<style scoped>
.contratos-upd-iniobl-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}
.detalle-table {
  width: 100%;
  margin-bottom: 1rem;
  border-collapse: collapse;
}
.detalle-table th, .detalle-table td {
  border: 1px solid #ccc;
  padding: 0.3rem 0.5rem;
}
.message {
  margin-top: 1rem;
  padding: 0.5rem 1rem;
  border-radius: 4px;
}
.success {
  background: #e0ffe0;
  color: #1a6d1a;
}
.error {
  background: #ffe0e0;
  color: #a00;
}
</style>
